import 'package:deenhub/core/notification/notification_manager.dart';
import 'package:deenhub/core/notification/notification_types.dart';
import 'package:deenhub/main.dart';

/// Modern Zakat notification service using the centralized NotificationManager
class ZakatNotificationService {
  // Singleton implementation
  static ZakatNotificationService? _instance;
  factory ZakatNotificationService() => _instance ??= ZakatNotificationService._internal();
  ZakatNotificationService._internal();

  final NotificationManager _notificationManager = NotificationManager();

  /// Initialize the Zakat notification service
  Future<void> initialize() async {
    logger.i('Initializing Zakat Notification Service...');
    
    // Ensure notification manager is initialized
    if (!_notificationManager.isInitialized) {
      await _notificationManager.initialize();
    }
    
    logger.i('Zakat Notification Service initialized successfully');
  }

  /// Schedule Zakat reminder notification
  Future<void> scheduleZakatReminder({
    required DateTime reminderDate,
    required double zakatAmount,
    String? customTitle,
    String? customBody,
  }) async {
    try {
      // Cancel any existing Zakat reminder
      await cancelZakatReminder();

      final title = customTitle ?? 'Zakat Reminder 🌙';
      final body = customBody ?? 
          'It\'s time to calculate and pay your Zakat for this year. Last calculated amount: \$${zakatAmount.toStringAsFixed(2)}';

      await _notificationManager.scheduleNotification(
        type: NotificationType.zakatReminder,
        title: title,
        body: body,
        scheduledDate: reminderDate,
        payload: 'zakat_reminder',
      );

      logger.i('Scheduled Zakat reminder for $reminderDate with amount \$${zakatAmount.toStringAsFixed(2)}');
    } catch (e) {
      logger.e('Error scheduling Zakat reminder: $e');
    }
  }

  /// Cancel Zakat reminder
  Future<void> cancelZakatReminder() async {
    try {
      await _notificationManager.cancelNotification(NotificationType.zakatReminder);
      logger.i('Cancelled Zakat reminder');
    } catch (e) {
      logger.e('Error cancelling Zakat reminder: $e');
    }
  }

  /// Test Zakat notification
  Future<void> testNotification() async {
    try {
      await _notificationManager.showNotification(
        type: NotificationType.test,
        title: 'Test Zakat Notification',
        body: 'Zakat notification system is working correctly!',
        payload: 'zakat_test',
      );
      logger.i('Test Zakat notification sent successfully');
    } catch (e) {
      logger.e('Error sending test Zakat notification: $e');
    }
  }
}