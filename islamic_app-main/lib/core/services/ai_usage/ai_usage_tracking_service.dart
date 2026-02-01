import 'dart:convert';
import 'package:deenhub/core/services/ai_usage/ai_config_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/supabase_provider.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/services/ai_usage/models/ai_usage_data.dart';
import 'package:deenhub/main.dart';

class SubscriptionPlan {
  final String id;
  final String name;

  const SubscriptionPlan({required this.id, required this.name});

  static const SubscriptionPlan free = SubscriptionPlan(
    id: 'free',
    name: 'Free',
  );

  static const SubscriptionPlan barakahAccess = SubscriptionPlan(
    id: 'barakah_access',
    name: 'Barakah Access',
  );

  static const SubscriptionPlan quranLite = SubscriptionPlan(
    id: 'quran_lite',
    name: 'Quran Lite',
  );

  static const SubscriptionPlan deenhubPro = SubscriptionPlan(
    id: 'deenhub_pro',
    name: 'DeenHub Pro',
  );
}

class AIUsageTrackingService {
  static const String _aiUsageDataKey = 'ai_usage_data';

  // Singleton pattern
  static final AIUsageTrackingService _instance =
      AIUsageTrackingService._internal();
  factory AIUsageTrackingService() => _instance;
  AIUsageTrackingService._internal();

  /// Track AI usage
  Future<void> trackUsage({
    required int tokensUsed,
    required int monthlyTokenLimit,
  }) async {
    try {
      // Save to both local storage (backup) and Supabase
      await _saveUsageToSupabase(tokensUsed, monthlyTokenLimit);
    } catch (e) {
      logger.e('Error tracking AI usage: $e');
    }
  }

  /// Save usage entry to Supabase users table
  Future<void> _saveUsageToSupabase(
    int tokensUsed,
    int monthlyTokenLimit,
  ) async {
    try {
      final userId = getIt<SharedPrefsHelper>().userId;
      if (userId == null) {
        logger.e('No user ID found, cannot track AI usage to Supabase');
        return;
      }

      final supabase = getIt<SupabaseProvider>().client;

      // Get current user's AI usage data
      final userResponse = await supabase
          .from('user_profiles')
          .select('ai_usage_data')
          .eq('user_id', userId)
          .single();

      Map<String, dynamic> currentUsage = {};
      if (userResponse['ai_usage_data'] != null) {
        currentUsage = Map<String, dynamic>.from(userResponse['ai_usage_data']);
      }

      // Initialize structure if not exists
      currentUsage['monthly_tokens'] ??= 0;
      currentUsage['total_requests'] ??= 0;
      currentUsage['last_reset_date'] ??= DateTime.now().toIso8601String();

      // Check if we need to reset monthly counter
      final lastResetDate = DateTime.parse(currentUsage['last_reset_date']);
      final now = DateTime.now();

      // Reset monthly counter if it's a new month
      if (lastResetDate.month != now.month || lastResetDate.year != now.year) {
        currentUsage['monthly_tokens'] = 0;
        currentUsage['last_reset_date'] = now.toIso8601String();
      }

      // Update counters
      currentUsage['monthly_tokens'] =
          (currentUsage['monthly_tokens'] as int) + tokensUsed;
      currentUsage['total_requests'] =
          (currentUsage['total_requests'] as int) + 1;
      currentUsage['last_used'] = now.toIso8601String();

      // Update user record
      await supabase
          .from('user_profiles')
          .update({'ai_usage_data': currentUsage})
          .eq('user_id', userId);

      // Also update local data
      await _updateLocalUsageData(currentUsage);

      logger.d(
        'AI Usage saved to Supabase: $tokensUsed tokens, Monthly total: ${currentUsage['monthly_tokens']}',
      );
    } catch (e) {
      logger.e('Error saving AI usage to Supabase: $e');
      // Don't throw error to prevent breaking the main flow
    }
  }

