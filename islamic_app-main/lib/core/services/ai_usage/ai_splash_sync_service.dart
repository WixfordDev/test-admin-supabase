import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/services/ai_usage/ai_usage_tracking_service.dart';
import 'package:deenhub/core/services/ai_usage/ai_config_service.dart';
import 'package:deenhub/main.dart';

class AISplashSyncService {
  static final AISplashSyncService _instance = AISplashSyncService._internal();
  factory AISplashSyncService() => _instance;
  AISplashSyncService._internal();

  /// Sync AI configuration and usage data during splash screen
  Future<void> syncAIDataIfNeeded() async {
    try {
      await _syncAIConfigIfNeeded();
      await _syncAIUsageDataIfNeeded();
    } catch (e) {
      logger.e('Error syncing AI data: $e');
      // Don't block navigation if sync fails
    }
  }

  /// Sync AI configuration from Supabase if needed
  Future<void> _syncAIConfigIfNeeded() async {
    try {
      final aiConfigService = AIConfigService();

      // Check if we need to refresh config
      final shouldRefresh = await aiConfigService.shouldRefreshConfig();
      if (!shouldRefresh) {
        logger.i('AI config refresh not needed');
        return;
      }

      logger.i('Syncing AI config from Supabase...');

      // Fetch config from Supabase
      final config = await aiConfigService.fetchAIConfigFromSupabase();
      if (config != null) {
        // Save to local storage
        await aiConfigService.saveAIConfigToPrefs(config);
        logger.i('AI config synced successfully');

        // Reset force refresh flag after successful sync
        if (config.forceRefresh) {
          await aiConfigService.updateForceRefreshFlag(false);
          logger.i('Force refresh flag reset');
        }
      } else {
        logger.w('No AI config fetched from Supabase, using default config');
        // Use default config with new API key
        final defaultConfig = await aiConfigService.getCurrentConfig();
        await aiConfigService.saveAIConfigToPrefs(defaultConfig);
        logger.i('Default AI config saved');
      }
    } catch (e) {
      logger.e('Error syncing AI config: $e');
    }
  }

  /// Sync AI usage data for pro users if data is null
  Future<void> _syncAIUsageDataIfNeeded() async {
    try {
      final sharedPrefsHelper = getIt<SharedPrefsHelper>();
      final aiUsageTracker = AIUsageTrackingService();

      // Check if user is logged in
      final userId = sharedPrefsHelper.userId;
      if (userId == null) {
        logger.i('No user logged in, skipping AI usage sync');
        return;
      }

      // Check if user is on pro plan
      final subscriptionType = sharedPrefsHelper.subscriptionStatus;
      if (subscriptionType != 'deenhub_pro') {
        logger.i('User is not on pro plan, skipping AI usage sync');
        return;
      }

      // Check if AI usage data is null
      final existingAIUsageData = await aiUsageTracker.getAIUsageDataFromPrefs();
      if (existingAIUsageData != null) {
        logger.i('AI usage data already exists, skipping sync');
        return;
      }

      logger.i('AI usage data is null for pro user, syncing from database...');

      // Sync AI usage data from Supabase
      await aiUsageTracker.syncAIUsageFromSupabase(userId);
    } catch (e) {
      logger.e('Error syncing AI usage data: $e');
    }
  }
}
