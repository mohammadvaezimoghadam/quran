// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ayah_of_the_day_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AyahOfTheDayState {

 bool get isLoading; AyahOfTheDay? get ayah; String? get errorMessage; bool get isPlayingAudio;
/// Create a copy of AyahOfTheDayState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AyahOfTheDayStateCopyWith<AyahOfTheDayState> get copyWith => _$AyahOfTheDayStateCopyWithImpl<AyahOfTheDayState>(this as AyahOfTheDayState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AyahOfTheDayState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.ayah, ayah) || other.ayah == ayah)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isPlayingAudio, isPlayingAudio) || other.isPlayingAudio == isPlayingAudio));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,ayah,errorMessage,isPlayingAudio);

@override
String toString() {
  return 'AyahOfTheDayState(isLoading: $isLoading, ayah: $ayah, errorMessage: $errorMessage, isPlayingAudio: $isPlayingAudio)';
}


}

/// @nodoc
abstract mixin class $AyahOfTheDayStateCopyWith<$Res>  {
  factory $AyahOfTheDayStateCopyWith(AyahOfTheDayState value, $Res Function(AyahOfTheDayState) _then) = _$AyahOfTheDayStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, AyahOfTheDay? ayah, String? errorMessage, bool isPlayingAudio
});


$AyahOfTheDayCopyWith<$Res>? get ayah;

}
/// @nodoc
class _$AyahOfTheDayStateCopyWithImpl<$Res>
    implements $AyahOfTheDayStateCopyWith<$Res> {
  _$AyahOfTheDayStateCopyWithImpl(this._self, this._then);

  final AyahOfTheDayState _self;
  final $Res Function(AyahOfTheDayState) _then;

/// Create a copy of AyahOfTheDayState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? ayah = freezed,Object? errorMessage = freezed,Object? isPlayingAudio = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,ayah: freezed == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as AyahOfTheDay?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isPlayingAudio: null == isPlayingAudio ? _self.isPlayingAudio : isPlayingAudio // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AyahOfTheDayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AyahOfTheDayCopyWith<$Res>? get ayah {
    if (_self.ayah == null) {
    return null;
  }

  return $AyahOfTheDayCopyWith<$Res>(_self.ayah!, (value) {
    return _then(_self.copyWith(ayah: value));
  });
}
}


/// Adds pattern-matching-related methods to [AyahOfTheDayState].
extension AyahOfTheDayStatePatterns on AyahOfTheDayState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AyahOfTheDayState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AyahOfTheDayState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AyahOfTheDayState value)  $default,){
final _that = this;
switch (_that) {
case _AyahOfTheDayState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AyahOfTheDayState value)?  $default,){
final _that = this;
switch (_that) {
case _AyahOfTheDayState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  AyahOfTheDay? ayah,  String? errorMessage,  bool isPlayingAudio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AyahOfTheDayState() when $default != null:
return $default(_that.isLoading,_that.ayah,_that.errorMessage,_that.isPlayingAudio);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  AyahOfTheDay? ayah,  String? errorMessage,  bool isPlayingAudio)  $default,) {final _that = this;
switch (_that) {
case _AyahOfTheDayState():
return $default(_that.isLoading,_that.ayah,_that.errorMessage,_that.isPlayingAudio);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  AyahOfTheDay? ayah,  String? errorMessage,  bool isPlayingAudio)?  $default,) {final _that = this;
switch (_that) {
case _AyahOfTheDayState() when $default != null:
return $default(_that.isLoading,_that.ayah,_that.errorMessage,_that.isPlayingAudio);case _:
  return null;

}
}

}

/// @nodoc


class _AyahOfTheDayState implements AyahOfTheDayState {
  const _AyahOfTheDayState({this.isLoading = true, this.ayah, this.errorMessage, this.isPlayingAudio = false});
  

@override@JsonKey() final  bool isLoading;
@override final  AyahOfTheDay? ayah;
@override final  String? errorMessage;
@override@JsonKey() final  bool isPlayingAudio;

/// Create a copy of AyahOfTheDayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AyahOfTheDayStateCopyWith<_AyahOfTheDayState> get copyWith => __$AyahOfTheDayStateCopyWithImpl<_AyahOfTheDayState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AyahOfTheDayState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.ayah, ayah) || other.ayah == ayah)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isPlayingAudio, isPlayingAudio) || other.isPlayingAudio == isPlayingAudio));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,ayah,errorMessage,isPlayingAudio);

@override
String toString() {
  return 'AyahOfTheDayState(isLoading: $isLoading, ayah: $ayah, errorMessage: $errorMessage, isPlayingAudio: $isPlayingAudio)';
}


}

/// @nodoc
abstract mixin class _$AyahOfTheDayStateCopyWith<$Res> implements $AyahOfTheDayStateCopyWith<$Res> {
  factory _$AyahOfTheDayStateCopyWith(_AyahOfTheDayState value, $Res Function(_AyahOfTheDayState) _then) = __$AyahOfTheDayStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, AyahOfTheDay? ayah, String? errorMessage, bool isPlayingAudio
});


@override $AyahOfTheDayCopyWith<$Res>? get ayah;

}
/// @nodoc
class __$AyahOfTheDayStateCopyWithImpl<$Res>
    implements _$AyahOfTheDayStateCopyWith<$Res> {
  __$AyahOfTheDayStateCopyWithImpl(this._self, this._then);

  final _AyahOfTheDayState _self;
  final $Res Function(_AyahOfTheDayState) _then;

/// Create a copy of AyahOfTheDayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? ayah = freezed,Object? errorMessage = freezed,Object? isPlayingAudio = null,}) {
  return _then(_AyahOfTheDayState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,ayah: freezed == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as AyahOfTheDay?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isPlayingAudio: null == isPlayingAudio ? _self.isPlayingAudio : isPlayingAudio // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AyahOfTheDayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AyahOfTheDayCopyWith<$Res>? get ayah {
    if (_self.ayah == null) {
    return null;
  }

  return $AyahOfTheDayCopyWith<$Res>(_self.ayah!, (value) {
    return _then(_self.copyWith(ayah: value));
  });
}
}

// dart format on
