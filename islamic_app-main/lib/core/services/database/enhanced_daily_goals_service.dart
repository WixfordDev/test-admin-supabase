import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// Enhanced Goal Models
enum GoalType {
  prayer,
  quranReading,
  quranMemorization,
  dhikr,
  sadaqah,
  fastingMonday,
  fastingThursday,
  surahKahf,
  duaRecitation,
  hadithReading,
  istighfar,
  salawat,
  custom,
}

enum GoalStatus {
  pending,
  inProgress,
  completed,
  skipped,
  paused,
}

enum GoalDifficulty {
  easy,
  medium,
  hard,
}

class EnhancedDailyGoal {
  final String id;
  final GoalType type;
  final String title;
  final String description;
  final int targetCount;
  final int currentCount;
  final GoalStatus status;
  final DateTime date;
  final bool isActive;
  final String? customNote;
  final GoalDifficulty difficulty;
  final String icon;
  final Color color;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<GoalProgressEntry> progressEntries;
  final NotificationSettings? notificationSettings;
  final bool isStreak;
  final int streakCount;

  const EnhancedDailyGoal({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.targetCount,
    this.currentCount = 0,
    this.status = GoalStatus.pending,
    required this.date,
    this.isActive = true,
    this.customNote,
    this.difficulty = GoalDifficulty.medium,
    required this.icon,
    required this.color,
    required this.createdAt,
    this.completedAt,
    this.progressEntries = const [],
    this.notificationSettings,
    this.isStreak = false,
    this.streakCount = 0,
  });

  double get progress => targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => status == GoalStatus.completed || currentCount >= targetCount;
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(date.add(const Duration(days: 1)));

  EnhancedDailyGoal copyWith({
    String? id,
    GoalType? type,
    String? title,
    String? description,
    int? targetCount,
    int? currentCount,
    GoalStatus? status,
    DateTime? date,
    bool? isActive,
    String? customNote,
    GoalDifficulty? difficulty,
    String? icon,
    Color? color,
    DateTime? createdAt,
    DateTime? completedAt,
    List<GoalProgressEntry>? progressEntries,
    NotificationSettings? notificationSettings,
    bool? isStreak,
    int? streakCount,
  }) {
    return EnhancedDailyGoal(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      status: status ?? this.status,
      date: date ?? this.date,
      isActive: isActive ?? this.isActive,
      customNote: customNote ?? this.customNote,
      difficulty: difficulty ?? this.difficulty,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      progressEntries: progressEntries ?? this.progressEntries,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      isStreak: isStreak ?? this.isStreak,
      streakCount: streakCount ?? this.streakCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'status': status.name,
      'date': date.toIso8601String(),
      'isActive': isActive,
      'customNote': customNote,
      'difficulty': difficulty.name,
      'icon': icon,
      'color': color.toARGB32(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'progressEntries': progressEntries.map((e) => e.toJson()).toList(),
      'notificationSettings': notificationSettings?.toJson(),
      'isStreak': isStreak,
      'streakCount': streakCount,
    };
  }

  factory EnhancedDailyGoal.fromJson(Map<String, dynamic> json) {
    return EnhancedDailyGoal(
      id: json['id'],
      type: GoalType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'],
      description: json['description'],
      targetCount: json['targetCount'],
      currentCount: json['currentCount'] ?? 0,
      status: GoalStatus.values.firstWhere((e) => e.name == json['status']),
      date: DateTime.parse(json['date']),
      isActive: json['isActive'] ?? true,
      customNote: json['customNote'],
      difficulty: GoalDifficulty.values.firstWhere((e) => e.name == json['difficulty']),
      icon: json['icon'],
      color: Color(json['color']),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      progressEntries: (json['progressEntries'] as List?)
              ?.map((e) => GoalProgressEntry.fromJson(e))
              .toList() ??
          [],
      notificationSettings: json['notificationSettings'] != null
          ? NotificationSettings.fromJson(json['notificationSettings'])
          : null,
      isStreak: json['isStreak'] ?? false,
      streakCount: json['streakCount'] ?? 0,
    );
  }
}

class GoalPreset {
  final String id;
  final GoalType type;
  final String title;
  final String description;
  final int defaultTargetCount;
  final String icon;
  final Color color;
  final bool isRecommended;
  final bool isActive;
  final bool isCustom;
  final GoalDifficulty difficulty;
  final NotificationSettings? defaultNotificationSettings;
  final DateTime createdAt;

  const GoalPreset({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.defaultTargetCount,
    required this.icon,
    required this.color,
    this.isRecommended = false,
    this.isActive = true,
    this.isCustom = false,
    this.difficulty = GoalDifficulty.medium,
    this.defaultNotificationSettings,
    required this.createdAt,
  });

