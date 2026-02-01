import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/notification/notification_manager.dart';
import 'package:deenhub/core/notification/notification_types.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/features/settings/data/entity/notification_settings_data.dart';
import 'package:deenhub/main.dart';

/// Sunnah Fasting Notification Service
/// Handles scheduling notifications for Monday and Thursday fasting reminders
class SunnahFastingNotificationService {
  // Singleton implementation
  static SunnahFastingNotificationService? _instance;
  factory SunnahFastingNotificationService() =>
      _instance ??= SunnahFastingNotificationService._internal();
  SunnahFastingNotificationService._internal();

  final NotificationManager _notificationManager = NotificationManager();

  /// Initialize the Sunnah Fasting notification service
  Future<void> initialize() async {
    logger.i('Initializing Sunnah Fasting Notification Service...');

    // Ensure notification manager is initialized
    if (!_notificationManager.isInitialized) {
      await _notificationManager.initialize();
    }

    // Schedule fasting notifications based on user settings
    await scheduleSunnahFastingNotifications();

    logger.i('Sunnah Fasting Notification Service initialized successfully');
  }

  /// Schedule Sunnah fasting notifications based on user settings
  Future<void> scheduleSunnahFastingNotifications() async {
    try {
      // Get user settings
      final settings = getIt<SharedPrefsHelper>().notificationSettingsData;

      // Cancel existing notifications first
      await cancelSunnahFastingNotifications();

      // Check if sunnah fasting reminders are enabled
      if (!settings.sunnahFastingReminders) {
        logger.i('Sunnah fasting reminders are disabled');
        return;
      }

      // Schedule Monday fasting reminder (night before - Sunday evening)
      if (settings.mondayFasting) {
        await _scheduleMondayFastingReminder(settings);
      }

      // Schedule Thursday fasting reminder (night before - Wednesday evening)
      if (settings.thursdayFasting) {
        await _scheduleThursdayFastingReminder(settings);
      }

      logger.i('Sunnah fasting notifications scheduled successfully');
    } catch (e) {
      logger.e('Error scheduling Sunnah fasting notifications: $e');
    }
  }

  /// Schedule Monday fasting reminder for Sunday evening
  Future<void> _scheduleMondayFastingReminder(
      NotificationSettingsData settings) async {
    try {
      final nextSunday = _getNextDayOfWeek(DateTime.sunday);

      final reminderTime = DateTime(
        nextSunday.year,
        nextSunday.month,
        nextSunday.day,
        settings.sunnahFastingReminderHour,
        settings.sunnahFastingReminderMinute,
      );

      await _notificationManager.scheduleNotification(
        type: NotificationType.mondayFasting,
        title: 'Monday Fasting Reminder',
        body:
            'Prepare for tomorrow\'s Sunnah fast. The Prophet \u{FDFA} used to fast on Mondays.',
        scheduledDate: reminderTime,
        payload: 'sunnah_fasting:monday',
      );

      logger.i(
          'Monday fasting reminder scheduled for Sunday at ${settings.sunnahFastingReminderHour}:${settings.sunnahFastingReminderMinute.toString().padLeft(2, '0')}');
    } catch (e) {
      logger.e('Error scheduling Monday fasting reminder: $e');
    }
  }

  /// Schedule Thursday fasting reminder for Wednesday evening
  Future<void> _scheduleThursdayFastingReminder(
      NotificationSettingsData settings) async {
    try {
      final nextWednesday = _getNextDayOfWeek(DateTime.wednesday);

      final reminderTime = DateTime(
        nextWednesday.year,
        nextWednesday.month,
        nextWednesday.day,
        settings.sunnahFastingReminderHour,
        settings.sunnahFastingReminderMinute,
      );

      await _notificationManager.scheduleNotification(
        type: NotificationType.thursdayFasting,
        title: 'Thursday Fasting Reminder',
        body:
            'Prepare for tomorrow\'s Sunnah fast. Actions are presented to Allah on Thursdays.',
        scheduledDate: reminderTime,
        payload: 'sunnah_fasting:thursday',
      );

      logger.i(
          'Thursday fasting reminder scheduled for Wednesday at ${settings.sunnahFastingReminderHour}:${settings.sunnahFastingReminderMinute.toString().padLeft(2, '0')}');
    } catch (e) {
      logger.e('Error scheduling Thursday fasting reminder: $e');
    }
  }

  /// Get the next occurrence of a specific day of the week
  DateTime _getNextDayOfWeek(int targetWeekday) {
    final now = DateTime.now();
    int daysUntilTarget = (targetWeekday - now.weekday) % 7;

    // If today is the target day but the reminder time has passed, schedule for next week
    if (daysUntilTarget == 0) {
      final settings = getIt<SharedPrefsHelper>().notificationSettingsData;
      final reminderTimeToday = DateTime(
        now.year,
        now.month,
        now.day,
        settings.sunnahFastingReminderHour,
        settings.sunnahFastingReminderMinute,
      );

      if (now.isAfter(reminderTimeToday)) {
        daysUntilTarget = 7;
      }
    }

    return now.add(Duration(days: daysUntilTarget));
  }

  /// Cancel all Sunnah fasting notifications
  Future<void> cancelSunnahFastingNotifications() async {
    try {
      await _notificationManager.cancelNotification(NotificationType.mondayFasting);
      await _notificationManager.cancelNotification(NotificationType.thursdayFasting);

      logger.i('Cancelled Sunnah fasting notifications');
    } catch (e) {
      logger.e('Error cancelling Sunnah fasting notifications: $e');
    }
  }

  /// Update notifications when settings change
  Future<void> updateNotifications() async {
    await scheduleSunnahFastingNotifications();
  }

  /// Test Sunnah fasting notification
  Future<void> testNotification({bool isMonday = true}) async {
    try {
      await _notificationManager.showNotification(
        type: NotificationType.test,
        title: isMonday ? 'Monday Fasting Reminder' : 'Thursday Fasting Reminder',
        body: isMonday
            ? 'Test: Prepare for tomorrow\'s Sunnah fast. The Prophet \u{FDFA} used to fast on Mondays.'
            : 'Test: Prepare for tomorrow\'s Sunnah fast. Actions are presented to Allah on Thursdays.',
        payload: 'sunnah_fasting:${isMonday ? 'monday' : 'thursday'}',
      );
      logger.i('Test Sunnah fasting notification sent successfully');
    } catch (e) {
      logger.e('Error sending test Sunnah fasting notification: $e');
    }
  }
}
