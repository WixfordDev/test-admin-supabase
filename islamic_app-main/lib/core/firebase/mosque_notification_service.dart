// ignore_for_file: constant_identifier_names

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:deenhub/common/prayers/prayer_times_helper.dart';
import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/features/location/data/entity/location_data.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_location_data.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';

class MosqueNotificationService {
  static const String MOSQUE_TOPIC_PREFIX = 'mosque_';
  static const String PRAYER_TIME_CHANNEL_ID = 'mosque_prayer_times';
  static const String PRAYER_TIME_CHANNEL_NAME = 'Mosque Prayer Times';
  static const String PRAYER_TIME_CHANNEL_DESC = 'Notifications for mosque prayer time updates';
  
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Use 24-hour format for internal calculations, 12-hour for display
  final DateFormat _internalTimeFormat = DateFormat('HH:mm');
  final DateFormat _displayTimeFormat = DateFormat('h:mm a');
  
  MosqueNotificationService();
  
  Future<void> initialize() async {
    // Request notification permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _localNotifications.initialize(initSettings);
    
    // Create notification channel for mosque updates
    if (kIsWeb == false) {
      const androidChannel = AndroidNotificationChannel(
        PRAYER_TIME_CHANNEL_ID,
        PRAYER_TIME_CHANNEL_NAME,
        description: PRAYER_TIME_CHANNEL_DESC,
        importance: Importance.high,
      );
      
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }
    
    // Handle FCM messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle when user taps on notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }
  
  /// Subscribe user to mosque notifications
  Future<void> subscribeToPrayerTimeUpdates(String mosqueId) async {
    final topic = '$MOSQUE_TOPIC_PREFIX$mosqueId';
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('Subscribed to mosque updates: $topic');
  }
  
  /// Unsubscribe user from mosque notifications
  Future<void> unsubscribeFromPrayerTimeUpdates(String mosqueId) async {
    final topic = '$MOSQUE_TOPIC_PREFIX$mosqueId';
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from mosque updates: $topic');
  }
  
  /// Handle message when app is in foreground
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📱 FCM Message received in foreground: ${message.messageId}');
    _processNotificationOnDevice(message);
  }
  
