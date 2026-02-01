import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deenhub/features/dashboard/domain/models/daily_goal.dart';

class DailyGoalsService {
  static const String _goalsKey = 'daily_goals';
  static const String _goalTemplatesKey = 'goal_templates';
  static const String _goalSettingsKey = 'goal_settings';

  // Singleton pattern
  static final DailyGoalsService _instance = DailyGoalsService._internal();
  factory DailyGoalsService() => _instance;
  DailyGoalsService._internal();

  /// Get predefined goal templates
  static List<GoalTemplate> getPredefinedTemplates() {
    return [
      const GoalTemplate(
        type: GoalType.prayer,
        title: 'Offer 5 Daily Prayers',
        description: 'Complete all mandatory prayers on time',
        defaultTargetCount: 5,
        icon: '🕌',
        color: '#2196F3',
        isRecommended: true,
      ),
      const GoalTemplate(
        type: GoalType.quranReading,
        title: 'Read Quran',
        description: 'Listen or read verses from the Holy Quran',
        defaultTargetCount: 1,
        icon: '📖',
        color: '#4CAF50',
        isRecommended: true,
      ),
      const GoalTemplate(
        type: GoalType.dhikr,
        title: 'Dhikr & Remembrance',
        description: 'Remember Allah through dhikr',
        defaultTargetCount: 100,
        icon: '📿',
        color: '#9C27B0',
        isRecommended: true,
      ),
      const GoalTemplate(
        type: GoalType.duaRecitation,
        title: 'Daily Duas',
        description: 'Recite morning and evening duas',
        defaultTargetCount: 2,
        icon: '🤲',
        color: '#E91E63',
        isRecommended: true,
      ),
      const GoalTemplate(
        type: GoalType.quranMemorization,
        title: 'Memorize Quran',
        description: 'Memorize verses from the Holy Quran',
        defaultTargetCount: 1,
        icon: '🧠',
        color: '#FF9800',
      ),
      const GoalTemplate(
        type: GoalType.sadaqah,
        title: 'Give Sadaqah',
        description: 'Give charity for the sake of Allah',
        defaultTargetCount: 1,
        icon: '💝',
        color: '#795548',
      ),
      const GoalTemplate(
        type: GoalType.fastingMonday,
        title: 'Fast on Monday',
        description: 'Observe sunnah fasting on Monday',
        defaultTargetCount: 1,
        icon: '🌙',
        color: '#607D8B',
      ),
      const GoalTemplate(
        type: GoalType.fastingThursday,
        title: 'Fast on Thursday',
        description: 'Observe sunnah fasting on Thursday',
        defaultTargetCount: 1,
        icon: '🌙',
        color: '#607D8B',
      ),
      const GoalTemplate(
        type: GoalType.surahKahf,
        title: 'Recite Surah Kahf',
        description: 'Recite Surah Kahf on Friday',
        defaultTargetCount: 1,
        icon: '📜',
        color: '#3F51B5',
      ),
      const GoalTemplate(
        type: GoalType.hadithReading,
        title: 'Read Hadith',
        description: 'Read and reflect on Prophet\'s sayings',
        defaultTargetCount: 1,
        icon: '📚',
        color: '#FF5722',
      ),
      const GoalTemplate(
        type: GoalType.istighfar,
        title: 'Seek Forgiveness',
        description: 'Recite Istighfar (Astaghfirullah)',
        defaultTargetCount: 100,
        icon: '🕊️',
        color: '#009688',
      ),
      const GoalTemplate(
        type: GoalType.salawat,
        title: 'Send Salawat',
        description: 'Send blessings upon Prophet Muhammad (PBUH)',
        defaultTargetCount: 10,
        icon: '💫',
        color: '#673AB7',
      ),
    ];
  }

  /// Get goals for a specific date
  Future<List<DailyGoal>> getGoalsForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString(_goalsKey);
    
    if (goalsJson == null) return [];
    
    final goalsMap = json.decode(goalsJson) as Map<String, dynamic>;
    final dateKey = _getDateKey(date);
    
    if (!goalsMap.containsKey(dateKey)) return [];
    
