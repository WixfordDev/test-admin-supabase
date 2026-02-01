part of 'location_bloc.dart';

@freezed
class LocationEvent with _$LocationEvent {
  const factory LocationEvent.getCurrentLocation(LocationData? locationData) = _GetCurrentLocationEvent;
  const factory LocationEvent.setCurrentLocation(LocationData data) = _SetCurrentLocationEvent;
  const factory LocationEvent.clearCurrentLocation() = _ClearCurrentLocationEvent;
}
