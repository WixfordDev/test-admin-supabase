// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboard_settings_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardSettingsEvent implements DiagnosticableTreeMixin {




@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'OnboardSettingsEvent'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardSettingsEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'OnboardSettingsEvent()';
}


}

/// @nodoc
class $OnboardSettingsEventCopyWith<$Res>  {
$OnboardSettingsEventCopyWith(OnboardSettingsEvent _, $Res Function(OnboardSettingsEvent) __);
}


/// Adds pattern-matching-related methods to [OnboardSettingsEvent].
extension OnboardSettingsEventPatterns on OnboardSettingsEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GetCurrentLocationEvent value)?  getCurrentLocation,TResult Function( _CancelFetchingCurrentLocation value)?  cancelFetchingCurrentLocation,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetCurrentLocationEvent() when getCurrentLocation != null:
return getCurrentLocation(_that);case _CancelFetchingCurrentLocation() when cancelFetchingCurrentLocation != null:
return cancelFetchingCurrentLocation(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GetCurrentLocationEvent value)  getCurrentLocation,required TResult Function( _CancelFetchingCurrentLocation value)  cancelFetchingCurrentLocation,}){
final _that = this;
switch (_that) {
case _GetCurrentLocationEvent():
return getCurrentLocation(_that);case _CancelFetchingCurrentLocation():
return cancelFetchingCurrentLocation(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GetCurrentLocationEvent value)?  getCurrentLocation,TResult? Function( _CancelFetchingCurrentLocation value)?  cancelFetchingCurrentLocation,}){
final _that = this;
switch (_that) {
case _GetCurrentLocationEvent() when getCurrentLocation != null:
return getCurrentLocation(_that);case _CancelFetchingCurrentLocation() when cancelFetchingCurrentLocation != null:
return cancelFetchingCurrentLocation(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( LatLng? position)?  getCurrentLocation,TResult Function()?  cancelFetchingCurrentLocation,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetCurrentLocationEvent() when getCurrentLocation != null:
return getCurrentLocation(_that.position);case _CancelFetchingCurrentLocation() when cancelFetchingCurrentLocation != null:
return cancelFetchingCurrentLocation();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( LatLng? position)  getCurrentLocation,required TResult Function()  cancelFetchingCurrentLocation,}) {final _that = this;
switch (_that) {
case _GetCurrentLocationEvent():
return getCurrentLocation(_that.position);case _CancelFetchingCurrentLocation():
return cancelFetchingCurrentLocation();case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( LatLng? position)?  getCurrentLocation,TResult? Function()?  cancelFetchingCurrentLocation,}) {final _that = this;
switch (_that) {
case _GetCurrentLocationEvent() when getCurrentLocation != null:
return getCurrentLocation(_that.position);case _CancelFetchingCurrentLocation() when cancelFetchingCurrentLocation != null:
return cancelFetchingCurrentLocation();case _:
  return null;

}
}

}

/// @nodoc


class _GetCurrentLocationEvent with DiagnosticableTreeMixin implements OnboardSettingsEvent {
  const _GetCurrentLocationEvent({this.position});
  

 final  LatLng? position;

/// Create a copy of OnboardSettingsEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetCurrentLocationEventCopyWith<_GetCurrentLocationEvent> get copyWith => __$GetCurrentLocationEventCopyWithImpl<_GetCurrentLocationEvent>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'OnboardSettingsEvent.getCurrentLocation'))
    ..add(DiagnosticsProperty('position', position));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetCurrentLocationEvent&&(identical(other.position, position) || other.position == position));
}


@override
int get hashCode => Object.hash(runtimeType,position);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'OnboardSettingsEvent.getCurrentLocation(position: $position)';
}


}

/// @nodoc
abstract mixin class _$GetCurrentLocationEventCopyWith<$Res> implements $OnboardSettingsEventCopyWith<$Res> {
  factory _$GetCurrentLocationEventCopyWith(_GetCurrentLocationEvent value, $Res Function(_GetCurrentLocationEvent) _then) = __$GetCurrentLocationEventCopyWithImpl;
@useResult
$Res call({
 LatLng? position
});




}
/// @nodoc
class __$GetCurrentLocationEventCopyWithImpl<$Res>
    implements _$GetCurrentLocationEventCopyWith<$Res> {
  __$GetCurrentLocationEventCopyWithImpl(this._self, this._then);

  final _GetCurrentLocationEvent _self;
  final $Res Function(_GetCurrentLocationEvent) _then;

/// Create a copy of OnboardSettingsEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? position = freezed,}) {
  return _then(_GetCurrentLocationEvent(
position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as LatLng?,
  ));
}


}

/// @nodoc


class _CancelFetchingCurrentLocation with DiagnosticableTreeMixin implements OnboardSettingsEvent {
  const _CancelFetchingCurrentLocation();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'OnboardSettingsEvent.cancelFetchingCurrentLocation'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CancelFetchingCurrentLocation);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'OnboardSettingsEvent.cancelFetchingCurrentLocation()';
}


}




/// @nodoc
mixin _$OnboardSettingsState implements DiagnosticableTreeMixin {

 LatLng get position; String get locName; String get country; String get localTimezone;
/// Create a copy of OnboardSettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardSettingsStateCopyWith<OnboardSettingsState> get copyWith => _$OnboardSettingsStateCopyWithImpl<OnboardSettingsState>(this as OnboardSettingsState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'OnboardSettingsState'))
    ..add(DiagnosticsProperty('position', position))..add(DiagnosticsProperty('locName', locName))..add(DiagnosticsProperty('country', country))..add(DiagnosticsProperty('localTimezone', localTimezone));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardSettingsState&&(identical(other.position, position) || other.position == position)&&(identical(other.locName, locName) || other.locName == locName)&&(identical(other.country, country) || other.country == country)&&(identical(other.localTimezone, localTimezone) || other.localTimezone == localTimezone));
}