    final goalsList = goalsMap[dateKey] as List<dynamic>;
    return goalsList.map((goalJson) => DailyGoal.fromJson(goalJson)).toList();
  }

  /// Save goals for a specific date
  Future<void> saveGoalsForDate(DateTime date, List<DailyGoal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final existingGoalsJson = prefs.getString(_goalsKey);
    
    Map<String, dynamic> goalsMap = {};
    if (existingGoalsJson != null) {
      goalsMap = json.decode(existingGoalsJson) as Map<String, dynamic>;
    }
    
    final dateKey = _getDateKey(date);
    goalsMap[dateKey] = goals.map((goal) => goal.toJson()).toList();
    
    await prefs.setString(_goalsKey, json.encode(goalsMap));
  }

  /// Update a specific goal
  Future<void> updateGoal(DailyGoal updatedGoal) async {
    final goals = await getGoalsForDate(updatedGoal.date);
    final goalIndex = goals.indexWhere((g) => g.id == updatedGoal.id);
    
    if (goalIndex != -1) {
      goals[goalIndex] = updatedGoal;
      await saveGoalsForDate(updatedGoal.date, goals);
    }
  }

  /// Initialize goals for today if not exists
  Future<List<DailyGoal>> initializeTodayGoals() async {
    final today = DateTime.now();
    final existingGoals = await getGoalsForDate(today);
    
    if (existingGoals.isNotEmpty) {
      return existingGoals;
    }
    
    // Get active goal templates and create today's goals
    final templates = await getActiveGoalTemplates();
    final todayGoals = templates.map((template) => template.toDailyGoal(date: today)).toList();
    
    await saveGoalsForDate(today, todayGoals);
    return todayGoals;
  }

  /// Get active goal templates from settings
  Future<List<GoalTemplate>> getActiveGoalTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final templatesJson = prefs.getString(_goalTemplatesKey);
    
    if (templatesJson == null) {
      // Return recommended templates by default
      final recommendedTemplates = getPredefinedTemplates().where((t) => t.isRecommended).toList();
      await saveActiveGoalTemplates(recommendedTemplates);
      return recommendedTemplates;
    }
    
    final templatesList = json.decode(templatesJson) as List<dynamic>;
    final activeTemplates = <GoalTemplate>[];
    
    for (final templateJson in templatesList) {
      final template = getPredefinedTemplates().firstWhere(
        (t) => t.type.name == templateJson['type'],
        orElse: () => GoalTemplate(
          type: GoalType.values.firstWhere((e) => e.name == templateJson['type']),
          title: templateJson['title'],
          description: templateJson['description'],
          defaultTargetCount: templateJson['defaultTargetCount'],
          icon: templateJson['icon'],
          color: templateJson['color'],
          isRecommended: templateJson['isRecommended'] ?? false,
        ),
      );
      activeTemplates.add(template);
    }
    
    return activeTemplates;
  }

  /// Save active goal templates
  Future<void> saveActiveGoalTemplates(List<GoalTemplate> templates) async {
    final prefs = await SharedPreferences.getInstance();
    final templatesJson = templates.map((t) => {
      'type': t.type.name,
      'title': t.title,
      'description': t.description,
      'defaultTargetCount': t.defaultTargetCount,
      'icon': t.icon,
      'color': t.color,
      'isRecommended': t.isRecommended,
    }).toList();
    
    await prefs.setString(_goalTemplatesKey, json.encode(templatesJson));
  }

  /// Get goal statistics for a date range
  Future<Map<String, dynamic>> getGoalStatistics(DateTime startDate, DateTime endDate) async {
    final days = endDate.difference(startDate).inDays + 1;
    int totalGoals = 0;
    int completedGoals = 0;
    final goalTypeStats = <GoalType, Map<String, int>>{};
    
    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final goals = await getGoalsForDate(date);
      
      totalGoals += goals.length;
      
      for (final goal in goals) {
        if (goal.isCompleted) {
          completedGoals++;
        }
        
        goalTypeStats[goal.type] = goalTypeStats[goal.type] ?? {'total': 0, 'completed': 0};
        goalTypeStats[goal.type]!['total'] = goalTypeStats[goal.type]!['total']! + 1;
        if (goal.isCompleted) {
          goalTypeStats[goal.type]!['completed'] = goalTypeStats[goal.type]!['completed']! + 1;
        }
      }
    }
    
    return {
      'totalGoals': totalGoals,
      'completedGoals': completedGoals,
      'completionRate': totalGoals > 0 ? (completedGoals / totalGoals) : 0.0,
      'goalTypeStats': goalTypeStats,
      'streak': await _calculateCurrentStreak(),
    };
  }

  /// Calculate current streak of completing all daily goals
  Future<int> _calculateCurrentStreak() async {
    int streak = 0;
    final today = DateTime.now();
    
    for (int i = 0; i < 365; i++) { // Check up to a year back
      final date = today.subtract(Duration(days: i));
      final goals = await getGoalsForDate(date);
      
      if (goals.isEmpty) break;
      
      final allCompleted = goals.every((goal) => goal.isCompleted);
      if (allCompleted) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  /// Helper method to get date key for storage
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Clear all goals data (for testing or reset)
  Future<void> clearAllGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_goalsKey);
    await prefs.remove(_goalTemplatesKey);
    await prefs.remove(_goalSettingsKey);
  }
} 