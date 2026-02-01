import 'package:deenhub/common/enums/prayer_calculation_method_type.dart';
import 'package:deenhub/common/enums/prayer_madhab.dart';
import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_item.dart';

import 'package:timezone/timezone.dart' as tz;

class LocationData {
  LocationData({
    required this.locName,
    required this.lat,
    required this.lng,
    required this.timezone,
    required this.calculationMethod,
    required this.asrMethod,
    required this.adjustments,
    this.currentTime,
    this.location,
    this.prayerTimes,
  });
  
  /// Factory constructor to create a default empty LocationData instance
  factory LocationData.empty() {
    return LocationData(
      locName: 'Default Location',
      lat: 0,
      lng: 0,
      timezone: 'UTC',
      calculationMethod: PrayerCalculationMethodType.moonsightingCommittee,
      asrMethod: PrayerMadhab.shafi,
      adjustments: getDefaultAdjustments(),
    );
  }

  /// Create LocationData from JSON
  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      locName: json['locName'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      timezone: json['timezone'] as String,
      calculationMethod: PrayerCalculationMethodType.values.firstWhere(
        (e) => e.name == json['calculationMethod'],
        orElse: () => PrayerCalculationMethodType.moonsightingCommittee,
      ),
      asrMethod: PrayerMadhab.values.firstWhere(
        (e) => e.name == json['asrMethod'],
        orElse: () => PrayerMadhab.shafi,
      ),
      adjustments: List<int>.from(json['adjustments'] as List),
    );
  }

  // Location
  final String locName;
  final double lat;
  final double lng;
  final String timezone;

  final PrayerCalculationMethodType calculationMethod;

  final PrayerMadhab asrMethod;

  final List<int> adjustments;

  // These fields are computed/temporary and not stored in JSON
  DateTime? currentTime;

  tz.Location? location;

  List<PrayerItem>? prayerTimes;

  /// Convert LocationData to JSON
  Map<String, dynamic> toJson() {
    return {
      'locName': locName,
      'lat': lat,
      'lng': lng,
      'timezone': timezone,
      'calculationMethod': calculationMethod.name,
      'asrMethod': asrMethod.name,
      'adjustments': adjustments,
    };
  }

  LocationData copyWith({
    String? locName,
    double? lat,
    double? lng,
    String? timezone,
    PrayerCalculationMethodType? calculationMethod,
    PrayerMadhab? asrMethod,
    List<int>? adjustments,
    DateTime? currentTime,
    tz.Location? location,
    List<PrayerItem>? prayerTimes,
  }) =>
      LocationData(
        locName: locName ?? this.locName,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        timezone: timezone ?? this.timezone,
        calculationMethod: calculationMethod ?? this.calculationMethod,
        asrMethod: asrMethod ?? this.asrMethod,
        adjustments: adjustments ?? this.adjustments,
        currentTime: currentTime ?? this.currentTime,
        location: location ?? this.location,
        prayerTimes: prayerTimes ?? this.prayerTimes,
      );
}
