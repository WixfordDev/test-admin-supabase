// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_location_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrayerLocationData _$PrayerLocationDataFromJson(Map<String, dynamic> json) =>
    _PrayerLocationData(
      locName: json['locName'] as String? ?? "",
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      timezone: json['timezone'] as String? ?? "",
      country: json['country'] as String? ?? "",
      calculationMethod:
          $enumDecodeNullable(
            _$PrayerCalculationMethodTypeEnumMap,
            json['calculationMethod'],
          ) ??
          PrayerCalculationMethodType.muslimWorldLeague,
      asrMethod:
          $enumDecodeNullable(_$PrayerMadhabEnumMap, json['asrMethod']) ??
          PrayerMadhab.shafi,
    );

Map<String, dynamic> _$PrayerLocationDataToJson(_PrayerLocationData instance) =>
    <String, dynamic>{
      'locName': instance.locName,
      'lat': instance.lat,
      'lng': instance.lng,
      'timezone': instance.timezone,
      'country': instance.country,
      'calculationMethod':
          _$PrayerCalculationMethodTypeEnumMap[instance.calculationMethod]!,
      'asrMethod': _$PrayerMadhabEnumMap[instance.asrMethod]!,
    };

const _$PrayerCalculationMethodTypeEnumMap = {
  PrayerCalculationMethodType.custom: 'custom',
  PrayerCalculationMethodType.egyptian: 'egyptian',
  PrayerCalculationMethodType.northAmerica: 'northAmerica',
  PrayerCalculationMethodType.moonsightingCommittee: 'moonsightingCommittee',
  PrayerCalculationMethodType.muslimWorldLeague: 'muslimWorldLeague',
  PrayerCalculationMethodType.ummAlQura: 'ummAlQura',
  PrayerCalculationMethodType.karachi: 'karachi',
  PrayerCalculationMethodType.malaysia: 'malaysia',
  PrayerCalculationMethodType.singapore: 'singapore',
  PrayerCalculationMethodType.indonesia: 'indonesia',
  PrayerCalculationMethodType.turkey: 'turkey',
  PrayerCalculationMethodType.france: 'france',
};

const _$PrayerMadhabEnumMap = {
  PrayerMadhab.shafi: 'shafi',
  PrayerMadhab.hanafi: 'hanafi',
};
