// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LocationEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LocationEvent()';
}


}

/// @nodoc
class $LocationEventCopyWith<$Res>  {
$LocationEventCopyWith(LocationEvent _, $Res Function(LocationEvent) __);
}


/// Adds pattern-matching-related methods to [LocationEvent].
extension LocationEventPatterns on LocationEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GetCurrentLocationEvent value)?  getCurrentLocation,TResult Function( _SetCurrentLocationEvent value)?  setCurrentLocation,TResult Function( _ClearCurrentLocationEvent value)?  clearCurrentLocation,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetCurrentLocationEvent() when getCurrentLocation != null:
return getCurrentLocation(_that);case _SetCurrentLocationEvent() when setCurrentLocation != null:
return setCurrentLocation(_that);case _ClearCurrentLocationEvent() when clearCurrentLocation != null:
return clearCurrentLocation(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GetCurrentLocationEvent value)  getCurrentLocation,required TResult Function( _SetCurrentLocationEvent value)  setCurrentLocation,required TResult Function( _ClearCurrentLocationEvent value)  clearCurrentLocation,}){
final _that = this;
switch (_that) {
case _GetCurrentLocationEvent():
return getCurrentLocation(_that);case _SetCurrentLocationEvent():
return setCurrentLocation(_that);case _ClearCurrentLocationEvent():
return clearCurrentLocation(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GetCurrentLocationEvent value)?  getCurrentLocation,TResult? Function( _SetCurrentLocationEvent value)?  setCurrentLocation,TResult? Function( _ClearCurrentLocationEvent value)?  clearCurrentLocation,}){
final _that = this;
switch (_that) {
case _GetCurrentLocationEvent() when getCurrentLocation != null:
return getCurrentLocation(_that);case _SetCurrentLocationEvent() when setCurrentLocation != null:
return setCurrentLocation(_that);case _ClearCurrentLocationEvent() when clearCurrentLocation != null:
return clearCurrentLocation(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( LocationData? locationData)?  getCurrentLocation,TResult Function( LocationData data)?  setCurrentLocation,TResult Function()?  clearCurrentLocation,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetCurrentLocationEvent() when getCurrentLocation != null:
return getCurrentLocation(_that.locationData);case _SetCurrentLocationEvent() when setCurrentLocation != null:
return setCurrentLocation(_that.data);case _ClearCurrentLocationEvent() when clearCurrentLocation != null:
return clearCurrentLocation();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( LocationData? locationData)  getCurrentLocation,required TResult Function( LocationData data)  setCurrentLocation,required TResult Function()  clearCurrentLocation,}) {final _that = this;
switch (_that) {
case _GetCurrentLocationEvent():
return getCurrentLocation(_that.locationData);case _SetCurrentLocationEvent():
return setCurrentLocation(_that.data);case _ClearCurrentLocationEvent():
return clearCurrentLocation();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( LocationData? locationData)?  getCurrentLocation,TResult? Function( LocationData data)?  setCurrentLocation,TResult? Function()?  clearCurrentLocation,}) {final _that = this;
switch (_that) {
case _GetCurrentLocationEvent() when getCurrentLocation != null:
return getCurrentLocation(_that.locationData);case _SetCurrentLocationEvent() when setCurrentLocation != null:
return setCurrentLocation(_that.data);case _ClearCurrentLocationEvent() when clearCurrentLocation != null:
return clearCurrentLocation();case _:
  return null;

}
}

}

/// @nodoc


class _GetCurrentLocationEvent implements LocationEvent {
  const _GetCurrentLocationEvent(this.locationData);
  

 final  LocationData? locationData;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetCurrentLocationEventCopyWith<_GetCurrentLocationEvent> get copyWith => __$GetCurrentLocationEventCopyWithImpl<_GetCurrentLocationEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetCurrentLocationEvent&&(identical(other.locationData, locationData) || other.locationData == locationData));
}


@override
int get hashCode => Object.hash(runtimeType,locationData);

@override
String toString() {
  return 'LocationEvent.getCurrentLocation(locationData: $locationData)';
}


}

/// @nodoc
abstract mixin class _$GetCurrentLocationEventCopyWith<$Res> implements $LocationEventCopyWith<$Res> {
  factory _$GetCurrentLocationEventCopyWith(_GetCurrentLocationEvent value, $Res Function(_GetCurrentLocationEvent) _then) = __$GetCurrentLocationEventCopyWithImpl;
@useResult
$Res call({
 LocationData? locationData
});




}
/// @nodoc
class __$GetCurrentLocationEventCopyWithImpl<$Res>
    implements _$GetCurrentLocationEventCopyWith<$Res> {
  __$GetCurrentLocationEventCopyWithImpl(this._self, this._then);

  final _GetCurrentLocationEvent _self;
  final $Res Function(_GetCurrentLocationEvent) _then;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? locationData = freezed,}) {
  return _then(_GetCurrentLocationEvent(
freezed == locationData ? _self.locationData : locationData // ignore: cast_nullable_to_non_nullable
as LocationData?,
  ));
}


}

/// @nodoc


class _SetCurrentLocationEvent implements LocationEvent {
  const _SetCurrentLocationEvent(this.data);
  

 final  LocationData data;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetCurrentLocationEventCopyWith<_SetCurrentLocationEvent> get copyWith => __$SetCurrentLocationEventCopyWithImpl<_SetCurrentLocationEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetCurrentLocationEvent&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'LocationEvent.setCurrentLocation(data: $data)';
}


}

