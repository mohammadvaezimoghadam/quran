// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mini_audio_player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MiniAudioPlayerState {

 bool get isDismissed;
/// Create a copy of MiniAudioPlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MiniAudioPlayerStateCopyWith<MiniAudioPlayerState> get copyWith => _$MiniAudioPlayerStateCopyWithImpl<MiniAudioPlayerState>(this as MiniAudioPlayerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MiniAudioPlayerState&&(identical(other.isDismissed, isDismissed) || other.isDismissed == isDismissed));
}


@override
int get hashCode => Object.hash(runtimeType,isDismissed);

@override
String toString() {
  return 'MiniAudioPlayerState(isDismissed: $isDismissed)';
}


}

/// @nodoc
abstract mixin class $MiniAudioPlayerStateCopyWith<$Res>  {
  factory $MiniAudioPlayerStateCopyWith(MiniAudioPlayerState value, $Res Function(MiniAudioPlayerState) _then) = _$MiniAudioPlayerStateCopyWithImpl;
@useResult
$Res call({
 bool isDismissed
});




}
/// @nodoc
class _$MiniAudioPlayerStateCopyWithImpl<$Res>
    implements $MiniAudioPlayerStateCopyWith<$Res> {
  _$MiniAudioPlayerStateCopyWithImpl(this._self, this._then);

  final MiniAudioPlayerState _self;
  final $Res Function(MiniAudioPlayerState) _then;

/// Create a copy of MiniAudioPlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isDismissed = null,}) {
  return _then(_self.copyWith(
isDismissed: null == isDismissed ? _self.isDismissed : isDismissed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MiniAudioPlayerState].
extension MiniAudioPlayerStatePatterns on MiniAudioPlayerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MiniAudioPlayerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MiniAudioPlayerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MiniAudioPlayerState value)  $default,){
final _that = this;
switch (_that) {
case _MiniAudioPlayerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MiniAudioPlayerState value)?  $default,){
final _that = this;
switch (_that) {
case _MiniAudioPlayerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isDismissed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MiniAudioPlayerState() when $default != null:
return $default(_that.isDismissed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isDismissed)  $default,) {final _that = this;
switch (_that) {
case _MiniAudioPlayerState():
return $default(_that.isDismissed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isDismissed)?  $default,) {final _that = this;
switch (_that) {
case _MiniAudioPlayerState() when $default != null:
return $default(_that.isDismissed);case _:
  return null;

}
}

}

/// @nodoc


class _MiniAudioPlayerState implements MiniAudioPlayerState {
  const _MiniAudioPlayerState({this.isDismissed = false});
  

@override@JsonKey() final  bool isDismissed;

/// Create a copy of MiniAudioPlayerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MiniAudioPlayerStateCopyWith<_MiniAudioPlayerState> get copyWith => __$MiniAudioPlayerStateCopyWithImpl<_MiniAudioPlayerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MiniAudioPlayerState&&(identical(other.isDismissed, isDismissed) || other.isDismissed == isDismissed));
}


@override
int get hashCode => Object.hash(runtimeType,isDismissed);

@override
String toString() {
  return 'MiniAudioPlayerState(isDismissed: $isDismissed)';
}


}

/// @nodoc
abstract mixin class _$MiniAudioPlayerStateCopyWith<$Res> implements $MiniAudioPlayerStateCopyWith<$Res> {
  factory _$MiniAudioPlayerStateCopyWith(_MiniAudioPlayerState value, $Res Function(_MiniAudioPlayerState) _then) = __$MiniAudioPlayerStateCopyWithImpl;
@override @useResult
$Res call({
 bool isDismissed
});




}
/// @nodoc
class __$MiniAudioPlayerStateCopyWithImpl<$Res>
    implements _$MiniAudioPlayerStateCopyWith<$Res> {
  __$MiniAudioPlayerStateCopyWithImpl(this._self, this._then);

  final _MiniAudioPlayerState _self;
  final $Res Function(_MiniAudioPlayerState) _then;

/// Create a copy of MiniAudioPlayerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isDismissed = null,}) {
  return _then(_MiniAudioPlayerState(
isDismissed: null == isDismissed ? _self.isDismissed : isDismissed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
