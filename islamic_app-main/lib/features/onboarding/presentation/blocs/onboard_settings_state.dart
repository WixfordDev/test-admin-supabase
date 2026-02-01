part of 'onboard_settings_bloc.dart';

@freezed
abstract class OnboardSettingsState with _$OnboardSettingsState {
  const factory OnboardSettingsState.currentLocationFetched(
          LatLng position, String locName, String country, String localTimezone) =
      CurrentLocationFetched;
}
