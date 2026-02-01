import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/bloc/data_state.dart';
import 'package:deenhub/core/widgets/button/outlined_button_view.dart';
import 'package:deenhub/core/widgets/loading_view.dart';
import 'package:deenhub/features/onboarding/presentation/blocs/onboard_settings_bloc.dart';
import 'package:deenhub/features/onboarding/presentation/pages/location_details_onboard_screen.dart';
import 'package:deenhub/features/onboarding/presentation/widgets/onboard_app_bar_scaffold.dart';
import 'package:deenhub/features/settings/presentation/pages/settings/select_time_zone_screen.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';

// ignore: must_be_immutable
class GetPrayerTimesOnboardScreen extends StatelessWidget {
  GetPrayerTimesOnboardScreen({super.key});

  bool isGPS = false;
  final bloc = OnboardSettingsBloc();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardSettingsBloc, Ds<OnboardSettingsState>>(
      bloc: bloc,
      listenWhen: (previous, current) => current is SuccessState || current is ErrorState,
      buildWhen: (previous, current) => current is! SuccessState,
      listener: _handleListeners,
      builder: (context, state) {
        return OnboardAppBarScaffold(
          pageTitle: state is LoadingState
              ? context.tr(LocaleKeys.gettingCurrentLocation)
              : context.tr(LocaleKeys.getYourPrayerTimes),
          showBackButton: false,
          showNextButton: false,
          children: [
            if (state is LoadingState) ...[
              const LoadingView(),
              gapH60,
              TextButton(
                onPressed: () {
                  bloc.add(const OnboardSettingsEvent.cancelFetchingCurrentLocation());
                },
                child: Text(
                  context.tr(LocaleKeys.cancel),
                  style: const TextStyle(
                    color: ThemeColors.black,
                    fontSize: 22,
                  ),
                ),
              ),
            ] else ...[
              gapH12,
              // Permission explanation
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Enable Location for Accurate Prayer Times',
                    style: TextStyle(
                      color: ThemeColors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'To give you the best experience, DeenHub uses your location to:\n\n• Calculate precise prayer times\n• Show nearby mosques\n• Send prayer reminders (optional)\n\nWe\'ll ask for permission on the next screen.',
                    style: TextStyle(
                      color: ThemeColors.darkGray,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              gapH12,
              // Continue to permission request
              OutlinedButtonView(
                text: 'Continue',
                onPressed: () {
                  isGPS = true;
                  bloc.add(const OnboardSettingsEvent.getCurrentLocation());
                },
              ),
              gapH12,
              // OutlinedButtonView(
              //   text: context.tr(LocaleKeys.searchInternet),
              //   onPressed: () {
              //     isGPS = false;
              //     bloc.add(const OnboardSettingsEvent.getCurrentLocation());
              //   },
              // ),
              // gapH12,
              // OutlinedButtonView(
              //   text: context.tr(LocaleKeys.selectManual),
              //   onPressed: () {
              //     context.pushNamed(Routes.selectManual.name);
              //   },
              // ),
            ],
          ],
        );
      },
    );
  }

  void _handleListeners(BuildContext context, Ds<OnboardSettingsState> state) {
    state.whenOrNull(
        error: (msg) {
          // Handle permission denied or location error
          ScaffoldMessenger.of(context).clearSnackBars();
          
          // Show user-friendly message about permission denial
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Location permission was denied. You can continue without location services or enable it later in Settings.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Continue',
                textColor: Colors.white,
                onPressed: () {
                  // Mark onboarding as done without location
                  getIt<SharedPrefsHelper>().setInitialSetupDone = true;
                  context.goNamed(Routes.home.name);
                },
              ),
            ),
          );
          
          // Auto-proceed after showing the message
          Future.delayed(const Duration(seconds: 5), () {
            if (context.mounted) {
              getIt<SharedPrefsHelper>().setInitialSetupDone = true;
              context.goNamed(Routes.home.name);
            }
          });
        },
        success: (data) =>
            data.when(currentLocationFetched: (position, locName, country, localTimezone) {
          if (isGPS) {
            context.pushNamed(
              Routes.locationDetailsOnboard.name,
              queryParameters: {
                LocationDetailsOnboardScreen.argLocLat: position.latitude.toString(),
                LocationDetailsOnboardScreen.argLocLng: position.longitude.toString(),
                LocationDetailsOnboardScreen.argLocName: locName,
                LocationDetailsOnboardScreen.argCountry: country,
                SelectTimezoneScreen.argDeviceTimezone: localTimezone,
              },
            );

            ///
          } else {
            context.pushNamed(
              Routes.searchLocation.name,
              queryParameters: {
                LocationDetailsOnboardScreen.argLocLat: position.latitude.toString(),
                LocationDetailsOnboardScreen.argLocLng: position.longitude.toString(),
              },
            );
          }
          bloc.add(const OnboardSettingsEvent.cancelFetchingCurrentLocation());

          return null;
        }),
    );
  }
}
