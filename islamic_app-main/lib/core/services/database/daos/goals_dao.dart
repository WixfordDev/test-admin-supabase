import 'package:drift/drift.dart';
import 'package:deenhub/core/services/database/app_database.dart';
import 'package:deenhub/core/services/database/tables/goal_tables.dart';

part 'goals_dao.g.dart';

// Custom result classes
class DailyGoalWithPreset {
  final DailyGoal goal;
  final GoalPreset? preset;

  DailyGoalWithPreset({required this.goal, this.preset});
}

@DriftAccessor(tables: [
  GoalPresets,
  DailyGoals,
  GoalProgress,
  GoalHistory,
  GoalNotifications,
  GoalStatistics,
])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.db);

  // === Goal Presets Management ===
  
  // Get all active goal presets
  Future<List<GoalPreset>> getAllActivePresets() {
    return (select(goalPresets)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.isRecommended), (t) => OrderingTerm.asc(t.title)]))
        .get();
  }

  // Get recommended presets
  Future<List<GoalPreset>> getRecommendedPresets() {
    return (select(goalPresets)
          ..where((t) => t.isRecommended.equals(true) & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.title)]))
        .get();
  }

  // Add or update goal preset
  Future<int> upsertGoalPreset(GoalPresetsCompanion preset) {
    return into(goalPresets).insertOnConflictUpdate(preset);
  }

  // Delete goal preset
  Future<int> deleteGoalPreset(int presetId) {
    return (delete(goalPresets)..where((t) => t.id.equals(presetId))).go();
  }

  // === Daily Goals Management ===
  
  // Get daily goals for a specific date
  Future<List<DailyGoal>> getDailyGoalsForDate(DateTime date) {
    return (select(dailyGoals)
          ..where((t) => t.date.day.equals(date.day) & 
                        t.date.month.equals(date.month) & 
                        t.date.year.equals(date.year) &
                        t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  // Get daily goals with their presets for a date
  Stream<List<DailyGoalWithPreset>> watchDailyGoalsForDate(DateTime date) {
    final query = select(dailyGoals).join([
      leftOuterJoin(goalPresets, goalPresets.id.equalsExp(dailyGoals.presetId)),
    ]);
    
    query.where(dailyGoals.date.day.equals(date.day) & 
                dailyGoals.date.month.equals(date.month) & 
                dailyGoals.date.year.equals(date.year) &
                dailyGoals.isActive.equals(true));
    
    query.orderBy([OrderingTerm.asc(dailyGoals.createdAt)]);
    
    return query.watch().map((rows) {
      return rows.map((row) {
        final goal = row.readTable(dailyGoals);
        final preset = row.readTableOrNull(goalPresets);
        return DailyGoalWithPreset(goal: goal, preset: preset);
      }).toList();
    });
  }

  // Create daily goal from preset
  Future<int> createDailyGoalFromPreset(int presetId, DateTime date, {String? customNote}) async {
    final preset = await (select(goalPresets)..where((t) => t.id.equals(presetId))).getSingle();
    
    final goalId = 'goal_${preset.goalType}_${_getDateString(date)}';
    
    return into(dailyGoals).insert(
      DailyGoalsCompanion.insert(
        goalId: goalId,
        presetId: presetId,
        title: preset.title,
        description: preset.description,
        targetCount: Value(preset.defaultTargetCount),
        date: date,
        customNote: Value(customNote),
      ),
    );
  }

  // Update daily goal progress
  Future<int> updateGoalProgress(int dailyGoalId, int newCount, {String? note}) async {
    final goal = await (select(dailyGoals)..where((t) => t.id.equals(dailyGoalId))).getSingle();
    
    return await transaction(() async {
      // Update the goal's current count
      await (update(dailyGoals)..where((t) => t.id.equals(dailyGoalId))).write(
        DailyGoalsCompanion(
          currentCount: Value(newCount),
          status: Value(newCount >= goal.targetCount ? 'completed' : 'pending'),
          completedAt: Value(newCount >= goal.targetCount ? DateTime.now() : null),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // Add progress entry
      return await into(goalProgress).insert(
        GoalProgressCompanion.insert(
          dailyGoalId: dailyGoalId,
          incrementValue: Value(newCount - goal.currentCount),
          note: Value(note),
        ),
      );
    });
  }

  // === Goal History Management ===
  
  // Get goal history for date range
  Future<List<GoalHistoryData>> getGoalHistory(DateTime startDate, DateTime endDate) {
    return (select(goalHistory)
          ..where((t) => t.date.isBetweenValues(startDate, endDate))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  // Get goal history for specific goal type
  Future<List<GoalHistoryData>> getGoalHistoryByType(String goalType, {int? limit}) {
    final query = select(goalHistory)
      ..where((t) => t.goalType.equals(goalType))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    
    if (limit != null) {
      query.limit(limit);
    }
    
    return query.get();
  }

  // Archive completed daily goals to history
  Future<void> archiveDailyGoalsToHistory(DateTime date) async {
    final goals = await getDailyGoalsForDate(date);
    
    await transaction(() async {
      for (final goal in goals) {
        await into(goalHistory).insert(
          GoalHistoryCompanion.insert(
            goalType: (await (select(goalPresets)..where((t) => t.id.equals(goal.presetId))).getSingle()).goalType,
            title: goal.title,
            date: goal.date,
            targetCount: goal.targetCount,
            achievedCount: goal.currentCount,
            wasCompleted: goal.status == 'completed',
          ),
        );
      }
    });
  }

  // === Goal Statistics ===
  
  // Get statistics for all goal types
  Future<List<GoalStatistic>> getAllGoalStatistics() {
    return select(goalStatistics).get();
  }

  // Get statistics for specific goal type
  Future<GoalStatistic?> getGoalStatistics(String goalType) async {
    final query = select(goalStatistics)..where((t) => t.goalType.equals(goalType));
    final results = await query.get();
    return results.isNotEmpty ? results.first : null;
  }

  // Update goal statistics
  Future<void> updateGoalStatistics(String goalType) async {
    final history = await getGoalHistoryByType(goalType);
    
    if (history.isEmpty) return;
    
    final totalGoals = history.length;
    final completedGoals = history.where((h) => h.wasCompleted).length;
    final completionRate = totalGoals > 0 ? completedGoals / totalGoals : 0.0;
    
    // Calculate current streak
    int currentStreak = 0;
    final sortedHistory = history..sort((a, b) => b.date.compareTo(a.date));
    for (final goal in sortedHistory) {
      if (goal.wasCompleted) {
        currentStreak++;
      } else {
        break;
      }
    }
    
    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 0;
    for (final goal in history.reversed) {
      if (goal.wasCompleted) {
        tempStreak++;
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
      } else {
        tempStreak = 0;
      }
    }
    
    await into(goalStatistics).insertOnConflictUpdate(
      GoalStatisticsCompanion.insert(
        goalType: goalType,
        totalGoals: Value(totalGoals),
        completedGoals: Value(completedGoals),
        currentStreak: Value(currentStreak),
        longestStreak: Value(longestStreak),
        lastCompletedDate: Value(history.where((h) => h.wasCompleted).isNotEmpty 
          ? history.where((h) => h.wasCompleted).first.date 
          : null),
        firstGoalDate: Value(history.isNotEmpty ? history.last.date : null),
        completionRate: Value(completionRate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // === Notification Management ===
  
  // Get all active notifications
  Future<List<GoalNotification>> getAllActiveNotifications() {
    return (select(goalNotifications)
          ..where((t) => t.isEnabled.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.reminderTime)]))
        .get();
  }

  // Update notification settings
  Future<int> upsertNotificationSettings(GoalNotificationsCompanion notification) {
    return into(goalNotifications).insertOnConflictUpdate(notification);
  }

  // === Utility Methods ===
  
  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Initialize default presets if none exist
  Future<void> initializeDefaultPresets() async {
    final existingPresets = await getAllActivePresets();
    if (existingPresets.isNotEmpty) return;

    final defaultPresets = [
      GoalPresetsCompanion.insert(
        goalType: 'prayer',
        title: 'Offer 5 Daily Prayers',
        description: 'Complete all mandatory prayers on time',
        defaultTargetCount: const Value(5),
        icon: '🕌',
        color: '#2196F3',
        isRecommended: const Value(true),
      ),
      GoalPresetsCompanion.insert(
        goalType: 'quranReading',
        title: 'Read Quran',
        description: 'Listen or read verses from the Holy Quran',
        defaultTargetCount: const Value(1),
        icon: '📖',
        color: '#4CAF50',
        isRecommended: const Value(true),
      ),
      GoalPresetsCompanion.insert(
        goalType: 'dhikr',
        title: 'Dhikr & Remembrance',
        description: 'Remember Allah through dhikr',
        defaultTargetCount: const Value(100),
        icon: '📿',
        color: '#9C27B0',
        isRecommended: const Value(true),
      ),
      GoalPresetsCompanion.insert(
        goalType: 'duaRecitation',
        title: 'Daily Duas',
        description: 'Recite morning and evening duas',
        defaultTargetCount: const Value(2),
        icon: '🤲',
        color: '#E91E63',
        isRecommended: const Value(true),
      ),
    ];

    await transaction(() async {
      for (final preset in defaultPresets) {
        await into(goalPresets).insert(preset);
      }
    });
  }
} 