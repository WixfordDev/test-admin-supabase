import 'package:flutter/services.dart';
import 'package:deenhub/config/gen/assets.gen.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/config/themes/decoration_styles.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/services/ai_usage/ai_splash_sync_service.dart';
import 'package:deenhub/core/services/app_update_service.dart';
import 'package:deenhub/core/services/location_update_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/core/utils/primitive_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/image_view.dart';
import 'package:deenhub/config/constants/app_constants.dart';
import 'package:deenhub/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAndNavigate();
  }

  Future<void> checkAndNavigate() async {
    await initInjections();
    await LocationUpdateService.updateLocationIfNeeded();

    // Preload nearby mosques data in background (don't await to avoid blocking navigation)
    LocationUpdateService.preloadNearbyMosques();

    // Preload audio source in background for faster first-time audio playback
    _preloadAudioInBackground();

    // Sync AI configuration and usage data for pro users if needed
    await _syncAIDataIfNeeded();

    // Check app update status (forced/optional)
    final shouldProceed = await _handleAppUpdateIfNeeded();
    if (!shouldProceed) {
      return; // Force update or user chose to update now
    }

    navigateUser();
  }



  /// Preload audio source in background for faster first-time audio playback
  void _preloadAudioInBackground() {
    try {
      logger.i('Starting audio source preload in background...');

      // Get the SharedAudioService instance and start preloading
      // This is done without await to avoid blocking navigation
      audioHandler.preloadAudioSource();

      logger.i('Audio preload initiated successfully');
    } catch (e) {
      logger.w('Error starting audio preload: $e');
      // Don't block navigation if preload setup fails
    }
  }

  /// Sync AI configuration and usage data if needed
  Future<void> _syncAIDataIfNeeded() async {
    try {
      final aiSplashSyncService = AISplashSyncService();
      await aiSplashSyncService.syncAIDataIfNeeded();
    } catch (e) {
      logger.e('Error syncing AI data: $e');
      // Don't block navigation if sync fails
    }
  }

  Future<bool> _handleAppUpdateIfNeeded() async {
    try {
      final updateService = AppUpdateService();
      final prefs = getIt<SharedPrefsHelper>();

      final config = await updateService.fetchConfigForCurrentPlatform();
      if (config == null) return true;

      final currentVersion = await updateService.getCurrentAppVersion();

      // Forced update if below minimum version
      if (config.isBelowMin(currentVersion)) {
        await _showForceUpdateDialog();
        return false;
      }

      // Optional one-time prompt if below recommended version
      if (config.isBelowRec(currentVersion)) {
        final lastPrompt = updateService.getLastRecommendedPromptVersion(prefs);
        if (lastPrompt != config.recVersion) {
          final accepted = await _showOptionalUpdateDialog();
          updateService.setLastRecommendedPromptVersion(prefs, config.recVersion);
          if (accepted) {
            _openStoreListing();
            return false;
          }
        }
      }

      return true;
    } catch (e) {
      logger.e('Error during app update check: $e');
      return true; // fail-open
    }
  }

  Future<void> _showForceUpdateDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Required'),
        content: const Text(
          'A newer version of DeenHub is required to continue. Please update to continue using the app.',
        ),
        actions: [
          TextButton(
            onPressed: _openStoreListing,
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showOptionalUpdateDialog() async {
    if (!mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: const Text(
          'A newer version of DeenHub is available with improvements and fixes. Would you like to update now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Maybe Later'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _openStoreListing() {
    AppConstants.downloadUrl.launchURL();
  }

  void navigateUser() {
    final initialSetupDone = getIt<SharedPrefsHelper>().initialSetupDone;
    final route = (!initialSetupDone.orFalse)
        ? Routes.chooseLanguageOnboard
        : Routes.home;
    context.goNamed(route.name);
  }

  String text = "";
  @override
  Widget build(BuildContext context) {
    final systemBarColors = DecorationStyles.appBarSystemUiOverlayStyle(
      context: context,
    );
    SystemChrome.setSystemUIOverlayStyle(systemBarColors);

    final size = context.width * .5;
    return Scaffold(
      backgroundColor: Colors.white,
      // backgroundColor: context.primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App Logo
          ImageView(
            imagePath: Assets.logoAppLogo,
            height: size,
            width: size,
            radius: BorderRadiusDirectional.circular(32),
            clipBehavior: Clip.hardEdge,
          ),
          const SizedBox(height: 40),

          // Inspirational Tagline with innovative styling
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade50,
                  Colors.teal.shade50,
                  Colors.blue.shade50,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.green.shade200.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade100.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Main tagline
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.green.shade700,
                      Colors.teal.shade600,
                      Colors.blue.shade600,
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'A Clear Path to Deen',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // This will be overridden by shader
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),

                // Secondary line with icon
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.block, size: 18, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'AD-Free. Always.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.verified,
                      size: 18,
                      color: Colors.green.shade600,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ).center(),
    );
  }
}