  /// Handle when user taps on notification
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('📱 User tapped on notification: ${message.messageId}');
    // This would navigate to mosque details screen
    // Navigation would be handled by the app's navigation system
  }
  
  /// MAIN PROCESSING: Process minimal FCM data and calculate everything on device
  Future<void> _processNotificationOnDevice(RemoteMessage message) async {
    try {
      final data = message.data;
      
      // Check if this is a mosque prayer time change notification
      if (data['type'] != 'mosque_prayer_time_change') {
        debugPrint('📱 Not a mosque prayer time notification, skipping');
        return;
      }
      
      debugPrint('📱 Processing FCM data with mosque info on device:');
      debugPrint('FCM data: $data');
      
      // Extract data from FCM payload (now includes mosque info)
      final mosqueId = data['mosque_id'] ?? '';
      final mosqueName = data['mosque_name'] ?? 'Mosque';
      final mosqueLatitude = double.tryParse(data['mosque_latitude'] ?? '') ?? 0.0;
      final mosqueLongitude = double.tryParse(data['mosque_longitude'] ?? '') ?? 0.0;
      final prayerName = data['prayer_name'] ?? '';
      final timeType = data['time_type'] ?? 'adhan';
      final adjustmentMinutes = int.tryParse(data['adjustment_minutes'] ?? '0') ?? 0;
      final previousAdjustment = int.tryParse(data['previous_adjustment'] ?? '0');
      final changeSource = data['change_source'] ?? 'user';
      final isReset = data['is_reset'] == 'true'; // Check if this is a reset operation
      
      if (mosqueId.isEmpty || prayerName.isEmpty || mosqueName.isEmpty) {
        debugPrint('📱 Missing required notification data');
        return;
      }
      
      debugPrint('📱 Mosque info from FCM: $mosqueName at ($mosqueLatitude, $mosqueLongitude)');
      debugPrint('📱 Is reset operation: $isReset');
      
      // Handle reset notifications differently
      if (isReset) {
        final notificationContent = _formatResetNotification(
          mosqueName: mosqueName,
          prayerName: prayerName,
          timeType: timeType,
          previousAdjustment: previousAdjustment,
        );
        
        // Show reset notification
        await _showDeviceProcessedNotification(
          mosqueId: mosqueId,
          title: notificationContent['title']!,
          body: notificationContent['body']!,
        );
      } else {
        // Handle normal time change notifications
        // Calculate actual prayer times on device using provided coordinates
        final timeResult = await _calculateActualPrayerTimeOnDevice(
          prayerName: prayerName,
          timeType: timeType,
          adjustmentMinutes: adjustmentMinutes,
          previousAdjustment: previousAdjustment,
          mosqueLatitude: mosqueLatitude,
          mosqueLongitude: mosqueLongitude,
        );
        
        debugPrint('📱 Calculated times: current=${timeResult['current']}, previous=${timeResult['previous']}');
        
        // Format notification message with actual times
        final notificationContent = _formatDeviceNotification(
          mosqueName: mosqueName,
          prayerName: prayerName,
          timeType: timeType,
          currentTime: timeResult['current'],
          previousTime: timeResult['previous'],
          adjustmentMinutes: adjustmentMinutes,
          previousAdjustment: previousAdjustment,
          changeSource: changeSource,
        );
        
        // Show local notification with processed data
        await _showDeviceProcessedNotification(
          mosqueId: mosqueId,
          title: notificationContent['title']!,
          body: notificationContent['body']!,
        );
      }
      
    } catch (e) {
      debugPrint('📱 Error processing notification on device: $e');
      
      // Fallback: Show simple notification if processing fails
      await _showSimpleNotification(
        title: 'Mosque Prayer Time Updated',
        body: 'A mosque prayer time has been updated. Check the app for details.',
      );
    }
  }
  
  /// Calculate actual prayer times with adjustments on the user's device
  /// Returns both current and previous times for comparison
  Future<Map<String, String?>> _calculateActualPrayerTimeOnDevice({
    required String prayerName,
    required String timeType,
    required int adjustmentMinutes,
    int? previousAdjustment,
    required double mosqueLatitude,
    required double mosqueLongitude,
  }) async {
    try {
      // Get user's prayer calculation settings
      final sharedPrefsHelper = getIt<SharedPrefsHelper>();
      final userPrayerSettings = sharedPrefsHelper.prayerLocationData;
      
      // Create location data for the mosque using user's calculation preferences
      final mosqueLocationData = LocationData(
        locName: 'Mosque Location',
        lat: mosqueLatitude,
        lng: mosqueLongitude,
        timezone: userPrayerSettings.timezone, // Use user's timezone preferences
        calculationMethod: userPrayerSettings.calculationMethod,
        asrMethod: userPrayerSettings.asrMethod,
        adjustments: List<int>.filled(7, 0), // Start with no adjustments
      );
      
      final mosquePrayerLocationData = PrayerLocationData(
        lat: mosqueLatitude,
        lng: mosqueLongitude,
        locName: 'Mosque Location',
        timezone: userPrayerSettings.timezone,
        country: userPrayerSettings.country,
        calculationMethod: userPrayerSettings.calculationMethod,
        asrMethod: userPrayerSettings.asrMethod,
      );
      
      // Calculate prayer times for today at the mosque location
      final prayerData = PrayerTimesHelper.getPrayerTimings(
        mosqueLocationData,
        mosquePrayerLocationData,
        time: DateTime.now(),
      );
      
      // Find the specific prayer
      final prayerTypeEnum = _getPrayerTypeFromString(prayerName);
      if (prayerTypeEnum == null) {
        debugPrint('📱 Unknown prayer type: $prayerName');
        return {'current': null, 'previous': null};
      }
      
      final prayer = prayerData.prayerTimes?.firstWhere(
        (p) => p.type == prayerTypeEnum,
        orElse: () => throw Exception('Prayer not found'),
      );
      
      if (prayer == null) {
        debugPrint('📱 Prayer not found: $prayerName');
        return {'current': null, 'previous': null};
      }
      
      // IMPORTANT: Always use adhan time as base for both adhan and iqamah calculations
      // Database adjustments are calculated from the original adhan time
      // For iqamah, the adjustment already includes the +15 minute offset from adhan
      final baseTime = prayer.time; // Always use adhan time as base
      
      // FIXED: Normalize base time to 0 seconds and 0 milliseconds for accurate calculations
      final normalizedBaseTime = DateTime(
        baseTime.year,
        baseTime.month,
        baseTime.day,
        baseTime.hour,
        baseTime.minute,
        0, // seconds = 0
        0, // milliseconds = 0
        0, // microseconds = 0
      );
      
      // Calculate current adjusted time
      final currentAdjustedTime = normalizedBaseTime.add(Duration(minutes: adjustmentMinutes));
      final currentTimeString = _displayTimeFormat.format(currentAdjustedTime);
      
      // Calculate previous adjusted time if available
      String? previousTimeString;
      if (previousAdjustment != null) {
        final previousAdjustedTime = normalizedBaseTime.add(Duration(minutes: previousAdjustment));
        previousTimeString = _displayTimeFormat.format(previousAdjustedTime);
      }
      
      debugPrint('📱 Base adhan time: ${_displayTimeFormat.format(normalizedBaseTime)}');
      debugPrint('📱 Time type: $timeType');
      debugPrint('📱 Current adjustment: $adjustmentMinutes min → $currentTimeString');
      debugPrint('📱 Previous adjustment: $previousAdjustment min → $previousTimeString');
      
      return {
        'current': currentTimeString,
        'previous': previousTimeString,
      };
      
    } catch (e) {
      debugPrint('📱 Error calculating prayer time on device: $e');
      return {'current': null, 'previous': null};
    }
  }
  
  /// Helper to convert prayer name string to PrayerType enum
  PrayerType? _getPrayerTypeFromString(String prayerName) {
    final name = prayerName.toLowerCase().trim();
    switch (name) {
      case 'fajr':
        return PrayerType.fajr;
      case 'dhuhr':
      case 'dhur':
        return PrayerType.dhuhr;
      case 'asr':
        return PrayerType.asr;
      case 'maghrib':
        return PrayerType.maghrib;
      case 'isha':
        return PrayerType.isha;
      default:
        return null;
    }
  }
  
  /// Format notification message with device-calculated data
  Map<String, String> _formatDeviceNotification({
    required String mosqueName,
    required String prayerName,
    required String timeType,
    String? currentTime,
    String? previousTime,
    required int adjustmentMinutes,
    int? previousAdjustment,
    required String changeSource,
  }) {
    final prayerDisplayName = prayerName.substring(0, 1).toUpperCase() + prayerName.substring(1);
    final timeTypeDisplay = timeType.toLowerCase() == 'iqamah' ? 'Iqamah' : 'Adhan';
    
    // Determine effective date
    final isUserChange = changeSource == 'user';
    final effectiveDate = isUserChange ? DateTime.now() : DateTime.now().add(const Duration(days: 1));
    final dateFormat = DateFormat('MM/dd').format(effectiveDate);
    
    String title = mosqueName;
    String body;
    
    if (isUserChange) {
      // User changes: Show time comparison if both times are available
      if (currentTime != null && previousTime != null && previousTime != currentTime) {
        body = '$prayerDisplayName $timeTypeDisplay time updated by a user: $previousTime ➝ $currentTime (effective $dateFormat).';
      } else if (currentTime != null) {
        body = '$prayerDisplayName $timeTypeDisplay time updated by a user to $currentTime (effective $dateFormat).';
      } else {
        // Fallback when time calculation fails
        final adjustText = _getAdjustmentText(adjustmentMinutes);
        body = '$prayerDisplayName $timeTypeDisplay time updated by a user ($adjustText, effective $dateFormat).';
      }
    } else {
      // System/prediction changes: Focus on upcoming change
      if (currentTime != null) {
        if (timeType.toLowerCase() == 'iqamah') {
          body = 'Iqamah times will change starting tomorrow ($dateFormat). $prayerDisplayName is expected at $currentTime.';
        } else {
          body = 'Adhan times will change starting tomorrow ($dateFormat). $prayerDisplayName is expected at $currentTime.';
        }
      } else {
        // Fallback when calculation fails
        final adjustText = _getAdjustmentText(adjustmentMinutes);
        if (timeType.toLowerCase() == 'iqamah') {
          body = 'Iqamah times will change starting tomorrow ($dateFormat). $prayerDisplayName $adjustText.';
        } else {
          body = 'Adhan times will change starting tomorrow ($dateFormat). $prayerDisplayName $adjustText.';
        }
      }
    }
    
    return {
      'title': title,
      'body': body,
    };
  }
  
  /// Get human-readable adjustment text
  String _getAdjustmentText(int adjustmentMinutes) {
    if (adjustmentMinutes == 0) {
      return 'reset to standard time';
    } else if (adjustmentMinutes > 0) {
      return 'delayed by $adjustmentMinutes min';
    } else {
      return 'advanced by ${adjustmentMinutes.abs()} min';
    }
  }

  /// Format notification message for reset operations
  Map<String, String> _formatResetNotification({
    required String mosqueName,
    required String prayerName,
    required String timeType,
    int? previousAdjustment,
  }) {
    final prayerDisplayName = prayerName.substring(0, 1).toUpperCase() + prayerName.substring(1);
    final timeTypeDisplay = timeType.toLowerCase() == 'iqamah' ? 'Iqamah' : 'Adhan';
    final dateFormat = DateFormat('MM/dd').format(DateTime.now());
    
    String title = mosqueName;
    String body;
    
    if (previousAdjustment != null && previousAdjustment != 0) {
      // Show what was reset
      final previousAdjustmentText = previousAdjustment > 0 ? 
          '+${previousAdjustment} min' : 
          '${previousAdjustment} min';
      
      body = '$prayerDisplayName $timeTypeDisplay time reset to original calculated time (was $previousAdjustmentText, effective $dateFormat).';
    } else {
      // Generic reset message
      body = '$prayerDisplayName $timeTypeDisplay time reset to original calculated time (effective $dateFormat).';
    }
    
    return {
      'title': title,
      'body': body,
    };
  }
  
  /// Show the processed notification on device
  Future<void> _showDeviceProcessedNotification({
    required String mosqueId,
    required String title,
    required String body,
  }) async {
    try {
      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          PRAYER_TIME_CHANNEL_ID,
          PRAYER_TIME_CHANNEL_NAME,
          channelDescription: PRAYER_TIME_CHANNEL_DESC,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
      
      await _localNotifications.show(
        mosqueId.hashCode, // Use mosque ID hash as notification ID
        title,
        body,
        notificationDetails,
        payload: 'mosque:$mosqueId',
      );
      
      debugPrint('📱 Device-processed notification shown:');
      debugPrint('  - Title: $title');
      debugPrint('  - Body: $body');
      
    } catch (e) {
      debugPrint('📱 Error showing processed notification: $e');
    }
  }
  
  /// Show simple fallback notification
  Future<void> _showSimpleNotification({
    required String title,
    required String body,
  }) async {
    try {
      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          PRAYER_TIME_CHANNEL_ID,
          PRAYER_TIME_CHANNEL_NAME,
          channelDescription: PRAYER_TIME_CHANNEL_DESC,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
      
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch,
        title,
        body,
        notificationDetails,
      );
      
      debugPrint('📱 Simple fallback notification shown');
      
    } catch (e) {
      debugPrint('📱 Error showing simple notification: $e');
    }
  }

  /// Test mosque notification with sample data
  Future<void> testMosqueNotification({
    String mosqueId = 'test_mosque_001',
    String mosqueName = 'Test Mosque',
    double mosqueLatitude = 40.7128,
    double mosqueLongitude = -74.0060,
    String prayerName = 'fajr',
    String timeType = 'iqamah',
    int adjustmentMinutes = 15,
    int? previousAdjustment = 10,
    String changeSource = 'user',
  }) async {
    try {
      debugPrint('🧪 Testing mosque notification with:');
      debugPrint('  - Mosque: $mosqueName ($mosqueLatitude, $mosqueLongitude)');
      debugPrint('  - Prayer: $prayerName $timeType');
      debugPrint('  - Adjustment: ${adjustmentMinutes}min (was: ${previousAdjustment ?? 'none'})');
      debugPrint('  - Source: $changeSource');

      // Create test FCM message data
      final testData = {
        'type': 'mosque_prayer_time_change',
        'mosque_id': mosqueId,
        'mosque_name': mosqueName,
        'mosque_latitude': mosqueLatitude.toString(),
        'mosque_longitude': mosqueLongitude.toString(),
        'prayer_name': prayerName,
        'time_type': timeType,
        'adjustment_minutes': adjustmentMinutes.toString(),
        'change_source': changeSource,
        'effective_date': DateTime.now().toIso8601String().split('T')[0],
      };

      if (previousAdjustment != null) {
        testData['previous_adjustment'] = previousAdjustment.toString();
      }

      // Create test remote message
      final testMessage = RemoteMessage(
        messageId: 'test_${DateTime.now().millisecondsSinceEpoch}',
        data: testData,
        notification: const RemoteNotification(
          title: 'Test Mosque Notification',
          body: 'Testing mosque prayer time notification',
        ),
      );

      // Process the test message
      await _processNotificationOnDevice(testMessage);

      debugPrint('🧪 Test mosque notification completed');
    } catch (e) {
      debugPrint('🧪 Error in test mosque notification: $e');
    }
  }

  /// Test time calculation with specific parameters
  Future<void> testTimeCalculation({
    String prayerName = 'fajr',
    String timeType = 'iqamah',
    int adjustmentMinutes = 15,
    int? previousAdjustment = 10,
    double mosqueLatitude = 40.7128,
    double mosqueLongitude = -74.0060,
  }) async {
    try {
      debugPrint('🧪 Testing time calculation with:');
      debugPrint('  - Prayer: $prayerName $timeType');
      debugPrint('  - Location: ($mosqueLatitude, $mosqueLongitude)');
      debugPrint('  - Current adjustment: ${adjustmentMinutes}min');
      debugPrint('  - Previous adjustment: ${previousAdjustment ?? 'none'}');

      final timeResult = await _calculateActualPrayerTimeOnDevice(
        prayerName: prayerName,
        timeType: timeType,
        adjustmentMinutes: adjustmentMinutes,
        previousAdjustment: previousAdjustment,
        mosqueLatitude: mosqueLatitude,
        mosqueLongitude: mosqueLongitude,
      );

      debugPrint('🧪 Time calculation results:');
      debugPrint('  - Current time: ${timeResult['current']}');
      debugPrint('  - Previous time: ${timeResult['previous']}');

      // Test notification formatting
      final notificationContent = _formatDeviceNotification(
        mosqueName: 'Test Mosque',
        prayerName: prayerName,
        timeType: timeType,
        currentTime: timeResult['current'],
        previousTime: timeResult['previous'],
        adjustmentMinutes: adjustmentMinutes,
        previousAdjustment: previousAdjustment,
        changeSource: 'user',
      );

      debugPrint('🧪 Notification formatting results:');
      debugPrint('  - Title: ${notificationContent['title']}');
      debugPrint('  - Body: ${notificationContent['body']}');

    } catch (e) {
      debugPrint('🧪 Error in test time calculation: $e');
    }
  }

  /// Validate time format consistency
  Future<void> validateTimeFormats() async {
    try {
      debugPrint('🧪 Validating time format consistency...');

      // Test various times
      final testTimes = [
        DateTime.now().copyWith(hour: 5, minute: 30), // 5:30 AM
        DateTime.now().copyWith(hour: 12, minute: 15), // 12:15 PM
        DateTime.now().copyWith(hour: 18, minute: 45), // 6:45 PM
        DateTime.now().copyWith(hour: 23, minute: 59), // 11:59 PM
      ];

      for (final testTime in testTimes) {
        final internalFormat = _internalTimeFormat.format(testTime);
        final displayFormat = _displayTimeFormat.format(testTime);
        
        debugPrint('🧪 Time: ${testTime.toString()} → Internal: $internalFormat, Display: $displayFormat');
      }

      debugPrint('🧪 Time format validation completed');
    } catch (e) {
      debugPrint('🧪 Error in time format validation: $e');
    }
  }
}

