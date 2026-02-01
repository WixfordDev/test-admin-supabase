part of 'onboard_settings_bloc.dart';

@freezed
abstract class OnboardSettingsEvent with _$OnboardSettingsEvent {
  const factory OnboardSettingsEvent.getCurrentLocation({LatLng? position}) =
      _GetCurrentLocationEvent;
  const factory OnboardSettingsEvent.cancelFetchingCurrentLocation() =
      _CancelFetchingCurrentLocation;
}
