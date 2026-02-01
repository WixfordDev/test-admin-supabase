import 'dart:convert';
import 'package:deenhub/common/enums/high_latitude_rule.dart';
import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/core/services/shared_prefs.dart';
import 'package:deenhub/core/utils/primitive_utils.dart';
import 'package:deenhub/features/settings/data/entity/notification_settings_data.dart';
import 'package:deenhub/features/settings/domain/utils/language_options.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_location_data.dart';
import 'package:deenhub/features/nearby_mosques/data/models/local_favorite_mosque.dart';
import 'package:deenhub/features/location/data/entity/location_data.dart';

/// v2
const String _kDeviceLanguageKey = 'device_language';
const String _kInitialSetupDoneKey = 'initial_setup_done';
const String _kPrayerLocationDataKey = 'prayer_location_data';
const String _kNotificationSettingsKey = 'notification_settings';
const String _kLocationDataKey = 'location_data';

/// v2
const String _kHigherLatitudeMethodKey = 'higher_latitude_method';
const String _kShowPrayersKey = 'show_prayers';

/// User authentication
const String _kIsLoggedInKey = 'is_logged_in';
const String _kUserIdKey = 'user_id';
const String _kIsSubscribedKey = 'isSubscribed';
const String _kSubscriptionStatusKey = 'subscriptionType';
const String _kSubscriptionExpiryKey = 'subscriptionExpiry';

/// App update prompt tracking
const String _kLastRecPromptVersionAndroid = 'last_rec_prompt_version_android';
const String _kLastRecPromptVersionIos = 'last_rec_prompt_version_ios';

/// Local favorite mosques (stored locally, no auth required)
const String _kFavoriteMosquesKey = 'favorite_mosques_local';

/// Trivia username management (per user)
const String _kTriviaUsernameKeyPrefix = 'trivia_username_';

/// Verse view settings
const String _kVerseViewSettingsKey = 'verse_view_settings';

/// Notification management
const String _kScheduledNotificationIdsKey = 'scheduled_notification_ids';
const String _kLastScheduledDateKey = 'last_scheduled_date';

class SharedPrefsHelper {
  final SharedPrefs _prefs;
  SharedPrefs get sharedPrefs => _prefs;

  const SharedPrefsHelper(this._prefs);

  ///////////////////// v2
  // initial_setup_done
  bool? get initialSetupDone => _prefs.getData(_kInitialSetupDoneKey);
  set setInitialSetupDone(bool value) =>
      _prefs.saveData(_kInitialSetupDoneKey, value);

  // device_language
  LanguageOption get deviceLanguage =>
      LanguageOption.values.of(_deviceLanguageValue) ?? LanguageOption.device;
  String? get _deviceLanguageValue => _prefs.getData(_kDeviceLanguageKey);
  set setDeviceLanguage(LanguageOption value) =>
      _prefs.saveData(_kDeviceLanguageKey, value.name);

  // prayer_location_data
  // WARNING: Use `hasPrayerLocationData` or `prayerLocationDataOrNull` when location may be absent
  PrayerLocationData get prayerLocationData =>
      prayerLocationDataEncodedFromJson(prayerLocationDataValue)!;
  String? get prayerLocationDataValue =>
      _prefs.getData(_kPrayerLocationDataKey);
  set setPrayerLocationData(PrayerLocationData value) => _prefs.saveData(
      _kPrayerLocationDataKey, prayerLocationDataEncodedToJson(value));

  // Safe helpers for optional access
  bool get hasPrayerLocationData => _prefs.getData(_kPrayerLocationDataKey) != null;
  PrayerLocationData? get prayerLocationDataOrNull =>
      prayerLocationDataEncodedFromJson(prayerLocationDataValue);

  // notification_settings
  NotificationSettingsData get notificationSettingsData {
    final jsonString = _prefs.getData(_kNotificationSettingsKey);
    if (jsonString == null) return NotificationSettingsData.initial;

    try {
      final jsonMap = json.decode(jsonString as String) as Map<String, dynamic>;
      return NotificationSettingsData.fromJson(jsonMap);
    } catch (e) {
      // If there's an error parsing the JSON, return the default settings
      print('Error parsing notification settings: $e');
      return NotificationSettingsData.initial;
    }
  }

  set setNotificationSettings(NotificationSettingsData value) {
    final jsonMap = value.toJson();
    final jsonString = json.encode(jsonMap);
    _prefs.saveData(_kNotificationSettingsKey, jsonString);
  }

  ///////////////////// v2
  // higher_latitude_method
  HighLatitudeRule get higherLatitudeMethod =>
      HighLatitudeRule.values.of(_higherLatitudeMethodValue) ??
      HighLatitudeRule.twilightAngle;
  String? get _higherLatitudeMethodValue =>
      _prefs.getData(_kHigherLatitudeMethodKey);
  set setHigherLatitudeMethod(HighLatitudeRule value) =>
      _prefs.saveData(_kHigherLatitudeMethodKey, value.name);

