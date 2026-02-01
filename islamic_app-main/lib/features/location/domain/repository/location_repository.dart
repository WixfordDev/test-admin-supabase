import 'package:deenhub/features/location/data/entity/location_data.dart';

abstract class LocationRepository {
  /// Get the current user location data
  LocationData? getCurrentLocation();
  
  /// Set the current user location data
  Future<void> setCurrentLocation(LocationData data);
  
  /// Clear the current user location data
  Future<void> clearCurrentLocation();
  
  /// Check if location data exists
  bool hasLocationData();
  
  /// Stream to listen for location data changes
  Stream<LocationData?> watchCurrentLocation();
}