  EnhancedDailyGoal toDailyGoal({
    required DateTime date,
    String? customNote,
    int? customTargetCount,
  }) {
    return EnhancedDailyGoal(
      id: const Uuid().v4(),
      type: type,
      title: title,
      description: description,
      targetCount: customTargetCount ?? defaultTargetCount,
      date: date,
      customNote: customNote,
      difficulty: difficulty,
      icon: icon,
      color: color,
      createdAt: DateTime.now(),
      notificationSettings: defaultNotificationSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'defaultTargetCount': defaultTargetCount,
      'icon': icon,
      'color': color.toARGB32(),
      'isRecommended': isRecommended,
      'isActive': isActive,
      'isCustom': isCustom,
      'difficulty': difficulty.name,
      'defaultNotificationSettings': defaultNotificationSettings?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GoalPreset.fromJson(Map<String, dynamic> json) {
    return GoalPreset(
      id: json['id'],
      type: GoalType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'],
      description: json['description'],
      defaultTargetCount: json['defaultTargetCount'],
      icon: json['icon'],
      color: Color(json['color']),
      isRecommended: json['isRecommended'] ?? false,
      isActive: json['isActive'] ?? true,
      isCustom: json['isCustom'] ?? false,
      difficulty: GoalDifficulty.values.firstWhere((e) => e.name == json['difficulty']),
      defaultNotificationSettings: json['defaultNotificationSettings'] != null
          ? NotificationSettings.fromJson(json['defaultNotificationSettings'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  GoalPreset copyWith({
    String? id,
    GoalType? type,
    String? title,
    String? description,
    int? defaultTargetCount,
    String? icon,
    Color? color,
    bool? isRecommended,
    bool? isActive,
    bool? isCustom,
    GoalDifficulty? difficulty,
    NotificationSettings? defaultNotificationSettings,
    DateTime? createdAt,
  }) {
    return GoalPreset(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      defaultTargetCount: defaultTargetCount ?? this.defaultTargetCount,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isRecommended: isRecommended ?? this.isRecommended,
      isActive: isActive ?? this.isActive,
      isCustom: isCustom ?? this.isCustom,
      difficulty: difficulty ?? this.difficulty,
      defaultNotificationSettings:
          defaultNotificationSettings ?? this.defaultNotificationSettings,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class GoalProgressEntry {
  final String id;
  final DateTime timestamp;
  final int incrementValue;
  final String? note;
  final String? mood; // User's mood when completing this entry

  const GoalProgressEntry({
    required this.id,
    required this.timestamp,
    required this.incrementValue,
    this.note,
    this.mood,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'incrementValue': incrementValue,
      'note': note,
      'mood': mood,
    };
  }

  factory GoalProgressEntry.fromJson(Map<String, dynamic> json) {
    return GoalProgressEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      incrementValue: json['incrementValue'],
      note: json['note'],
      mood: json['mood'],
    );
  }
}

class NotificationSettings {
  final bool isEnabled;
  final TimeOfDay reminderTime;
  final List<int> reminderDays; // Days of week (1=Monday, 7=Sunday)
  final String? customMessage;
  final bool isRecurring;
  final Duration? snoozeInterval;

  const NotificationSettings({
    this.isEnabled = true,
    required this.reminderTime,
    this.reminderDays = const [1, 2, 3, 4, 5, 6, 7], // All days by default
    this.customMessage,
    this.isRecurring = true,
    this.snoozeInterval,
  });

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'reminderTime': {'hour': reminderTime.hour, 'minute': reminderTime.minute},
      'reminderDays': reminderDays,
      'customMessage': customMessage,
      'isRecurring': isRecurring,
      'snoozeInterval': snoozeInterval?.inMinutes,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      isEnabled: json['isEnabled'] ?? true,
      reminderTime: TimeOfDay(
        hour: json['reminderTime']['hour'],
        minute: json['reminderTime']['minute'],
      ),
      reminderDays: List<int>.from(json['reminderDays'] ?? [1, 2, 3, 4, 5, 6, 7]),
      customMessage: json['customMessage'],
      isRecurring: json['isRecurring'] ?? true,
      snoozeInterval: json['snoozeInterval'] != null
          ? Duration(minutes: json['snoozeInterval'])
          : null,
    );
  }
}

class GoalStatistics {
  final GoalType goalType;
  final int totalGoals;
  final int completedGoals;
  final int currentStreak;
  final int longestStreak;
  final double completionRate;
  final DateTime? lastCompletedDate;
  final DateTime? firstGoalDate;
  final int totalTimeSpent; // in minutes
  final double averageCompletionTime; // in minutes
  final Map<GoalDifficulty, int> difficultyBreakdown;

  const GoalStatistics({
    required this.goalType,
    required this.totalGoals,
    required this.completedGoals,
    required this.currentStreak,
    required this.longestStreak,
    required this.completionRate,
    this.lastCompletedDate,
    this.firstGoalDate,
    this.totalTimeSpent = 0,
    this.averageCompletionTime = 0.0,
    this.difficultyBreakdown = const {},
  });
}

class GoalHistory {
  final String id;
  final GoalType goalType;
  final String title;
  final DateTime date;
  final int targetCount;
  final int achievedCount;
  final bool wasCompleted;
  final GoalDifficulty difficulty;
  final Duration? timeToComplete;
  final String? note;

  const GoalHistory({
    required this.id,
    required this.goalType,
    required this.title,
    required this.date,
    required this.targetCount,
    required this.achievedCount,
    required this.wasCompleted,
    required this.difficulty,
    this.timeToComplete,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalType': goalType.name,
      'title': title,
      'date': date.toIso8601String(),
      'targetCount': targetCount,
      'achievedCount': achievedCount,
      'wasCompleted': wasCompleted,
      'difficulty': difficulty.name,
      'timeToComplete': timeToComplete?.inMinutes,
      'note': note,
    };
  }

  factory GoalHistory.fromJson(Map<String, dynamic> json) {
    return GoalHistory(
      id: json['id'],
      goalType: GoalType.values.firstWhere((e) => e.name == json['goalType']),
      title: json['title'],
      date: DateTime.parse(json['date']),
      targetCount: json['targetCount'],
      achievedCount: json['achievedCount'],
      wasCompleted: json['wasCompleted'],
      difficulty: GoalDifficulty.values.firstWhere((e) => e.name == json['difficulty']),
      timeToComplete: json['timeToComplete'] != null
          ? Duration(minutes: json['timeToComplete'])
          : null,
      note: json['note'],
    );
  }
}

class EnhancedDailyGoalsService {
  static const String _goalsKey = 'enhanced_daily_goals';
  static const String _presetsKey = 'goal_presets';
  static const String _historyKey = 'goal_history';
  static const String _statisticsKey = 'goal_statistics';
  static const String _settingsKey = 'goal_settings';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Singleton pattern
  static final EnhancedDailyGoalsService _instance =
      EnhancedDailyGoalsService._internal();
  factory EnhancedDailyGoalsService() => _instance;
  EnhancedDailyGoalsService._internal();

  /// Initialize the service
  Future<void> initialize() async {
    await _initializeNotifications();
    await _initializeDefaultPresets();
    await scheduleAutomaticDailyReset();
  }

  /// Initialize notification settings
  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  /// Get predefined goal presets
  static List<GoalPreset> getPredefinedPresets() {
    return [
      GoalPreset(
        id: 'preset_prayer',
        type: GoalType.prayer,
        title: 'Offer 5 Daily Prayers',
        description: 'Complete all mandatory prayers on time',
        defaultTargetCount: 5,
        icon: '🕌',
        color: const Color(0xFF2196F3),
        isRecommended: true,
        difficulty: GoalDifficulty.medium,
        createdAt: DateTime.now(),
        defaultNotificationSettings: const NotificationSettings(
          reminderTime: TimeOfDay(hour: 8, minute: 0),
          customMessage: 'Time for your daily prayers! 🕌',
        ),
      ),
      GoalPreset(
        id: 'preset_quran_reading',
        type: GoalType.quranReading,
        title: 'Read Quran',
        description: 'Listen or read verses from the Holy Quran',
        defaultTargetCount: 1,
        icon: '📖',
        color: const Color(0xFF4CAF50),
        isRecommended: true,
        difficulty: GoalDifficulty.easy,
        createdAt: DateTime.now(),
        defaultNotificationSettings: const NotificationSettings(
          reminderTime: TimeOfDay(hour: 21, minute: 0),
          customMessage: 'Time to read the Quran 📖',
        ),
      ),
      GoalPreset(
        id: 'preset_dhikr',
        type: GoalType.dhikr,
        title: 'Dhikr & Remembrance',
        description: 'Remember Allah through dhikr',
        defaultTargetCount: 100,
        icon: '📿',
        color: const Color(0xFF9C27B0),
        isRecommended: true,
        difficulty: GoalDifficulty.medium,
        createdAt: DateTime.now(),
        defaultNotificationSettings: const NotificationSettings(
          reminderTime: TimeOfDay(hour: 19, minute: 0),
          customMessage: 'Time for dhikr and remembrance 📿',
        ),
      ),
      GoalPreset(
        id: 'preset_dua',
        type: GoalType.duaRecitation,
        title: 'Daily Duas',
        description: 'Recite morning and evening duas',
        defaultTargetCount: 2,
        icon: '🤲',
        color: const Color(0xFFE91E63),
        isRecommended: true,
        difficulty: GoalDifficulty.easy,
        createdAt: DateTime.now(),
        defaultNotificationSettings: const NotificationSettings(
          reminderTime: TimeOfDay(hour: 7, minute: 0),
          reminderDays: [1, 2, 3, 4, 5, 6, 7],
          customMessage: 'Start your day with duas 🤲',
        ),
      ),
      // Additional presets for unused goal types
      GoalPreset(
        id: 'preset_quran_memorization',
        type: GoalType.quranMemorization,
        title: 'Memorize Quran',
        description: 'Memorize verses or chapters from the Quran',
        defaultTargetCount: 5,
        icon: '🧠',
        color: const Color(0xFFFF9800),
        isRecommended: false,
        difficulty: GoalDifficulty.hard,
        createdAt: DateTime.now(),
        defaultNotificationSettings: const NotificationSettings(
          reminderTime: TimeOfDay(hour: 6, minute: 0),
          customMessage: 'Time to memorize the Quran 🧠',
        ),
      ),
      GoalPreset(
        id: 'preset_sadaqah',
        type: GoalType.sadaqah,
        title: 'Give Charity (Sadaqah)',
        description: 'Donate to charity or help someone in need',
        defaultTargetCount: 1,
        icon: '💝',
        color: const Color(0xFF795548),
        isRecommended: false,
        difficulty: GoalDifficulty.easy,
        createdAt: DateTime.now(),
        defaultNotificationSettings: const NotificationSettings(
          reminderTime: TimeOfDay(hour: 12, minute: 0),
          customMessage: 'Remember to give charity today 💝',
        ),
      ),
      GoalPreset(
        id: 'preset_fasting_monday',
        type: GoalType.fastingMonday,
        title: 'Fast on Monday',
        description: 'Observe voluntary fasting on Mondays',
        defaultTargetCount: 1,
        icon: '🌙',
        color: const Color(0xFF607D8B),
        isRecommended: false,
        difficulty: GoalDifficulty.medium,
        createdAt: DateTime.now(),
        defaultNotificationSettings: const NotificationSettings(
          reminderTime: TimeOfDay(hour: 18, minute: 0),
          reminderDays: [1], // Monday only
          customMessage: 'Fast on Monday for extra rewards 🌙',
        ),
      ),
      GoalPreset(
        id: 'preset_fasting_thursday',
        type: GoalType.fastingThursday,
        title: 'Fast on Thursday',
        description: 'Observe voluntary fasting on Thursdays',
        defaultTargetCount: 1,
        icon: '🌙',
        color: const Color(0xFF607D8B),
        isRecommended: false,
        difficulty: GoalDifficulty.medium,
        createdAt: DateTime.now(),
        defaultNotificationSettings: const NotificationSettings(
          reminderTime: TimeOfDay(hour: 18, minute: 0),
          reminderDays: [4], // Thursday only
          customMessage: 'Fast on Thursday for extra rewards 🌙',
        ),
      ),
      GoalPreset(
        id: 'preset_surah_kahf',
        type: GoalType.surahKahf,
        title: 'Recite Surah Al-Kahf',
        description: 'Read Surah Al-Kahf on Fridays',
        defaultTargetCount: 1,
        icon: '📜',
        color: const Color(0xFF3F51B5),
        isRecommended: false,
        difficulty: GoalDifficulty.medium,
        createdAt: DateTime.now(),
        defaultNotificationSettings: const NotificationSettings(
          reminderTime: TimeOfDay(hour: 14, minute: 0),
          reminderDays: [5], // Friday only
          customMessage: 'Read Surah Al-Kahf on Friday 📜',
        ),
      ),
      GoalPreset(
        id: 'preset_hadith_reading',
        type: GoalType.hadithReading,
        title: 'Read Daily Hadith',
        description: 'Read and reflect on hadith collections',
        defaultTargetCount: 3,
        icon: '📚',
        color: const Color(0xFFFF5722),
        isRecommended: false,
        difficulty: GoalDifficulty.easy,
        createdAt: DateTime.now(),
        defaultNotificationSettings: const NotificationSettings(
          reminderTime: TimeOfDay(hour: 20, minute: 0),
          customMessage: 'Learn from the Sunnah - read hadith 📚',
        ),
      ),
      GoalPreset(
        id: 'preset_istighfar',
        type: GoalType.istighfar,
        title: 'Seek Forgiveness (Istighfar)',
        description: 'Recite Astaghfirullah and seek Allah\'s forgiveness',
        defaultTargetCount: 100,
        icon: '🕊️',
        color: const Color(0xFF009688),
        isRecommended: false,
        difficulty: GoalDifficulty.easy,
        createdAt: DateTime.now(),
        defaultNotificationSettings: const NotificationSettings(
          reminderTime: TimeOfDay(hour: 22, minute: 0),
          customMessage: 'Seek Allah\'s forgiveness - Istighfar 🕊️',
        ),
      ),
      GoalPreset(
        id: 'preset_salawat',
        type: GoalType.salawat,
        title: 'Send Salawat on Prophet',
        description: 'Recite Salawat (blessings) upon Prophet Muhammad ﷺ',
        defaultTargetCount: 100,
        icon: '💫',
        color: const Color(0xFF673AB7),
        isRecommended: false,
        difficulty: GoalDifficulty.easy,
        createdAt: DateTime.now(),
        defaultNotificationSettings: const NotificationSettings(
          reminderTime: TimeOfDay(hour: 15, minute: 0),
          customMessage: 'Send blessings upon the Prophet ﷺ 💫',
        ),
      ),
      // Comprehensive spiritual goals
      GoalPreset(
        id: 'preset_night_prayer',
        type: GoalType.prayer,
        title: 'Pray Tahajjud (Night Prayer)',
        description: 'Wake up for voluntary night prayers',
        defaultTargetCount: 1,
        icon: '🌌',
        color: const Color(0xFF1A237E),
        isRecommended: false,
        difficulty: GoalDifficulty.hard,
        createdAt: DateTime.now(),
        defaultNotificationSettings: const NotificationSettings(
          reminderTime: TimeOfDay(hour: 3, minute: 0),
          customMessage: 'Time for Tahajjud - night prayer 🌌',
        ),
      ),
      GoalPreset(
        id: 'preset_tasbih_after_prayer',
        type: GoalType.dhikr,
        title: 'Tasbih After Prayer',
        description: 'Recite Tasbih, Tahmid, and Takbir after each prayer',
        defaultTargetCount: 5,
        icon: '✨',
        color: const Color(0xFFAD1457),
        isRecommended: false,
        difficulty: GoalDifficulty.easy,
        createdAt: DateTime.now(),
        defaultNotificationSettings: const NotificationSettings(
          reminderTime: TimeOfDay(hour: 17, minute: 30),
          customMessage: 'Remember to do Tasbih after prayers ✨',
        ),
      ),
      GoalPreset(
        id: 'preset_quran_pages',
        type: GoalType.quranReading,
        title: 'Read 2 Pages of Quran',
        description: 'Read at least 2 pages from the Quran daily',
        defaultTargetCount: 2,
        icon: '📄',
        color: const Color(0xFF2E7D32),
        isRecommended: false,
        difficulty: GoalDifficulty.medium,
        createdAt: DateTime.now(),
        defaultNotificationSettings: const NotificationSettings(
          reminderTime: TimeOfDay(hour: 8, minute: 30),
          customMessage: 'Read your daily Quran pages 📄',
        ),
      ),
      GoalPreset(
        id: 'preset_morning_adhkar',
        type: GoalType.duaRecitation,
        title: 'Morning Adhkar',
        description: 'Recite comprehensive morning remembrances',
        defaultTargetCount: 1,
        icon: '☀️',
        color: const Color(0xFFF57C00),
        isRecommended: false,
        difficulty: GoalDifficulty.medium,
        createdAt: DateTime.now(),
        defaultNotificationSettings: const NotificationSettings(
          reminderTime: TimeOfDay(hour: 6, minute: 30),
          customMessage: 'Start with morning Adhkar ☀️',
        ),
      ),
      GoalPreset(
        id: 'preset_evening_adhkar',
        type: GoalType.duaRecitation,
        title: 'Evening Adhkar',
        description: 'Recite comprehensive evening remembrances',
        defaultTargetCount: 1,
        icon: '🌅',
        color: const Color(0xFFE65100),
        isRecommended: false,
        difficulty: GoalDifficulty.medium,
        createdAt: DateTime.now(),
        defaultNotificationSettings: const NotificationSettings(
          reminderTime: TimeOfDay(hour: 18, minute: 30),
          customMessage: 'Time for evening Adhkar 🌅',
        ),
      ),
    ];
  }

  /// Initialize default presets if none exist
  Future<void> _initializeDefaultPresets() async {
    final existingPresets = await getActivePresets();
    if (existingPresets.isNotEmpty) return;

    final defaultPresets = getPredefinedPresets();
    for (final preset in defaultPresets) {
      await savePreset(preset);
    }
  }

  /// === PRESET MANAGEMENT ===

  /// Get all active presets
  Future<List<GoalPreset>> getActivePresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = prefs.getStringList(_presetsKey) ?? [];
      
      final List<GoalPreset> presets = [];
      
      // Add saved custom presets
      for (final presetJson in presetsJson) {
        try {
          final presetMap = jsonDecode(presetJson) as Map<String, dynamic>;
          presets.add(GoalPreset.fromJson(presetMap));
        } catch (e) {
          debugPrint('Error parsing preset: $e');
        }
      }
      
      // Add default presets if no custom presets exist
      if (presets.isEmpty) {
        presets.addAll(getPredefinedPresets());
      } else {
        // Add default presets that aren't custom
        final defaultPresets = getPredefinedPresets();
        for (final defaultPreset in defaultPresets) {
          if (!presets.any((p) => p.id == defaultPreset.id)) {
            presets.add(defaultPreset);
          }
        }
      }
      
      return presets.where((preset) => preset.isActive).toList();
    } catch (e) {
      debugPrint('Error loading presets: $e');
      return getPredefinedPresets();
    }
  }

  /// Get recommended presets
  Future<List<GoalPreset>> getRecommendedPresets() async {
    final allPresets = await getActivePresets();
    return allPresets.where((preset) => preset.isRecommended).toList();
  }

  /// Save/Update a preset
  Future<void> savePreset(GoalPreset preset) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = prefs.getStringList(_presetsKey) ?? [];
      
      // Remove existing preset with same ID
      presetsJson.removeWhere((presetJson) {
        try {
          final presetMap = jsonDecode(presetJson) as Map<String, dynamic>;
          return presetMap['id'] == preset.id;
        } catch (e) {
          return false;
        }
      });
      
      // Add the new/updated preset
      presetsJson.add(jsonEncode(preset.toJson()));
      
      await prefs.setStringList(_presetsKey, presetsJson);
    } catch (e) {
      debugPrint('Error saving preset: $e');
      rethrow;
    }
  }

  /// Delete a preset
  Future<void> deletePreset(String presetId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = prefs.getStringList(_presetsKey) ?? [];
      
      // Remove preset with matching ID
      presetsJson.removeWhere((presetJson) {
        try {
          final presetMap = jsonDecode(presetJson) as Map<String, dynamic>;
          return presetMap['id'] == presetId;
        } catch (e) {
          return false;
        }
      });
      
      await prefs.setStringList(_presetsKey, presetsJson);
    } catch (e) {
      debugPrint('Error deleting preset: $e');
      rethrow;
    }
  }

  /// Create custom preset
  Future<GoalPreset> createCustomPreset({
    required GoalType type,
    required String title,
    required String description,
    required int defaultTargetCount,
    required String icon,
    required Color color,
    GoalDifficulty difficulty = GoalDifficulty.medium,
    NotificationSettings? defaultNotificationSettings,
  }) async {
    final preset = GoalPreset(
      id: const Uuid().v4(),
      type: type,
      title: title,
      description: description,
      defaultTargetCount: defaultTargetCount,
      icon: icon,
      color: color,
      isCustom: true,
      difficulty: difficulty,
      defaultNotificationSettings: defaultNotificationSettings,
      createdAt: DateTime.now(),
    );

    await savePreset(preset);
    return preset;
  }

  /// === DAILY GOALS MANAGEMENT ===

  /// Get daily goals for a specific date
  Future<List<EnhancedDailyGoal>> getDailyGoalsForDate(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = '${_goalsKey}_${_formatDateKey(date)}';
      final goalsJson = prefs.getStringList(dateKey) ?? [];
      
      final List<EnhancedDailyGoal> goals = [];
      for (final goalJson in goalsJson) {
        try {
          final goalMap = jsonDecode(goalJson) as Map<String, dynamic>;
          goals.add(EnhancedDailyGoal.fromJson(goalMap));
        } catch (e) {
          debugPrint('Error parsing goal: $e');
        }
      }
      
      return goals;
    } catch (e) {
      debugPrint('Error loading goals for date $date: $e');
      return [];
    }
  }

