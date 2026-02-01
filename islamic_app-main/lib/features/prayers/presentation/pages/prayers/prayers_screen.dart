import 'dart:async';
// import 'package:flutter/foundation.dart';
import 'package:deenhub/hijri_date/calendar_type.dart';
import 'package:deenhub/hijri_date/hijri_date_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/common/enums/prayer_calculation_method_type.dart';
import 'package:deenhub/common/enums/prayer_madhab.dart';
import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/common/prayers/prayer_times_helper.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/bloc/data_state.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/notification/services/prayer_notification_service.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/utils/date_time_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/common_widgets.dart';
import 'package:deenhub/core/widgets/dialog/radio_list_dialog.dart';
import 'package:deenhub/core/widgets/dotted_line.dart';
import 'package:deenhub/core/widgets/image_view.dart';
import 'package:deenhub/core/widgets/menu_anchor_view.dart';
import 'package:deenhub/features/location/data/entity/location_data.dart';
import 'package:deenhub/features/location/presentation/bloc/location_bloc.dart';
import 'package:deenhub/features/location/presentation/dialogs/getting_current_location_dialog.dart';
import 'package:deenhub/features/onboarding/presentation/blocs/onboard_settings_bloc.dart';
import 'package:deenhub/features/settings/data/entity/notification_settings_data.dart';
import 'package:deenhub/features/settings/presentation/widgets/settings_item_view.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_item.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_location_data.dart';
import 'package:deenhub/features/prayers/presentation/pages/prayers/prayers_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/hijri_date/hijri_date_time.dart';
import 'package:deenhub/main.dart';
import 'package:share_plus/share_plus.dart';

import 'prayer_item_view.dart';

class PrayersScreen extends StatefulWidget {
  const PrayersScreen({super.key});

  @override
  State<PrayersScreen> createState() => _PrayersScreenState();
}