@override
int get hashCode => Object.hash(runtimeType,position,locName,country,localTimezone);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'OnboardSettingsState(position: $position, locName: $locName, country: $country, localTimezone: $localTimezone)';
}


}

/// @nodoc
abstract mixin class $OnboardSettingsStateCopyWith<$Res>  {
  factory $OnboardSettingsStateCopyWith(OnboardSettingsState value, $Res Function(OnboardSettingsState) _then) = _$OnboardSettingsStateCopyWithImpl;
@useResult
$Res call({
 LatLng position, String locName, String country, String localTimezone
});




}
/// @nodoc
class _$OnboardSettingsStateCopyWithImpl<$Res>
    implements $OnboardSettingsStateCopyWith<$Res> {
  _$OnboardSettingsStateCopyWithImpl(this._self, this._then);

  final OnboardSettingsState _self;
  final $Res Function(OnboardSettingsState) _then;

/// Create a copy of OnboardSettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? position = null,Object? locName = null,Object? country = null,Object? localTimezone = null,}) {
  return _then(_self.copyWith(
position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as LatLng,locName: null == locName ? _self.locName : locName // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,localTimezone: null == localTimezone ? _self.localTimezone : localTimezone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardSettingsState].
extension OnboardSettingsStatePatterns on OnboardSettingsState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CurrentLocationFetched value)?  currentLocationFetched,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CurrentLocationFetched() when currentLocationFetched != null:
return currentLocationFetched(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CurrentLocationFetched value)  currentLocationFetched,}){
final _that = this;
switch (_that) {
case CurrentLocationFetched():
return currentLocationFetched(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CurrentLocationFetched value)?  currentLocationFetched,}){
final _that = this;
switch (_that) {
case CurrentLocationFetched() when currentLocationFetched != null:
return currentLocationFetched(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( LatLng position,  String locName,  String country,  String localTimezone)?  currentLocationFetched,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CurrentLocationFetched() when currentLocationFetched != null:
return currentLocationFetched(_that.position,_that.locName,_that.country,_that.localTimezone);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( LatLng position,  String locName,  String country,  String localTimezone)  currentLocationFetched,}) {final _that = this;
switch (_that) {
case CurrentLocationFetched():
return currentLocationFetched(_that.position,_that.locName,_that.country,_that.localTimezone);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( LatLng position,  String locName,  String country,  String localTimezone)?  currentLocationFetched,}) {final _that = this;
switch (_that) {
case CurrentLocationFetched() when currentLocationFetched != null:
return currentLocationFetched(_that.position,_that.locName,_that.country,_that.localTimezone);case _:
  return null;

}
}

}

/// @nodoc


class CurrentLocationFetched with DiagnosticableTreeMixin implements OnboardSettingsState {
  const CurrentLocationFetched(this.position, this.locName, this.country, this.localTimezone);
  

@override final  LatLng position;
@override final  String locName;
@override final  String country;
@override final  String localTimezone;

/// Create a copy of OnboardSettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentLocationFetchedCopyWith<CurrentLocationFetched> get copyWith => _$CurrentLocationFetchedCopyWithImpl<CurrentLocationFetched>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'OnboardSettingsState.currentLocationFetched'))
    ..add(DiagnosticsProperty('position', position))..add(DiagnosticsProperty('locName', locName))..add(DiagnosticsProperty('country', country))..add(DiagnosticsProperty('localTimezone', localTimezone));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentLocationFetched&&(identical(other.position, position) || other.position == position)&&(identical(other.locName, locName) || other.locName == locName)&&(identical(other.country, country) || other.country == country)&&(identical(other.localTimezone, localTimezone) || other.localTimezone == localTimezone));
}


@override
int get hashCode => Object.hash(runtimeType,position,locName,country,localTimezone);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'OnboardSettingsState.currentLocationFetched(position: $position, locName: $locName, country: $country, localTimezone: $localTimezone)';
}


}

/// @nodoc
abstract mixin class $CurrentLocationFetchedCopyWith<$Res> implements $OnboardSettingsStateCopyWith<$Res> {
  factory $CurrentLocationFetchedCopyWith(CurrentLocationFetched value, $Res Function(CurrentLocationFetched) _then) = _$CurrentLocationFetchedCopyWithImpl;
@override @useResult
$Res call({
 LatLng position, String locName, String country, String localTimezone
});




}
/// @nodoc
class _$CurrentLocationFetchedCopyWithImpl<$Res>
    implements $CurrentLocationFetchedCopyWith<$Res> {
  _$CurrentLocationFetchedCopyWithImpl(this._self, this._then);

  final CurrentLocationFetched _self;
  final $Res Function(CurrentLocationFetched) _then;

/// Create a copy of OnboardSettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? position = null,Object? locName = null,Object? country = null,Object? localTimezone = null,}) {
  return _then(CurrentLocationFetched(
null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as LatLng,null == locName ? _self.locName : locName // ignore: cast_nullable_to_non_nullable
as String,null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,null == localTimezone ? _self.localTimezone : localTimezone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