/// Format notification message for reset operations (background) - top-level function
Map<String, String> _formatBackgroundResetNotification({
  required String mosqueName,
  required String prayerName,
  required String timeType,
  int? previousAdjustment,
}) {
  final prayerDisplayName = prayerName.substring(0, 1).toUpperCase() + prayerName.substring(1);
  final timeTypeDisplay = timeType.toLowerCase() == 'iqamah' ? 'Iqamah' : 'Adhan';
  final dateFormat = DateFormat('MM/dd').format(DateTime.now());
  
  String title = mosqueName;
  String body;
  
  if (previousAdjustment != null && previousAdjustment != 0) {
    // Show what was reset
    final previousAdjustmentText = previousAdjustment > 0 ? 
        '+${previousAdjustment} min' : 
        '${previousAdjustment} min';
    
    body = '$prayerDisplayName $timeTypeDisplay time reset to original calculated time (was $previousAdjustmentText, effective $dateFormat).';
  } else {
    // Generic reset message
    body = '$prayerDisplayName $timeTypeDisplay time reset to original calculated time (effective $dateFormat).';
  }
  
  return {
    'title': title,
    'body': body,
  };
}

/// Handle background messages (must be top-level function)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('📱 FCM Background message: ${message.messageId}');
  
  try {
    final data = message.data;
    
    // Check if this is a mosque prayer time change notification
    if (data['type'] != 'mosque_prayer_time_change') {
      debugPrint('📱 Not a mosque prayer time notification, skipping background processing');
      return;
    }
    
    debugPrint('📱 Processing background FCM data:');
    debugPrint('FCM data: $data');
    
    // Extract data from FCM payload
    final mosqueId = data['mosque_id'] ?? '';
    final mosqueName = data['mosque_name'] ?? 'Mosque';
    final prayerName = data['prayer_name'] ?? '';
    final timeType = data['time_type'] ?? 'adhan';
    final adjustmentMinutes = int.tryParse(data['adjustment_minutes'] ?? '0') ?? 0;
    final previousAdjustment = int.tryParse(data['previous_adjustment'] ?? '0');
    final changeSource = data['change_source'] ?? 'user';
    final isReset = data['is_reset'] == 'true'; // Check if this is a reset operation
    
    if (mosqueId.isEmpty || prayerName.isEmpty || mosqueName.isEmpty) {
      debugPrint('📱 Missing required notification data in background');
      return;
    }
    
    // Handle reset vs normal notifications
    Map<String, String> notificationContent;
    
    if (isReset) {
      // Format reset notification
      notificationContent = _formatBackgroundResetNotification(
        mosqueName: mosqueName,
        prayerName: prayerName,
        timeType: timeType,
        previousAdjustment: previousAdjustment,
      );
    } else {
      // Format normal notification (using simplified logic for background)
      notificationContent = _formatBackgroundNotification(
        mosqueName: mosqueName,
        prayerName: prayerName,
        timeType: timeType,
        adjustmentMinutes: adjustmentMinutes,
        previousAdjustment: previousAdjustment,
        changeSource: changeSource,
      );
    }
    
    // Show background notification
    await _showBackgroundNotification(
      mosqueId: mosqueId,
      title: notificationContent['title']!,
      body: notificationContent['body']!,
    );
    
  } catch (e) {
    debugPrint('📱 Error handling background message: $e');
    
    // Show fallback notification
    await _showBackgroundNotification(
      mosqueId: 'fallback',
      title: 'Mosque Prayer Time Updated',
      body: 'A mosque prayer time has been updated. Open the app for details.',
    );
  }
}

