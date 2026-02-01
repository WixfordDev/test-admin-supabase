import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:deenhub/core/notification/notification_manager.dart';
import 'package:deenhub/core/notification/notification_types.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/common/prayers/prayer_times_helper.dart';
import 'package:deenhub/features/location/data/entity/location_data.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_item.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_location_data.dart';
import 'package:deenhub/features/settings/data/entity/notification_settings_data.dart';
import 'package:deenhub/main.dart';

/// Modern prayer notification service using the centralized NotificationManager
class PrayerNotificationService {
  // Singleton implementation
  static PrayerNotificationService? _instance;
  factory PrayerNotificationService() =>
      _instance ??= PrayerNotificationService._internal();
  PrayerNotificationService._internal();

  final NotificationManager _notificationManager = NotificationManager();
  Timer? _schedulingTimer;
  bool _isScheduling = false;
  DateTime? _lastScheduledDate;
  Set<int> _scheduledNotificationIds = <int>{};

  /// Initialize the prayer notification service
  Future<void> initialize() async {
    logger.i('Initializing Prayer Notification Service...');

    // Ensure notification manager is initialized
    if (!_notificationManager.isInitialized) {
      await _notificationManager.initialize();
    }

    // Request permissions
    final hasPermission = await _notificationManager.requestPermissions();
    if (!hasPermission) {
      logger.w('Notification permissions not granted');
      return;
    }

    // Restore persisted state
    await _restorePersistedState();

    // Schedule today's notifications
    await _scheduleTodayNotifications();

    // Setup daily scheduler
    await _setupDailyScheduler();

    logger.i('Prayer Notification Service initialized successfully');
  }

  /// Schedule all prayer notifications for today
  Future<void> _scheduleTodayNotifications() async {
    // Prevent concurrent scheduling
    if (_isScheduling) {
      logger.w('Notification scheduling already in progress, skipping');
      return;
    }

    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    
    // Skip if already scheduled for today
    if (_lastScheduledDate != null && 
        DateTime(_lastScheduledDate!.year, _lastScheduledDate!.month, _lastScheduledDate!.day) == todayKey) {
      logger.i('Notifications already scheduled for today, skipping');
      return;
    }

    _isScheduling = true;
    
    try {
      final prefsHelper = getIt<SharedPrefsHelper>();
      final prayerLocationData = prefsHelper.prayerLocationDataOrNull;
      if (prayerLocationData == null) {
        logger.w('No prayer location data available; skipping scheduling');
        return;
      }
      final notificationSettings = prefsHelper.notificationSettingsData;

      if (!notificationSettings.masterSwitch) {
        logger.i('Prayer notifications are disabled globally');
        return;
      }

      // Clear any existing notifications first
      await _clearAllExistingNotifications();

      // Create location data from prayer location data
      final tempLocationData = LocationData(
        locName: prayerLocationData.locName,
        lat: prayerLocationData.lat,
        lng: prayerLocationData.lng,
        timezone: prayerLocationData.timezone,
        calculationMethod: prayerLocationData.calculationMethod,
        asrMethod: prayerLocationData.asrMethod,
        adjustments: getDefaultAdjustments(),
      );

      // Get prayer timings for today
      final prayerTypesList = getMandatoryPrayersList().toList()
        ..add(PrayerType.qiyam);
      final prayerData = PrayerTimesHelper.getPrayerTimings(
        tempLocationData,
        prayerLocationData,
        time: DateTime.now(),
        prayerTypesList: prayerTypesList,
      );

      final prayerItems = prayerData.prayerTimes ?? [];

      // Schedule notifications for each prayer
      await _schedulePrayerNotifications(
          prayerItems, prayerLocationData, notificationSettings);

      // Schedule Surah Al-Mulk reminder (30 minutes after Isha)
      await _scheduleSurahMulkReminder(prayerItems);

      // Update tracking and persist state
      _lastScheduledDate = today;
      _persistState();
      logger.i('Successfully scheduled today\'s prayer notifications');
    } catch (e) {
      logger.e('Error scheduling today\'s notifications: $e');
    } finally {
      _isScheduling = false;
    }
  }

