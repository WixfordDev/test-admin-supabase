import 'package:deenhub/core/notification/notification_manager.dart';
import 'package:deenhub/core/notification/notification_types.dart';
import 'package:deenhub/main.dart';

/// Modern Friday Kahf notification service using the centralized NotificationManager
class FridayKahfNotificationService {
  // Singleton implementation
  static FridayKahfNotificationService? _instance;
  factory FridayKahfNotificationService() => _instance ??= FridayKahfNotificationService._internal();
  FridayKahfNotificationService._internal();

  final NotificationManager _notificationManager = NotificationManager();

  /// Initialize the Friday Kahf notification service
  Future<void> initialize() async {
    logger.i('Initializing Friday Kahf Notification Service...');
    
    // Ensure notification manager is initialized
    if (!_notificationManager.isInitialized) {
      await _notificationManager.initialize();
    }
    
    // Schedule Friday Kahf notifications
    await scheduleFridayKahfNotifications();
    
    logger.i('Friday Kahf Notification Service initialized successfully');
  }

  /// Schedule Friday Kahf notifications
  Future<void> scheduleFridayKahfNotifications() async {
    try {
      // Cancel any existing Friday Kahf notifications
      await cancelFridayKahfNotifications();

      // Find the next Friday
      final nextFriday = _getNextFriday();

      // Schedule morning notification at 8:00 AM every Friday
      final morningNotificationTime = DateTime(
        nextFriday.year,
        nextFriday.month,
        nextFriday.day,
        8, // 8:00 AM
        0, // 0 minutes
      );

      await _notificationManager.scheduleNotification(
        type: NotificationType.fridayKahfMorning,
        title: 'Friday Morning Reminder 🌅',
        body: 'Start your blessed Friday by reading Surah Al-Kahf',
        scheduledDate: morningNotificationTime,
        payload: 'friday_kahf:18',
      );

      // Schedule noon notification at 12:00 PM every Friday
      final noonNotificationTime = DateTime(
        nextFriday.year,
        nextFriday.month,
        nextFriday.day,
        12, // 12:00 PM
        0, // 0 minutes
      );

      await _notificationManager.scheduleNotification(
        type: NotificationType.fridayKahfNoon,
        title: 'Friday Noon Reminder ☀️',
        body: 'Don\'t miss the blessing! Read Surah Al-Kahf before Jummah',
        scheduledDate: noonNotificationTime,
        payload: 'friday_kahf:18',
      );

      logger.i('Friday Surah Al-Kahf notifications scheduled for: 8:00 AM and 12:00 PM every Friday');
    } catch (e) {
      logger.e('Error scheduling Friday Surah Al-Kahf notifications: $e');
    }
  }

  /// Cancel Friday Kahf notifications
  Future<void> cancelFridayKahfNotifications() async {
    try {
      await _notificationManager.cancelNotification(NotificationType.fridayKahfMorning);
      await _notificationManager.cancelNotification(NotificationType.fridayKahfNoon);
      
      logger.i('Cancelled Friday Kahf notifications');
    } catch (e) {
      logger.e('Error cancelling Friday Kahf notifications: $e');
    }
  }

  /// Get the next Friday date (or today if it's Friday and notifications haven't passed)
  DateTime _getNextFriday() {
    final now = DateTime.now();
    final daysUntilFriday = (DateTime.friday - now.weekday) % 7;

    // If today is Friday
    if (daysUntilFriday == 0) {
      // Check if the noon notification time has already passed
      final noonNotificationTime = DateTime(now.year, now.month, now.day, 12, 0);
      if (now.isBefore(noonNotificationTime)) {
        // Today is Friday and notifications haven't all passed, use today
        return DateTime(now.year, now.month, now.day);
      } else {
        // All Friday notifications have passed, schedule for next Friday
        final nextFriday = now.add(const Duration(days: 7));
        return DateTime(nextFriday.year, nextFriday.month, nextFriday.day);
      }
    }

    // Not Friday, calculate next Friday
    final nextFriday = now.add(Duration(days: daysUntilFriday));
    return DateTime(nextFriday.year, nextFriday.month, nextFriday.day);
  }

  /// Schedule a custom Friday Kahf reminder
  Future<void> scheduleCustomFridayKahfReminder({
    required DateTime reminderTime,
    String? customTitle,
    String? customBody,
  }) async {
    try {
      // Only schedule if it's a Friday
      if (reminderTime.weekday != DateTime.friday) {
        logger.w('Custom reminder time is not on a Friday, skipping');
        return;
      }

      await _notificationManager.scheduleNotification(
        type: NotificationType.fridayKahfMorning, // Reuse the morning type
        title: customTitle ?? 'Friday Surah Al-Kahf Reminder',
        body: customBody ?? 'Time to read Surah Al-Kahf for Friday\'s blessings',
        scheduledDate: reminderTime,
        payload: 'friday_kahf:18',
      );

      logger.i('Custom Friday Kahf reminder scheduled for $reminderTime');
    } catch (e) {
      logger.e('Error scheduling custom Friday Kahf reminder: $e');
    }
  }

  /// Test Friday Kahf notification
  Future<void> testNotification() async {
    try {
      await _notificationManager.showNotification(
        type: NotificationType.test,
        title: 'Test Friday Kahf Notification',
        body: 'Friday Kahf notification system is working correctly!',
        payload: 'friday_kahf:18',
      );
      logger.i('Test Friday Kahf notification sent successfully');
    } catch (e) {
      logger.e('Error sending test Friday Kahf notification: $e');
    }
  }
} 