class _PrayersScreenState extends State<PrayersScreen>
    with WidgetsBindingObserver {
  Timer? _periodicTimer;
  PrayerLocationData? data;
  LocationData? locData;
  bool isCountdown = false;
  HijriDateTime today = HijriDateTime.now();
  late HijriDateTime dateTime;
  int _secondsCounter = 0; // Counter to track seconds for optimization

  @override
  void initState() {
    super.initState();
    dateTime = today;
    data = getIt<SharedPrefsHelper>().prayerLocationDataOrNull;
    locData = data?.toLocationData();
    if (locData != null && data != null) {
      initPrayerTimings();
    }
    WidgetsBinding.instance.addObserver(this);
    _startPeriodicTimer();
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state case AppLifecycleState.resumed) {
      logger.i("App Resumed");
      data = getIt<SharedPrefsHelper>().prayerLocationDataOrNull;
      setState(() {
        _updateTime();
        _startPeriodicTimer();
      });
    } else if (state case AppLifecycleState.paused) {
      logger.i("App Paused");
      _periodicTimer?.cancel();
    }
  }

  void _startPeriodicTimer() {
    _periodicTimer?.cancel(); // Cancel existing timer if any

    // Start timer immediately for first update
    _updateTimerCallback();

    // Update every second for real-time countdown
    const oneSecond = Duration(seconds: 1);
    _periodicTimer = Timer.periodic(oneSecond, (Timer timer) {
      _updateTimerCallback();
    });
  }

  void _updateTimerCallback() {
    final now = DateTime.now();

    // Check if current upcoming prayer has passed (countdown reached 0)
    bool shouldForceUpdate = false;
    if (locData?.prayerTimes != null) {
      final upcomingPrayerList =
          locData!.prayerTimes!.where((item) => item.isUpcoming);
      if (upcomingPrayerList.isNotEmpty) {
        final upcomingPrayer = upcomingPrayerList.first;
        final difference =
            upcomingPrayer.time.copyWith(second: 0).difference(now);
        if (difference.isNegative || difference.inSeconds == 0) {
          shouldForceUpdate = true;
          logger.i('Prayer time passed, forcing immediate update');
        }
      }
    }

    setState(() {
      _secondsCounter++;

      // Update current time every second for real-time countdown
      if (locData != null) {
        locData = locData!.copyWith(
          currentTime: now,
        );
      }

      // Recalculate prayer timings on first run, when prayer passes, new day, or every minute for efficiency
      if (_secondsCounter == 1 ||
          shouldForceUpdate ||
          _secondsCounter % 60 ==
              0 || // Recalculate every minute for data accuracy
          (locData != null &&
              locData!.currentTime != null &&
              locData!.currentTime!.day != now.day)) {
        _updateTime();
      }
    });
  }

  void _updateTime() {
    today = HijriDateTime.now();
    dateTime = today;
    initPrayerTimings();
  }

  void initPrayerTimings() {
    if (locData == null || data == null) return;
    locData = PrayerTimesHelper.getPrayerTimings(
      locData!,
      data!,
      time: dateTime.toDateTime(),
      fetchOnlyMandatory: false,
    );
    logger.i("loc: ${locData!.prayerTimes.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: context.primaryColor,
        child: (locData == null || data == null)
            ? _buildEnableLocationCta(context)
            : _buildLocationSuccessState(),
      ),
    );
  }

  Widget _buildLocationSuccessState() {
    // Update current time to ensure real-time accuracy
    final currentTime = DateTime.now();
    final updatedLocData = locData!.copyWith(currentTime: currentTime);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrayersAppBar(
          currentLoc: updatedLocData,
          upcomingPrayer:
              updatedLocData.prayerTimes!.lastWhere((item) => item.isUpcoming),
        ),
        _buildViewsContainer().expanded(),
      ],
    );
  }

  Widget _buildEnableLocationCta(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 64, color: Colors.white),
            gapH16,
            const Text(
              'Enable location to get accurate prayer times and notifications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            gapH8,
            const Text(
              'You can enable it now or later from settings.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            gapH16,
            ElevatedButton(
              onPressed: () {
                context.pushNamed(Routes.getPrayerTimesOnboard.name);
              },
              child: const Text('Set up location'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewsContainer() {
    return BlocListener<OnboardSettingsBloc, Ds<OnboardSettingsState>>(
      bloc: getIt<OnboardSettingsBloc>(),
      listener: _handleListeners,
      child: ClipRRect(
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(24),
          topEnd: Radius.circular(24),
        ),
        child: Container(
          color: context.surfaceColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCurrentDateView(),
              const AppDivider(),
              SingleChildScrollView(
                child: Column(
                  children: [
                    if (locData?.prayerTimes != null)
                      _buildSalahItemsListView(locData!.prayerTimes!),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: ThemeColors.lightGray2,
                      ),
                      margin: px16,
                      child: Column(
                        children: [
                          SettingsItemView(
                            title: context.tr(LocaleKeys.calcMethod),
                            subtitle: data?.calculationMethod.label,
                            onTap: () {
                              _openCalculationMethodSettings();
                            },
                          ),
                          const AppDivider().withPadding(px16),
                          SettingsItemView(
                            title: context.tr(LocaleKeys.juristic),
                            subtitle: data?.asrMethod.label,
                            onTap: () {
                              _openPrayerMadhabDialog();
                            },
                          ),
                          const AppDivider().withPadding(px16),
                          SettingsItemView(
                            title: context.tr("Prayer Notifications"),
                            subtitle: "Manage prayer notifications",
                            onTap: () {
                              _managePrayerNotifications();
                            },
                          ),
                        ],
                      ),
                    ),
                    gapH16,
                    // Debug notification buttons (only in debug mode)
                    // _buildDebugNotificationButtons(),
                  ],
                ),
              ).expanded(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _managePrayerNotifications() async {
    final notificationSettings =
        getIt<SharedPrefsHelper>().notificationSettingsData;

    final updatedSettings = await context.pushNamed<NotificationSettingsData>(
      Routes.prayerNotificationSettings.name,
      extra: notificationSettings,
    );

    if (updatedSettings != null) {
      getIt<SharedPrefsHelper>().setNotificationSettings = updatedSettings;

      // Reschedule notifications with new settings
      if (locData?.prayerTimes != null && data != null) {
        await getIt<PrayerNotificationService>().schedulePrayerNotifications(
          locData!.prayerTimes!,
          data!,
        );
      }
    }
  }

  Widget _buildCurrentDateView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildDateView().expanded(),
        gapW8,
        ImageView(
          imagePath: Icons.event_rounded,
          color: ThemeColors.darkGray,
          padding: p8,
          onTap: () {
            context.pushNamed(Routes.prayersCalendar.name);
          },
        ),
        // gapW8,
        // _buildMoreOptionsView(),
        gapW16,
      ],
    );
  }

  Widget _buildDateView() {
    final calendarType = CalendarType.gregorian;
    final nextDay =
        today.toDateTime().add(const Duration(days: 1)).toHijriDate();
    final nextSecondDay =
        today.toDateTime().add(const Duration(days: 2)).toHijriDate();
    final nextThirdDay =
        today.toDateTime().add(const Duration(days: 3)).toHijriDate();

    return MenuAnchorView(
      alignmentOffset: const Offset(24, 0),
      menuChildren: [
        getMenuItemView(
          context,
          label: context.tr(LocaleKeys.today),
          title: today.toDateTime().format(),
          subtitle: today.toFormat(),
          onPressed: () {
            selectDate(calendarType, today);
          },
        ),
        getMenuItemView(
          context,
          title: nextDay.toDateTime().format(),
          subtitle: nextDay.toFormat(),
          onPressed: () {
            selectDate(calendarType, nextDay);
          },
        ),
        getMenuItemView(
          context,
          title: nextSecondDay.toDateTime().format(),
          subtitle: nextSecondDay.toFormat(),
          onPressed: () {
            selectDate(calendarType, nextSecondDay);
          },
        ),
        getMenuItemView(
          context,
          title: nextThirdDay.toDateTime().format(),
          subtitle: nextThirdDay.toFormat(),
          onPressed: () {
            selectDate(calendarType, nextThirdDay);
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dateTime.toDateTime().format(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.onSurfaceColor,
                  overflow: TextOverflow.ellipsis,
                ),
              ).tr(context: context).expanded(),
              const ImageView(
                imagePath: Icons.keyboard_arrow_down_rounded,
                color: ThemeColors.darkGray,
              ),
            ],
          ),
          Text(
            dateTime.toFormat(),
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 16,
              color: ThemeColors.darkGray,
            ),
          ).tr(context: context),
        ],
      ).withPadding(const EdgeInsetsDirectional.only(
          start: 24, end: 8, top: 10, bottom: 10)),
    );
  }

  Widget _buildSalahItemsListView(List<PrayerItem> salahItems) {
    final notificationSettings =
        getIt<SharedPrefsHelper>().notificationSettingsData;
    // Use real-time current time for accurate calculations (updated every second)
    final currentTime = DateTime.now();

    return ListView.separated(
      padding: p16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        return (salahItems.elementAtOrNull(index + 1)?.showDivider == true)
            ? DottedLine(dashColor: context.outlineVariantColor)
                .withPadding(py8)
            : gapH4;
      },
      itemCount: salahItems.length,
      itemBuilder: (context, index) {
        final item = salahItems[index];
        // Allow notifications for both mandatory prayers and Qiyam
        final isNotifiable =
            item.type.isMandatory || item.type == PrayerType.qiyam;
        final isEnabled =
            isNotifiable && notificationSettings.isPrayerEnabled(item.type);

        return InkWell(
          onTap:
              isNotifiable ? () => _togglePrayerNotification(item.type) : null,
          child: PrayerItemView(
            item: item,
            isCountdown: isCountdown,
            currentTime: currentTime,
            reminderOn: isEnabled,
          ),
        );
      },
    );
  }

  void _togglePrayerNotification(PrayerType prayerType) {
    final settings = getIt<SharedPrefsHelper>().notificationSettingsData;
    final isCurrentlyEnabled = settings.isPrayerEnabled(prayerType);

    final updatedMap = Map<String, bool>.from(settings.prayerNotifications);
    updatedMap[prayerType.name] = !isCurrentlyEnabled;

    final updatedSettings = settings.copyWith(
      prayerNotifications: updatedMap,
    );

    getIt<SharedPrefsHelper>().setNotificationSettings = updatedSettings;

    // Reschedule notifications with the updated settings
    if (locData?.prayerTimes != null && data != null) {
      getIt<PrayerNotificationService>().schedulePrayerNotifications(
        locData!.prayerTimes!,
        data!,
      );
    }

    setState(() {});
  }

  Future<void> _openCalculationMethodSettings() async {
    final value = await context.pushNamed<String>(
      Routes.calculationMethodSettings.name,
      pathParameters: {'method': data!.calculationMethod.name},
    );
    if (value == null) return;

    setState(() {
      final method = PrayerCalculationMethodType.values.byName(value);
      data = data?.copyWith(calculationMethod: method);
      getIt<SharedPrefsHelper>().setPrayerLocationData = data!;
      initPrayerTimings();
    });
  }

  Future<void> _openPrayerMadhabDialog() async {
    final value = await context.showDialogNow<PrayerMadhab>(
      child: RadioListDialog<PrayerMadhab>(
        list: PrayerMadhab.values,
        selectedValue: data!.asrMethod,
        title: context.tr(LocaleKeys.juristic),
        getItemLabel: (item) => item.label,
        getItemSubtitle: (item) => item.subtitle,
      ),
    );
    if (value == null) return;

    setState(() {
      data = data?.copyWith(asrMethod: value);
      getIt<SharedPrefsHelper>().setPrayerLocationData = data!;
      initPrayerTimings();
    });
  }

  void selectDate(CalendarType calendarType, HijriDateTime selectedDate) {
    if (!isSameDay(calendarType, dateTime, selectedDate)) {
      setState(() {
        dateTime = selectedDate;
      });
    }
  }

  void shareData(BuildContext context) {
    final text =
        'Prayer times for ${locData?.currentTime?.format(pattern: dayFormatPattern)} (${locData?.locName})\n${locData?.prayerTimes!.map((e) => '${e.time.time()}  ${e.type.label}').join('\n')}\n\nAndroid app: market://details?id=com.kabbo.deenhub\niOS app: market://details?id=com.kabbo.deenhub';

    final box = context.findRenderObject() as RenderBox?;
    Share.share(text,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }

  void _handleListeners(BuildContext context, Ds<OnboardSettingsState> state) =>
      state.whenOrNull(
        loading: () {
          context.showDialogNow(
            barrierDismissible: true,
            child: const GettingCurrentLocationDialog(),
          );
          return null;
        },
        success: (sData) => sData.when(currentLocationFetched:
            (position, locName, country, localTimezone) {
          context.pop();

          getIt<LocationBloc>().add(LocationEvent.setCurrentLocation(
            locData!.copyWith(
              lat: position.latitude,
              lng: position.longitude,
              locName: locName,
              timezone: localTimezone,
            ),
          ));
          return null;
        }),
        error: (error) {
          return context.showErrorSnackBar(error);
        },
      );

  // Debug: Add test notification buttons (remove after testing)
  Widget _buildDebugNotificationButtons() {
    if (kDebugMode) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Debug Notifications'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await getIt<PrayerNotificationService>()
                          .testNotification();
                      context.showSnackBar('Test notification sent');
                    },
                    child: const Text('Test Now'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await getIt<PrayerNotificationService>()
                          .testScheduledNotification();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Test scheduled for 10s')),
                      );
                    },
                    child: const Text('Test 10s'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await getIt<PrayerNotificationService>()
                      .testExactMinuteNotification();
                  final now = DateTime.now();
                  final nextMinute = DateTime(now.year, now.month, now.day,
                      now.hour, now.minute + 1, 0);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '⏰ Exact minute test scheduled for ${nextMinute.hour.toString().padLeft(2, '0')}:${nextMinute.minute.toString().padLeft(2, '0')}:00'),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('🎯 Test Exact After 1 Minute'),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
