import 'dart:async';
import 'package:deenhub/features/location/data/entity/location_data.dart';
import 'package:deenhub/features/location/domain/repository/location_repository.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';

class LocationRepositoryImpl implements LocationRepository {
  final SharedPrefsHelper _sharedPrefsHelper;
  final StreamController<LocationData?> _locationController = StreamController<LocationData?>.broadcast();

  LocationRepositoryImpl(this._sharedPrefsHelper);

  @override
  LocationData? getCurrentLocation() {
    return _sharedPrefsHelper.locationData;
  }

  @override
  Future<void> setCurrentLocation(LocationData data) async {
    _sharedPrefsHelper.setLocationData = data;
    _locationController.add(data);
  }

  @override
  Future<void> clearCurrentLocation() async {
    _sharedPrefsHelper.clearLocationData();
    _locationController.add(null);
  }

  @override
  bool hasLocationData() {
    return _sharedPrefsHelper.hasLocationData;
  }

  @override
  Stream<LocationData?> watchCurrentLocation() {
    // Emit current value immediately and then listen for changes
    return _locationController.stream;
  }

  void dispose() {
    _locationController.close();
  }
}
