// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SubscriptionEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubscriptionEvent()';
}


}

/// @nodoc
class $SubscriptionEventCopyWith<$Res>  {
$SubscriptionEventCopyWith(SubscriptionEvent _, $Res Function(SubscriptionEvent) __);
}


/// Adds pattern-matching-related methods to [SubscriptionEvent].
extension SubscriptionEventPatterns on SubscriptionEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initialize value)?  initialize,TResult Function( _LoadProducts value)?  loadProducts,TResult Function( _Purchase value)?  purchase,TResult Function( _RestorePurchases value)?  restorePurchases,TResult Function( _PurchaseCompleted value)?  purchaseCompleted,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initialize() when initialize != null:
return initialize(_that);case _LoadProducts() when loadProducts != null:
return loadProducts(_that);case _Purchase() when purchase != null:
return purchase(_that);case _RestorePurchases() when restorePurchases != null:
return restorePurchases(_that);case _PurchaseCompleted() when purchaseCompleted != null:
return purchaseCompleted(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initialize value)  initialize,required TResult Function( _LoadProducts value)  loadProducts,required TResult Function( _Purchase value)  purchase,required TResult Function( _RestorePurchases value)  restorePurchases,required TResult Function( _PurchaseCompleted value)  purchaseCompleted,}){
final _that = this;
switch (_that) {
case _Initialize():
return initialize(_that);case _LoadProducts():
return loadProducts(_that);case _Purchase():
return purchase(_that);case _RestorePurchases():
return restorePurchases(_that);case _PurchaseCompleted():
return purchaseCompleted(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initialize value)?  initialize,TResult? Function( _LoadProducts value)?  loadProducts,TResult? Function( _Purchase value)?  purchase,TResult? Function( _RestorePurchases value)?  restorePurchases,TResult? Function( _PurchaseCompleted value)?  purchaseCompleted,}){
final _that = this;
switch (_that) {
case _Initialize() when initialize != null:
return initialize(_that);case _LoadProducts() when loadProducts != null:
return loadProducts(_that);case _Purchase() when purchase != null:
return purchase(_that);case _RestorePurchases() when restorePurchases != null:
return restorePurchases(_that);case _PurchaseCompleted() when purchaseCompleted != null:
return purchaseCompleted(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initialize,TResult Function()?  loadProducts,TResult Function( SubscriptionProduct product)?  purchase,TResult Function()?  restorePurchases,TResult Function( bool success)?  purchaseCompleted,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initialize() when initialize != null:
return initialize();case _LoadProducts() when loadProducts != null:
return loadProducts();case _Purchase() when purchase != null:
return purchase(_that.product);case _RestorePurchases() when restorePurchases != null:
return restorePurchases();case _PurchaseCompleted() when purchaseCompleted != null:
return purchaseCompleted(_that.success);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initialize,required TResult Function()  loadProducts,required TResult Function( SubscriptionProduct product)  purchase,required TResult Function()  restorePurchases,required TResult Function( bool success)  purchaseCompleted,}) {final _that = this;
switch (_that) {
case _Initialize():
return initialize();case _LoadProducts():
return loadProducts();case _Purchase():
return purchase(_that.product);case _RestorePurchases():
return restorePurchases();case _PurchaseCompleted():
return purchaseCompleted(_that.success);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initialize,TResult? Function()?  loadProducts,TResult? Function( SubscriptionProduct product)?  purchase,TResult? Function()?  restorePurchases,TResult? Function( bool success)?  purchaseCompleted,}) {final _that = this;
switch (_that) {
case _Initialize() when initialize != null:
return initialize();case _LoadProducts() when loadProducts != null:
return loadProducts();case _Purchase() when purchase != null:
return purchase(_that.product);case _RestorePurchases() when restorePurchases != null:
return restorePurchases();case _PurchaseCompleted() when purchaseCompleted != null:
return purchaseCompleted(_that.success);case _:
  return null;

}
}

}

/// @nodoc


class _Initialize implements SubscriptionEvent {
  const _Initialize();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initialize);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubscriptionEvent.initialize()';
}


}




/// @nodoc


class _LoadProducts implements SubscriptionEvent {
  const _LoadProducts();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadProducts);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubscriptionEvent.loadProducts()';
}


}




/// @nodoc


class _Purchase implements SubscriptionEvent {
  const _Purchase(this.product);
  

 final  SubscriptionProduct product;

/// Create a copy of SubscriptionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseCopyWith<_Purchase> get copyWith => __$PurchaseCopyWithImpl<_Purchase>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Purchase&&(identical(other.product, product) || other.product == product));
}


@override
int get hashCode => Object.hash(runtimeType,product);

@override
String toString() {
  return 'SubscriptionEvent.purchase(product: $product)';
}


}

