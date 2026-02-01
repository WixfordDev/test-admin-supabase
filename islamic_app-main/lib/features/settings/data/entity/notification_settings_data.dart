import 'package:deenhub/common/enums/prayer_types.dart';

class NotificationSettingsData {
  final bool masterSwitch;
  final Map<String, bool> prayerNotifications;
  final bool notifyBeforePrayer;
  final int beforePrayerMinutes;
  final bool notifyOnPrayerTime;
  final bool playSound;
  final bool vibrate;
  final bool lockNotification;
  final bool autoClearNotification;
  final int autoClearMinutes;

  // Memorization & Study Settings
  final bool memorizationReminders;
  final int memorizationReminderHour;
  final int memorizationReminderMinute;
  final List<int> memorizationReminderDays; // 1-7 (Monday-Sunday)

  // Sunnah Fasting Settings
  final bool sunnahFastingReminders;
  final int sunnahFastingReminderHour;
  final int sunnahFastingReminderMinute;
  final bool mondayFasting;
  final bool thursdayFasting;

  // Zakat Settings
  final bool zakatReminders;
  final DateTime? zakatReminderDate;
  final int zakatReminderDaysBefore;

  // Community & Location Settings
  final bool mosqueNotifications;
  final double mosqueNotificationRadius; // in kilometers
  final bool fridayKahfReminder;
  final int fridayKahfReminderHour;
  final int fridayKahfReminderMinute;

  // Islamic Calendar & Events Settings
  final bool islamicEventsNotifications;
  final bool ramadanNotifications;
  final bool eidNotifications;
  final bool hajjNotifications;
  final bool hijriDateNotifications;
  final bool islamicNewYearReminder;

  // Do Not Disturb Settings
  final bool doNotDisturbEnabled;
  final int doNotDisturbStartHour;
  final int doNotDisturbStartMinute;
  final int doNotDisturbEndHour;
  final int doNotDisturbEndMinute;
  final bool doNotDisturbOnlyNonEssential; // Allow prayer notifications even during DND

  // Notification Sound Settings
  final String prayerNotificationSound;
  final double notificationVolume;
  final bool useCustomSounds;
  final String reminderNotificationSound;

  const NotificationSettingsData({
    this.masterSwitch = true,
    Map<String, bool>? prayerNotifications,
    this.notifyBeforePrayer = true,
    this.beforePrayerMinutes = 30,
    this.notifyOnPrayerTime = true,
    this.playSound = true,
    this.vibrate = true,
    this.lockNotification = false,
    this.autoClearNotification = true,
    this.autoClearMinutes = 15,

    // Memorization settings
    this.memorizationReminders = true,
    this.memorizationReminderHour = 20, // 8 PM
    this.memorizationReminderMinute = 0,
    this.memorizationReminderDays = const [1, 2, 3, 4, 5, 6, 7], // Daily

    // Sunnah fasting settings
    this.sunnahFastingReminders = true,
    this.sunnahFastingReminderHour = 21, // 9 PM (night before)
    this.sunnahFastingReminderMinute = 0,
    this.mondayFasting = true,
    this.thursdayFasting = true,

    // Zakat settings
    this.zakatReminders = true,
    this.zakatReminderDate,
    this.zakatReminderDaysBefore = 7,

    // Community settings
    this.mosqueNotifications = true,
    this.mosqueNotificationRadius = 5.0,
    this.fridayKahfReminder = true,
    this.fridayKahfReminderHour = 10, // 10 AM Friday
    this.fridayKahfReminderMinute = 0,

    // Islamic events settings
    this.islamicEventsNotifications = true,
    this.ramadanNotifications = true,
    this.eidNotifications = true,
    this.hajjNotifications = true,
    this.hijriDateNotifications = true,
    this.islamicNewYearReminder = true,

    // Do not disturb settings
    this.doNotDisturbEnabled = false,
    this.doNotDisturbStartHour = 22, // 10 PM
    this.doNotDisturbStartMinute = 0,
    this.doNotDisturbEndHour = 6, // 6 AM
    this.doNotDisturbEndMinute = 0,
    this.doNotDisturbOnlyNonEssential = true,

    // Sound settings
    this.prayerNotificationSound = 'default',
    this.notificationVolume = 0.8,
    this.useCustomSounds = false,
    this.reminderNotificationSound = 'default',
  }) : prayerNotifications = prayerNotifications ?? const {};

