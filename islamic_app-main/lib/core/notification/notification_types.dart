import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Central repository for all notification types, IDs, and channel configurations
/// This ensures no ID conflicts and provides type safety for notifications

enum NotificationType {
  // Prayer notifications - highest priority
  fajrPrayer(id: 1001, channel: 'fajr_prayer', priority: NotificationPriority.critical),
  dhuhrPrayer(id: 1002, channel: 'other_prayers', priority: NotificationPriority.critical),
  asrPrayer(id: 1003, channel: 'other_prayers', priority: NotificationPriority.critical),
  maghribPrayer(id: 1004, channel: 'other_prayers', priority: NotificationPriority.critical),
  ishaPrayer(id: 1005, channel: 'other_prayers', priority: NotificationPriority.critical),
  qiyamPrayer(id: 1006, channel: 'qiyam_prayer', priority: NotificationPriority.critical),
  
  // Before prayer notifications - high priority
  beforeFajr(id: 2001, channel: 'before_prayer', priority: NotificationPriority.high),
  beforeDhuhr(id: 2002, channel: 'before_prayer', priority: NotificationPriority.high),
  beforeAsr(id: 2003, channel: 'before_prayer', priority: NotificationPriority.high),
  beforeMaghrib(id: 2004, channel: 'before_prayer', priority: NotificationPriority.high),
  beforeIsha(id: 2005, channel: 'before_prayer', priority: NotificationPriority.high),
  beforeQiyam(id: 2006, channel: 'before_prayer', priority: NotificationPriority.high),
  
  // Daily goals notifications
  dailyGoalReminder(id: 3001, channel: 'daily_goals', priority: NotificationPriority.medium),
  goalCompletion(id: 3002, channel: 'goal_completion', priority: NotificationPriority.high),
  streakMilestone(id: 3003, channel: 'goal_completion', priority: NotificationPriority.high),
  dailyMotivation(id: 3004, channel: 'motivation', priority: NotificationPriority.low),
  progressCheck(id: 3005, channel: 'daily_goals', priority: NotificationPriority.medium),
  weeklyReview(id: 3006, channel: 'daily_goals', priority: NotificationPriority.medium),
  
  // Special notifications
  fridayKahfMorning(id: 4001, channel: 'friday_kahf', priority: NotificationPriority.high),
  fridayKahfNoon(id: 4002, channel: 'friday_kahf', priority: NotificationPriority.high),
  surahMulkReminder(id: 4003, channel: 'sunnah_reminders', priority: NotificationPriority.medium),
  
  // Memorization reminders
  memorizationReminder(id: 5001, channel: 'memorization_reminder', priority: NotificationPriority.medium),
  
  // Sunnah reminders
  mondayFasting(id: 6001, channel: 'sunnah_fasting', priority: NotificationPriority.medium),
  thursdayFasting(id: 6002, channel: 'sunnah_fasting', priority: NotificationPriority.medium),
  
  // Zakat reminders
  zakatReminder(id: 7001, channel: 'zakat_reminder', priority: NotificationPriority.high),

  // Subscription notifications
  subscriptionSuccess(id: 8001, channel: 'sunnah_reminders', priority: NotificationPriority.high),

  // System notifications
  dailyScheduler(id: 9001, channel: 'silent', priority: NotificationPriority.low),
  
  // Test notifications
  test(id: 99999, channel: 'fajr_prayer', priority: NotificationPriority.critical);

  const NotificationType({
    required this.id,
    required this.channel,
    required this.priority,
  });

  final int id;
  final String channel;
  final NotificationPriority priority;
}

enum NotificationPriority {
  low,
  medium,
  high,
  critical;
  
  /// Convert to Flutter's Importance enum
  Importance get importance {
    switch (this) {
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.medium:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.critical:
        return Importance.max;
    }
  }
  
  Priority get priority {
    switch (this) {
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.medium:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.critical:
        return Priority.max;
    }
  }
}

/// Extension to easily get notification type by prayer type
extension NotificationTypeExtensions on NotificationType {
  /// Get the appropriate notification type for a prayer
  static NotificationType forPrayer(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return NotificationType.fajrPrayer;
      case 'dhuhr':
        return NotificationType.dhuhrPrayer;
      case 'asr':
        return NotificationType.asrPrayer;
      case 'maghrib':
        return NotificationType.maghribPrayer;
      case 'isha':
        return NotificationType.ishaPrayer;
      case 'qiyam':
        return NotificationType.qiyamPrayer;
      default:
        throw ArgumentError('Unknown prayer type: $prayerName');
    }
  }
  
  /// Get the before prayer notification type
  static NotificationType forBeforePrayer(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return NotificationType.beforeFajr;
      case 'dhuhr':
        return NotificationType.beforeDhuhr;
      case 'asr':
        return NotificationType.beforeAsr;
      case 'maghrib':
        return NotificationType.beforeMaghrib;
      case 'isha':
        return NotificationType.beforeIsha;
      case 'qiyam':
        return NotificationType.beforeQiyam;
      default:
        throw ArgumentError('Unknown prayer type: $prayerName');
    }
  }
} 