/// @nodoc
abstract mixin class _$PurchaseCopyWith<$Res> implements $SubscriptionEventCopyWith<$Res> {
  factory _$PurchaseCopyWith(_Purchase value, $Res Function(_Purchase) _then) = __$PurchaseCopyWithImpl;
@useResult
$Res call({
 SubscriptionProduct product
});




}
/// @nodoc
class __$PurchaseCopyWithImpl<$Res>
    implements _$PurchaseCopyWith<$Res> {
  __$PurchaseCopyWithImpl(this._self, this._then);

  final _Purchase _self;
  final $Res Function(_Purchase) _then;

/// Create a copy of SubscriptionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? product = null,}) {
  return _then(_Purchase(
null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as SubscriptionProduct,
  ));
}


}

/// @nodoc


class _RestorePurchases implements SubscriptionEvent {
  const _RestorePurchases();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestorePurchases);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubscriptionEvent.restorePurchases()';
}


}




/// @nodoc


class _PurchaseCompleted implements SubscriptionEvent {
  const _PurchaseCompleted(this.success);
  

 final  bool success;

/// Create a copy of SubscriptionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseCompletedCopyWith<_PurchaseCompleted> get copyWith => __$PurchaseCompletedCopyWithImpl<_PurchaseCompleted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseCompleted&&(identical(other.success, success) || other.success == success));
}


@override
int get hashCode => Object.hash(runtimeType,success);

@override
String toString() {
  return 'SubscriptionEvent.purchaseCompleted(success: $success)';
}


}

/// @nodoc
abstract mixin class _$PurchaseCompletedCopyWith<$Res> implements $SubscriptionEventCopyWith<$Res> {
  factory _$PurchaseCompletedCopyWith(_PurchaseCompleted value, $Res Function(_PurchaseCompleted) _then) = __$PurchaseCompletedCopyWithImpl;
@useResult
$Res call({
 bool success
});




}
/// @nodoc
class __$PurchaseCompletedCopyWithImpl<$Res>
    implements _$PurchaseCompletedCopyWith<$Res> {
  __$PurchaseCompletedCopyWithImpl(this._self, this._then);

  final _PurchaseCompleted _self;
  final $Res Function(_PurchaseCompleted) _then;

/// Create a copy of SubscriptionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? success = null,}) {
  return _then(_PurchaseCompleted(
null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$SubscriptionState {

 bool get isLoading; bool get isSubscribed; List<SubscriptionProduct> get products; String get errorMessage; bool get isPurchaseInProgress; bool get isPurchaseCompleted; bool get isRestoringPurchases;
/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionStateCopyWith<SubscriptionState> get copyWith => _$SubscriptionStateCopyWithImpl<SubscriptionState>(this as SubscriptionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSubscribed, isSubscribed) || other.isSubscribed == isSubscribed)&&const DeepCollectionEquality().equals(other.products, products)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isPurchaseInProgress, isPurchaseInProgress) || other.isPurchaseInProgress == isPurchaseInProgress)&&(identical(other.isPurchaseCompleted, isPurchaseCompleted) || other.isPurchaseCompleted == isPurchaseCompleted)&&(identical(other.isRestoringPurchases, isRestoringPurchases) || other.isRestoringPurchases == isRestoringPurchases));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isSubscribed,const DeepCollectionEquality().hash(products),errorMessage,isPurchaseInProgress,isPurchaseCompleted,isRestoringPurchases);

@override
String toString() {
  return 'SubscriptionState(isLoading: $isLoading, isSubscribed: $isSubscribed, products: $products, errorMessage: $errorMessage, isPurchaseInProgress: $isPurchaseInProgress, isPurchaseCompleted: $isPurchaseCompleted, isRestoringPurchases: $isRestoringPurchases)';
}


}

