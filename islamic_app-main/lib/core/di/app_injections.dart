import 'package:deenhub/core/services/shared_audio_service.dart';
import 'package:deenhub/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:deenhub/features/auth/data/repositories/auth_repository.dart';
import 'package:deenhub/features/auth/data/services/memorization_sync_service.dart';

import 'package:deenhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:deenhub/features/dua_collection/data/repositories/dua_service.dart';
import 'package:deenhub/features/hadith/data/repositories/hadith_supabase_service.dart';
import 'package:deenhub/features/nearby_mosques/data/repositories/mosque_notification_repository.dart';
import 'package:deenhub/features/nearby_mosques/data/services/supabase_mosque_service.dart';
import 'package:deenhub/core/firebase/mosque_notification_service.dart';
import 'package:deenhub/features/nearby_mosques/domain/repositories/mosque_repository.dart';
import 'package:deenhub/features/quran/data/repository/memorization_service.dart';
import 'package:deenhub/features/quran/data/repository/quran_service.dart';
import 'package:deenhub/features/subscription/data/services/subscription_service.dart';
import 'package:deenhub/firebase_options.dart';
import 'package:deenhub/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:deenhub/config/routes/app_router.dart';
import 'package:deenhub/core/bloc/app_bloc_observer.dart';
import 'package:deenhub/core/services/shared_prefs.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/services/supabase_provider.dart';
import 'package:deenhub/features/location/data/repository/location_repository_impl.dart';
import 'package:deenhub/features/location/domain/repository/location_repository.dart';
import 'package:deenhub/features/location/presentation/bloc/location_bloc.dart';
import 'package:deenhub/features/onboarding/presentation/blocs/onboard_settings_bloc.dart';
import 'package:deenhub/features/quran/data/repository/quran_repository.dart';
import 'package:deenhub/core/services/database/app_database.dart';
import 'package:deenhub/core/services/database/chat_history_service.dart';
import 'package:deenhub/core/services/embeddings_service.dart';
import 'package:deenhub/features/free_quran/data/services/free_quran_service.dart';
import 'package:deenhub/core/notification/notification_manager.dart';
import 'package:deenhub/core/notification/services/prayer_notification_service.dart';
import 'package:deenhub/core/notification/services/daily_goals_notification_service.dart';
import 'package:deenhub/core/notification/services/friday_kahf_notification_service.dart';
import 'package:deenhub/core/notification/services/memorization_reminder_service.dart';
import 'package:deenhub/core/notification/services/zakat_notification_service.dart';
import 'package:deenhub/core/notification/services/sunnah_fasting_notification_service.dart';
import 'package:deenhub/core/services/report_service.dart';
import 'package:deenhub/features/nearby_mosques/presentation/cubit/nearby_mosque_cubit.dart';
import 'package:deenhub/features/trivia/data/services/trivia_service.dart';
import 'package:deenhub/core/services/remote_config/firebase_remote_config_service.dart';
import 'package:deenhub/core/services/remote_config/app_remote_config_helper.dart';

import 'package:timezone/data/latest.dart' as tz;

import '../notification/services/subscription_notification_service.dart';

final getIt = GetIt.instance;

Future<void> initAppInjections() async {
  AppRouter.instance;
  await initSharedPrefsInjections();

  // Register Supabase provider
  getIt.registerSingleton<SupabaseProvider>(SupabaseProvider.instance);
}

