// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prayer_location_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrayerLocationData {

 String get locName; double get lat; double get lng; String get timezone; String get country; PrayerCalculationMethodType get calculationMethod; PrayerMadhab get asrMethod;
/// Create a copy of PrayerLocationData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrayerLocationDataCopyWith<PrayerLocationData> get copyWith => _$PrayerLocationDataCopyWithImpl<PrayerLocationData>(this as PrayerLocationData, _$identity);

  /// Serializes this PrayerLocationData to a JSON map.
  Map<String, dynamic> toJson();




@override
String toString() {
  return 'PrayerLocationData(locName: $locName, lat: $lat, lng: $lng, timezone: $timezone, country: $country, calculationMethod: $calculationMethod, asrMethod: $asrMethod)';
}


}

/// @nodoc
abstract mixin class $PrayerLocationDataCopyWith<$Res>  {
  factory $PrayerLocationDataCopyWith(PrayerLocationData value, $Res Function(PrayerLocationData) _then) = _$PrayerLocationDataCopyWithImpl;
@useResult
$Res call({
 String locName, double lat, double lng, String timezone, String country, PrayerCalculationMethodType calculationMethod, PrayerMadhab asrMethod
});




}
/// @nodoc
class _$PrayerLocationDataCopyWithImpl<$Res>
    implements $PrayerLocationDataCopyWith<$Res> {
  _$PrayerLocationDataCopyWithImpl(this._self, this._then);

  final PrayerLocationData _self;
  final $Res Function(PrayerLocationData) _then;

/// Create a copy of PrayerLocationData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locName = null,Object? lat = null,Object? lng = null,Object? timezone = null,Object? country = null,Object? calculationMethod = null,Object? asrMethod = null,}) {
  return _then(_self.copyWith(
locName: null == locName ? _self.locName : locName // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,calculationMethod: null == calculationMethod ? _self.calculationMethod : calculationMethod // ignore: cast_nullable_to_non_nullable
as PrayerCalculationMethodType,asrMethod: null == asrMethod ? _self.asrMethod : asrMethod // ignore: cast_nullable_to_non_nullable
as PrayerMadhab,
  ));
}

}



/// @nodoc
@JsonSerializable()

class _PrayerLocationData implements PrayerLocationData {
  const _PrayerLocationData({this.locName = "", this.lat = 0.0, this.lng = 0.0, this.timezone = "", this.country = "", this.calculationMethod = PrayerCalculationMethodType.muslimWorldLeague, this.asrMethod = PrayerMadhab.shafi});
  factory _PrayerLocationData.fromJson(Map<String, dynamic> json) => _$PrayerLocationDataFromJson(json);

@override@JsonKey() final  String locName;
@override@JsonKey() final  double lat;
@override@JsonKey() final  double lng;
@override@JsonKey() final  String timezone;
@override@JsonKey() final  String country;
@override@JsonKey() final  PrayerCalculationMethodType calculationMethod;
@override@JsonKey() final  PrayerMadhab asrMethod;

/// Create a copy of PrayerLocationData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrayerLocationDataCopyWith<_PrayerLocationData> get copyWith => __$PrayerLocationDataCopyWithImpl<_PrayerLocationData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrayerLocationDataToJson(this, );
}



@override
String toString() {
  return 'PrayerLocationData(locName: $locName, lat: $lat, lng: $lng, timezone: $timezone, country: $country, calculationMethod: $calculationMethod, asrMethod: $asrMethod)';
}


}

/// @nodoc
abstract mixin class _$PrayerLocationDataCopyWith<$Res> implements $PrayerLocationDataCopyWith<$Res> {
  factory _$PrayerLocationDataCopyWith(_PrayerLocationData value, $Res Function(_PrayerLocationData) _then) = __$PrayerLocationDataCopyWithImpl;
@override @useResult
$Res call({
 String locName, double lat, double lng, String timezone, String country, PrayerCalculationMethodType calculationMethod, PrayerMadhab asrMethod
});




}
/// @nodoc
class __$PrayerLocationDataCopyWithImpl<$Res>
    implements _$PrayerLocationDataCopyWith<$Res> {
  __$PrayerLocationDataCopyWithImpl(this._self, this._then);

  final _PrayerLocationData _self;
  final $Res Function(_PrayerLocationData) _then;

/// Create a copy of PrayerLocationData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locName = null,Object? lat = null,Object? lng = null,Object? timezone = null,Object? country = null,Object? calculationMethod = null,Object? asrMethod = null,}) {
  return _then(_PrayerLocationData(
locName: null == locName ? _self.locName : locName // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,calculationMethod: null == calculationMethod ? _self.calculationMethod : calculationMethod // ignore: cast_nullable_to_non_nullable
as PrayerCalculationMethodType,asrMethod: null == asrMethod ? _self.asrMethod : asrMethod // ignore: cast_nullable_to_non_nullable
as PrayerMadhab,
  ));
}


}

// dart format on