  /// Get daily goals for today
  Future<List<EnhancedDailyGoal>> getTodayGoals() async {
    return getDailyGoalsForDate(DateTime.now());
  }

  /// Initialize today's goals from active presets
  Future<List<EnhancedDailyGoal>> initializeTodayGoals() async {
    final today = DateTime.now();
    final existingGoals = await getDailyGoalsForDate(today);
    
    // Check if this is a first-time user (no custom presets and no existing goals)
    final isFirstTime = existingGoals.isEmpty && !(await hasUserCustomPresets());
    
    if (isFirstTime) {
      // For first-time users, create goals from recommended presets
      return await _createFreshGoalsFromUserPresets(today);
    }
    
    // Check if we need to reset goals (new day)
    final shouldReset = await _shouldResetGoalsForNewDay(today, existingGoals);
    
    if (shouldReset) {
      // Auto-save current goals as user presets before resetting
      await _autoSaveCurrentGoalsAsPresets();
      
      // Reset to fresh goals from user presets
      return await _createFreshGoalsFromUserPresets(today);
    }
    
    // Return existing goals if no reset needed
    return existingGoals;
  }

  /// Check if we should reset goals for a new day
  Future<bool> _shouldResetGoalsForNewDay(DateTime today, List<EnhancedDailyGoal> existingGoals) async {
    if (existingGoals.isEmpty) return true;
    
    // Check if any goals are from a previous day
    final todayStart = DateTime(today.year, today.month, today.day);
    final hasOldGoals = existingGoals.any((goal) => 
        goal.date.isBefore(todayStart));
    
    return hasOldGoals;
  }

