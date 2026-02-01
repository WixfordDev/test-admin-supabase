import 'package:deenhub/features/nearby_mosques/presentation/cubit/nearby_mosque_cubit.dart';
import 'package:deenhub/features/settings/presentation/pages/settings/select_time_zone_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/common/enums/prayer_calculation_method_type.dart';
import 'package:deenhub/common/enums/prayer_madhab.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/text_styles.dart';
import 'package:deenhub/core/bloc/data_state.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/utils/primitive_utils.dart';
import 'package:deenhub/core/utils/date_time_utils.dart';
import 'package:deenhub/core/widgets/edit_text/input_edit_text.dart';
import 'package:deenhub/features/location/presentation/bloc/location_bloc.dart';
import 'package:deenhub/features/onboarding/presentation/widgets/onboard_app_bar_scaffold.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_location_data.dart';
import 'package:deenhub/main.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:deenhub/core/notification/notification_manager.dart';
import 'package:deenhub/core/notification/notification_types.dart';
import 'package:deenhub/core/notification/services/prayer_notification_service.dart';
import 'package:deenhub/core/notification/services/friday_kahf_notification_service.dart';
import 'package:deenhub/core/notification/services/daily_goals_notification_service.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'dart:io';

class LocationDetailsOnboardScreen extends StatefulWidget {
  static const argLocLat = 'locLat';
  static const argLocLng = 'locLng';
  static const argLocName = 'locName';
  static const argAsrMethod = 'asrMethod';
  static const argCountry = 'country';
  static const argFetchOnly = 'fetchOnly';

  final Map<String, String> queryParams;

  const LocationDetailsOnboardScreen({super.key, required this.queryParams});

  @override
  State<LocationDetailsOnboardScreen> createState() =>
      _LocationDetailsOnboardScreenState();
}

