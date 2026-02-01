import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deenhub/core/bloc/data_state.dart';
import 'package:deenhub/core/utils/pair.dart';
import 'package:deenhub/core/utils/primitive_utils.dart';
import 'package:deenhub/main.dart';

part 'onboard_settings_event.dart';
part 'onboard_settings_state.dart';
part 'onboard_settings_bloc.freezed.dart';

class OnboardSettingsBloc
    extends Bloc<OnboardSettingsEvent, Ds<OnboardSettingsState>> {
  OnboardSettingsBloc() : super(const Ds.initial()) {
    on<OnboardSettingsEvent>((event, emit) async {
      await event.map(
        getCurrentLocation: (value) => _getCurrentLocation(value, emit),
        cancelFetchingCurrentLocation: (value) =>
            _cancelFetchingCurrentLocation(value, emit),
      );
    }, transformer: restartable());
  }

  FutureOr<void> _cancelFetchingCurrentLocation(
    _CancelFetchingCurrentLocation event,
    Emitter<Ds<OnboardSettingsState>> emit,
  ) async {
    emit(const Ds.initial());
  }

  FutureOr<void> _getCurrentLocation(
    _GetCurrentLocationEvent event,
    Emitter<Ds<OnboardSettingsState>> emit,
  ) async {
    emit(const Ds.loading());

    final LatLng position;
    final String locName;

    if (event.position != null) {
      position = event.position!;
    } else {
      try {
        final loc = await _determinePosition();
        position = LatLng(loc.latitude, loc.longitude);
        logger.d(loc.toJson().toString());
      } catch (e) {
        logger.e('Error determining position: $e');
        emit(Ds.error("$e"));
        return;
      }
    }

    final locData = await _getLocName(position.latitude, position.longitude);
    locName = locData.first;
    final deviceTimezone = await FlutterTimezone.getLocalTimezone();
    logger.d('Device  Loc: $deviceTimezone');

    emit(
      Ds.success(
        OnboardSettingsState.currentLocationFetched(
          position,
          locName,
          locData.second,
          deviceTimezone.identifier,
        ),
      ),
    );
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<Pair<String, String>> _getLocName(
    double latitude,
    double longitude,
  ) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      latitude,
      longitude,
    );

    var output = '';
    var country = '';
    if (placemarks.isNotEmpty) {
      final address = placemarks.first;
      country = (address.isoCountryCode?.toLowerCase()).orEmpty;

      if ((address.locality ?? '').isNotEmpty) {
        output = '${address.locality}, ';
      }
      if ((address.subAdministrativeArea ?? '').isNotEmpty) {
        output += address.subAdministrativeArea!;
      }
    } else {
      output = 'No results found.';
    }

    return Pair(output, country);
  }
}
