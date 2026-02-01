import 'dart:convert';
import 'package:deenhub/config/routes/app_router.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/features/quran/data/repository/quran_service.dart';
import 'package:deenhub/core/notification/services/prayer_notification_service.dart';
import 'package:deenhub/main.dart';
import 'package:go_router/go_router.dart';

class NotificationNavigationService {
  static void handleNavigation(String payload) {
    try {
      logger.i('Handling notification navigation with payload: $payload');

      // Try to parse as JSON first (for daily goals notifications)
      try {
        final Map<String, dynamic> jsonPayload = json.decode(payload);
        final type = jsonPayload['type'] as String?;
        
        if (type != null) {
          _handleJsonPayload(jsonPayload, type);
          return;
        }
      } catch (e) {
        // Not JSON, continue with colon-separated parsing
        logger.d('Payload is not JSON, parsing as colon-separated string');
      }

      // Parse colon-separated payload (for legacy notifications)
      final parts = payload.split(':');
      if (parts.isEmpty) return;

      final type = parts[0];

      switch (type) {
        case 'prayer_time':
          _navigateToPrayersTab();
          break;
        case 'friday_kahf':
          if (parts.length > 1) {
            final surahNumber = int.tryParse(parts[1]);
            if (surahNumber != null) {
              _navigateToSurahKahf(surahNumber);
            }
          }
          break;
        case 'surah_mulk':
          if (parts.length > 1) {
            final surahNumber = int.tryParse(parts[1]);
            if (surahNumber != null) {
              _navigateToSurahMulk(surahNumber);
            }
          }
          break;
        case 'memorization':
          if (parts.length > 2) {
            final surahNumber = int.tryParse(parts[1]);
            final verseNumber = int.tryParse(parts[2]);
            if (surahNumber != null && verseNumber != null) {
              _navigateToMemorizationVerse(surahNumber, verseNumber);
            }
          }
          break;
        case 'sunnah_fasting':
          _navigateToFastingInfo();
          break;
        case 'zakat_reminder':
          _navigateToZakatCalculator();
          break;
        case 'daily_scheduler':
          _handleDailyScheduler();
          break;
        default:
          logger.w('Unknown notification payload type: $type');
      }
    } catch (e) {
      logger.e('Error handling notification navigation: $e');
    }
  }

  static void _handleJsonPayload(Map<String, dynamic> payload, String type) {
    switch (type) {
      case 'goal_reminder':
        _navigateToDailyGoals();
        break;
      case 'goal_completion':
        _navigateToDailyGoals();
        break;
      case 'motivation':
        _navigateToDailyGoals();
        break;
      case 'progress_check':
        _navigateToDailyGoals();
        break;
      case 'weekly_review':
        _navigateToDailyGoals();
        break;
      case 'streak_milestone':
        _navigateToDailyGoals();
        break;
      default:
        logger.w('Unknown JSON notification payload type: $type');
    }
  }

  static void _navigateToPrayersTab() {
    // Navigate to prayers tab (index 2 based on NavigationBarItems)
    final context = AppRouter.parentNavigatorKey.currentContext;
    if (context != null) {
      // Use GoRouter to navigate to the prayers route
      context.goNamed(Routes.prayers.name);
      logger.i('Navigated to prayers tab from notification');
    }
  }

  static void _navigateToDailyGoals() {
    // Navigate to main dashboard where daily goals are displayed
    final context = AppRouter.parentNavigatorKey.currentContext;
    if (context != null) {
      try {
        // Navigate to main dashboard/home page where daily goals are shown
        context.goNamed(Routes.main.name);
        logger.i('Navigated to main dashboard for daily goals');
      } catch (e) {
        logger.e('Error navigating to daily goals: $e');
      }
    }
  }