  /// Auto-save current goals as user presets before resetting
  Future<void> _autoSaveCurrentGoalsAsPresets() async {
    // Try to get goals from yesterday first, then today
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final today = DateTime.now();
    
    var currentGoals = await getDailyGoalsForDate(yesterday);
    if (currentGoals.isEmpty) {
      // If no goals from yesterday, try today's goals
      currentGoals = await getDailyGoalsForDate(today);
    }
    
    // Only save if there are goals and user doesn't already have custom presets
    if (currentGoals.isNotEmpty) {
      final existingUserPresets = await getUserCustomPresets();
      
      // If user already has custom presets, update them; otherwise create new ones
      final userPresets = <GoalPreset>[];
      
      for (final goal in currentGoals) {
        final preset = GoalPreset(
          id: goal.id,
          type: goal.type,
          title: goal.title,
          description: goal.description,
          defaultTargetCount: goal.targetCount,
          icon: goal.icon,
          color: goal.color,
          isRecommended: true,
          isActive: true,
          isCustom: true,
          difficulty: goal.difficulty,
          defaultNotificationSettings: goal.notificationSettings,
          createdAt: DateTime.now(),
        );
        userPresets.add(preset);
      }
      
      await saveUserCustomPresets(userPresets);
      debugPrint('Auto-saved ${userPresets.length} goals as user presets');
    }
  }

