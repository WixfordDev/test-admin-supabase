import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:deenhub/core/notification/notification_types.dart';
import 'package:deenhub/core/notification/notification_navigation_service.dart';
import 'package:deenhub/main.dart';

/// Core notification manager that handles all notification operations
/// Uses singleton pattern with factory constructor for better control
class NotificationManager {
  // Singleton implementation using factory constructor
  static NotificationManager? _instance;
  factory NotificationManager() =>
      _instance ??= NotificationManager._internal();
  NotificationManager._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Check if notification manager is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the notification manager
  @pragma("vm:entry-point")
  Future<void> initialize() async {
    if (_isInitialized) {
      logger.w('NotificationManager already initialized');
      return;
    }

    try {
      await _flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestSoundPermission: false,
            requestBadgePermission: false,
            requestAlertPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: _onNotificationTapped,
        onDidReceiveBackgroundNotificationResponse: _onNotificationTapped,
      );

      // Create all notification channels
      await _createAllNotificationChannels();

      _isInitialized = true;
      logger.i('NotificationManager initialized successfully');
    } catch (e) {
      logger.e('Failed to initialize NotificationManager: $e');
      rethrow;
    }
  }

  /// Handle notification tap events
  @pragma("vm:entry-point")
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    logger.i('Notification tapped: $payload');
    if (payload != null) {
      NotificationNavigationService.handleNavigation(payload);
    }
  }

  /// Request notification permissions
  @pragma("vm:entry-point")
  Future<bool> requestPermissions() async {
    try {
      bool? result;

      if (Platform.isAndroid) {
        final androidImplementation = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        result = await androidImplementation?.requestNotificationsPermission();

        // Also request exact alarm permission for Android
        await androidImplementation?.requestExactAlarmsPermission();
      } else if (Platform.isIOS) {
        final iosImplementation = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();

        result = await iosImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      logger.i('Notification permission result: $result');
      return result ?? false;
    } catch (e) {
      logger.e('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Create a notification channel
  @pragma("vm:entry-point")
  Future<void> createNotificationChannel({
    required String channelId,
    required String channelName,
    required String channelDescription,
    Importance importance = Importance.defaultImportance,
    bool enableVibration = true,
    bool playSound = true,
    AndroidNotificationSound? sound,
  }) async {
    if (!Platform.isAndroid) return;

    final androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: importance,
      sound: sound,
      enableVibration: enableVibration,
      playSound: playSound,
      showBadge: true,
      audioAttributesUsage: sound != null
          ? AudioAttributesUsage.alarm
          : AudioAttributesUsage.notification,
      enableLights: true,
      ledColor: const Color(0xFF00FF00),
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Delete a notification channel
  @pragma("vm:entry-point")
  Future<void> deleteNotificationChannel(String channelId) async {
    if (!Platform.isAndroid) return;

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannel(channelId);
  }

  /// Show an immediate notification
  @pragma("vm:entry-point")
  Future<void> showNotification({
    required NotificationType type,
    required String title,
    required String body,
    String? payload,
    AndroidNotificationSound? sound,
    bool fullScreenIntent = false,
    bool ongoing = false,
    bool autoCancel = true,
    String? bigPicture,
  }) async {
    if (!_isInitialized) {
      logger.e('NotificationManager not initialized');
      return;
    }

    try {
      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          type.channel,
          _getChannelName(type.channel),
          channelDescription: _getChannelDescription(type.channel),
          importance: type.priority.importance,
          priority: type.priority.priority,
          sound: sound,
          fullScreenIntent: fullScreenIntent,
          ongoing: ongoing,
          autoCancel: autoCancel,
          playSound: sound != null,
          enableVibration: true,
          visibility: NotificationVisibility.public,
          styleInformation: bigPicture != null
              ? BigPictureStyleInformation(FilePathAndroidBitmap(bigPicture))
              : null,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: sound != null ? _getIOSSoundName(sound) : 'default.caf',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      );

      await _flutterLocalNotificationsPlugin.show(
        type.id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      logger.d('Notification shown: ${type.name} - $title');
    } catch (e) {
      logger.e('Error showing notification: $e');
    }
  }

  /// Schedule a notification
  @pragma("vm:entry-point")
  Future<void> scheduleNotification({
    required NotificationType type,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    AndroidNotificationSound? sound,
    bool fullScreenIntent = false,
    String?
        timezone, // Optional timezone, falls back to tz.local if not provided
  }) async {
    return scheduleNotificationWithId(
      id: type.id,
      type: type,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
      sound: sound,
      fullScreenIntent: fullScreenIntent,
      timezone: timezone,
    );
  }

  /// Schedule a notification with a specific ID
  @pragma("vm:entry-point")
  Future<void> scheduleNotificationWithId({
    required int id,
    required NotificationType type,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    AndroidNotificationSound? sound,
    bool fullScreenIntent = false,
    String?
        timezone, // Optional timezone, falls back to tz.local if not provided
  }) async {
    if (!_isInitialized) {
      logger.e('NotificationManager not initialized');
      return;
    }

    try {
      // Ensure precise timing by creating a normalized DateTime first
      final normalizedDate = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        scheduledDate.hour,
        scheduledDate.minute,
        0, // Exactly 0 seconds
        0, // Exactly 0 milliseconds
        0, // Exactly 0 microseconds
      );

      // Use provided timezone or fall back to device local timezone
      final tz.Location targetTimezone =
          timezone != null ? tz.getLocation(timezone) : tz.local;

      final tz.TZDateTime tzScheduledDate =
          tz.TZDateTime.from(normalizedDate, targetTimezone);

      // Check if scheduled time is in the past using the same timezone
      final now = tz.TZDateTime.now(targetTimezone);
      if (tzScheduledDate.isBefore(now)) {
        logger.w(
            'Notification scheduled in the past: $tzScheduledDate, current: $now');

        // Check if this is a recursive call (avoid infinite loops)
        final timeDifference = now.difference(tzScheduledDate).inMinutes;
        if (timeDifference > 60) { // More than 1 hour in the past
          logger.e('Notification scheduled too far in the past ($timeDifference minutes), skipping');
          return;
        }

        // For most cases, we'll schedule it a bit later instead
        final adjustedTime = now.add(const Duration(minutes: 1));
        return scheduleNotification(
          type: type,
          title: title,
          body: body,
          scheduledDate: adjustedTime.toLocal(),
          payload: payload,
          sound: sound,
          fullScreenIntent: fullScreenIntent,
          timezone: timezone, // Preserve timezone when rescheduling
        );
      }

      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          type.channel,
          _getChannelName(type.channel),
          channelDescription: _getChannelDescription(type.channel),
          importance: type.priority.importance,
          priority: type.priority.priority,
          sound: sound,
          fullScreenIntent: fullScreenIntent,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          autoCancel: true,
          ongoing: false,
          playSound: sound != null,
          enableVibration: true,
          onlyAlertOnce: false,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: sound != null,
          sound: sound != null ? _getIOSSoundName(sound) : 'default.caf',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      // Enhanced logging with precise timing details
      final formattedTime =
          '${tzScheduledDate.hour.toString().padLeft(2, '0')}:${tzScheduledDate.minute.toString().padLeft(2, '0')}:${tzScheduledDate.second.toString().padLeft(2, '0')}';
      final timezoneInfo = timezone ?? 'device_local';
      logger.i(
          '✅ Notification scheduled: ${type.name} (ID: $id) at $tzScheduledDate ($formattedTime) in $timezoneInfo timezone - Exact timing enforced');
    } catch (e) {
      logger.e('Error scheduling notification: $e');
    }
  }

  /// Cancel a specific notification
  @pragma("vm:entry-point")
  Future<void> cancelNotification(NotificationType type) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(type.id);
      logger.d('Notification cancelled: ${type.name}');
    } catch (e) {
      logger.e('Error cancelling notification: $e');
    }
  }

  /// Cancel a notification by specific ID
  @pragma("vm:entry-point")
  Future<void> cancelNotificationById(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      logger.d('Notification cancelled by ID: $id');
    } catch (e) {
      logger.e('Error cancelling notification by ID $id: $e');
    }
  }

  /// Cancel all notifications
  @pragma("vm:entry-point")
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      logger.i('All notifications cancelled');
    } catch (e) {
      logger.e('Error cancelling all notifications: $e');
    }
  }

  /// Get pending notifications
  @pragma("vm:entry-point")
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
    } catch (e) {
      logger.e('Error getting pending notifications: $e');
      return [];
    }
  }

  /// Get notification launch details
  @pragma("vm:entry-point")
  Future<NotificationAppLaunchDetails?>
      getNotificationAppLaunchDetails() async {
    try {
      return await _flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();
    } catch (e) {
      logger.e('Error getting notification launch details: $e');
      return null;
    }
  }

  @pragma("vm:entry-point")
  Future<String?> getNotificationLaunchPayload() async {
    try {
      final NotificationAppLaunchDetails? notificationAppLaunchDetails =
          await getNotificationAppLaunchDetails();

      if (notificationAppLaunchDetails?.didNotificationLaunchApp == true) {
        return notificationAppLaunchDetails?.notificationResponse?.payload;
      }
      return null;
    } catch (e) {
      logger.e('Error getting notification launch payload: $e');
      return null;
    }
  }

  /// Create all notification channels
  @pragma("vm:entry-point")
  Future<void> _createAllNotificationChannels() async {
    // Prayer channels
    await createNotificationChannel(
      channelId: 'fajr_prayer',
      channelName: 'Fajr Prayer',
      channelDescription: 'Notifications for Fajr prayer time',
      importance: Importance.high,
      sound: const RawResourceAndroidNotificationSound("res_azan_fajr"),
    );

    await createNotificationChannel(
      channelId: 'other_prayers',
      channelName: 'Prayer Times',
      channelDescription:
          'Notifications for Dhuhr, Asr, Maghrib, and Isha prayer times',
      importance: Importance.high,
      sound: const RawResourceAndroidNotificationSound("res_azan"),
    );

    await createNotificationChannel(
      channelId: 'qiyam_prayer',
      channelName: 'Qiyam Prayer',
      channelDescription: 'Notifications for Qiyam prayer time',
      importance: Importance.high,
    );

    await createNotificationChannel(
      channelId: 'before_prayer',
      channelName: 'Before Prayer Reminders',
      channelDescription: 'Notifications for before prayer reminders',
      importance: Importance.high,
    );

    // Daily goals channels
    await createNotificationChannel(
      channelId: 'daily_goals',
      channelName: 'Daily Goals',
      channelDescription: 'Reminders for your daily Islamic goals',
      importance: Importance.defaultImportance,
    );

    await createNotificationChannel(
      channelId: 'goal_completion',
      channelName: 'Goal Completion',
      channelDescription: 'Celebrations for completed goals',
      importance: Importance.max,
    );

    await createNotificationChannel(
      channelId: 'motivation',
      channelName: 'Motivation',
      channelDescription: 'Daily motivational reminders',
      importance: Importance.defaultImportance,
    );

    // Special notification channels
    await createNotificationChannel(
      channelId: 'friday_kahf',
      channelName: 'Friday Surah Al-Kahf',
      channelDescription: 'Notifications for Friday Surah Al-Kahf reminder',
      importance: Importance.high,
    );

    await createNotificationChannel(
      channelId: 'memorization_reminder',
      channelName: 'Memorization Reminders',
      channelDescription: 'Notifications for memorization progress reminders',
      importance: Importance.high,
    );

    await createNotificationChannel(
      channelId: 'sunnah_fasting',
      channelName: 'Sunnah Fasting Reminders',
      channelDescription:
          'Notifications for Monday and Thursday Sunnah fasting reminders',
      importance: Importance.high,
    );

    await createNotificationChannel(
      channelId: 'zakat_reminder',
      channelName: 'Zakat Reminders',
      channelDescription: 'Annual reminders for Zakat calculation and payment',
      importance: Importance.high,
    );

    await createNotificationChannel(
      channelId: 'sunnah_reminders',
      channelName: 'Sunnah Reminders',
      channelDescription:
          'Reminders for recommended Islamic practices like Surah Al-Mulk',
      importance: Importance.defaultImportance,
    );

    await createNotificationChannel(
      channelId: 'subscription',
      channelName: 'Subscription Notifications',
      channelDescription: 'Notifications for subscription updates and benefits',
      importance: Importance.high,
    );

    // System channels
    await createNotificationChannel(
      channelId: 'silent',
      channelName: 'Silent notifications',
      channelDescription: 'Silent notification channel for internal operations',
      importance: Importance.low,
      playSound: false,
    );

    // Test channel
    await createNotificationChannel(
      channelId: 'test',
      channelName: 'Test Notifications',
      channelDescription: 'Test notification channel for debugging',
      importance: Importance.defaultImportance,
    );
  }

  /// Get channel name for a channel ID
  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'fajr_prayer':
        return 'Fajr Prayer';
      case 'other_prayers':
        return 'Prayer Times';
      case 'qiyam_prayer':
        return 'Qiyam Prayer';
      case 'before_prayer':
        return 'Before Prayer Reminders';
      case 'daily_goals':
        return 'Daily Goals';
      case 'goal_completion':
        return 'Goal Completion';
      case 'motivation':
        return 'Motivation';
      case 'friday_kahf':
        return 'Friday Surah Al-Kahf';
      case 'memorization_reminder':
        return 'Memorization Reminders';
      case 'sunnah_fasting':
        return 'Sunnah Fasting Reminders';
      case 'zakat_reminder':
        return 'Zakat Reminders';
      case 'sunnah_reminders':
        return 'Sunnah Reminders';
      case 'subscription':
        return 'Subscription Notifications';
      case 'silent':
        return 'Silent notifications';
      case 'test':
        return 'Test Notifications';
      default:
        return 'DeenHub Notifications';
    }
  }

  /// Get channel description for a channel ID
  @pragma("vm:entry-point")
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'fajr_prayer':
        return 'Notifications for Fajr prayer time';
      case 'other_prayers':
        return 'Notifications for Dhuhr, Asr, Maghrib, and Isha prayer times';
      case 'qiyam_prayer':
        return 'Notifications for Qiyam prayer time';
      case 'before_prayer':
        return 'Notifications for before prayer reminders';
      case 'daily_goals':
        return 'Reminders for your daily Islamic goals';
      case 'goal_completion':
        return 'Celebrations for completed goals';
      case 'motivation':
        return 'Daily motivational reminders';
      case 'friday_kahf':
        return 'Notifications for Friday Surah Al-Kahf reminder';
      case 'memorization_reminder':
        return 'Notifications for memorization progress reminders';
      case 'sunnah_fasting':
        return 'Notifications for Monday and Thursday Sunnah fasting reminders';
      case 'zakat_reminder':
        return 'Annual reminders for Zakat calculation and payment';
      case 'sunnah_reminders':
        return 'Reminders for recommended Islamic practices like Surah Al-Mulk';
      case 'subscription':
        return 'Notifications for subscription updates and benefits';
      case 'silent':
        return 'Silent notification channel for internal operations';
      case 'test':
        return 'Test notification channel for debugging';
      default:
        return 'DeenHub notification channel';
    }
  }

  /// Convert Android sound to iOS sound name
  @pragma("vm:entry-point")
  String _getIOSSoundName(AndroidNotificationSound sound) {
    return '${sound.sound}.caf';
  }
}
