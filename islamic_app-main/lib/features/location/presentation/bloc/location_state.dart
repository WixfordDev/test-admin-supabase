part of 'location_bloc.dart';

@freezed
class LocationState with _$LocationState {
  const factory LocationState.currentLocationFetched(LocationData? currentLoc) = CurrentLocationFetched;
  const factory LocationState.locationSet() = LocationSet;
  const factory LocationState.locationCleared() = LocationCleared;
}