Future<void> initInjections() async {
  // Initialize the audio service
  try {
    audioHandler = SharedAudioService.instance;
    await audioHandler.initialize();
    logger.i('SharedAudioService initialized successfully');
  } catch (e) {
    logger.e('Failed to initialize SharedAudioService: $e');
    // Still create the audio handler instance but don't initialize it
    audioHandler = SharedAudioService.instance;
    logger.w(
        'SharedAudioService created without AudioPlayer due to initialization failure');
  }

  // Initialize Supabase
  try {
    await SupabaseProvider.instance.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    logger.i('Supabase initialized successfully');
  } catch (e) {
    logger.e('Failed to initialize Supabase: $e');
  }

  /// Timezone
  tz.initializeTimeZones();
  await initDriftDatabaseInjections();
  await initBlocs();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialize Firebase Remote Config
  try {
    final remoteConfigService = FirebaseRemoteConfigService.instance;
    await remoteConfigService.initialize();
    getIt.registerSingleton<FirebaseRemoteConfigService>(remoteConfigService);
    
    // Initialize app-specific helper
    final appConfigHelper = AppRemoteConfigHelper.instance;
    await appConfigHelper.initialize();
    getIt.registerSingleton<AppRemoteConfigHelper>(appConfigHelper);
    
    logger.i('Firebase Remote Config initialized successfully');
  } catch (e) {
    logger.e('Error initializing Firebase Remote Config: $e');
  }

  // Initialize centralized notification system
  await _initializeNotificationSystem();

  try {
    // Initialize services
    await QuranService().initialize();
    getIt.registerSingleton<MemorizationService>(MemorizationService());
    await getIt<MemorizationService>().initialize();
    await DuaService().initialize();
  } catch (e) {
    logger.e('Error initializing services: $e');
  }

  // Initialize Hadith Supabase service
  getIt
      .registerSingleton<HadithSupabaseService>(HadithSupabaseService.instance);

  // Initialize Mosque Services
  getIt.registerLazySingleton<SupabaseMosqueService>(
      () => SupabaseMosqueService(getIt<SupabaseProvider>()));

  getIt.registerLazySingleton<MosqueNotificationRepository>(() =>
      MosqueNotificationRepository(
          supabase: getIt<SupabaseProvider>().supabase));

  // Initialize the notification service
  try {
    // Initialize Firebase-based Mosque Notification Service
    getIt.registerLazySingleton<MosqueNotificationService>(
        () => MosqueNotificationService());
    await getIt<MosqueNotificationService>().initialize();
    logger.i('Mosque notification service initialized successfully');
  } catch (e) {
    logger.e('Error initializing mosque notification service: $e');
  }

  // Notification services are now initialized in _initializeNotificationSystem()
  // which is called earlier in the initialization process

  // Initialize Mosque Repository with notification service
  getIt.registerLazySingleton<MosqueRepository>(() => MosqueRepository(
        supabaseProvider: getIt<SupabaseProvider>(),
        notificationService: getIt<MosqueNotificationService>(),
        sharedPrefsHelper: getIt<SharedPrefsHelper>(),
      ));

  // Register NearbyMosqueCubit for centralized mosque data management
  getIt.registerLazySingleton<NearbyMosqueCubit>(() => NearbyMosqueCubit(
        mosqueRepository: getIt<MosqueRepository>(),
        sharedPrefsHelper: getIt<SharedPrefsHelper>(),
      ));

  // Initialize Free Quran Service
  getIt.registerLazySingleton<FreeQuranService>(
      () => FreeQuranService(getIt<SupabaseProvider>()));

  // Trivia Service
  getIt.registerLazySingleton<TriviaService>(
      () => TriviaService(getIt<SupabaseProvider>()));

  // Initialize Report Service
  getIt.registerLazySingleton<ReportService>(() {
    final reportService = ReportService.instance;
    reportService.initialize();
    return reportService;
  });
}

Future<void> initBlocs() async {
  Bloc.observer = AppBlocObserver();

  /// Auth
  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<SupabaseProvider>()));
  // Register MemorizationSyncService with SupabaseMemorizationService
  getIt.registerLazySingleton<MemorizationSyncService>(() =>
      MemorizationSyncService(
          getIt<SupabaseProvider>(), getIt<MemorizationService>()));
  getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(getIt<AuthRepository>(),
      getIt<MemorizationSyncService>(), getIt<SharedPrefsHelper>()));

  /// Features
  // Onboard Settings
  getIt.registerLazySingleton<OnboardSettingsBloc>(() => OnboardSettingsBloc());
  // Location
  getIt.registerLazySingleton<LocationRepository>(
      () => LocationRepositoryImpl(getIt<SharedPrefsHelper>()));
  getIt.registerLazySingleton<LocationBloc>(
      () => LocationBloc(getIt<LocationRepository>()));
  // Quran
  getIt.registerLazySingleton<QuranRepository>(
      () => QuranRepository(getIt<AppDatabase>()));
  // Subscription
  getIt.registerLazySingleton<SubscriptionService>(() => SubscriptionService());
}