/// @nodoc
abstract mixin class _$SetCurrentLocationEventCopyWith<$Res> implements $LocationEventCopyWith<$Res> {
  factory _$SetCurrentLocationEventCopyWith(_SetCurrentLocationEvent value, $Res Function(_SetCurrentLocationEvent) _then) = __$SetCurrentLocationEventCopyWithImpl;
@useResult
$Res call({
 LocationData data
});




}
/// @nodoc
class __$SetCurrentLocationEventCopyWithImpl<$Res>
    implements _$SetCurrentLocationEventCopyWith<$Res> {
  __$SetCurrentLocationEventCopyWithImpl(this._self, this._then);

  final _SetCurrentLocationEvent _self;
  final $Res Function(_SetCurrentLocationEvent) _then;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_SetCurrentLocationEvent(
null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as LocationData,
  ));
}


}

/// @nodoc


class _ClearCurrentLocationEvent implements LocationEvent {
  const _ClearCurrentLocationEvent();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClearCurrentLocationEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LocationEvent.clearCurrentLocation()';
}


}




/// @nodoc
mixin _$LocationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LocationState()';
}


}

/// @nodoc
class $LocationStateCopyWith<$Res>  {
$LocationStateCopyWith(LocationState _, $Res Function(LocationState) __);
}


/// Adds pattern-matching-related methods to [LocationState].
extension LocationStatePatterns on LocationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CurrentLocationFetched value)?  currentLocationFetched,TResult Function( LocationSet value)?  locationSet,TResult Function( LocationCleared value)?  locationCleared,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CurrentLocationFetched() when currentLocationFetched != null:
return currentLocationFetched(_that);case LocationSet() when locationSet != null:
return locationSet(_that);case LocationCleared() when locationCleared != null:
return locationCleared(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CurrentLocationFetched value)  currentLocationFetched,required TResult Function( LocationSet value)  locationSet,required TResult Function( LocationCleared value)  locationCleared,}){
final _that = this;
switch (_that) {
case CurrentLocationFetched():
return currentLocationFetched(_that);case LocationSet():
return locationSet(_that);case LocationCleared():
return locationCleared(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CurrentLocationFetched value)?  currentLocationFetched,TResult? Function( LocationSet value)?  locationSet,TResult? Function( LocationCleared value)?  locationCleared,}){
final _that = this;
switch (_that) {
case CurrentLocationFetched() when currentLocationFetched != null:
return currentLocationFetched(_that);case LocationSet() when locationSet != null:
return locationSet(_that);case LocationCleared() when locationCleared != null:
return locationCleared(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( LocationData? currentLoc)?  currentLocationFetched,TResult Function()?  locationSet,TResult Function()?  locationCleared,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CurrentLocationFetched() when currentLocationFetched != null:
return currentLocationFetched(_that.currentLoc);case LocationSet() when locationSet != null:
return locationSet();case LocationCleared() when locationCleared != null:
return locationCleared();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( LocationData? currentLoc)  currentLocationFetched,required TResult Function()  locationSet,required TResult Function()  locationCleared,}) {final _that = this;
switch (_that) {
case CurrentLocationFetched():
return currentLocationFetched(_that.currentLoc);case LocationSet():
return locationSet();case LocationCleared():
return locationCleared();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( LocationData? currentLoc)?  currentLocationFetched,TResult? Function()?  locationSet,TResult? Function()?  locationCleared,}) {final _that = this;
switch (_that) {
case CurrentLocationFetched() when currentLocationFetched != null:
return currentLocationFetched(_that.currentLoc);case LocationSet() when locationSet != null:
return locationSet();case LocationCleared() when locationCleared != null:
return locationCleared();case _:
  return null;

}
}

}

/// @nodoc


class CurrentLocationFetched implements LocationState {
  const CurrentLocationFetched(this.currentLoc);
  

 final  LocationData? currentLoc;

/// Create a copy of LocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentLocationFetchedCopyWith<CurrentLocationFetched> get copyWith => _$CurrentLocationFetchedCopyWithImpl<CurrentLocationFetched>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentLocationFetched&&(identical(other.currentLoc, currentLoc) || other.currentLoc == currentLoc));
}


@override
int get hashCode => Object.hash(runtimeType,currentLoc);

@override
String toString() {
  return 'LocationState.currentLocationFetched(currentLoc: $currentLoc)';
}


}

/// @nodoc
abstract mixin class $CurrentLocationFetchedCopyWith<$Res> implements $LocationStateCopyWith<$Res> {
  factory $CurrentLocationFetchedCopyWith(CurrentLocationFetched value, $Res Function(CurrentLocationFetched) _then) = _$CurrentLocationFetchedCopyWithImpl;
@useResult
$Res call({
 LocationData? currentLoc
});




}
/// @nodoc
class _$CurrentLocationFetchedCopyWithImpl<$Res>
    implements $CurrentLocationFetchedCopyWith<$Res> {
  _$CurrentLocationFetchedCopyWithImpl(this._self, this._then);

  final CurrentLocationFetched _self;
  final $Res Function(CurrentLocationFetched) _then;

/// Create a copy of LocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? currentLoc = freezed,}) {
  return _then(CurrentLocationFetched(
freezed == currentLoc ? _self.currentLoc : currentLoc // ignore: cast_nullable_to_non_nullable
as LocationData?,
  ));
}


}

/// @nodoc


class LocationSet implements LocationState {
  const LocationSet();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationSet);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LocationState.locationSet()';
}


}




/// @nodoc


class LocationCleared implements LocationState {
  const LocationCleared();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationCleared);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LocationState.locationCleared()';
}


}




// dart format on
