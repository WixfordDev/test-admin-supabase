import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/features/nearby_mosques/presentation/cubit/nearby_mosque_cubit.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_location_data.dart';
import 'package:deenhub/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

/// Service responsible for updating user location and related data
class LocationUpdateService {
  static const String _logTag = 'LocationUpdateService';

  /// Updates the current location if needed and refreshes dependent data
  /// Returns true if location was updated, false otherwise
  static Future<bool> updateLocationIfNeeded() async {
    final sharedPrefsHelper = getIt<SharedPrefsHelper>();
    final initialSetupDone = sharedPrefsHelper.initialSetupDone;

    // Only update location if onboarding is complete
    if (!(initialSetupDone ?? false)) {
      logger.i('[$_logTag] Onboarding not complete, skipping location update');
      return false;
    }

    try {
      logger.i('[$_logTag] Onboarding complete, updating current location...');

      // Check location permission first
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        logger.w('[$_logTag] Location permission denied, skipping location update');
        return false;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        logger.w('[$_logTag] Location services disabled, skipping location update');
        return false;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10), // Add timeout
        ),
      );

      // Get location name from coordinates
      String locName = '';
      String country = '';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final address = placemarks.first;
          country = (address.isoCountryCode?.toLowerCase()) ?? '';

          if ((address.locality ?? '').isNotEmpty) {
            locName = '${address.locality}, ';
          }
          if ((address.subAdministrativeArea ?? '').isNotEmpty) {
            locName += address.subAdministrativeArea!;
          }
        }
      } catch (e) {
        logger.w('[$_logTag] Failed to get location name: $e');
        locName =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      }

      // Get device timezone
      final deviceTimezone = await FlutterTimezone.getLocalTimezone();

      // Get current saved location data (may be null if user skipped)
      final currentLocationData = sharedPrefsHelper.prayerLocationDataOrNull;

      if (currentLocationData != null) {
        // Update the existing location data with new coordinates
        final updatedLocationData = currentLocationData.copyWith(
          lat: position.latitude,
          lng: position.longitude,
          locName: locName.isNotEmpty ? locName : currentLocationData.locName,
          timezone: deviceTimezone.identifier,
          country: country.isNotEmpty ? country : currentLocationData.country,
        );

        // Save updated location data
        sharedPrefsHelper.setPrayerLocationData = updatedLocationData;

        logger.i(
          '[$_logTag] Location updated successfully: $locName (${position.latitude}, ${position.longitude})',
        );

        // Location was updated, refresh dependent data
        await _refreshDependentData(updatedLocationData);
        return true;
      } else {
        logger.w('[$_logTag] No existing location data found, cannot update');
        return false;
      }
    } catch (e) {
      logger.e('[$_logTag] Error updating location: $e');
      return false;
    }
  }

  /// Refreshes dependent data after location update
  static Future<void> _refreshDependentData(PrayerLocationData locationData) async {
    try {
      logger.i('[$_logTag] Refreshing dependent data after location update...');

      // Refresh nearby mosques data
      final nearbyMosqueCubit = getIt<NearbyMosqueCubit>();
      await nearbyMosqueCubit.refresh();

      logger.i('[$_logTag] Dependent data refreshed successfully');
    } catch (e) {
      logger.e('[$_logTag] Error refreshing dependent data: $e');
    }
  }

  /// Preloads nearby mosques data in background
  static void preloadNearbyMosques() {
    try {
      final sharedPrefsHelper = getIt<SharedPrefsHelper>();
      final initialSetupDone = sharedPrefsHelper.initialSetupDone;

      // Only preload if onboarding is complete and location data exists
      if ((initialSetupDone ?? false) &&
          sharedPrefsHelper.prayerLocationDataOrNull != null) {
        logger.i('[$_logTag] Preloading nearby mosques data in background...');

        // Get the cubit and start fetching (don't await - let it run in background)
        final nearbyMosqueCubit = getIt<NearbyMosqueCubit>();
        nearbyMosqueCubit
            .fetchNearbyMosques()
            .then((_) {
              logger.i('[$_logTag] Nearby mosques preloaded successfully');
            })
            .catchError((error) {
              logger.w('[$_logTag] Failed to preload nearby mosques: $error');
            });
      }
    } catch (e) {
      logger.w('[$_logTag] Error starting mosque preload: $e');
    }
  }
}
