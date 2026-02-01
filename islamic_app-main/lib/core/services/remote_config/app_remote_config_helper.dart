import 'package:deenhub/core/constants/remote_config_keys.dart';
import 'package:deenhub/core/services/remote_config/firebase_remote_config_service.dart';
import 'package:deenhub/core/services/remote_config/models/trivia_config.dart';
import 'package:flutter/foundation.dart';

/// App-specific Remote Config Helper
/// 
/// This class extends the generic FirebaseRemoteConfigService with
/// app-specific feature config methods. Use this throughout your app.
class AppRemoteConfigHelper {
  final FirebaseRemoteConfigService _service;

  AppRemoteConfigHelper(this._service);

  /// Singleton instance
  static AppRemoteConfigHelper? _instance;
  static AppRemoteConfigHelper get instance {
    _instance ??= AppRemoteConfigHelper(FirebaseRemoteConfigService.instance);
    return _instance!;
  }

  /// Initialize with app-specific defaults
  Future<void> initialize() async {
    await _service.setDefaultValues(_getAppDefaults());
  }

  /// Get app-specific default values
  Map<String, dynamic> _getAppDefaults() {
    return {
      // Trivia configuration - all disabled by default
      RemoteConfigKeys.triviaConfig: TriviaConfig.defaults().toJsonString(),
      
      // Add more feature configs here following the same pattern
      // Example: RemoteConfigKeys.aiChatbotConfig: AiChatbotConfig.defaults().toJsonString(),
    };
  }

  // ==================== TRIVIA CONFIGURATION ====================

  /// Get trivia configuration from nested JSON
  TriviaConfig getTriviaConfig() {
    try {
      final jsonString = _service.getString(RemoteConfigKeys.triviaConfig);
      if (jsonString.isEmpty) {
        return TriviaConfig.defaults();
      }
      return TriviaConfig.fromJson(jsonString);
    } catch (e) {
      debugPrint('Error getting trivia config: $e');
      return TriviaConfig.defaults();
    }
  }

  /// Check if trivia feature is enabled
  bool get isTriviaEnabled {
    return getTriviaConfig().featureEnabled;
  }

  /// Check if trivia solo mode is enabled
  bool get isTriviaSoloModeEnabled {
    return getTriviaConfig().soloModeEnabled;
  }

  /// Check if trivia group mode is enabled
  bool get isTriviaGroupModeEnabled {
    return getTriviaConfig().groupModeEnabled;
  }

  // ==================== GENERIC ACCESSORS ====================

  /// Get any config as JSON string
  String getConfigJson(String key, {String defaultValue = ''}) {
    return _service.getString(key, defaultValue: defaultValue);
  }

  /// Get boolean value
  bool getBool(String key, {bool defaultValue = false}) {
    return _service.getBool(key, defaultValue: defaultValue);
  }

  /// Get string value
  String getString(String key, {String defaultValue = ''}) {
    return _service.getString(key, defaultValue: defaultValue);
  }

  /// Get int value
  int getInt(String key, {int defaultValue = 0}) {
    return _service.getInt(key, defaultValue: defaultValue);
  }

  /// Get double value
  double getDouble(String key, {double defaultValue = 0.0}) {
    return _service.getDouble(key, defaultValue: defaultValue);
  }

  /// Force fetch latest config
  Future<bool> forceFetch() {
    return _service.forceFetch();
  }

  /// Listen to config updates
  Stream<void> get onConfigUpdate => _service.onConfigUpdate;
}