/// @nodoc
abstract mixin class $SubscriptionStateCopyWith<$Res>  {
  factory $SubscriptionStateCopyWith(SubscriptionState value, $Res Function(SubscriptionState) _then) = _$SubscriptionStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool isSubscribed, List<SubscriptionProduct> products, String errorMessage, bool isPurchaseInProgress, bool isPurchaseCompleted, bool isRestoringPurchases
});




}
/// @nodoc
class _$SubscriptionStateCopyWithImpl<$Res>
    implements $SubscriptionStateCopyWith<$Res> {
  _$SubscriptionStateCopyWithImpl(this._self, this._then);

  final SubscriptionState _self;
  final $Res Function(SubscriptionState) _then;

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? isSubscribed = null,Object? products = null,Object? errorMessage = null,Object? isPurchaseInProgress = null,Object? isPurchaseCompleted = null,Object? isRestoringPurchases = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSubscribed: null == isSubscribed ? _self.isSubscribed : isSubscribed // ignore: cast_nullable_to_non_nullable
as bool,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<SubscriptionProduct>,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,isPurchaseInProgress: null == isPurchaseInProgress ? _self.isPurchaseInProgress : isPurchaseInProgress // ignore: cast_nullable_to_non_nullable
as bool,isPurchaseCompleted: null == isPurchaseCompleted ? _self.isPurchaseCompleted : isPurchaseCompleted // ignore: cast_nullable_to_non_nullable
as bool,isRestoringPurchases: null == isRestoringPurchases ? _self.isRestoringPurchases : isRestoringPurchases // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionState].
extension SubscriptionStatePatterns on SubscriptionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionState value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionState value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool isSubscribed,  List<SubscriptionProduct> products,  String errorMessage,  bool isPurchaseInProgress,  bool isPurchaseCompleted,  bool isRestoringPurchases)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionState() when $default != null:
return $default(_that.isLoading,_that.isSubscribed,_that.products,_that.errorMessage,_that.isPurchaseInProgress,_that.isPurchaseCompleted,_that.isRestoringPurchases);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool isSubscribed,  List<SubscriptionProduct> products,  String errorMessage,  bool isPurchaseInProgress,  bool isPurchaseCompleted,  bool isRestoringPurchases)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionState():
return $default(_that.isLoading,_that.isSubscribed,_that.products,_that.errorMessage,_that.isPurchaseInProgress,_that.isPurchaseCompleted,_that.isRestoringPurchases);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool isSubscribed,  List<SubscriptionProduct> products,  String errorMessage,  bool isPurchaseInProgress,  bool isPurchaseCompleted,  bool isRestoringPurchases)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionState() when $default != null:
return $default(_that.isLoading,_that.isSubscribed,_that.products,_that.errorMessage,_that.isPurchaseInProgress,_that.isPurchaseCompleted,_that.isRestoringPurchases);case _:
  return null;

}
}

}

/// @nodoc


class _SubscriptionState implements SubscriptionState {
  const _SubscriptionState({this.isLoading = false, this.isSubscribed = false, final  List<SubscriptionProduct> products = const [], this.errorMessage = '', this.isPurchaseInProgress = false, this.isPurchaseCompleted = false, this.isRestoringPurchases = false}): _products = products;
  

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isSubscribed;
 final  List<SubscriptionProduct> _products;
@override@JsonKey() List<SubscriptionProduct> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

@override@JsonKey() final  String errorMessage;
@override@JsonKey() final  bool isPurchaseInProgress;
@override@JsonKey() final  bool isPurchaseCompleted;
@override@JsonKey() final  bool isRestoringPurchases;

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionStateCopyWith<_SubscriptionState> get copyWith => __$SubscriptionStateCopyWithImpl<_SubscriptionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSubscribed, isSubscribed) || other.isSubscribed == isSubscribed)&&const DeepCollectionEquality().equals(other._products, _products)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isPurchaseInProgress, isPurchaseInProgress) || other.isPurchaseInProgress == isPurchaseInProgress)&&(identical(other.isPurchaseCompleted, isPurchaseCompleted) || other.isPurchaseCompleted == isPurchaseCompleted)&&(identical(other.isRestoringPurchases, isRestoringPurchases) || other.isRestoringPurchases == isRestoringPurchases));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isSubscribed,const DeepCollectionEquality().hash(_products),errorMessage,isPurchaseInProgress,isPurchaseCompleted,isRestoringPurchases);

@override
String toString() {
  return 'SubscriptionState(isLoading: $isLoading, isSubscribed: $isSubscribed, products: $products, errorMessage: $errorMessage, isPurchaseInProgress: $isPurchaseInProgress, isPurchaseCompleted: $isPurchaseCompleted, isRestoringPurchases: $isRestoringPurchases)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionStateCopyWith<$Res> implements $SubscriptionStateCopyWith<$Res> {
  factory _$SubscriptionStateCopyWith(_SubscriptionState value, $Res Function(_SubscriptionState) _then) = __$SubscriptionStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool isSubscribed, List<SubscriptionProduct> products, String errorMessage, bool isPurchaseInProgress, bool isPurchaseCompleted, bool isRestoringPurchases
});




}
/// @nodoc
class __$SubscriptionStateCopyWithImpl<$Res>
    implements _$SubscriptionStateCopyWith<$Res> {
  __$SubscriptionStateCopyWithImpl(this._self, this._then);

  final _SubscriptionState _self;
  final $Res Function(_SubscriptionState) _then;

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? isSubscribed = null,Object? products = null,Object? errorMessage = null,Object? isPurchaseInProgress = null,Object? isPurchaseCompleted = null,Object? isRestoringPurchases = null,}) {
  return _then(_SubscriptionState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSubscribed: null == isSubscribed ? _self.isSubscribed : isSubscribed // ignore: cast_nullable_to_non_nullable
as bool,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<SubscriptionProduct>,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,isPurchaseInProgress: null == isPurchaseInProgress ? _self.isPurchaseInProgress : isPurchaseInProgress // ignore: cast_nullable_to_non_nullable
as bool,isPurchaseCompleted: null == isPurchaseCompleted ? _self.isPurchaseCompleted : isPurchaseCompleted // ignore: cast_nullable_to_non_nullable
as bool,isRestoringPurchases: null == isRestoringPurchases ? _self.isRestoringPurchases : isRestoringPurchases // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