  bool isPrayerEnabled(PrayerType prayerType) {
    if (!masterSwitch) return false;
    return prayerNotifications[prayerType.name] ?? true;
  }

  bool isInDoNotDisturbPeriod(DateTime time) {
    if (!doNotDisturbEnabled) return false;
    
    final currentHour = time.hour;
    final currentMinute = time.minute;
    final currentTotalMinutes = currentHour * 60 + currentMinute;
    
    final startTotalMinutes = doNotDisturbStartHour * 60 + doNotDisturbStartMinute;
    final endTotalMinutes = doNotDisturbEndHour * 60 + doNotDisturbEndMinute;
    
    if (startTotalMinutes <= endTotalMinutes) {
      // Same day range (e.g., 10 PM to 6 AM next day)
      return currentTotalMinutes >= startTotalMinutes && currentTotalMinutes < endTotalMinutes;
    } else {
      // Crosses midnight (e.g., 22:00 to 06:00)
      return currentTotalMinutes >= startTotalMinutes || currentTotalMinutes < endTotalMinutes;
    }
  }

  NotificationSettingsData copyWith({
    bool? masterSwitch,
    Map<String, bool>? prayerNotifications,
    bool? notifyBeforePrayer,
    int? beforePrayerMinutes,
    bool? notifyOnPrayerTime,
    bool? playSound,
    bool? vibrate,
    bool? lockNotification,
    bool? autoClearNotification,
    int? autoClearMinutes,

    bool? memorizationReminders,
    int? memorizationReminderHour,
    int? memorizationReminderMinute,
    List<int>? memorizationReminderDays,

    bool? sunnahFastingReminders,
    int? sunnahFastingReminderHour,
    int? sunnahFastingReminderMinute,
    bool? mondayFasting,
    bool? thursdayFasting,

    bool? zakatReminders,
    DateTime? zakatReminderDate,
    int? zakatReminderDaysBefore,

    bool? mosqueNotifications,
    double? mosqueNotificationRadius,
    bool? fridayKahfReminder,
    int? fridayKahfReminderHour,
    int? fridayKahfReminderMinute,

    bool? islamicEventsNotifications,
    bool? ramadanNotifications,
    bool? eidNotifications,
    bool? hajjNotifications,
    bool? hijriDateNotifications,
    bool? islamicNewYearReminder,

    bool? doNotDisturbEnabled,
    int? doNotDisturbStartHour,
    int? doNotDisturbStartMinute,
    int? doNotDisturbEndHour,
    int? doNotDisturbEndMinute,
    bool? doNotDisturbOnlyNonEssential,

    String? prayerNotificationSound,
    double? notificationVolume,
    bool? useCustomSounds,
    String? reminderNotificationSound,
  }) {
    return NotificationSettingsData(
      masterSwitch: masterSwitch ?? this.masterSwitch,
      prayerNotifications: prayerNotifications ?? Map.from(this.prayerNotifications),
      notifyBeforePrayer: notifyBeforePrayer ?? this.notifyBeforePrayer,
      beforePrayerMinutes: beforePrayerMinutes ?? this.beforePrayerMinutes,
      notifyOnPrayerTime: notifyOnPrayerTime ?? this.notifyOnPrayerTime,
      playSound: playSound ?? this.playSound,
      vibrate: vibrate ?? this.vibrate,
      lockNotification: lockNotification ?? this.lockNotification,
      autoClearNotification: autoClearNotification ?? this.autoClearNotification,
      autoClearMinutes: autoClearMinutes ?? this.autoClearMinutes,

      memorizationReminders: memorizationReminders ?? this.memorizationReminders,
      memorizationReminderHour: memorizationReminderHour ?? this.memorizationReminderHour,
      memorizationReminderMinute: memorizationReminderMinute ?? this.memorizationReminderMinute,
      memorizationReminderDays: memorizationReminderDays ?? List.from(this.memorizationReminderDays),

      sunnahFastingReminders: sunnahFastingReminders ?? this.sunnahFastingReminders,
      sunnahFastingReminderHour: sunnahFastingReminderHour ?? this.sunnahFastingReminderHour,
      sunnahFastingReminderMinute: sunnahFastingReminderMinute ?? this.sunnahFastingReminderMinute,
      mondayFasting: mondayFasting ?? this.mondayFasting,
      thursdayFasting: thursdayFasting ?? this.thursdayFasting,

      zakatReminders: zakatReminders ?? this.zakatReminders,
      zakatReminderDate: zakatReminderDate ?? this.zakatReminderDate,
      zakatReminderDaysBefore: zakatReminderDaysBefore ?? this.zakatReminderDaysBefore,

      mosqueNotifications: mosqueNotifications ?? this.mosqueNotifications,
      mosqueNotificationRadius: mosqueNotificationRadius ?? this.mosqueNotificationRadius,
      fridayKahfReminder: fridayKahfReminder ?? this.fridayKahfReminder,
      fridayKahfReminderHour: fridayKahfReminderHour ?? this.fridayKahfReminderHour,
      fridayKahfReminderMinute: fridayKahfReminderMinute ?? this.fridayKahfReminderMinute,

      islamicEventsNotifications: islamicEventsNotifications ?? this.islamicEventsNotifications,
      ramadanNotifications: ramadanNotifications ?? this.ramadanNotifications,
      eidNotifications: eidNotifications ?? this.eidNotifications,
      hajjNotifications: hajjNotifications ?? this.hajjNotifications,
      hijriDateNotifications: hijriDateNotifications ?? this.hijriDateNotifications,
      islamicNewYearReminder: islamicNewYearReminder ?? this.islamicNewYearReminder,

      doNotDisturbEnabled: doNotDisturbEnabled ?? this.doNotDisturbEnabled,
      doNotDisturbStartHour: doNotDisturbStartHour ?? this.doNotDisturbStartHour,
      doNotDisturbStartMinute: doNotDisturbStartMinute ?? this.doNotDisturbStartMinute,
      doNotDisturbEndHour: doNotDisturbEndHour ?? this.doNotDisturbEndHour,
      doNotDisturbEndMinute: doNotDisturbEndMinute ?? this.doNotDisturbEndMinute,
      doNotDisturbOnlyNonEssential: doNotDisturbOnlyNonEssential ?? this.doNotDisturbOnlyNonEssential,

      prayerNotificationSound: prayerNotificationSound ?? this.prayerNotificationSound,
      notificationVolume: notificationVolume ?? this.notificationVolume,
      useCustomSounds: useCustomSounds ?? this.useCustomSounds,
      reminderNotificationSound: reminderNotificationSound ?? this.reminderNotificationSound,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'masterSwitch': masterSwitch,
      'prayerNotifications': prayerNotifications,
      'notifyBeforePrayer': notifyBeforePrayer,
      'beforePrayerMinutes': beforePrayerMinutes,
      'notifyOnPrayerTime': notifyOnPrayerTime,
      'playSound': playSound,
      'vibrate': vibrate,
      'lockNotification': lockNotification,
      'autoClearNotification': autoClearNotification,
      'autoClearMinutes': autoClearMinutes,

      'memorizationReminders': memorizationReminders,
      'memorizationReminderHour': memorizationReminderHour,
      'memorizationReminderMinute': memorizationReminderMinute,
      'memorizationReminderDays': memorizationReminderDays,

      'sunnahFastingReminders': sunnahFastingReminders,
      'sunnahFastingReminderHour': sunnahFastingReminderHour,
      'sunnahFastingReminderMinute': sunnahFastingReminderMinute,
      'mondayFasting': mondayFasting,
      'thursdayFasting': thursdayFasting,

      'zakatReminders': zakatReminders,
      'zakatReminderDate': zakatReminderDate?.millisecondsSinceEpoch,
      'zakatReminderDaysBefore': zakatReminderDaysBefore,

      'mosqueNotifications': mosqueNotifications,
      'mosqueNotificationRadius': mosqueNotificationRadius,
      'fridayKahfReminder': fridayKahfReminder,
      'fridayKahfReminderHour': fridayKahfReminderHour,
      'fridayKahfReminderMinute': fridayKahfReminderMinute,

      'islamicEventsNotifications': islamicEventsNotifications,
      'ramadanNotifications': ramadanNotifications,
      'eidNotifications': eidNotifications,
      'hajjNotifications': hajjNotifications,
      'hijriDateNotifications': hijriDateNotifications,
      'islamicNewYearReminder': islamicNewYearReminder,

      'doNotDisturbEnabled': doNotDisturbEnabled,
      'doNotDisturbStartHour': doNotDisturbStartHour,
      'doNotDisturbStartMinute': doNotDisturbStartMinute,
      'doNotDisturbEndHour': doNotDisturbEndHour,
      'doNotDisturbEndMinute': doNotDisturbEndMinute,
      'doNotDisturbOnlyNonEssential': doNotDisturbOnlyNonEssential,

      'prayerNotificationSound': prayerNotificationSound,
      'notificationVolume': notificationVolume,
      'useCustomSounds': useCustomSounds,
      'reminderNotificationSound': reminderNotificationSound,
    };
  }

