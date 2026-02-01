import 'dart:io';

import 'package:deenhub/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:deenhub/features/auth/presentation/pages/login_screen.dart';
import 'package:deenhub/features/auth/presentation/pages/signup_screen.dart';
import 'package:deenhub/features/free_quran/presentation/pages/free_quran_screen.dart';
import 'package:deenhub/features/legal/presentation/pages/legal_webview_screen.dart';
import 'package:deenhub/features/qibla/qibla_screen.dart';
import 'package:deenhub/features/prayer_guide/presentation/pages/prayer_guide_screen.dart';
import 'package:deenhub/features/quran/data/repository/quran_service.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/memorization/memorization_report_screen.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/reading_mode_screen.dart';
import 'package:deenhub/features/settings/data/entity/notification_settings_data.dart';
import 'package:deenhub/features/settings/presentation/pages/notification/notification_settings_screen.dart';
import 'package:deenhub/features/settings/presentation/pages/notification/prayer_notification_settings_screen.dart';
import 'package:deenhub/features/settings/presentation/pages/settings/calculation_method/calculation_method_screen.dart';
import 'package:deenhub/features/settings/presentation/pages/settings/select_time_zone_screen.dart';
import 'package:deenhub/features/subscription/presentation/pages/subscription_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:deenhub/config/constants/app_constants.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/core/utils/primitive_utils.dart';
import 'package:deenhub/features/location/presentation/pages/search_map/search_map_screen.dart';
import 'package:deenhub/features/dashboard/presentation/pages/home_screen.dart';
import 'package:deenhub/features/hadith/presentation/pages/hadith_screen.dart';
import 'package:deenhub/features/hadith/presentation/pages/hadith_chapters_screen.dart';
import 'package:deenhub/features/hadith/presentation/pages/hadith_detail_screen.dart';
import 'package:deenhub/features/hadith/presentation/pages/hadith_search_screen.dart';
import 'package:deenhub/features/nearby_mosques/presentation/pages/add_mosque/add_mosque_screen.dart';
import 'package:deenhub/features/nearby_mosques/presentation/pages/favorite_mosques/favorite_mosques_screen.dart';
import 'package:deenhub/features/nearby_mosques/presentation/pages/mosques_screen.dart';
import 'package:deenhub/features/onboarding/presentation/pages/choose_language_onboard_screen.dart';
import 'package:deenhub/features/onboarding/presentation/pages/get_prayer_times_onboard_screen.dart';
import 'package:deenhub/features/onboarding/presentation/pages/location_details_onboard_screen.dart';
import 'package:deenhub/features/prayers/presentation/pages/prayers_calendar/prayers_calendar_screen.dart';
import 'package:deenhub/features/prayers/presentation/pages/prayers/prayers_screen.dart';
import 'package:deenhub/features/main/presentation/pages/main_screen.dart';
import 'package:deenhub/features/main/presentation/pages/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/features/settings/presentation/pages/settings/settings_screen.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/quran_screen.dart';
import 'package:deenhub/map_location_picker/map_location_picker.dart';
import 'package:deenhub/features/zakat/presentation/pages/zakat_calculator_screen.dart';
import 'package:deenhub/features/ai_chatbot/presentation/pages/ai_chatbot_screen.dart';
import 'package:deenhub/features/dua_collection/presentation/pages/dua_collection_screen.dart';
import 'package:deenhub/features/nearby_mosques/presentation/pages/location_autocomplete_screen.dart';
import 'package:deenhub/features/faq/presentation/pages/faq_screen.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/verse_view_screen.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/settings/pages/verse_view_settings_screen.dart';
import 'package:deenhub/features/hadith/presentation/pages/hadith_list_screen.dart';
import 'package:deenhub/features/ai_chatbot/presentation/pages/chat_history_screen.dart';
import 'package:deenhub/features/prayer_guide/presentation/pages/hajj_guide_screen.dart';
import 'package:deenhub/features/prayer_guide/presentation/pages/wudu_guide_screen.dart';
import 'package:deenhub/features/trivia/presentation/pages/trivia_home_screen.dart';
import 'package:deenhub/features/trivia/presentation/pages/trivia_solo_lobby_screen.dart';
import 'package:deenhub/features/trivia/presentation/pages/trivia_solo_screen.dart';
import 'package:deenhub/features/trivia/presentation/pages/trivia_group_lobby_screen.dart';
import 'package:deenhub/features/trivia/presentation/pages/trivia_leaderboard_screen.dart';
import 'package:deenhub/features/trivia/presentation/pages/trivia_group_game_screen.dart';