class _LocationDetailsOnboardScreenState
    extends State<LocationDetailsOnboardScreen> {
  final TextEditingController locNameController = TextEditingController();
  final TextEditingController locLatController = TextEditingController();
  final TextEditingController locLngController = TextEditingController();
  final TextEditingController timezoneController = TextEditingController();

  double locLat = 0;
  double locLng = 0;
  String country = '';
  String deviceTimezone = '';
  String timezone = '';

  @override
  void initState() {
    super.initState();
    initLocDetails();
  }

  @override
  void dispose() {
    locNameController.dispose();
    locLatController.dispose();
    locLngController.dispose();
    timezoneController.dispose();
    super.dispose();
  }

  void initLocDetails() {
    // Device time
    deviceTimezone =
        widget.queryParams[SelectTimezoneScreen.argDeviceTimezone]!;
    timezone = deviceTimezone;

    // Location
    locLat =
        widget.queryParams[LocationDetailsOnboardScreen.argLocLat].toDouble;
    locLng =
        widget.queryParams[LocationDetailsOnboardScreen.argLocLng].toDouble;
    final locName =
        widget.queryParams[LocationDetailsOnboardScreen.argLocName].orEmpty;
    country =
        widget.queryParams[LocationDetailsOnboardScreen.argCountry].orEmpty;

    locLatController.text = locLat.toString();
    locLngController.text = locLng.toString();
    locNameController.text = locName;

    getTimezone();
  }

  void getTimezone() {
    final timezoneLoc = tz.getLocation(timezone);
    tz.setLocalLocation(timezoneLoc);

    setState(() {
      timezoneController.text = '${timezoneLoc.offsetGMT} ${timezoneLoc.name}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationBloc, Ds<LocationState>>(
      bloc: getIt<LocationBloc>(),
      listener: _handleListeners,
      child: OnboardAppBarScaffold(
        pageTitle: context.tr(LocaleKeys.locationInfoTitleConfirm),
        resizeToAvoidBottomInset: false,
        onNextButtonClick: _handleNextButtonClick,
        children: [
          gapH32,
          InputEditText(
            controller: locNameController,
            label: context.tr(LocaleKeys.locationName),
          ),
          gapH16,
          _buildLatLngView(),
          gapH16,
          InputEditText(
            controller: timezoneController,
            label: context.tr(LocaleKeys.timeZone),
            readOnly: true,
            onTap: () {
              _openSelectTimeZoneScreen();
            },
          ),
          gapH16,
        ],
      ),
    );
  }

  Widget _buildLatLngView() {
    return Table(
      children: [
        TableRow(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputEditText(
                controller: locLatController,
                label: context.tr(LocaleKeys.latitudeDegree),
                inputType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                onValueSaved: (value) =>
                    locLat = double.tryParse(value ?? '') ?? 0,
                onValueChanged: (value) =>
                    setState(() => locLat = double.tryParse(value ?? '') ?? 0),
              ),
              const SizedBox(height: 16),
              InputEditText(
                controller: locLngController,
                label: context.tr(LocaleKeys.longitudeDegree),
                inputType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                onValueSaved: (value) =>
                    locLng = double.tryParse(value ?? '') ?? 0,
                onValueChanged: (value) =>
                    setState(() => locLng = double.tryParse(value ?? '') ?? 0),
              ),
            ],
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.fill,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  locLat.convertDegrees(true),
                  style: TextStyles.titleTextStyle(context),
                ),
                const SizedBox(height: 16),
                Text(
                  locLng.convertDegrees(false),
                  style: TextStyles.titleTextStyle(context),
                ),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  Future<void> _openSelectTimeZoneScreen() async {
    final value = await context.pushNamed<String>(
      Routes.selectTimeZone.name,
      queryParameters: {
        SelectTimezoneScreen.argZone: timezone,
        SelectTimezoneScreen.argDeviceTimezone: deviceTimezone,
      },
    );

    if (value == null) return;

    timezone = value;
    getTimezone();
  }

  Future<void> _handleNextButtonClick() async {
    try {
      final madhab = getPrayerMadhab(locLat, locLng);
      final method = getPrayerCalculationMethod(country);
      logger.d('Madhab: $madhab | Method: $method');

      final data = PrayerLocationData(
        locName: locNameController.text,
        lat: locLat,
        lng: locLng,
        timezone: timezone,
        country: country,
        calculationMethod: method,
        asrMethod: madhab,
      );

      // Save location data first
      getIt<SharedPrefsHelper>().setPrayerLocationData = data;
      getIt<SharedPrefsHelper>().setInitialSetupDone = true;

      // Setup all notifications
      await _setupInitialNotifications();
      _preloadNearbyMosques();

      if (mounted) {
        // Navigate to next step without showing notification setup
        context.goNamed(Routes.home.name);
      }
    } catch (e) {
      logger.e('Error saving location data: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                        'Failed to save location data. Please try again.')),
              ],
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _handleNextButtonClick,
            ),
          ),
        );
      }
    }
  }

  Future<void> _setupInitialNotifications() async {
    try {
      // 1. Request battery optimization disable for Android
      await _requestBatteryOptimizationDisable();

      // 2. Get the centralized notification services from dependency injection
      // These are already initialized in app_injections.dart
      logger.i(
          'Setting up initial notifications using dependency-injected services...');
      final notificationManager = getIt<NotificationManager>();
      final prayerService = getIt<PrayerNotificationService>();
      final fridayKahfService = getIt<FridayKahfNotificationService>();
      final dailyGoalsService = getIt<DailyGoalsNotificationService>();

      // 3. Setup prayer notifications now that location is available
      logger.i('Setting up prayer time notifications...');
      await prayerService.initialize();
      // The prayer service will automatically schedule today's prayers
      // when it detects that location data is now available

      // 4. Setup Friday Surah Al-Kahf notifications
      logger.i('Setting up Friday Surah Al-Kahf notifications...');
      await fridayKahfService.scheduleFridayKahfNotifications();

      // 5. Setup daily goals notifications
      logger.i('Setting up daily goals notifications...');
      await dailyGoalsService.scheduleWeeklyGoalReview();

      // 6. Schedule Sunnah fasting notifications (Monday and Thursday)
      logger.i('Setting up Sunnah fasting notifications...');
      await _scheduleSunnahFastingNotifications(notificationManager);

      logger.i('All notification setup completed successfully');
    } catch (e) {
      logger.e('Error setting up notifications: $e');
      rethrow;
    }
  }

  /// Preload nearby mosques data in background for faster screen loading
  void _preloadNearbyMosques() {
    try {
      // Only preload if onboarding is complete and location data exists
      if (getIt<SharedPrefsHelper>().prayerLocationData != null) {
        logger.i('Preloading nearby mosques data in background...');

        // Get the cubit and start fetching (don't await - let it run in background)
        final nearbyMosqueCubit = getIt<NearbyMosqueCubit>();
        nearbyMosqueCubit.fetchNearbyMosques().then((_) {
          logger.i('Nearby mosques preloaded successfully');
        }).catchError((error) {
          logger.w('Failed to preload nearby mosques: $error');
          // Don't block navigation if preloading fails
        });
      }
    } catch (e) {
      logger.w('Error starting mosque preload: $e');
      // Don't block navigation if preload setup fails
    }
  }

  /// Schedule Sunnah fasting notifications (Monday and Thursday)
  Future<void> _scheduleSunnahFastingNotifications(
      NotificationManager notificationManager) async {
    try {
      // Schedule Monday fasting reminder (Sunday evening)
      await _scheduleDayOfWeekNotification(
        notificationManager,
        DateTime.sunday,
        'Sunnah Reminder: Fast on Monday',
        'Make your intention tonight! Fasting Monday brings blessings. Follow the Sunnah & earn reward.',
        'sunnah_fasting:monday',
        18, // 6:00 PM
        0,
      );

      // Schedule Thursday fasting reminder (Wednesday evening)
      await _scheduleDayOfWeekNotification(
        notificationManager,
        DateTime.wednesday,
        'Sunnah Reminder: Fast on Thursday',
        'Make your intention tonight! Fasting Thursday brings blessings. Follow the Sunnah & earn reward.',
        'sunnah_fasting:thursday',
        18, // 6:00 PM
        0,
      );

      logger
          .i('Scheduled Sunnah fasting notifications for Monday and Thursday');
    } catch (e) {
      logger.e('Error scheduling Sunnah fasting notifications: $e');
    }
  }

  /// Schedule notification for specific day of week
  Future<void> _scheduleDayOfWeekNotification(
    NotificationManager notificationManager,
    int dayOfWeek,
    String title,
    String body,
    String payload,
    int hour,
    int minute,
  ) async {
    try {
      // Calculate the next occurrence of the specified day and time
      final now = DateTime.now();
      var targetDate = DateTime(now.year, now.month, now.day, hour, minute);

      // Find the next occurrence of the specified day of week
      while (targetDate.weekday != dayOfWeek) {
        targetDate = targetDate.add(const Duration(days: 1));
      }

      // If the target time has already passed today and it's the correct day, schedule for next week
      if (targetDate.isBefore(now) && now.weekday == dayOfWeek) {
        targetDate = targetDate.add(const Duration(days: 7));
      }

      // Choose appropriate notification type based on day
      final notificationType = dayOfWeek == DateTime.sunday
          ? NotificationType.mondayFasting
          : NotificationType.thursdayFasting;

      await notificationManager.scheduleNotification(
        type: notificationType,
        title: title,
        body: body,
        scheduledDate: targetDate,
        payload: payload,
      );
    } catch (e) {
      logger.e('Error scheduling day-of-week notification: $e');
    }
  }

  Future<void> _requestBatteryOptimizationDisable() async {
    try {
      if (Platform.isAndroid) {
        logger.i('Checking battery optimization status...');

        // Check if battery optimization is enabled
        bool? isBatteryOptimizationDisabled =
            await DisableBatteryOptimization.isBatteryOptimizationDisabled;

        if (isBatteryOptimizationDisabled == false) {
          logger.i('Battery optimization is enabled, requesting to disable...');

          if (mounted) {
            // Show a dialog explaining why we need this permission
            final shouldRequest = await _showBatteryOptimizationDialog();

            if (shouldRequest) {
              // Request to disable battery optimization
              await DisableBatteryOptimization
                  .showDisableBatteryOptimizationSettings();
            }
          }
        } else {
          logger.i(
              'Battery optimization is already disabled or could not be determined');
        }
      }
    } catch (e) {
      logger.e('Error handling battery optimization: $e');
      // Don't rethrow as this is not critical for the app to function
    }
  }

  Future<bool> _showBatteryOptimizationDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Battery Optimization'),
              content: const Text(
                'To ensure prayer time notifications work properly, please allow this app to run in the background by disabling battery optimization.\n\n'
                'This will help ensure you never miss a prayer notification.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Skip'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Allow'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _handleListeners(BuildContext context, Ds<LocationState> state) =>
      state.whenOrNull(
        success: (data) => data.whenOrNull(
          locationSet: () {
            getIt<SharedPrefsHelper>().setInitialSetupDone = true;

            if (mounted) {
              context.goNamed(Routes.home.name);
            }
            return null;
          },
        ),
      );
}