  static void _navigateToSurahKahf(int surahNumber) {
    final context = AppRouter.parentNavigatorKey.currentContext;
    if (context != null) {
      try {
        final quranService = QuranService();
        final surah = quranService.getSurah(surahNumber);

        // Navigate to reading mode screen for Surah Al-Kahf starting from verse 1
        context.pushNamed(
          Routes.quranReadingMode.name,
          queryParameters: {
            'surahId': surah.number.toString(),
            'verseId': '1',
          },
        );
      } catch (e) {
        logger.e('Error navigating to Surah Al-Kahf: $e');
      }
    }
  }

  static void _navigateToSurahMulk(int surahNumber) {
    final context = AppRouter.parentNavigatorKey.currentContext;
    if (context != null) {
      try {
        final quranService = QuranService();
        final surah = quranService.getSurah(surahNumber);

        // Navigate to reading mode screen for Surah Al-Mulk starting from verse 1
        context.pushNamed(
          Routes.quranReadingMode.name,
          queryParameters: {
            'surahId': surah.number.toString(),
            'verseId': '1',
          },
        );
        logger.i('Successfully navigated to Surah Al-Mulk');
      } catch (e) {
        logger.e('Error navigating to Surah Al-Mulk: $e');
        // Fallback navigation to Quran main page
        try {
          context.pushNamed(Routes.quran.name);
        } catch (fallbackError) {
          logger.e('Fallback navigation also failed: $fallbackError');
        }
      }
    }
  }

  static void _navigateToMemorizationVerse(int surahNumber, int verseNumber) {
    final context = AppRouter.parentNavigatorKey.currentContext;
    if (context != null) {
      try {
        final quranService = QuranService();

        // Ensure QuranService is initialized
        if (!quranService.isInitialized) {
          logger
              .w('QuranService not initialized, navigating to Quran main page');
          context.pushNamed(Routes.quran.name);
          return;
        }

        final surah = quranService.getSurah(surahNumber);

        // Navigate to verse view screen for memorization with the specific verse
        // This ensures user goes to the exact verse they were memorizing
        context.pushNamed(
          Routes.verseView.name,
          queryParameters: {
            'surahId': surah.number.toString(),
            'verseId': verseNumber.toString(),
            'isMemorizationMode': 'true',
          },
        );
        logger.i(
            'Successfully navigated to memorization verse: Surah $surahNumber (${surah.englishName}), Verse $verseNumber');
      } catch (e) {
        logger.e('Error navigating to memorization verse: $e');
        // Fallback navigation to Quran main page
        try {
          context.pushNamed(Routes.quran.name);
        } catch (fallbackError) {
          logger.e('Fallback navigation also failed: $fallbackError');
        }
      }
    }
  }

  static void _navigateToFastingInfo() {
    final context = AppRouter.parentNavigatorKey.currentContext;
    if (context != null) {
      try {
        // Navigate to main dashboard/home page where fasting info can be accessed
        context.goNamed(Routes.main.name);
        logger.i('Navigated to main page for Sunnah fasting info');
      } catch (e) {
        logger.e('Error navigating for Sunnah fasting notification: $e');
      }
    }
  }

  static void _navigateToZakatCalculator() {
    final context = AppRouter.parentNavigatorKey.currentContext;
    if (context != null) {
      try {
        // Navigate to main dashboard where user can access Zakat calculator
        // Since we don't know the exact route name, navigate to main
        context.goNamed(Routes.zakat.name);
        logger.i('Navigated to main page for Zakat calculator access');
      } catch (e) {
        logger.e('Error navigating for Zakat notification: $e');
      }
    }
  }

  static void _handleDailyScheduler() {
    try {
      logger.i('Daily scheduler notification triggered - refreshing prayer notifications');

      // Reset the scheduling state to force a fresh schedule
      // This ensures we don't skip scheduling due to the "already scheduled today" check
      final prayerService = PrayerNotificationService();
      
      // Schedule notifications for the new day
      prayerService.refreshTodayNotifications();

      logger.i('Daily prayer notifications refreshed successfully');
    } catch (e) {
      logger.e('Error handling daily scheduler notification: $e');
    }
  }
}
