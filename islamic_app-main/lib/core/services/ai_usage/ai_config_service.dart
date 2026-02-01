import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/supabase_provider.dart';
import 'package:deenhub/core/services/ai_usage/models/ai_config_data.dart';
import 'package:deenhub/main.dart';

class AIConfigService {
  static const String _configKey = 'ai_config_data';
  static const String _supabaseConfigTable = 'ai_config';

  // Singleton pattern
  static final AIConfigService _instance = AIConfigService._internal();
  factory AIConfigService() => _instance;
  AIConfigService._internal();

  /// Get AI config from shared preferences
  Future<AIConfigData?> getAIConfigFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_configKey);
      if (jsonString == null) {
        return null;
      }
      final jsonData = jsonDecode(jsonString);
      return AIConfigData.fromJson(jsonData);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting AI config from shared preferences: $e');
      }
      return null;
    }
  }

  /// Save AI config to shared preferences
  Future<void> saveAIConfigToPrefs(AIConfigData config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(config.toJson());
      await prefs.setString(_configKey, jsonString);
      if (kDebugMode) {
        print('AI Config saved to shared preferences');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving AI config to shared preferences: $e');
      }
    }
  }

  /// Fetch AI config from Supabase
  Future<AIConfigData?> fetchAIConfigFromSupabase() async {
    try {
      final supabase = getIt<SupabaseProvider>().client;

      final response = await supabase
          .from(_supabaseConfigTable)
          .select(
            'api_key, model_name, force_refresh, monthly_token_limit, max_completion_tokens',
          )
          .eq('id', 1)
          .maybeSingle();

      if (response != null) {
        final config = AIConfigData(
          apiKey: response['api_key'] as String? ?? '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',
          modelName: response['model_name'] as String? ?? 'gpt-5-mini',
          forceRefresh: response['force_refresh'] as bool? ?? false,
          monthlyTokenLimit: response['monthly_token_limit'] as int? ?? 0,
          maxCompletionTokens: response['max_completion_tokens'] as int? ?? 0,
        );

        logger.i('AI Config fetched from Supabase: $config');
        return config;
      }

      logger.w('No AI config found in Supabase, using default config with new API key');
      return const AIConfigData(
        apiKey: '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',
        modelName: 'gpt-5-mini',
        forceRefresh: false,
        monthlyTokenLimit: 0,
        maxCompletionTokens: 500,
      );
    } catch (e) {
      logger.e('Error fetching AI config from Supabase: $e');
      return const AIConfigData(
        apiKey: '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',
        modelName: 'gpt-5-mini',
        forceRefresh: false,
        monthlyTokenLimit: 0,
        maxCompletionTokens: 500,
      );
    }
  }

  /// Check if config refresh is needed
  Future<bool> shouldRefreshConfig() async {
    try {
      // First check if we have any config at all
      final currentConfig = await getAIConfigFromPrefs();
      if (currentConfig == null || currentConfig.apiKey.isEmpty || currentConfig.apiKey == '') {
        logger.i('No AI config found locally, refresh needed');
        return true;
      }

      // Check force refresh flag from Supabase
      final supabase = getIt<SupabaseProvider>().client;
      final response = await supabase
          .from(_supabaseConfigTable)
          .select('force_refresh')
          .eq('id', 1)
          .maybeSingle();

      final forceRefresh = response?['force_refresh'] as bool? ?? false;
      if (forceRefresh) {
        logger.i('Force refresh is enabled, config refresh needed');
        return true;
      }

      logger.i('Config refresh not needed');
      return false;
    } catch (e) {
      logger.e('Error checking config refresh status: $e');
      return false;
    }
  }

  /// Get current AI config (with fallback to default)
  Future<AIConfigData> getCurrentConfig() async {
    try {
      final config = await getAIConfigFromPrefs();
      if (config != null && config.apiKey.isNotEmpty) {
        return config;
      }

      // Return default config if no valid config found
      return const AIConfigData(
        apiKey: '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', // New API key
        modelName: 'gpt-5-mini',
        forceRefresh: false,
        monthlyTokenLimit: 0,
        maxCompletionTokens: 500,
      );
    } catch (e) {
      logger.e('Error getting current AI config: $e');
      return const AIConfigData(
        apiKey: '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', // New API key
        modelName: 'gpt-5-mini',
        forceRefresh: false,
        monthlyTokenLimit: 0,
        maxCompletionTokens: 500,
      );
    }
  }

  /// Update force refresh flag in Supabase (admin function)
  Future<bool> updateForceRefreshFlag(bool forceRefresh) async {
    try {
      final supabase = getIt<SupabaseProvider>().client;

      await supabase
          .from(_supabaseConfigTable)
          .update({'force_refresh': forceRefresh})
          .eq('id', 1);

      logger.i('Force refresh flag updated to: $forceRefresh');
      return true;
    } catch (e) {
      logger.e('Error updating force refresh flag: $e');
      return false;
    }
  }

  /// Clear AI config from shared preferences
  Future<void> clearAIConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_configKey);
      if (kDebugMode) {
        print('AI Config cleared from shared preferences');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing AI config from shared preferences: $e');
      }
    }
  }
}