  /// Update local usage data from Supabase data
  Future<void> _updateLocalUsageData(Map<String, dynamic> supabaseData) async {
    try {
      final usageData = AIUsageData(
        lastUsed: supabaseData['last_used'],
        monthlyTokens: supabaseData['monthly_tokens'] ?? 0,
        totalRequests: supabaseData['total_requests'] ?? 0,
        lastResetDate:
            supabaseData['last_reset_date'] ?? DateTime.now().toIso8601String(),
      );

      await saveAIUsageDataToPrefs(usageData);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating local usage data: $e');
      }
    }
  }

  /// Check if user can make AI request based on their plan
  Future<bool> canMakeRequest({
    required int estimatedTokens,
    int? monthlyTokenLimit,
  }) async {
    // Check if API key is valid first
    final config = await AIConfigService().getCurrentConfig();
    if (config.apiKey.isEmpty || config.apiKey == '') {
      logger.w('No valid API key available');
      return false;
    }

    final currentPlan = await getCurrentPlan();

    // Only DeenHub Pro has AI access
    if (currentPlan.id != 'deenhub_pro') {
      logger.d('User is not on DeenHub Pro plan');
      return false;
    }

    // Get AI config for API key and model
    if (monthlyTokenLimit == null) {
      monthlyTokenLimit = config.monthlyTokenLimit;
    }

    // Try to get data from shared preferences first
    try {
      final prefsData = await getAIUsageDataFromPrefs();
      if (prefsData != null) {
        // Check if we need to reset monthly counter
        final lastResetDate = DateTime.parse(prefsData.lastResetDate);
        final now = DateTime.now();

        // Reset monthly counter if it's a new month
        int currentMonthlyTokens = prefsData.monthlyTokens;
        if (lastResetDate.month != now.month ||
            lastResetDate.year != now.year) {
          currentMonthlyTokens = 0;
        }

        logger.d('prefsData monthlyTokens: $currentMonthlyTokens');
        logger.d('estimatedTokens: $estimatedTokens');
        logger.d('monthlyTokenLimit: $monthlyTokenLimit');

        if (monthlyTokenLimit > 0 &&
            currentMonthlyTokens + estimatedTokens > monthlyTokenLimit) {
          return false;
        }

        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting usage from shared preferences: $e');
      }
    }

    // If no local data, assume user can make request (will be tracked when made)
    return true;
  }

  /// Get current subscription plan
  Future<SubscriptionPlan> getCurrentPlan() async {
    try {
      final planName = getIt<SharedPrefsHelper>().subscriptionStatus;
      logger.d('Current plan: $planName');

      switch (planName) {
        case 'barakah_access':
          return SubscriptionPlan.barakahAccess;
        case 'quran_lite':
          return SubscriptionPlan.quranLite;
        case 'deenhub_pro':
          return SubscriptionPlan.deenhubPro;
        default:
          return SubscriptionPlan.free;
      }
    } catch (e) {
      return SubscriptionPlan.free;
    }
  }

  /// Get usage summary for UI display
  Future<Map<String, dynamic>> getUsageSummary() async {
    final config = await AIConfigService().getCurrentConfig();
    final monthlyTokenLimit = config.monthlyTokenLimit;
    final plan = await getCurrentPlan();

    try {
      // Try to get data from shared preferences first
      final prefsData = await getAIUsageDataFromPrefs();
      if (prefsData != null) {
        // Check if we need to reset monthly counter
        final lastResetDate = DateTime.parse(prefsData.lastResetDate);
        final now = DateTime.now();

        int currentMonthlyTokens = prefsData.monthlyTokens;
        if (lastResetDate.month != now.month ||
            lastResetDate.year != now.year) {
          currentMonthlyTokens = 0;
        }

        final monthlyRemaining = plan.id == 'deenhub_pro'
            ? (monthlyTokenLimit - currentMonthlyTokens).clamp(
                0,
                monthlyTokenLimit,
              )
            : 0;

        DateTime? lastUsed;
        if (prefsData.lastUsed != null && prefsData.lastUsed!.isNotEmpty) {
          lastUsed = DateTime.tryParse(prefsData.lastUsed!);
        }

        return {
          'plan': plan.name,
          'monthlyUsed': currentMonthlyTokens,
          'monthlyLimit': monthlyTokenLimit,
          'monthlyRemaining': monthlyRemaining,
          'totalRequests': prefsData.totalRequests,
          'lastUsed': lastUsed,
          'hasAIAccess': plan.id == 'deenhub_pro',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting usage from shared preferences: $e');
      }
    }

    // Fallback to basic plan info
    return {
      'plan': plan.name,
      'monthlyUsed': 0,
      'monthlyLimit': monthlyTokenLimit,
      'monthlyRemaining': monthlyTokenLimit,
      'totalRequests': 0,
      'lastUsed': null,
      'hasAIAccess': plan.id == 'deenhub_pro',
    };
  }

  /// Save AI usage data to shared preferences
  Future<void> saveAIUsageDataToPrefs(AIUsageData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data.toJson());
      await prefs.setString(_aiUsageDataKey, jsonString);
      if (kDebugMode) {
        print('AI Usage data saved to shared preferences');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving AI usage data to shared preferences: $e');
      }
    }
  }

  /// Get AI usage data from shared preferences
  Future<AIUsageData?> getAIUsageDataFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_aiUsageDataKey);
      if (jsonString == null) {
        return null;
      }
      final jsonData = jsonDecode(jsonString);
      return AIUsageData.fromJson(jsonData);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting AI usage data from shared preferences: $e');
      }
      return null;
    }
  }

  /// Sync AI usage data from Supabase to local storage
  Future<void> syncAIUsageFromSupabase(String userId) async {
    try {
      final supabase = getIt<SupabaseProvider>().client;
      final response = await supabase
          .from('user_profiles')
          .select('ai_usage_data')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['ai_usage_data'] != null) {
        final aiUsageData = response['ai_usage_data'] as Map<String, dynamic>;
        await _updateLocalUsageData(aiUsageData);
        logger.i('AI usage data synced successfully from Supabase');
      } else {
        // Create default data for new users
        final defaultUsageData = AIUsageData(
          lastUsed: null,
          monthlyTokens: 0,
          totalRequests: 0,
          lastResetDate: DateTime.now().toIso8601String(),
        );
        await saveAIUsageDataToPrefs(defaultUsageData);
        logger.i('Default AI usage data created');
      }
    } catch (e) {
      logger.e('Error syncing AI usage data from Supabase: $e');
    }
  }

  /// Clear all usage data
  Future<void> clearAllUsageData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_aiUsageDataKey);
  }
}
