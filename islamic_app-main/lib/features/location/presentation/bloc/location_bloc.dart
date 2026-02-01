import 'dart:async';
import 'dart:collection';

import 'package:deenhub/hijri_date/calendar_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/common/prayers/prayer_times_helper.dart';
import 'package:deenhub/core/bloc/data_state.dart';

import 'package:deenhub/features/location/data/entity/location_data.dart';
import 'package:deenhub/features/location/domain/repository/location_repository.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_item.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_location_data.dart';
import 'package:deenhub/hijri_date/hijri_date_time.dart';
import 'package:deenhub/main.dart';

part 'location_event.dart';
part 'location_state.dart';
part 'location_bloc.freezed.dart';

class LocationBloc extends Bloc<LocationEvent, Ds<LocationState>> {
  final LocationRepository locationRepository;
  LocationData? currentLoc;

  LocationBloc(this.locationRepository) : super(const Ds.initial()) {
    on<LocationEvent>((event, emit) async {
      await event.map(
        getCurrentLocation: (value) => _getCurrentLocation(value, emit),
        setCurrentLocation: (value) => _setCurrentLocation(value, emit),
        clearCurrentLocation: (value) => _clearCurrentLocation(value, emit),
      );
    });

    // Initialize with current location
    _initializeCurrentLocation();

    // Listen for location changes
    locationRepository.watchCurrentLocation().listen(
      (locationData) {
        add(LocationEvent.getCurrentLocation(locationData));
      },
    );
  }

  void _initializeCurrentLocation() {
    currentLoc = locationRepository.getCurrentLocation();
    if (currentLoc != null) {
      add(LocationEvent.getCurrentLocation(currentLoc));
    }
  }

  FutureOr<void> _getCurrentLocation(
    _GetCurrentLocationEvent event,
    Emitter<Ds<LocationState>> emit,
  ) async {
    currentLoc = event.locationData;
    emit(Ds.success(LocationState.currentLocationFetched(currentLoc)));
  }

  FutureOr<void> _setCurrentLocation(
    _SetCurrentLocationEvent event,
    Emitter<Ds<LocationState>> emit,
  ) async {
    await locationRepository.setCurrentLocation(event.data);
    emit(const Ds.success(LocationState.locationSet()));
  }

  FutureOr<void> _clearCurrentLocation(
    _ClearCurrentLocationEvent event,
    Emitter<Ds<LocationState>> emit,
  ) async {
    await locationRepository.clearCurrentLocation();
    emit(const Ds.success(LocationState.locationCleared()));
  }

  LinkedHashMap<HijriDateTime, List<PrayerItem>> getMonthlyPrayerTimings(
    CalendarType calendarType,
    LocationData locData,
    PrayerLocationData prayerLocData,
    Iterable<PrayerType> prayerTypesList,
    HijriDateTime day,
  ) {
    HijriDateTime? focusedStartDate;
    HijriDateTime? focusedEndDate;

    if (calendarType.isGregorianType) {
      // Find first and last dates of Gregorian Calendar
      focusedStartDate = day.toDateTime().copyWith(day: 1).toHijriDate();
      int daysInMonth = day
          .toDateTime()
          .copyWith(month: day.toDateTime().month + 1, day: 0)
          .day; // 0 represents the last day of the previous month
      focusedEndDate = day.toDateTime().copyWith(day: daysInMonth).toHijriDate();
    } else {
      // Find first and last dates of Hijri Calendar
      focusedStartDate = day.copyWith(day: 1);
      focusedEndDate = day.copyWith(day: focusedStartDate.lengthOfMonth);
    }
    logger.w("W: $day; [$focusedStartDate: $focusedEndDate]");

    return PrayerTimesHelper.getPrayerTimingsForRange(
        locData, prayerLocData, prayerTypesList, focusedStartDate, focusedEndDate);
  }
}