  /// Create fresh goals from user presets
  Future<List<EnhancedDailyGoal>> _createFreshGoalsFromUserPresets(DateTime today) async {
    // Get user's custom presets first, fallback to recommended if none exist
    final userPresets = await getUserCustomPresets();
    final presetsToUse = userPresets.isNotEmpty ? userPresets : await getRecommendedPresets();
    
    final freshGoals = <EnhancedDailyGoal>[];
    
    for (final preset in presetsToUse) {
      final newGoal = preset.toDailyGoal(date: today);
      await saveDailyGoal(newGoal);
      freshGoals.add(newGoal);
    }

    return freshGoals;
  }

  /// Reset daily goals - create fresh goals from user's custom presets
  Future<List<EnhancedDailyGoal>> resetDailyGoals() async {
    final today = DateTime.now();
    
    // Auto-save current goals as presets before resetting
    await _autoSaveCurrentGoalsAsPresets();
    
    // Create fresh goals from user presets
    return await _createFreshGoalsFromUserPresets(today);
  }

  /// Save a daily goal
  Future<void> saveDailyGoal(EnhancedDailyGoal goal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = '${_goalsKey}_${_formatDateKey(goal.date)}';
      final goalsJson = prefs.getStringList(dateKey) ?? [];
      
      // Remove existing goal with same ID
      goalsJson.removeWhere((goalJson) {
        try {
          final goalMap = jsonDecode(goalJson) as Map<String, dynamic>;
          return goalMap['id'] == goal.id;
        } catch (e) {
          return false;
        }
      });
      
      // Add the new/updated goal
      goalsJson.add(jsonEncode(goal.toJson()));
      
      await prefs.setStringList(dateKey, goalsJson);
    } catch (e) {
      debugPrint('Error saving goal: $e');
      rethrow;
    }
  }