  // show_prayers
  List<PrayerType> get showPrayers {
    final value = _showPrayersValue;
    if (value == null) return PrayerType.values.toList();
    // if (value == null) return getMandatoryPrayersList().toList();
    return value.split(',').map((e) => PrayerType.values.of(e)!).toList();
  }

  String? get _showPrayersValue => _prefs.getData(_kShowPrayersKey);
  set setShowPrayers(List<PrayerType> value) =>
      _prefs.saveData(_kShowPrayersKey, value.map((e) => e.name).join(','));

  ///////////////////// User authentication
  // is_logged_in
  bool get isLoggedIn => _prefs.getData(_kIsLoggedInKey) ?? false;
  set setIsLoggedIn(bool value) => _prefs.saveData(_kIsLoggedInKey, value);

  // user_id
  String? get userId => _prefs.getData(_kUserIdKey);
  set setUserId(String? value) {
    if (value != null) {
      _prefs.saveData(_kUserIdKey, value);
    } else {
      _prefs.removeData(_kUserIdKey);
    }
  }

  // subscription_status
  String get subscriptionStatus =>
      _prefs.getData(_kSubscriptionStatusKey) ?? 'free';
  set setSubscriptionStatus(String value) =>
      _prefs.saveData(_kSubscriptionStatusKey, value);

  // subscription_expiry
  DateTime? get subscriptionExpiry {
    final value = _prefs.getData(_kSubscriptionExpiryKey);
    return value != null ? DateTime.tryParse(value) : null;
  }

  set setSubscriptionExpiry(DateTime? value) {
    if (value != null) {
      _prefs.saveData(_kSubscriptionExpiryKey, value.toIso8601String());
    } else {
      _prefs.removeData(_kSubscriptionExpiryKey);
    }
  }

  // Clear auth data
  void clearAuthData() {
    _prefs.removeData(_kIsLoggedInKey);
    _prefs.removeData(_kUserIdKey);
    _prefs.removeData(_kIsSubscribedKey);
    _prefs.removeData(_kSubscriptionStatusKey);
    _prefs.removeData(_kSubscriptionExpiryKey);

    // Also clear memorization-related data
    _prefs.removeData('quran_memorization_progress');
    _prefs.removeData('last_read_surah');
    _prefs.removeData('last_read_verse');
    _prefs.removeData('deenhub_device_id');
  }

  ///////////////////// App Update Prompt Tracking
  // last recommended prompt version per platform
  String? get lastRecPromptVersionAndroid =>
      _prefs.getData(_kLastRecPromptVersionAndroid);
  set setLastRecPromptVersionAndroid(String? value) {
    if (value == null) {
      _prefs.removeData(_kLastRecPromptVersionAndroid);
    } else {
      _prefs.saveData(_kLastRecPromptVersionAndroid, value);
    }
  }

  String? get lastRecPromptVersionIos =>
      _prefs.getData(_kLastRecPromptVersionIos);
  set setLastRecPromptVersionIos(String? value) {
    if (value == null) {
      _prefs.removeData(_kLastRecPromptVersionIos);
    } else {
      _prefs.saveData(_kLastRecPromptVersionIos, value);
    }
  }

  ///////////////////// Location Data
  // location_data
  LocationData? get locationData {
    final jsonString = _prefs.getData(_kLocationDataKey);
    if (jsonString == null) return null;

    try {
      final jsonMap = json.decode(jsonString as String) as Map<String, dynamic>;
      return LocationData.fromJson(jsonMap);
    } catch (e) {
      print('Error parsing location data: $e');
      return null;
    }
  }

  set setLocationData(LocationData? value) {
    if (value != null) {
      final jsonMap = value.toJson();
      final jsonString = json.encode(jsonMap);
      _prefs.saveData(_kLocationDataKey, jsonString);
    } else {
      _prefs.removeData(_kLocationDataKey);
    }
  }

  // Helper methods for location data
  void clearLocationData() {
    _prefs.removeData(_kLocationDataKey);
  }

  bool get hasLocationData {
    return locationData != null;
  }

  ///////////////////// Local favorite mosques (no auth required)
  // favorite_mosques_local
  List<LocalFavoriteMosque> get favoriteMosques {
    final data = _prefs.getData(_kFavoriteMosquesKey);
    if (data == null) return [];
    return LocalFavoriteMosque.listFromJsonString(data);
  }

  set setFavoriteMosques(List<LocalFavoriteMosque> value) => _prefs.saveData(
      _kFavoriteMosquesKey, LocalFavoriteMosque.listToJsonString(value));

  // Helper methods for favorite mosques
  void addFavoriteMosque(LocalFavoriteMosque mosque) {
    final favorites = favoriteMosques;
    if (!favorites.any((f) => f.mosqueId == mosque.mosqueId)) {
      favorites.add(mosque);
      setFavoriteMosques = favorites;
    }
  }

