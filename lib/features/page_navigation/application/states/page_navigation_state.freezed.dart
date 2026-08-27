// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'page_navigation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PageNavigationState {

 bool get isLoading; String? get errorMessage; PageNavigationTarget? get target;
/// Create a copy of PageNavigationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PageNavigationStateCopyWith<PageNavigationState> get copyWith => _$PageNavigationStateCopyWithImpl<PageNavigationState>(this as PageNavigationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PageNavigationState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.target, target) || other.target == target));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,errorMessage,target);

@override
String toString() {
  return 'PageNavigationState(isLoading: $isLoading, errorMessage: $errorMessage, target: $target)';
}


}

/// @nodoc
abstract mixin class $PageNavigationStateCopyWith<$Res>  {
  factory $PageNavigationStateCopyWith(PageNavigationState value, $Res Function(PageNavigationState) _then) = _$PageNavigationStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, String? errorMessage, PageNavigationTarget? target
});




}
/// @nodoc
class _$PageNavigationStateCopyWithImpl<$Res>
    implements $PageNavigationStateCopyWith<$Res> {
  _$PageNavigationStateCopyWithImpl(this._self, this._then);

  final PageNavigationState _self;
  final $Res Function(PageNavigationState) _then;

/// Create a copy of PageNavigationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? errorMessage = freezed,Object? target = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as PageNavigationTarget?,
  ));
}

}


/// Adds pattern-matching-related methods to [PageNavigationState].
extension PageNavigationStatePatterns on PageNavigationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PageNavigationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PageNavigationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PageNavigationState value)  $default,){
final _that = this;
switch (_that) {
case _PageNavigationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PageNavigationState value)?  $default,){
final _that = this;
switch (_that) {
case _PageNavigationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  String? errorMessage,  PageNavigationTarget? target)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PageNavigationState() when $default != null:
return $default(_that.isLoading,_that.errorMessage,_that.target);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  String? errorMessage,  PageNavigationTarget? target)  $default,) {final _that = this;
switch (_that) {
case _PageNavigationState():
return $default(_that.isLoading,_that.errorMessage,_that.target);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  String? errorMessage,  PageNavigationTarget? target)?  $default,) {final _that = this;
switch (_that) {
case _PageNavigationState() when $default != null:
return $default(_that.isLoading,_that.errorMessage,_that.target);case _:
  return null;

}
}

}

/// @nodoc


class _PageNavigationState implements PageNavigationState {
  const _PageNavigationState({this.isLoading = false, this.errorMessage, this.target});
  

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;
@override final  PageNavigationTarget? target;

/// Create a copy of PageNavigationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PageNavigationStateCopyWith<_PageNavigationState> get copyWith => __$PageNavigationStateCopyWithImpl<_PageNavigationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PageNavigationState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.target, target) || other.target == target));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,errorMessage,target);

@override
String toString() {
  return 'PageNavigationState(isLoading: $isLoading, errorMessage: $errorMessage, target: $target)';
}


}

/// @nodoc
abstract mixin class _$PageNavigationStateCopyWith<$Res> implements $PageNavigationStateCopyWith<$Res> {
  factory _$PageNavigationStateCopyWith(_PageNavigationState value, $Res Function(_PageNavigationState) _then) = __$PageNavigationStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, String? errorMessage, PageNavigationTarget? target
});




}
/// @nodoc
class __$PageNavigationStateCopyWithImpl<$Res>
    implements _$PageNavigationStateCopyWith<$Res> {
  __$PageNavigationStateCopyWithImpl(this._self, this._then);

  final _PageNavigationState _self;
  final $Res Function(_PageNavigationState) _then;

/// Create a copy of PageNavigationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? errorMessage = freezed,Object? target = freezed,}) {
  return _then(_PageNavigationState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as PageNavigationTarget?,
  ));
}


}

// dart format on