  /// Delete a daily goal
  Future<void> deleteDailyGoal(String goalId, DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = '${_goalsKey}_${_formatDateKey(date)}';
      final goalsJson = prefs.getStringList(dateKey) ?? [];
      
      // Remove goal with matching ID
      goalsJson.removeWhere((goalJson) {
        try {
          final goalMap = jsonDecode(goalJson) as Map<String, dynamic>;
          return goalMap['id'] == goalId;
        } catch (e) {
          return false;
        }
      });
      
      await prefs.setStringList(dateKey, goalsJson);
    } catch (e) {
      debugPrint('Error deleting goal: $e');
      rethrow;
    }
  }

  /// Format date for storage key
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Update goal progress with prayer-specific handling
  Future<EnhancedDailyGoal> updateGoalProgress(
    String goalId,
    int newCount, {
    String? note,
    String? mood,
    Map<String, bool>? prayerCompletions, // For prayer tracking
  }) async {
    try {
      // Get current goal
      final goals = await getTodayGoals();
      final goalIndex = goals.indexWhere((g) => g.id == goalId);
      
      if (goalIndex == -1) {
        throw Exception('Goal not found');
      }

      final goal = goals[goalIndex];
      
      // Handle prayer-specific progress
      String? progressNote = note;
      if (goal.type == GoalType.prayer && prayerCompletions != null) {
        final completedPrayers = prayerCompletions.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();
        
        progressNote = 'Completed prayers: ${completedPrayers.join(', ')}';
      }
      
      // Create progress entry
      final progressEntry = GoalProgressEntry(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        incrementValue: newCount - goal.currentCount,
        note: progressNote,
        mood: mood,
      );

      // Update goal
      final updatedGoal = goal.copyWith(
        currentCount: newCount,
        status: newCount >= goal.targetCount ? GoalStatus.completed : GoalStatus.inProgress,
        completedAt: newCount >= goal.targetCount ? DateTime.now() : null,
        progressEntries: [...goal.progressEntries, progressEntry],
      );

      await saveDailyGoal(updatedGoal);

      // Schedule celebration notification if completed
      if (updatedGoal.isCompleted && !goal.isCompleted) {
        await _scheduleCompletionNotification(updatedGoal);
      }

      return updatedGoal;
    } catch (e) {
      debugPrint('Error updating goal progress: $e');
      rethrow;
    }
  }

  /// === GOAL HISTORY ===

  /// Get goal history for date range
  Future<List<GoalHistory>> getGoalHistory({
    DateTime? startDate,
    DateTime? endDate,
    GoalType? goalType,
    int? limit,
  }) async {
    // Implementation would query database
    return [];
  }

  /// Archive completed goals to history
  Future<void> archiveGoalsToHistory(DateTime date) async {
    final goals = await getDailyGoalsForDate(date);
    
    for (final goal in goals) {
      final history = GoalHistory(
        id: const Uuid().v4(),
        goalType: goal.type,
        title: goal.title,
        date: goal.date,
        targetCount: goal.targetCount,
        achievedCount: goal.currentCount,
        wasCompleted: goal.isCompleted,
        difficulty: goal.difficulty,
        timeToComplete: goal.completedAt?.difference(goal.createdAt),
        note: goal.customNote,
      );
      
      await _saveGoalHistory(history);
    }
  }

  Future<void> _saveGoalHistory(GoalHistory history) async {
    // Implementation would save to database
  }

  /// === STATISTICS ===

  /// Get comprehensive goal statistics
  Future<GoalStatistics> getGoalStatistics(GoalType goalType) async {
    final history = await getGoalHistory(goalType: goalType);
    
    final totalGoals = history.length;
    final completedGoals = history.where((h) => h.wasCompleted).length;
    final completionRate = totalGoals > 0 ? completedGoals / totalGoals : 0.0;
    
    // Calculate streaks
    final currentStreak = await _calculateCurrentStreak(goalType);
    final longestStreak = await _calculateLongestStreak(goalType);
    
    return GoalStatistics(
      goalType: goalType,
      totalGoals: totalGoals,
      completedGoals: completedGoals,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      completionRate: completionRate,
      lastCompletedDate: history
          .where((h) => h.wasCompleted)
          .map((h) => h.date)
          .fold<DateTime?>(null, (prev, date) => prev == null || date.isAfter(prev) ? date : prev),
      firstGoalDate: history.isNotEmpty ? history.map((h) => h.date).reduce((a, b) => a.isBefore(b) ? a : b) : null,
    );
  }

  Future<int> _calculateCurrentStreak(GoalType goalType) async {
    // Implementation would calculate current streak
    return 0;
  }

  Future<int> _calculateLongestStreak(GoalType goalType) async {
    // Implementation would calculate longest streak
    return 0;
  }

  /// === NOTIFICATIONS ===

  /// Schedule reminder notification for a goal
  Future<void> scheduleGoalNotification(EnhancedDailyGoal goal) async {
    if (goal.notificationSettings?.isEnabled != true) return;

    final settings = goal.notificationSettings!;
    final now = DateTime.now();
    final scheduleTime = DateTime(
      now.year,
      now.month,
      now.day,
      settings.reminderTime.hour,
      settings.reminderTime.minute,
    );

    // If time has passed today, schedule for tomorrow
    final finalScheduleTime = scheduleTime.isBefore(now)
        ? scheduleTime.add(const Duration(days: 1))
        : scheduleTime;

    await _notifications.zonedSchedule(
      goal.id.hashCode,
      '${goal.icon} ${goal.title}',
      settings.customMessage ?? 'Time to work on your goal: ${goal.description}',
      tz.TZDateTime.from(finalScheduleTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_goals',
          'Daily Goals',
          channelDescription: 'Reminders for your daily Islamic goals',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedule completion celebration notification
  Future<void> _scheduleCompletionNotification(EnhancedDailyGoal goal) async {
    await _notifications.show(
      goal.id.hashCode + 1000, // Different ID for completion
      '🎉 Goal Completed!',
      'Congratulations! You completed "${goal.title}". May Allah reward you!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'goal_completion',
          'Goal Completion',
          channelDescription: 'Celebrations for completed goals',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Cancel notifications for a goal
  Future<void> cancelGoalNotifications(String goalId) async {
    await _notifications.cancel(goalId.hashCode);
    await _notifications.cancel(goalId.hashCode + 1000);
  }

  /// === UTILITY METHODS ===

  /// Get goal icon for type
  String getGoalIcon(GoalType type) {
    switch (type) {
      case GoalType.prayer:
        return '🕌';
      case GoalType.quranReading:
        return '📖';
      case GoalType.quranMemorization:
        return '🧠';
      case GoalType.dhikr:
        return '📿';
      case GoalType.sadaqah:
        return '💝';
      case GoalType.fastingMonday:
      case GoalType.fastingThursday:
        return '🌙';
      case GoalType.surahKahf:
        return '📜';
      case GoalType.duaRecitation:
        return '🤲';
      case GoalType.hadithReading:
        return '📚';
      case GoalType.istighfar:
        return '🕊️';
      case GoalType.salawat:
        return '💫';
      case GoalType.custom:
        return '⭐';
    }
  }

  /// Get goal color for type
  Color getGoalColor(GoalType type) {
    switch (type) {
      case GoalType.prayer:
        return const Color(0xFF2196F3);
      case GoalType.quranReading:
        return const Color(0xFF4CAF50);
      case GoalType.quranMemorization:
        return const Color(0xFFFF9800);
      case GoalType.dhikr:
        return const Color(0xFF9C27B0);
      case GoalType.sadaqah:
        return const Color(0xFF795548);
      case GoalType.fastingMonday:
      case GoalType.fastingThursday:
        return const Color(0xFF607D8B);
      case GoalType.surahKahf:
        return const Color(0xFF3F51B5);
      case GoalType.duaRecitation:
        return const Color(0xFFE91E63);
      case GoalType.hadithReading:
        return const Color(0xFFFF5722);
      case GoalType.istighfar:
        return const Color(0xFF009688);
      case GoalType.salawat:
        return const Color(0xFF673AB7);
      case GoalType.custom:
        return const Color(0xFF757575);
    }
  }

  /// Schedule automatic daily goal reset at midnight
  Future<void> scheduleAutomaticDailyReset() async {
    // This would be called from the app initialization
    // to ensure goals reset automatically every day
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);
    
    // Schedule the reset
    Future.delayed(timeUntilMidnight, () async {
      await resetDailyGoals();
      // Schedule the next reset (every 24 hours)
      scheduleAutomaticDailyReset();
    });
  }
  
  /// Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Remove all goal-related keys including date-specific ones
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_goalsKey) || 
          key == _presetsKey || 
          key == _historyKey || 
          key == _statisticsKey || 
          key == _settingsKey) {
        await prefs.remove(key);
      }
    }
  }

  /// Get user's custom presets (their personalized daily template)
  Future<List<GoalPreset>> getUserCustomPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userPresetsJson = prefs.getStringList('user_custom_presets') ?? [];
      
      final List<GoalPreset> userPresets = [];
      
      for (final presetJson in userPresetsJson) {
        try {
          final presetMap = jsonDecode(presetJson) as Map<String, dynamic>;
          userPresets.add(GoalPreset.fromJson(presetMap));
        } catch (e) {
          debugPrint('Error parsing user preset: $e');
        }
      }
      
      return userPresets.where((preset) => preset.isActive).toList();
    } catch (e) {
      debugPrint('Error loading user custom presets: $e');
      return [];
    }
  }

  /// Save user's custom presets (their personalized daily template)
  Future<void> saveUserCustomPresets(List<GoalPreset> presets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = presets.map((preset) => jsonEncode(preset.toJson())).toList();
      await prefs.setStringList('user_custom_presets', presetsJson);
    } catch (e) {
      debugPrint('Error saving user custom presets: $e');
      rethrow;
    }
  }

  /// Add a goal to user's custom presets template
  Future<void> addToUserPresets(EnhancedDailyGoal goal) async {
    final userPresets = await getUserCustomPresets();
    
    // Check if preset already exists
    final existingIndex = userPresets.indexWhere((preset) => 
        preset.type == goal.type && preset.title == goal.title);
    
    final newPreset = GoalPreset(
      id: goal.id,
      type: goal.type,
      title: goal.title,
      description: goal.description,
      defaultTargetCount: goal.targetCount,
      icon: goal.icon,
      color: goal.color,
      isRecommended: true, // User's presets are considered recommended for them
      isActive: true,
      isCustom: true,
      difficulty: goal.difficulty,
      defaultNotificationSettings: goal.notificationSettings,
      createdAt: goal.createdAt,
    );
    
    if (existingIndex != -1) {
      // Update existing preset
      userPresets[existingIndex] = newPreset;
    } else {
      // Add new preset
      userPresets.add(newPreset);
    }
    
    await saveUserCustomPresets(userPresets);
  }

  /// Remove a goal from user's custom presets template
  Future<void> removeFromUserPresets(String goalType, String goalTitle) async {
    final userPresets = await getUserCustomPresets();
    userPresets.removeWhere((preset) => 
        preset.type.name == goalType && preset.title == goalTitle);
    await saveUserCustomPresets(userPresets);
  }

  /// Update a preset in user's custom presets template
  Future<void> updateUserPreset(GoalPreset updatedPreset) async {
    final userPresets = await getUserCustomPresets();
    final index = userPresets.indexWhere((preset) => preset.id == updatedPreset.id);
    
    if (index != -1) {
      userPresets[index] = updatedPreset;
      await saveUserCustomPresets(userPresets);
    }
  }

  /// Delete a preset from user's custom presets template
  Future<void> deleteUserPreset(String presetId) async {
    final userPresets = await getUserCustomPresets();
    userPresets.removeWhere((preset) => preset.id == presetId);
    await saveUserCustomPresets(userPresets);
  }

  /// Initialize user presets from current daily goals (when user first customizes)
  Future<void> initializeUserPresetsFromCurrentGoals() async {
    final userPresets = await getUserCustomPresets();
    if (userPresets.isNotEmpty) return; // Already initialized
    
    final todayGoals = await getTodayGoals();
    if (todayGoals.isEmpty) return;
    
    // Convert current daily goals to user presets
    final newUserPresets = <GoalPreset>[];
    for (final goal in todayGoals) {
      final preset = GoalPreset(
        id: goal.id,
        type: goal.type,
        title: goal.title,
        description: goal.description,
        defaultTargetCount: goal.targetCount,
        icon: goal.icon,
        color: goal.color,
        isRecommended: true,
        isActive: true,
        isCustom: true,
        difficulty: goal.difficulty,
        defaultNotificationSettings: goal.notificationSettings,
        createdAt: DateTime.now(),
      );
      newUserPresets.add(preset);
    }
    
    await saveUserCustomPresets(newUserPresets);
  }

  /// Check if user has custom presets
  Future<bool> hasUserCustomPresets() async {
    final userPresets = await getUserCustomPresets();
    return userPresets.isNotEmpty;
  }

  /// Reset to default presets (clear user customizations)
  Future<void> resetToDefaultPresets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_custom_presets');
  }

  /// Update an existing preset
  Future<void> updatePreset(GoalPreset updatedPreset) async {
    try {
      // Create a copy with updated timestamp
      final presetWithUpdatedTime = updatedPreset.copyWith(
        // We can add an updatedAt field to the model if needed
      );
      
      // Save the updated preset (savePreset handles update logic)
      await savePreset(presetWithUpdatedTime);
    } catch (e) {
      debugPrint('Error updating preset: $e');
      rethrow;
    }
  }
} 