  void removeFavoriteMosque(String mosqueId) {
    final favorites = favoriteMosques;
    favorites.removeWhere((f) => f.mosqueId == mosqueId);
    setFavoriteMosques = favorites;
  }

  bool isMosqueFavorite(String mosqueId) {
    return favoriteMosques.any((f) => f.mosqueId == mosqueId);
  }

  void updateFavoriteMosqueSubscription(String mosqueId, bool subscribed) {
    final favorites = favoriteMosques;
    final index = favorites.indexWhere((f) => f.mosqueId == mosqueId);
    if (index != -1) {
      favorites[index] =
          favorites[index].copyWith(subscribedToUpdates: subscribed);
      setFavoriteMosques = favorites;
    }
  }

  void updateFavoriteMosqueNotificationCheck(
      String mosqueId, DateTime timestamp) {
    final favorites = favoriteMosques;
    final index = favorites.indexWhere((f) => f.mosqueId == mosqueId);
    if (index != -1) {
      favorites[index] =
          favorites[index].copyWith(lastNotificationCheck: timestamp);
      setFavoriteMosques = favorites;
    }
  }

  ///////////////////// Trivia Username Management (per user)
  /// Get the saved trivia username for the current user
  String? get triviaUsername {
    final currentUserId = userId;
    if (currentUserId == null) return null;
    return _prefs.getData('$_kTriviaUsernameKeyPrefix$currentUserId') as String?;
  }

  /// Save the trivia username for the current user
  set setTriviaUsername(String? username) {
    final currentUserId = userId;
    if (currentUserId == null) return;

    if (username != null && username.trim().isNotEmpty) {
      _prefs.saveData('$_kTriviaUsernameKeyPrefix$currentUserId', username.trim());
    } else {
      _prefs.removeData('$_kTriviaUsernameKeyPrefix$currentUserId');
    }
  }

  /// Remove the saved trivia username for the current user
  void clearTriviaUsername() {
    final currentUserId = userId;
    if (currentUserId != null) {
      _prefs.removeData('$_kTriviaUsernameKeyPrefix$currentUserId');
    }
  }

  /// Get the saved trivia username for a specific user ID
  String? getTriviaUsernameForUser(String userId) {
    return _prefs.getData('$_kTriviaUsernameKeyPrefix$userId') as String?;
  }

  /// Save the trivia username for a specific user ID
  void setTriviaUsernameForUser(String userId, String username) {
    _prefs.saveData('$_kTriviaUsernameKeyPrefix$userId', username.trim());
  }

  /// Remove the saved trivia username for a specific user ID
  void clearTriviaUsernameForUser(String userId) {
    _prefs.removeData('$_kTriviaUsernameKeyPrefix$userId');
  }

  /// Get verse view settings
  Map<String, dynamic>? getVerseViewSettings() {
    final jsonString = _prefs.getData(_kVerseViewSettingsKey);
    if (jsonString == null) return null;

    try {
      return json.decode(jsonString as String) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing verse view settings: $e');
      return null;
    }
  }

  /// Save verse view settings
  void saveVerseViewSettings(Map<String, dynamic> settings) {
    final jsonString = json.encode(settings);
    _prefs.saveData(_kVerseViewSettingsKey, jsonString);
  }

  ///////////////////// Notification Management
  
  /// Get scheduled notification IDs
  Set<int> getScheduledNotificationIds() {
    try {
      final List<String>? idStrings = _prefs.getData(_kScheduledNotificationIdsKey) as List<String>?;
      if (idStrings == null) return <int>{};
      
      return idStrings.map((id) => int.tryParse(id)).where((id) => id != null).cast<int>().toSet();
    } catch (e) {
      print('Error getting scheduled notification IDs: $e');
      return <int>{};
    }
  }

  /// Save scheduled notification IDs
  void saveScheduledNotificationIds(Set<int> ids) {
    try {
      final idStrings = ids.map((id) => id.toString()).toList();
      _prefs.saveData(_kScheduledNotificationIdsKey, idStrings);
    } catch (e) {
      print('Error saving scheduled notification IDs: $e');
    }
  }

  /// Clear scheduled notification IDs
  void clearScheduledNotificationIds() {
    _prefs.removeData(_kScheduledNotificationIdsKey);
  }

  /// Get last scheduled date
  DateTime? getLastScheduledDate() {
    try {
      final String? dateString = _prefs.getData(_kLastScheduledDateKey) as String?;
      if (dateString == null) return null;
      
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error getting last scheduled date: $e');
      return null;
    }
  }

  /// Save last scheduled date
  void saveLastScheduledDate(DateTime date) {
    try {
      _prefs.saveData(_kLastScheduledDateKey, date.toIso8601String());
    } catch (e) {
      print('Error saving last scheduled date: $e');
    }
  }

  /// Clear last scheduled date
  void clearLastScheduledDate() {
    _prefs.removeData(_kLastScheduledDateKey);
  }
}