Future<void> initSharedPrefsInjections() async {
  getIt.registerSingletonAsync<SharedPrefs>(() async {
    final sharedPrefs = SharedPrefs();
    await sharedPrefs.init();
    return sharedPrefs;
  });
  await getIt.isReady<SharedPrefs>();

  getIt.registerLazySingleton<SharedPrefsHelper>(
      () => SharedPrefsHelper(getIt<SharedPrefs>()));
}

Future<void> initDriftDatabaseInjections() async {
  // Database
  getIt.registerSingleton<AppDatabase>(AppDatabase());
  getIt.registerSingleton<ChatHistoryService>(
      ChatHistoryService(getIt<AppDatabase>()));
}

void setupInjections() {
  // Register EmbeddingsService as a singleton if it's not already registered
  if (!getIt.isRegistered<EmbeddingsService>()) {
    getIt.registerLazySingleton<EmbeddingsService>(
        () => EmbeddingsService.instance);
  }
}

/// Initialize the centralized notification system
Future<void> _initializeNotificationSystem() async {
  try {
    logger.i('Initializing centralized notification system...');

    // 1. Initialize the core notification manager
    final notificationManager = NotificationManager();
    await notificationManager.initialize();
    await notificationManager.requestPermissions();
    logger.i('Core notification manager initialized');

    // 2. Register notification services as singletons
    getIt.registerSingleton<NotificationManager>(notificationManager);

    // 3. Initialize prayer notification service
    final prayerService = PrayerNotificationService();
    await prayerService.initialize();
    getIt.registerSingleton<PrayerNotificationService>(prayerService);
    logger.i('Prayer notification service initialized');

    // 4. Initialize daily goals notification service
    final dailyGoalsService = DailyGoalsNotificationService();
    await dailyGoalsService.initialize();
    getIt.registerSingleton<DailyGoalsNotificationService>(dailyGoalsService);
    logger.i('Daily goals notification service initialized');

    // 5. Initialize Friday Kahf notification service
    final fridayKahfService = FridayKahfNotificationService();
    await fridayKahfService.initialize();
    getIt.registerSingleton<FridayKahfNotificationService>(fridayKahfService);
    logger.i('Friday Kahf notification service initialized');

    // 6. Initialize memorization reminder service
    final memorizationService = MemorizationReminderService();
    await memorizationService.initialize();
    getIt.registerSingleton<MemorizationReminderService>(memorizationService);
    logger.i('Memorization reminder service initialized');

    // 7. Initialize Zakat notification service
    final zakatService = ZakatNotificationService();
    await zakatService.initialize();
    getIt.registerSingleton<ZakatNotificationService>(zakatService);
    logger.i('Zakat notification service initialized');

    // 8. Initialize Sunnah Fasting notification service
    final sunnahFastingService = SunnahFastingNotificationService();
    await sunnahFastingService.initialize();
    getIt.registerSingleton<SunnahFastingNotificationService>(sunnahFastingService);
    logger.i('Sunnah Fasting notification service initialized');

    // 9. Initialize Subscription notification service
    final subscriptionNotificationService = SubscriptionNotificationService(notificationManager);
    getIt.registerSingleton<SubscriptionNotificationService>(subscriptionNotificationService);
    logger.i('Subscription notification service initialized');

    logger.i(
        'Centralized notification system initialization completed successfully');
  } catch (e) {
    logger.e('Error initializing centralized notification system: $e');
    rethrow;
  }
}
