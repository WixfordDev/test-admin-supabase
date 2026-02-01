import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:deenhub/common/enums/prayer_calculation_method_type.dart';
import 'package:deenhub/common/enums/prayer_madhab.dart';
import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/core/utils/common_utils.dart';
import 'package:deenhub/features/location/data/entity/location_data.dart';

part 'prayer_location_data.freezed.dart';
part 'prayer_location_data.g.dart';

PrayerLocationData? prayerLocationDataEncodedFromJson(String? str) =>
    str == null ? null : PrayerLocationData.fromJson(json.decode(str));

String prayerLocationDataEncodedToJson(PrayerLocationData data) =>
    json.encode(data.toJson());

@freezedOnSharedPrefDataClass
abstract class PrayerLocationData with _$PrayerLocationData {
  const factory PrayerLocationData({
    @Default("") String locName,
    @Default(0.0) double lat,
    @Default(0.0) double lng,
    @Default("") String timezone,
    @Default("") String country,
    @Default(PrayerCalculationMethodType.muslimWorldLeague)
    PrayerCalculationMethodType calculationMethod,
    @Default(PrayerMadhab.shafi) PrayerMadhab asrMethod,
  }) = _PrayerLocationData;

  factory PrayerLocationData.fromJson(Map<String, dynamic> json) =>
      _$PrayerLocationDataFromJson(json);
}

extension PrayerLocationDataExtension on PrayerLocationData {
  LocationData toLocationData() {
    return LocationData(
      locName: locName,
      lat: lat,
      lng: lng,
      timezone: timezone,
      calculationMethod: calculationMethod,
      asrMethod: asrMethod,
      adjustments: getDefaultAdjustments(),
    );
  }
}