class AppRouter {
  static final AppRouter _instance = AppRouter._internal();
  static AppRouter get instance => _instance;
  factory AppRouter() {
    return _instance;
  }

  static late final GoRouter router;

  BuildContext get context =>
      router.routerDelegate.navigatorKey.currentContext!;

  GoRouterDelegate get routerDelegate => router.routerDelegate;

  GoRouteInformationParser get routeInformationParser =>
      router.routeInformationParser;

  static final parentNavigatorKey = GlobalKey<NavigatorState>();
  static final homeTabNavigatorKey = GlobalKey<NavigatorState>();
  static final prayersTabNavigatorKey = GlobalKey<NavigatorState>();
  static final mosquesTabNavigatorKey = GlobalKey<NavigatorState>();
  static final quranTabNavigatorKey = GlobalKey<NavigatorState>();

  AppRouter._internal() {
    final routes = [
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: parentNavigatorKey,
        branches: [
          StatefulShellBranch(
            navigatorKey: homeTabNavigatorKey,
            routes: [
              getGoRouteInstance(route: Routes.home, child: const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: mosquesTabNavigatorKey,
            routes: [
              getGoRouteInstance(
                route: Routes.mosque,
                child: const MosquesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: prayersTabNavigatorKey,
            routes: [
              getGoRouteInstance(
                  route: Routes.prayers, child: const PrayersScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: quranTabNavigatorKey,
            routes: [
              getGoRouteInstance(route: Routes.quran, child: QuranScreen()),
            ],
          ),
        ],
        pageBuilder: (context, state, navigationShell) =>
            getPage(state: state, child: MainScreen(child: navigationShell)),
      ),

      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.settings,
        child: const SettingsScreen(),
      ),

      // Nearby Mosques
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.addMosque,
        child: const AddMosqueScreen(),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.favoriteMosques,
        child: const FavoriteMosquesScreen(),
      ),
      // More
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.qibla,
        child: const QiblaScreen(),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.hadith,
        child: const HadithScreen(),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.hadithChapters,
        pageBuilder: (context, state) {
          final params = state.uri.queryParameters;
          final bookId = params['bookId'] ?? '1';
          return getPage(
            state: state,
            child: HadithChaptersScreen(bookId: bookId),
          );
        },
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.hadithDetail,
        pageBuilder: (context, state) {
          final params = state.uri.queryParameters;
          final bookId = params['bookId'] ?? '1';
          final chapterId = params['chapterId'] ?? '1';
          final hadithId = params['hadithId'] ?? '1';
          return getPage(
            state: state,
            child: HadithDetailScreen(
              bookId: bookId,
              chapterId: chapterId,
              hadithId: hadithId,
            ),
          );
        },
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.hadithList,
        pageBuilder: (context, state) {
          final params = state.uri.queryParameters;
          final bookId = params['bookId'] ?? '1';
          final chapterId = params['chapterId'] ?? '1';
          return getPage(
            state: state,
            child: HadithListScreen(
              bookId: bookId,
              chapterId: chapterId,
            ),
          );
        },
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.hadithSearch,
        pageBuilder: (context, state) {
          final params = state.uri.queryParameters;
          return getPage(
            state: state,
            child: HadithSearchScreen(queryParams: params),
          );
        },
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.zakat,
        child: const ZakatCalculatorScreen(),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.aiChatbot,
        pageBuilder: (context, state) {
          final params = state.uri.queryParameters;
          final int? sessionId = params['sessionId'] != null
              ? int.tryParse(params['sessionId']!)
              : null;
          return getPage(
            state: state,
            child: AIChatbotScreen(sessionId: sessionId),
          );
        },
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.chatHistory,
        child: const ChatHistoryScreen(),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.duaCollection,
        child: const DuaCollectionScreen(),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.faq,
        child: const FAQScreen(),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.prayerGuide,
        child: const PrayerGuideScreen(),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.hajjGuide,
        child: const HajjGuideScreen(),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.wuduGuide,
        child: const WuduGuideScreen(),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.freeQuran,
        child: const FreeQuranScreen(),
      ),

      // Trivia
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.trivia,
        child: const TriviaHomeScreen(),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.triviaSoloLobby,
        child: const TriviaSoloLobbyScreen(),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.triviaSolo,
        pageBuilder: (context, state) {
          return getPage(
            state: state,
            child: TriviaSoloScreen(queryParams: state.uri.queryParameters),
          );
        },
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.triviaGroupLobby,
        pageBuilder: (context, state) => getPage(
          state: state,
          child: TriviaGroupLobbyScreen(queryParams: state.uri.queryParameters),
        ),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.triviaGroupGame,
        pageBuilder: (context, state) => getPage(
          state: state,
          child: TriviaGroupGameScreen(queryParams: state.uri.queryParameters),
        ),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.triviaLeaderboard,
        child: const TriviaLeaderboardScreen(),
      ),

      // Subscription
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.subscription,
        child: const SubscriptionScreen(),
      ),

      // Quran Reading Mode
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.quranReadingMode,
        pageBuilder: (context, state) {
          final params = state.uri.queryParameters;
          final int surahId = int.parse(params['surahId'] ?? '1');
          final int verseId = int.parse(params['verseId'] ?? '1');
          return getPage(
            state: state,
            child: ReadingModeScreen(
              surah: QuranService().getSurah(surahId),
              initialVerseId: verseId,
            ),
          );
        },
      ),

      // Memorization Report Screen
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.memorizationReport,
        child: const MemorizationReportScreen(),
      ),