/// Format notification message for background (simplified without time calculation)
Map<String, String> _formatBackgroundNotification({
  required String mosqueName,
  required String prayerName,
  required String timeType,
  required int adjustmentMinutes,
  int? previousAdjustment,
  required String changeSource,
}) {
  final prayerDisplayName = prayerName.substring(0, 1).toUpperCase() + prayerName.substring(1);
  final timeTypeDisplay = timeType.toLowerCase() == 'iqamah' ? 'Iqamah' : 'Adhan';
  
  // Determine effective date
  final isUserChange = changeSource == 'user';
  final effectiveDate = isUserChange ? DateTime.now() : DateTime.now().add(const Duration(days: 1));
  final dateFormat = DateFormat('MM/dd').format(effectiveDate);
  
  String title = mosqueName;
  String body;
  
  if (isUserChange) {
    // User changes: Show adjustment information
    if (previousAdjustment != null && previousAdjustment != adjustmentMinutes) {
      final changeMinutes = adjustmentMinutes - previousAdjustment;
      final changeText = changeMinutes > 0 ? 
          '$changeMinutes min later' : 
          '${changeMinutes.abs()} min earlier';
      body = '$prayerDisplayName $timeTypeDisplay time updated by a user: $changeText (effective $dateFormat).';
    } else {
      final adjustText = _getBackgroundAdjustmentText(adjustmentMinutes);
      body = '$prayerDisplayName $timeTypeDisplay time updated by a user: $adjustText (effective $dateFormat).';
    }
  } else {
    // System/prediction changes: Focus on upcoming change
    final adjustText = _getBackgroundAdjustmentText(adjustmentMinutes);
    if (timeType.toLowerCase() == 'iqamah') {
      body = 'Iqamah times will change starting tomorrow ($dateFormat). $prayerDisplayName $adjustText.';
    } else {
      body = 'Adhan times will change starting tomorrow ($dateFormat). $prayerDisplayName $adjustText.';
    }
  }
  
  return {
    'title': title,
    'body': body,
  };
}