  /// Schedule prayer notifications for the given prayer items
  Future<void> _schedulePrayerNotifications(
    List<PrayerItem> prayerItems,
    PrayerLocationData locationData,
    NotificationSettingsData settings,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final prayer in prayerItems) {
      if (!settings.isPrayerEnabled(prayer.type)) {
        continue;
      }

      // Skip past prayer times
      if (prayer.time.isBefore(now)) {
        continue;
      }

      // Schedule main prayer notification
      if (settings.notifyOnPrayerTime) {
        await _schedulePrayerNotification(
          prayer: prayer,
          locationData: locationData,
          settings: settings,
          isBeforeReminder: false,
          scheduledDate: today,
        );
      }

      // Schedule before-prayer notification
      if (settings.notifyBeforePrayer) {
        final beforeTime = prayer.time.subtract(
          Duration(minutes: settings.beforePrayerMinutes),
        );

        if (beforeTime.isAfter(now)) {
          await _schedulePrayerNotification(
            prayer: prayer,
            locationData: locationData,
            settings: settings,
            isBeforeReminder: true,
            customTime: beforeTime,
            scheduledDate: today,
          );
        }
      }
    }
  }

  /// Schedule individual prayer notification
  Future<void> _schedulePrayerNotification({
    required PrayerItem prayer,
    required PrayerLocationData locationData,
    required NotificationSettingsData settings,
    required bool isBeforeReminder,
    DateTime? customTime,
    required DateTime scheduledDate,
  }) async {
    try {
      // Ensure exact minute timing by normalizing to zero seconds
      final rawTime = customTime ?? prayer.time;
      final scheduledTime = DateTime(
        rawTime.year,
        rawTime.month,
        rawTime.day,
        rawTime.hour,
        rawTime.minute,
        0, // Set seconds to 0
        0, // Set milliseconds to 0
        0, // Set microseconds to 0
      );
      
      // Generate unique notification ID based on date and prayer type
      final baseNotificationType = isBeforeReminder
          ? NotificationTypeExtensions.forBeforePrayer(prayer.type.name)
          : NotificationTypeExtensions.forPrayer(prayer.type.name);
      
      // Create unique ID by combining base ID with date offset
      final daysSinceEpoch = scheduledDate.difference(DateTime(2024, 1, 1)).inDays;
      final uniqueId = baseNotificationType.id + (daysSinceEpoch * 10000);
      
      // Track scheduled notification IDs
      _scheduledNotificationIds.add(uniqueId);
      _persistState(); // Persist after each notification

      final title = isBeforeReminder
          ? 'Upcoming: ${prayer.type.label} in ${settings.beforePrayerMinutes} min'
          : '${prayer.type.label} Prayer Time';

      final body = isBeforeReminder
          ? _getBeforePrayerMessage(prayer.type)
          : _getPrayerMessage(prayer.type, prayerTime: prayer.time);

      // Determine sound based on prayer type and settings
      AndroidNotificationSound? sound;
      if (settings.playSound && !isBeforeReminder) {
        switch (prayer.type) {
          case PrayerType.fajr:
            sound = const RawResourceAndroidNotificationSound("res_azan_fajr");
            break;
          case PrayerType.dhuhr:
          case PrayerType.asr:
          case PrayerType.maghrib:
          case PrayerType.isha:
            sound = const RawResourceAndroidNotificationSound("res_azan");
            break;
          default:
            sound = null; // Use default for Qiyam and others
        }
      }

      await _notificationManager.scheduleNotificationWithId(
        id: uniqueId,
        type: baseNotificationType,
        title: title,
        body: body,
        scheduledDate: scheduledTime,
        payload: 'prayer_time:${prayer.type.name}',
        sound: sound,
        fullScreenIntent: false,
        timezone: locationData.timezone, // Use prayer location's timezone
      );

      logger.d(
          'Scheduled ${isBeforeReminder ? 'before-' : ''}prayer notification: ${prayer.type.name} at $scheduledTime (ID: $uniqueId)');
    } catch (e) {
      logger.e(
          'Error scheduling prayer notification for ${prayer.type.name}: $e');
    }
  }

  /// Schedule Surah Al-Mulk reminder (30 minutes after Isha)
  Future<void> _scheduleSurahMulkReminder(List<PrayerItem> prayerItems) async {
    try {
      final ishaTime =
          prayerItems.where((p) => p.type == PrayerType.isha).firstOrNull;

      if (ishaTime == null) return;

      final rawReminderTime = ishaTime.time.add(const Duration(minutes: 30));
      
      // Ensure exact minute timing by normalizing to zero seconds
      final reminderTime = DateTime(
        rawReminderTime.year,
        rawReminderTime.month,
        rawReminderTime.day,
        rawReminderTime.hour,
        rawReminderTime.minute,
        0, // Set seconds to 0
        0, // Set milliseconds to 0
        0, // Set microseconds to 0
      );

      // Only schedule if in the future
      if (reminderTime.isAfter(DateTime.now())) {
        if (getIt<SharedPrefsHelper>().prayerLocationDataOrNull == null) return;
        
        // Generate unique ID for Surah Al-Mulk reminder
        final today = DateTime.now();
        final daysSinceEpoch = DateTime(today.year, today.month, today.day).difference(DateTime(2024, 1, 1)).inDays;
        final uniqueId = NotificationType.surahMulkReminder.id + (daysSinceEpoch * 10000);
        _scheduledNotificationIds.add(uniqueId);
        _persistState(); // Persist after each notification
        
        await _notificationManager.scheduleNotificationWithId(
          id: uniqueId,
          type: NotificationType.surahMulkReminder,
          title: 'Nightly Reminder 🌙',
          body: 'End your day with Surah Al-Mulk for protection and blessings',
          scheduledDate: reminderTime,
          payload: 'surah_mulk:67',
          timezone: getIt<SharedPrefsHelper>().prayerLocationDataOrNull!.timezone, // Use prayer location timezone
        );

        logger.i('Scheduled Surah Al-Mulk reminder for $reminderTime (ID: $uniqueId)');
      }
    } catch (e) {
      logger.e('Error scheduling Surah Al-Mulk reminder: $e');
    }
  }

  /// Setup daily scheduler to refresh notifications
  Future<void> _setupDailyScheduler() async {
    _schedulingTimer?.cancel();

    try {
      // Schedule daily refresh at 4:00 AM with exact timing
      const refreshHour = 4;
      final now = DateTime.now();
      var nextRefresh = DateTime(
        now.year, 
        now.month, 
        now.day, 
        refreshHour,
        0, // Exact minute
        0, // Zero seconds
        0, // Zero milliseconds
        0, // Zero microseconds
      );

      if (nextRefresh.isBefore(now)) {
        nextRefresh = nextRefresh.add(const Duration(days: 1));
      }

      if (getIt<SharedPrefsHelper>().prayerLocationDataOrNull == null) return;
      
      // Generate unique ID for daily scheduler
      final daysSinceEpoch = DateTime(now.year, now.month, now.day).difference(DateTime(2024, 1, 1)).inDays;
      final uniqueId = NotificationType.dailyScheduler.id + (daysSinceEpoch * 10000);
      _scheduledNotificationIds.add(uniqueId);
      _persistState(); // Persist after each notification
      
      await _notificationManager.scheduleNotificationWithId(
        id: uniqueId,
        type: NotificationType.dailyScheduler,
        title: 'Daily Prayer Update',
        body: 'Refreshing prayer notifications',
        scheduledDate: nextRefresh,
        timezone: getIt<SharedPrefsHelper>().prayerLocationDataOrNull!.timezone, // Use prayer location timezone
      );

      logger.i('Daily scheduler set for $nextRefresh (ID: $uniqueId)');
    } catch (e) {
      logger.e('Error setting up daily scheduler: $e');
    }
  }

  /// Cancel all prayer notifications
  Future<void> cancelAllPrayerNotifications() async {
    try {
      // Cancel all tracked notification IDs
      for (final id in _scheduledNotificationIds) {
        await _notificationManager.cancelNotificationById(id);
      }
      
      // Also cancel by type for any remaining notifications
      final prayerTypes = [
        NotificationType.fajrPrayer,
        NotificationType.dhuhrPrayer,
        NotificationType.asrPrayer,
        NotificationType.maghribPrayer,
        NotificationType.ishaPrayer,
        NotificationType.qiyamPrayer,
        NotificationType.beforeFajr,
        NotificationType.beforeDhuhr,
        NotificationType.beforeAsr,
        NotificationType.beforeMaghrib,
        NotificationType.beforeIsha,
        NotificationType.beforeQiyam,
        NotificationType.surahMulkReminder,
        NotificationType.dailyScheduler,
      ];

      for (final type in prayerTypes) {
        await _notificationManager.cancelNotification(type);
      }

      // Clear tracked IDs and persist state
      _scheduledNotificationIds.clear();
      _lastScheduledDate = null;
      _persistState();

      logger.i('Cancelled all prayer notifications');
    } catch (e) {
      logger.e('Error cancelling prayer notifications: $e');
    }
  }

  /// Clear all existing notifications before scheduling new ones
  Future<void> _clearAllExistingNotifications() async {
    try {
      // Get all pending notifications
      final pendingNotifications = await _notificationManager.getPendingNotifications();
      
      // Cancel all pending notifications
      for (final notification in pendingNotifications) {
        await _notificationManager.cancelNotificationById(notification.id);
      }
      
      // Clear our tracking and persist state
      _scheduledNotificationIds.clear();
      _persistState();
      
      logger.i('Cleared ${pendingNotifications.length} existing notifications');
    } catch (e) {
      logger.e('Error clearing existing notifications: $e');
    }
  }

  /// Get prayer message
  String _getPrayerMessage(PrayerType prayerType, {DateTime? prayerTime}) {
    // For iOS, include the prayer time in the message
    if (Platform.isIOS && prayerTime != null) {
      final timeFormat = DateFormat('h:mm a');
      final formattedTime = timeFormat.format(prayerTime);

      switch (prayerType) {
        case PrayerType.fajr:
          return "Begin your day with light and peace. Fajr at $formattedTime.";
        case PrayerType.dhuhr:
          return "Take a pause and reconnect with Allah. Dhuhr at $formattedTime.";
        case PrayerType.asr:
          return "Recenter your heart before sunset. Asr at $formattedTime.";
        case PrayerType.maghrib:
          return "Gratitude at day's end. Maghrib at $formattedTime.";
        case PrayerType.isha:
          return "End your day with peace and reflection. Isha at $formattedTime.";
        case PrayerType.qiyam:
          return "While the world sleeps, you rise — Qiyam is the path of the devoted.";
        default:
          return "It's time for prayer!";
      }
    }

    // For Android and other platforms, use the original messages
    switch (prayerType) {
      case PrayerType.fajr:
        return "Winners wake up for Fajr — start strong!";
      case PrayerType.dhuhr:
        return "Success isn't just hustle — Dhuhr is your recharge.";
      case PrayerType.asr:
        return "Push through with purpose — it's Asr time!";
      case PrayerType.maghrib:
        return "You made it this far — fuel your soul with Maghrib.";
      case PrayerType.isha:
        return "End the day strong — Isha brings peace and power.";
      case PrayerType.qiyam:
        return "While the world sleeps, you rise — Qiyam is the path of the devoted.";
      default:
        return "It's time for prayer!";
    }
  }

  /// Get before prayer message
  String _getBeforePrayerMessage(PrayerType prayerType) {
    switch (prayerType) {
      case PrayerType.fajr:
        return "Fajr is approaching — prepare your heart for the day's first light.";
      case PrayerType.dhuhr:
        return "Dhuhr time is near — take a break and recharge your soul.";
      case PrayerType.asr:
        return "Asr is coming — pause and connect with Allah.";
      case PrayerType.maghrib:
        return "Maghrib approaches — prepare to break the day with gratitude.";
      case PrayerType.isha:
        return "Isha is near — end your day with peace and prayer.";
      case PrayerType.qiyam:
        return "Qiyam time approaches — prepare for a blessed night prayer.";
      default:
        return "${prayerType.label} prayer time is approaching!";
    }
  }

  /// Public method to schedule prayer notifications for specific prayer items
  /// Used by screens that need to refresh notifications when prayer times change
  Future<void> schedulePrayerNotifications(
    List<PrayerItem> prayerItems,
    PrayerLocationData locationData,
  ) async {
    // Prevent concurrent scheduling
    if (_isScheduling) {
      logger.w('Notification scheduling already in progress, skipping public call');
      return;
    }

    _isScheduling = true;
    
    try {
      final prefsHelper = getIt<SharedPrefsHelper>();
      final notificationSettings = prefsHelper.notificationSettingsData;

      if (!notificationSettings.masterSwitch) {
        logger.i('Prayer notifications are disabled globally');
        return;
      }

      // Clear existing notifications first
      await _clearAllExistingNotifications();
      
      final today = DateTime.now();
      await _schedulePrayerNotifications(
          prayerItems, locationData, notificationSettings);

      // Also schedule Surah Al-Mulk reminder
      await _scheduleSurahMulkReminder(prayerItems);
      
      // Update tracking and persist state
      _lastScheduledDate = today;
      _persistState();

      logger.i(
          'Successfully scheduled prayer notifications for ${prayerItems.length} prayers');
    } catch (e) {
      logger.e('Error in public schedulePrayerNotifications: $e');
    } finally {
      _isScheduling = false;
    }
  }

  /// Refresh all prayer notifications (public method)
  Future<void> refreshTodayNotifications() async {
    // Reset scheduling state to force reschedule
    _lastScheduledDate = null;
    _persistState();
    await _scheduleTodayNotifications();
  }

  /// Test notification functionality
  Future<void> testNotification() async {
    try {
      await _notificationManager.showNotification(
        type: NotificationType.test,
        title: 'Test Prayer Notification',
        body: 'Prayer notification system is working correctly!',
        payload: 'prayer_time:test',
        sound: const RawResourceAndroidNotificationSound("res_azan_fajr"),
      );

      logger.i('Test notification sent successfully');
    } catch (e) {
      logger.e('Error sending test notification: $e');
    }
  }

  /// Test scheduled notification (for testing purposes)
  Future<void> testScheduledNotification() async {
    try {
      final testTime = DateTime.now().add(const Duration(seconds: 10));
      if (getIt<SharedPrefsHelper>().prayerLocationDataOrNull == null) return;
      await _notificationManager.scheduleNotification(
        type: NotificationType.test,
        title: 'Test Scheduled Prayer Notification',
        body: 'This is a test scheduled notification!',
        scheduledDate: testTime,
        payload: 'prayer_test:scheduled',
        timezone: getIt<SharedPrefsHelper>().prayerLocationDataOrNull!.timezone, // Use prayer location timezone
      );    
      logger.i('Test scheduled notification set for $testTime');
    } catch (e) {
      logger.e('Error scheduling test notification: $e');
    }
  }

  /// Test Surah Al-Mulk notification (for testing purposes)
  Future<void> testSurahMulkNotification() async {
    try {
      final testTime = DateTime.now().add(const Duration(seconds: 15));
      if (getIt<SharedPrefsHelper>().prayerLocationDataOrNull == null) return;
      await _notificationManager.scheduleNotification(
        type: NotificationType.surahMulkReminder,
        title: 'Test Nightly Reminder 🌙',
        body: 'Test: End your day with Surah Al-Mulk for protection and blessings',
        scheduledDate: testTime,
        payload: 'surah_mulk:67',
        timezone: getIt<SharedPrefsHelper>().prayerLocationDataOrNull!.timezone, // Use prayer location timezone
      );
      logger.i('Test Surah Al-Mulk notification scheduled for $testTime');
    } catch (e) {
      logger.e('Error scheduling test Surah Al-Mulk notification: $e');
    }
  }

  /// Test exact minute notification (for precise timing testing)
  Future<void> testExactMinuteNotification() async {
    try {
      final now = DateTime.now();
      
      // Schedule for the next exact minute (e.g., if it's 3:04:32, schedule for 3:05:00)
      final nextMinute = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute + 1, // Next minute
        0, // Exactly 0 seconds
        0, // Exactly 0 milliseconds
        0, // Exactly 0 microseconds
      );

      if (getIt<SharedPrefsHelper>().prayerLocationDataOrNull == null) return;
      
      // Generate unique ID for test notification
      final daysSinceEpoch = DateTime(now.year, now.month, now.day).difference(DateTime(2024, 1, 1)).inDays;
      final uniqueId = NotificationType.test.id + (daysSinceEpoch * 10000) + 1; // +1 to differentiate from other tests
      
      await _notificationManager.scheduleNotificationWithId(
        id: uniqueId,
        type: NotificationType.test,
        title: 'Exact Minute Test ⏰',
        body: 'This notification should arrive at exactly ${DateFormat('HH:mm:ss').format(nextMinute)} with 0 seconds delay!',
        scheduledDate: nextMinute,
        payload: 'exact_minute_test',
        sound: const RawResourceAndroidNotificationSound("res_azan_fajr"),
        timezone: getIt<SharedPrefsHelper>().prayerLocationDataOrNull!.timezone, // Use prayer location timezone
      );
      
      logger.i('Test exact minute notification scheduled for $nextMinute (${DateFormat('HH:mm:ss').format(nextMinute)}) with ID: $uniqueId');
    } catch (e) {
      logger.e('Error scheduling test exact minute notification: $e');
    }
  }

  /// Test notification system health and cleanup
  Future<void> testNotificationSystemHealth() async {
    try {
      logger.i('🔍 Testing notification system health...');
      
      // Get pending notifications
      final pendingNotifications = await _notificationManager.getPendingNotifications();
      logger.i('📊 Current pending notifications: ${pendingNotifications.length}');
      
      for (final notification in pendingNotifications) {
        logger.d('Pending: ID=${notification.id}, Title="${notification.title}"');
      }
      
      // Test scheduling state
      logger.i('📅 Last scheduled date: $_lastScheduledDate');
      logger.i('🔄 Is scheduling: $_isScheduling');
      logger.i('📝 Tracked notification IDs: ${_scheduledNotificationIds.length}');
      
      // Test unique ID generation
      final today = DateTime.now();
      final daysSinceEpoch = DateTime(today.year, today.month, today.day).difference(DateTime(2024, 1, 1)).inDays;
      final sampleId = NotificationType.fajrPrayer.id + (daysSinceEpoch * 10000);
      logger.i('🔢 Sample unique ID for today: $sampleId');
      
      // Test persistence
      final prefsHelper = getIt<SharedPrefsHelper>();
      final persistedIds = prefsHelper.getScheduledNotificationIds();
      final persistedDate = prefsHelper.getLastScheduledDate();
      logger.i('💾 Persisted IDs: ${persistedIds.length}, Persisted date: $persistedDate');
      
      logger.i('✅ Notification system health check completed');
    } catch (e) {
      logger.e('❌ Error during notification system health check: $e');
    }
  }

  /// Restore persisted state from SharedPreferences
  Future<void> _restorePersistedState() async {
    try {
      final prefsHelper = getIt<SharedPrefsHelper>();
      
      // Restore scheduled notification IDs
      final persistedIds = prefsHelper.getScheduledNotificationIds();
      _scheduledNotificationIds = persistedIds;
      
      // Restore last scheduled date
      final persistedDate = prefsHelper.getLastScheduledDate();
      _lastScheduledDate = persistedDate;
      
      logger.i('Restored persisted state: ${persistedIds.length} notification IDs, last scheduled: $persistedDate');
      
      // Clean up expired notification IDs (older than 7 days)
      await _cleanupExpiredNotificationIds();
      
    } catch (e) {
      logger.e('Error restoring persisted state: $e');
    }
  }

  /// Persist current state to SharedPreferences
  void _persistState() {
    try {
      final prefsHelper = getIt<SharedPrefsHelper>();
      
      // Save scheduled notification IDs
      prefsHelper.saveScheduledNotificationIds(_scheduledNotificationIds);
      
      // Save last scheduled date
      if (_lastScheduledDate != null) {
        prefsHelper.saveLastScheduledDate(_lastScheduledDate!);
      }
      
      logger.d('Persisted state: ${_scheduledNotificationIds.length} notification IDs, last scheduled: $_lastScheduledDate');
    } catch (e) {
      logger.e('Error persisting state: $e');
    }
  }

  /// Clean up expired notification IDs (older than 7 days)
  Future<void> _cleanupExpiredNotificationIds() async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      
      final expiredIds = <int>[];
      
      for (final id in _scheduledNotificationIds) {
        // Extract date from ID (reverse of generation logic)
        final baseId = id % 10000;
        final daysSinceEpoch = (id - baseId) ~/ 10000;
        final notificationDate = DateTime(2024, 1, 1).add(Duration(days: daysSinceEpoch));
        
        if (notificationDate.isBefore(sevenDaysAgo)) {
          expiredIds.add(id);
        }
      }
      
      if (expiredIds.isNotEmpty) {
        _scheduledNotificationIds.removeAll(expiredIds);
        _persistState();
        logger.i('Cleaned up ${expiredIds.length} expired notification IDs');
      }
    } catch (e) {
      logger.e('Error cleaning up expired notification IDs: $e');
    }
  }

  /// Clear all persisted notification data (for debugging/testing)
  Future<void> clearAllPersistedData() async {
    try {
      final prefsHelper = getIt<SharedPrefsHelper>();
      
      // Clear from SharedPreferences
      prefsHelper.clearScheduledNotificationIds();
      prefsHelper.clearLastScheduledDate();
      
      // Clear from memory
      _scheduledNotificationIds.clear();
      _lastScheduledDate = null;
      
      logger.i('Cleared all persisted notification data');
    } catch (e) {
      logger.e('Error clearing persisted data: $e');
    }
  }

  /// Test notification persistence across app restarts
  Future<void> testNotificationPersistence() async {
    try {
      logger.i('🔄 Testing notification persistence...');
      
      // Save current state
      final currentIds = Set<int>.from(_scheduledNotificationIds);
      final currentDate = _lastScheduledDate;
      
      logger.i('📝 Current state before persistence test:');
      logger.i('   - Notification IDs: ${currentIds.length}');
      logger.i('   - Last scheduled date: $currentDate');
      
      // Simulate app restart by clearing memory and restoring from persistence
      _scheduledNotificationIds.clear();
      _lastScheduledDate = null;
      
      logger.i('🧹 Cleared memory state (simulating app restart)');
      
      // Restore from persistence
      await _restorePersistedState();
      
      logger.i('📥 Restored state from persistence:');
      logger.i('   - Notification IDs: ${_scheduledNotificationIds.length}');
      logger.i('   - Last scheduled date: $_lastScheduledDate');
      
      // Verify restoration
      final idsMatch = currentIds.length == _scheduledNotificationIds.length && 
                      currentIds.every((id) => _scheduledNotificationIds.contains(id));
      final dateMatches = currentDate == _lastScheduledDate;
      
      if (idsMatch && dateMatches) {
        logger.i('✅ Persistence test PASSED - State restored correctly');
      } else {
        logger.w('⚠️ Persistence test FAILED - State mismatch detected');
        logger.w('   - IDs match: $idsMatch');
        logger.w('   - Date matches: $dateMatches');
      }
      
    } catch (e) {
      logger.e('❌ Error during persistence test: $e');
    }
  }
}