  factory NotificationSettingsData.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsData(
      masterSwitch: json['masterSwitch'] ?? true,
      prayerNotifications: Map<String, bool>.from(json['prayerNotifications'] ?? {}),
      notifyBeforePrayer: json['notifyBeforePrayer'] ?? true,
      beforePrayerMinutes: json['beforePrayerMinutes'] ?? 30,
      notifyOnPrayerTime: json['notifyOnPrayerTime'] ?? true,
      playSound: json['playSound'] ?? true,
      vibrate: json['vibrate'] ?? true,
      lockNotification: json['lockNotification'] ?? false,
      autoClearNotification: json['autoClearNotification'] ?? true,
      autoClearMinutes: json['autoClearMinutes'] ?? 15,

      memorizationReminders: json['memorizationReminders'] ?? true,
      memorizationReminderHour: json['memorizationReminderHour'] ?? 20,
      memorizationReminderMinute: json['memorizationReminderMinute'] ?? 0,
      memorizationReminderDays: List<int>.from(json['memorizationReminderDays'] ?? [1, 2, 3, 4, 5, 6, 7]),

      sunnahFastingReminders: json['sunnahFastingReminders'] ?? true,
      sunnahFastingReminderHour: json['sunnahFastingReminderHour'] ?? 21,
      sunnahFastingReminderMinute: json['sunnahFastingReminderMinute'] ?? 0,
      mondayFasting: json['mondayFasting'] ?? true,
      thursdayFasting: json['thursdayFasting'] ?? true,

      zakatReminders: json['zakatReminders'] ?? true,
      zakatReminderDate: json['zakatReminderDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['zakatReminderDate']) 
          : null,
      zakatReminderDaysBefore: json['zakatReminderDaysBefore'] ?? 7,

      mosqueNotifications: json['mosqueNotifications'] ?? true,
      mosqueNotificationRadius: (json['mosqueNotificationRadius'] ?? 5.0).toDouble(),
      fridayKahfReminder: json['fridayKahfReminder'] ?? true,
      fridayKahfReminderHour: json['fridayKahfReminderHour'] ?? 10,
      fridayKahfReminderMinute: json['fridayKahfReminderMinute'] ?? 0,

      islamicEventsNotifications: json['islamicEventsNotifications'] ?? true,
      ramadanNotifications: json['ramadanNotifications'] ?? true,
      eidNotifications: json['eidNotifications'] ?? true,
      hajjNotifications: json['hajjNotifications'] ?? true,
      hijriDateNotifications: json['hijriDateNotifications'] ?? true,
      islamicNewYearReminder: json['islamicNewYearReminder'] ?? true,

      doNotDisturbEnabled: json['doNotDisturbEnabled'] ?? false,
      doNotDisturbStartHour: json['doNotDisturbStartHour'] ?? 22,
      doNotDisturbStartMinute: json['doNotDisturbStartMinute'] ?? 0,
      doNotDisturbEndHour: json['doNotDisturbEndHour'] ?? 6,
      doNotDisturbEndMinute: json['doNotDisturbEndMinute'] ?? 0,
      doNotDisturbOnlyNonEssential: json['doNotDisturbOnlyNonEssential'] ?? true,

      prayerNotificationSound: json['prayerNotificationSound'] ?? 'default',
      notificationVolume: (json['notificationVolume'] ?? 0.8).toDouble(),
      useCustomSounds: json['useCustomSounds'] ?? false,
      reminderNotificationSound: json['reminderNotificationSound'] ?? 'default',
    );
  }

  static NotificationSettingsData get initial => const NotificationSettingsData();
} 