/// Get human-readable adjustment text for background notifications
String _getBackgroundAdjustmentText(int adjustmentMinutes) {
  if (adjustmentMinutes == 0) {
    return 'reset to standard time';
  } else if (adjustmentMinutes > 0) {
    return 'delayed by $adjustmentMinutes min';
  } else {
    return 'advanced by ${adjustmentMinutes.abs()} min';
  }
}

/// Show notification in background (must use Flutter Local Notifications)
Future<void> _showBackgroundNotification({
  required String mosqueId,
  required String title,
  required String body,
}) async {
  try {
    // Initialize local notifications for background use
    final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
    
    // Initialize if not already done
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await localNotifications.initialize(initSettings);
    
    // Create notification channel
    const androidChannel = AndroidNotificationChannel(
      'mosque_prayer_times',
      'Mosque Prayer Times',
      description: 'Notifications for mosque prayer time updates',
      importance: Importance.high,
    );
    
    await localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
    
    // Show notification
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'mosque_prayer_times',
        'Mosque Prayer Times',
        channelDescription: 'Notifications for mosque prayer time updates',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    
    await localNotifications.show(
      mosqueId.hashCode, // Use mosque ID hash as notification ID
      title,
      body,
      notificationDetails,
      payload: 'mosque:$mosqueId',
    );
    
    debugPrint('📱 Background notification shown:');
    debugPrint('  - Title: $title');
    debugPrint('  - Body: $body');
    
  } catch (e) {
    debugPrint('📱 Error showing background notification: $e');
  }
} 