      // Verse View Screen
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.verseView,
        pageBuilder: (context, state) {
          final params = state.uri.queryParameters;
          final int surahId = int.parse(params['surahId'] ?? '1');
          final int verseId = int.parse(params['verseId'] ?? '1');
          final bool isMemorizationMode =
              params['isMemorizationMode'] == 'true';

          return getPage(
            state: state,
            child: VerseViewScreen(
              surah: QuranService().getSurah(surahId),
              initialVerseId: verseId,
              isMemorizationMode: isMemorizationMode,
            ),
          );
        },
      ),

      // Verse View Settings Screen
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.verseViewSettings,
        child: const VerseViewSettingsScreen(),
      ),

      /// Others
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.mapsLocationPicker,
        pageBuilder: (context, state) {
          final params = state.uri.queryParameters;
          return getPage(
            state: state,
            child: GoogleMapLocationPicker(
              apiKey: AppConstants.mapsApiKey,
              hideMapTypeButton: true,
              hideMoreOptions: true,
              currentLatLng:
                  LatLng(params["lat"].toDouble, params["lng"].toDouble),
            ),
          );
        },
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.locationPicker,
        pageBuilder: (context, state) {
          final params = state.uri.queryParameters;
          return getPage(
            state: state,
            child: LocationAutocompleteScreen(
              apiKey: AppConstants.mapsApiKey,
              currentLatLng:
                  LatLng(params["lat"].toDouble, params["lng"].toDouble),
            ),
          );
        },
      ),

      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.splash,
        child: const SplashScreen(),
      ),
      // Onboard
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.chooseLanguageOnboard,
        child: const ChooseLanguageOnboardScreen(),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.getPrayerTimesOnboard,
        child: GetPrayerTimesOnboardScreen(),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.locationDetailsOnboard,
        pageBuilder: (context, state) {
          return getPage(
            state: state,
            child: LocationDetailsOnboardScreen(
              queryParams: state.uri.queryParameters,
            ),
          );
        },
      ),

      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.calculationMethodSettings,
        pageBuilder: (context, state) {
          final methodName = state.pathParameters['method'];
          return getPage(
            state: state,
            child: CalculationMethodScreen(method: methodName!),
          );
        },
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.prayersCalendar,
        child: const PrayersCalendarScreen(),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.notificationSettings,
        child: const NotificationSettingsScreen(),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.prayerNotificationSettings,
        pageBuilder: (context, state) {
          return getPage(
            state: state,
            child: PrayerNotificationSettingsScreen(
              settings: state.extra as NotificationSettingsData,
            ),
          );
        },
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.selectTimeZone,
        pageBuilder: (context, state) {
          return getPage(
            state: state,
            child: SelectTimezoneScreen(queryParams: state.uri.queryParameters),
          );
        },
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.searchLocation,
        pageBuilder: (context, state) {
          return getPage(
            state: state,
            child: SearchMapScreen(queryParams: state.uri.queryParameters),
          );
        },
      ),

      // Legal Routes
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.aboutUs,
        child: const LegalWebviewScreen(
          title: 'About Us',
          url: AppConstants.aboutUsUrl,
        ),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.termsConditions,
        child: const LegalWebviewScreen(
          title: 'Terms & Conditions',
          url: AppConstants.termsUrl,
        ),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.privacyPolicy,
        child: const LegalWebviewScreen(
          title: 'Privacy Policy',
          url: AppConstants.privacyUrl,
        ),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.contactUs,
        child: const LegalWebviewScreen(
          title: 'Contact Us',
          url: AppConstants.contactUsUrl,
        ),
      ),
      // Auth Routes
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.login,
        child: const LoginScreen(),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.signup,
        child: const SignupScreen(),
      ),
      getGoRouteInstance(
        parentNavigatorKey: parentNavigatorKey,
        route: Routes.forgotPassword,
        child: const ForgotPasswordScreen(),
      ),
    ];
    router = GoRouter(
      navigatorKey: parentNavigatorKey,
      debugLogDiagnostics: true,
      initialLocation: Routes.splash.path,
      routes: routes,
    );
  }

  static GoRoute getGoRouteInstance({
    GlobalKey<NavigatorState>? parentNavigatorKey,
    required Routes route,
    Page<dynamic> Function(BuildContext, GoRouterState)? pageBuilder,
    Widget? child,
    List<RouteBase> routes = const <RouteBase>[],
  }) {
    assert(pageBuilder != null || child != null,
        'pageBuilder, or child must be provided');
    return GoRoute(
      parentNavigatorKey: parentNavigatorKey,
      name: route.name,
      path: route.path,
      pageBuilder: pageBuilder ??
          (context, state) => getPage(state: state, child: child!),
      routes: routes,
    );
  }

  static Page getPage({required Widget child, required GoRouterState state}) {
    // Check if we're running on web
    if (const bool.fromEnvironment('dart.library.html')) {
      // On web, always use MaterialPage
      return MaterialPage(key: state.pageKey, child: child);
    }

    // On mobile platforms, use platform-specific pages
    try {
      return Platform.isIOS
          ? CupertinoPage(key: state.pageKey, child: child)
          : MaterialPage(key: state.pageKey, child: child);
    } catch (e) {
      // Fallback to MaterialPage if platform check fails
      return MaterialPage(key: state.pageKey, child: child);
    }
  }
}

/// A page that fades in an out.
class FadeTransitionPage extends CustomTransitionPage<void> {
  /// Creates a [FadeTransitionPage].
  FadeTransitionPage({
    required LocalKey super.key,
    required super.child,
  }) : super(
            transitionsBuilder: (BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child) =>
                FadeTransition(
                  opacity: animation.drive(_curveTween),
                  child: child,
                ));

  static final CurveTween _curveTween = CurveTween(curve: Curves.easeIn);
}
