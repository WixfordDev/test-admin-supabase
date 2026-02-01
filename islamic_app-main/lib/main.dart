import 'config/gen/assets.gen.dart';
import 'config/my_app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'core/di/app_injections.dart';
import 'core/services/ai_usage/ai_config_service.dart';
import 'core/services/shared_audio_service.dart';
import 'core/utils/csv_asset_loader.dart';
import 'features/settings/domain/utils/language_options.dart';

final logger = Logger(
  printer: PrettyPrinter(methodCount: 1),
  // output: MultiOutput([
  //   ConsoleOutput(),
  //   FirebaseLogOutput(),
  // ]),
);

// Global audio service for app-wide audio playback
late SharedAudioService audioHandler;

// Supabase configuration
const supabaseUrl = 'https://gbfgotocraqfbzovzzum.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdiZmdvdG9jcmFxZmJ6b3Z6enVtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY4NzA1NTQsImV4cCI6MjA2MjQ0NjU1NH0.HTmRSjrliQghBFyb2C9i-E8u2Qxa1pgbRdA_X3VC7mQ';

// App lifecycle observer to handle audio disposal
class AppLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Only dispose audio when app is actually being terminated
    // Audio continues playing when app goes to background (paused/inactive)
    if (state == AppLifecycleState.detached) {
      // Dispose only when app is actually being killed
      _disposeAudioServices();
    }
  }

  Future<void> _disposeAudioServices() async {
    try {
      logger.i('App being terminated, disposing audio services...');

      if (audioHandler.isInitialized) {
        await audioHandler.dispose();
        logger.i('Audio services disposed due to app termination');
      }
    } catch (e) {
      logger.e('Error disposing audio services: $e');
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Add lifecycle observer for proper audio disposal
  final lifecycleObserver = AppLifecycleObserver();
  WidgetsBinding.instance.addObserver(lifecycleObserver);

  // Configure system UI overlay style for edge-to-edge
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Enable edge-to-edge mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  // Initialize app injections including database
  await initAppInjections();
  EasyLocalization.logger.enableBuildModes = [];

  // Clear AI config to ensure new API key is used
  final aiConfigService = AIConfigService();
  await aiConfigService.clearAIConfig();

  runApp(
    EasyLocalization(
      path: Assets.translationsLangs,
      assetLoader: CsvAssetLoader(),
      supportedLocales: LanguageOption.values
          .where((e) => e.locale != null)
          .map((e) => e.locale!.toLocale())
          .toList(),
      child: const MyApp(),
    ),
  );
}

// class FirebaseLogOutput extends LogOutput {
//   @override
//   void output(OutputEvent event) {
//     for (var line in event.lines) {
//       // Log non-errors as logs
//       // FirebaseCrashlytics.instance.log(line);
//       // FirebaseAnalytics.instance.logEvent(
//       //   name: 'Logged at level ${event.level}',
//       //   parameters: {
//       //     'line': line,
//       //   },
//       // );

//       // You can also report severe logs as exceptions:
//       if (event.level.index >= Level.error.index) {
//         // FirebaseAnalytics.instance.logEvent(
//         //   name: 'Logged at level ${event.level}',
//         //   parameters: {
//         //     'line': line,
//         //   },
//         // );
//         FirebaseCrashlytics.instance.recordError(
//           Exception(line),
//           null,
//           reason: 'Logged at level ${event.level}',
//         );
//       }
//     }
//   }
// }
