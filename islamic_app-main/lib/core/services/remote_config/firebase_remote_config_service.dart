import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Generic Firebase Remote Config Service
/// 
/// This is a raw implementation that provides basic remote config operations.
/// Extend this class or create a helper for app-specific usage.
class FirebaseRemoteConfigService {
  static final FirebaseRemoteConfigService _instance =
      FirebaseRemoteConfigService._internal();
  static FirebaseRemoteConfigService get instance => _instance;
  factory FirebaseRemoteConfigService() => _instance;
  FirebaseRemoteConfigService._internal();

  late FirebaseRemoteConfig _remoteConfig;
  bool _isInitialized = false;

  /// Stream controller to notify listeners about config updates
  final _configUpdateController = StreamController<void>.broadcast();
  Stream<void> get onConfigUpdate => _configUpdateController.stream;

  /// Initialize Remote Config with default values
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('Remote Config already initialized');
      return;
    }

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      // Configure settings
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? const Duration(minutes: 5) // 5 minutes for debug/testing
              : const Duration(hours: 1), // 1 hour for production
        ),
      );

      // Set default values
      await _remoteConfig.setDefaults(getDefaultValues());

      // Fetch and activate
      await _fetchAndActivate();

      // Listen for config updates
      _remoteConfig.onConfigUpdated.listen((event) async {
        debugPrint('Remote Config updated, activating new values...');
        await _remoteConfig.activate();
        _configUpdateController.add(null);
        debugPrint('Remote Config values activated');
      });

      _isInitialized = true;
      debugPrint('Remote Config initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Remote Config: $e');
      // Don't rethrow - app should still work with default values
    }
  }

  /// Fetch and activate remote config values
  Future<bool> _fetchAndActivate() async {
    try {
      final activated = await _remoteConfig.fetchAndActivate();
      debugPrint('Remote Config fetch and activate: $activated');
      return activated;
    } catch (e) {
      debugPrint('Error fetching Remote Config: $e');
      return false;
    }
  }

  /// Force fetch remote config (useful for manual refresh)
  Future<bool> forceFetch() async {
    try {
      await _remoteConfig.fetch();
      final activated = await _remoteConfig.activate();
      if (activated) {
        _configUpdateController.add(null);
      }
      return activated;
    } catch (e) {
      debugPrint('Error force fetching Remote Config: $e');
      return false;
    }
  }

  /// Get default values for all remote config parameters
  /// Override this in your helper class to provide app-specific defaults
  Map<String, dynamic> getDefaultValues() {
    return {};
  }

  /// Set default values - call this with your app-specific defaults
  Future<void> setDefaultValues(Map<String, dynamic> defaults) async {
    await _remoteConfig.setDefaults(defaults);
  }

  // ==================== GENERIC GETTERS ====================

  /// Get boolean value
  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return _remoteConfig.getBool(key);
    } catch (e) {
      debugPrint('Error getting bool for key $key: $e');
      return defaultValue;
    }
  }

  /// Get string value
  String getString(String key, {String defaultValue = ''}) {
    try {
      return _remoteConfig.getString(key);
    } catch (e) {
      debugPrint('Error getting string for key $key: $e');
      return defaultValue;
    }
  }

  /// Get int value
  int getInt(String key, {int defaultValue = 0}) {
    try {
      return _remoteConfig.getInt(key);
    } catch (e) {
      debugPrint('Error getting int for key $key: $e');
      return defaultValue;
    }
  }

  /// Get double value
  double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return _remoteConfig.getDouble(key);
    } catch (e) {
      debugPrint('Error getting double for key $key: $e');
      return defaultValue;
    }
  }

  /// Get all remote config values (for debugging)
  Map<String, RemoteConfigValue> getAllValues() {
    return _remoteConfig.getAll();
  }

  /// Dispose resources
  void dispose() {
    _configUpdateController.close();
  }
}

