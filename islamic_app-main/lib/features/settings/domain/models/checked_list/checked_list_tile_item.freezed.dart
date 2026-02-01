// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checked_list_tile_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CheckedListTileItem {

 String get value; String get title; String? get subtitle; String? get description; String? get uri; String? get assetUri;
/// Create a copy of CheckedListTileItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckedListTileItemCopyWith<CheckedListTileItem> get copyWith => _$CheckedListTileItemCopyWithImpl<CheckedListTileItem>(this as CheckedListTileItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckedListTileItem&&(identical(other.value, value) || other.value == value)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.description, description) || other.description == description)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.assetUri, assetUri) || other.assetUri == assetUri));
}


@override
int get hashCode => Object.hash(runtimeType,value,title,subtitle,description,uri,assetUri);

@override
String toString() {
  return 'CheckedListTileItem(value: $value, title: $title, subtitle: $subtitle, description: $description, uri: $uri, assetUri: $assetUri)';
}


}

/// @nodoc
abstract mixin class $CheckedListTileItemCopyWith<$Res>  {
  factory $CheckedListTileItemCopyWith(CheckedListTileItem value, $Res Function(CheckedListTileItem) _then) = _$CheckedListTileItemCopyWithImpl;
@useResult
$Res call({
 String value, String title, String? subtitle, String? description, String? uri, String? assetUri
});




}
/// @nodoc
class _$CheckedListTileItemCopyWithImpl<$Res>
    implements $CheckedListTileItemCopyWith<$Res> {
  _$CheckedListTileItemCopyWithImpl(this._self, this._then);

  final CheckedListTileItem _self;
  final $Res Function(CheckedListTileItem) _then;

/// Create a copy of CheckedListTileItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? title = null,Object? subtitle = freezed,Object? description = freezed,Object? uri = freezed,Object? assetUri = freezed,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,assetUri: freezed == assetUri ? _self.assetUri : assetUri // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckedListTileItem].
extension CheckedListTileItemPatterns on CheckedListTileItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckedListTileItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckedListTileItem() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckedListTileItem value)  $default,){
final _that = this;
switch (_that) {
case _CheckedListTileItem():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckedListTileItem value)?  $default,){
final _that = this;
switch (_that) {
case _CheckedListTileItem() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  String title,  String? subtitle,  String? description,  String? uri,  String? assetUri)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckedListTileItem() when $default != null:
return $default(_that.value,_that.title,_that.subtitle,_that.description,_that.uri,_that.assetUri);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  String title,  String? subtitle,  String? description,  String? uri,  String? assetUri)  $default,) {final _that = this;
switch (_that) {
case _CheckedListTileItem():
return $default(_that.value,_that.title,_that.subtitle,_that.description,_that.uri,_that.assetUri);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  String title,  String? subtitle,  String? description,  String? uri,  String? assetUri)?  $default,) {final _that = this;
switch (_that) {
case _CheckedListTileItem() when $default != null:
return $default(_that.value,_that.title,_that.subtitle,_that.description,_that.uri,_that.assetUri);case _:
  return null;

}
}

}

/// @nodoc


class _CheckedListTileItem implements CheckedListTileItem {
  const _CheckedListTileItem({required this.value, required this.title, this.subtitle, this.description, this.uri, this.assetUri});
  

@override final  String value;
@override final  String title;
@override final  String? subtitle;
@override final  String? description;
@override final  String? uri;
@override final  String? assetUri;

/// Create a copy of CheckedListTileItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckedListTileItemCopyWith<_CheckedListTileItem> get copyWith => __$CheckedListTileItemCopyWithImpl<_CheckedListTileItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckedListTileItem&&(identical(other.value, value) || other.value == value)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.description, description) || other.description == description)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.assetUri, assetUri) || other.assetUri == assetUri));
}


@override
int get hashCode => Object.hash(runtimeType,value,title,subtitle,description,uri,assetUri);

@override
String toString() {
  return 'CheckedListTileItem(value: $value, title: $title, subtitle: $subtitle, description: $description, uri: $uri, assetUri: $assetUri)';
}


}

/// @nodoc
abstract mixin class _$CheckedListTileItemCopyWith<$Res> implements $CheckedListTileItemCopyWith<$Res> {
  factory _$CheckedListTileItemCopyWith(_CheckedListTileItem value, $Res Function(_CheckedListTileItem) _then) = __$CheckedListTileItemCopyWithImpl;
@override @useResult
$Res call({
 String value, String title, String? subtitle, String? description, String? uri, String? assetUri
});




}
/// @nodoc
class __$CheckedListTileItemCopyWithImpl<$Res>
    implements _$CheckedListTileItemCopyWith<$Res> {
  __$CheckedListTileItemCopyWithImpl(this._self, this._then);

  final _CheckedListTileItem _self;
  final $Res Function(_CheckedListTileItem) _then;

/// Create a copy of CheckedListTileItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? title = null,Object? subtitle = freezed,Object? description = freezed,Object? uri = freezed,Object? assetUri = freezed,}) {
  return _then(_CheckedListTileItem(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,assetUri: freezed == assetUri ? _self.assetUri : assetUri // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
