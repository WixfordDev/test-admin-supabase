import 'package:deenhub/core/notification/notification_manager.dart';
import 'package:deenhub/core/notification/notification_types.dart';
import 'package:deenhub/main.dart';

/// Modern memorization reminder service using the centralized NotificationManager
class MemorizationReminderService {
  // Singleton implementation
  static MemorizationReminderService? _instance;
  factory MemorizationReminderService() => _instance ??= MemorizationReminderService._internal();
  MemorizationReminderService._internal();

  final NotificationManager _notificationManager = NotificationManager();

  /// Initialize the memorization reminder service
  Future<void> initialize() async {
    logger.i('Initializing Memorization Reminder Service...');
    
    // Ensure notification manager is initialized
    if (!_notificationManager.isInitialized) {
      await _notificationManager.initialize();
    }
    
    logger.i('Memorization Reminder Service initialized successfully');
  }

  /// Schedule memorization reminder
  Future<void> scheduleMemorizationReminder({
    required int surahNumber,
    required int verseNumber,
    required String surahName,
    DateTime? reminderTime,
    String? customMessage,
  }) async {
    try {
      // Cancel any existing memorization reminder
      await cancelMemorizationReminder();

      // Use provided time or default to 10 minutes from now
      final scheduleTime = reminderTime ?? DateTime.now().add(const Duration(minutes: 10));

      final message = customMessage ?? 
          'Continue memorizing $surahName, Verse $verseNumber. Tap to resume your practice!';

      await _notificationManager.scheduleNotification(
        type: NotificationType.memorizationReminder,
        title: 'Memorization Reminder 📖',
        body: message,
        scheduledDate: scheduleTime,
        payload: 'memorization:$surahNumber:$verseNumber',
      );

      logger.i('Scheduled memorization reminder for $surahName verse $verseNumber at $scheduleTime');
    } catch (e) {
      logger.e('Error scheduling memorization reminder: $e');
    }
  }

  /// Schedule daily memorization reminder
  Future<void> scheduleDailyMemorizationReminder({
    required int surahNumber,
    required int verseNumber,
    required String surahName,
    required int hour,
    required int minute,
    String? customMessage,
  }) async {
    try {
      // Cancel any existing memorization reminder
      await cancelMemorizationReminder();

      final now = DateTime.now();
      var scheduleTime = DateTime(now.year, now.month, now.day, hour, minute);
      
      // If time has passed today, schedule for tomorrow
      if (scheduleTime.isBefore(now)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      final message = customMessage ?? 
          'Daily memorization practice: $surahName, Verse $verseNumber. Continue your journey!';

      await _notificationManager.scheduleNotification(
        type: NotificationType.memorizationReminder,
        title: 'Daily Memorization 📚',
        body: message,
        scheduledDate: scheduleTime,
        payload: 'memorization:$surahNumber:$verseNumber',
      );

      logger.i('Scheduled daily memorization reminder for $surahName at $hour:${minute.toString().padLeft(2, '0')}');
    } catch (e) {
      logger.e('Error scheduling daily memorization reminder: $e');
    }
  }

  /// Schedule memorization review reminder
  Future<void> scheduleMemorizationReview({
    required List<int> surahNumbers,
    required DateTime reminderTime,
    String? customMessage,
  }) async {
    try {
      final surahsText = surahNumbers.length > 1 
          ? '${surahNumbers.length} surahs'
          : 'Surah ${surahNumbers.first}';
      
      final message = customMessage ?? 
          'Time to review your memorized $surahsText. Consistent review strengthens your hifz!';

      await _notificationManager.scheduleNotification(
        type: NotificationType.memorizationReminder,
        title: 'Memorization Review 🔄',
        body: message,
        scheduledDate: reminderTime,
        payload: 'memorization_review:${surahNumbers.join(',')}',
      );

      logger.i('Scheduled memorization review reminder for $surahsText at $reminderTime');
    } catch (e) {
      logger.e('Error scheduling memorization review reminder: $e');
    }
  }

  /// Schedule weekly memorization goal reminder
  Future<void> scheduleWeeklyGoalReminder({
    required String goalDescription,
    int dayOfWeek = DateTime.sunday, // Default to Sunday
    int hour = 9, // Default to 9 AM
    int minute = 0,
  }) async {
    try {
      final now = DateTime.now();
      var scheduleTime = DateTime(now.year, now.month, now.day, hour, minute);
      
      // Find next occurrence of the specified day
      while (scheduleTime.weekday != dayOfWeek) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }
      
      // If we're on the target day but past the time, schedule for next week
      if (now.weekday == dayOfWeek && now.hour >= hour) {
        scheduleTime = scheduleTime.add(const Duration(days: 7));
      }

      await _notificationManager.scheduleNotification(
        type: NotificationType.memorizationReminder,
        title: 'Weekly Memorization Goal 🎯',
        body: 'Time to review your memorization progress: $goalDescription',
        scheduledDate: scheduleTime,
        payload: 'memorization_weekly_goal',
      );

      logger.i('Scheduled weekly memorization goal reminder for ${_getDayName(dayOfWeek)} at $hour:${minute.toString().padLeft(2, '0')}');
    } catch (e) {
      logger.e('Error scheduling weekly memorization goal reminder: $e');
    }
  }

  /// Cancel memorization reminder
  Future<void> cancelMemorizationReminder() async {
    try {
      await _notificationManager.cancelNotification(NotificationType.memorizationReminder);
      logger.i('Cancelled memorization reminder');
    } catch (e) {
      logger.e('Error cancelling memorization reminder: $e');
    }
  }

  /// Show immediate memorization encouragement
  Future<void> showMemorizationEncouragement({
    required String surahName,
    required int versesMemorized,
    String? customMessage,
  }) async {
    try {
      final message = customMessage ?? _getEncouragementMessage(surahName, versesMemorized);

      await _notificationManager.showNotification(
        type: NotificationType.memorizationReminder,
        title: 'Memorization Progress! 🌟',
        body: message,
        payload: 'memorization_encouragement',
      );

      logger.i('Showed memorization encouragement for $surahName');
    } catch (e) {
      logger.e('Error showing memorization encouragement: $e');
    }
  }

  /// Get encouragement message based on progress
  String _getEncouragementMessage(String surahName, int versesMemorized) {
    if (versesMemorized <= 5) {
      return 'Great start with $surahName! You\'ve memorized $versesMemorized verses. Keep going!';
    } else if (versesMemorized <= 10) {
      return 'Excellent progress with $surahName! $versesMemorized verses memorized. You\'re building momentum!';
    } else if (versesMemorized <= 20) {
      return 'Masha Allah! $versesMemorized verses of $surahName completed. Your dedication is inspiring!';
    } else {
      return 'Subhan Allah! You\'ve memorized $versesMemorized verses of $surahName. May Allah reward your efforts!';
    }
  }

  /// Get day name from day number
  String _getDayName(int dayOfWeek) {
    const days = [
      '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return days[dayOfWeek];
  }

  /// Test memorization notification
  Future<void> testNotification() async {
    try {
      await _notificationManager.showNotification(
        type: NotificationType.test,
        title: 'Test Memorization Notification',
        body: 'Memorization reminder system is working correctly!',
        payload: 'memorization:1:1',
      );
      logger.i('Test memorization notification sent successfully');
    } catch (e) {
      logger.e('Error sending test memorization notification: $e');
    }
  }
} 