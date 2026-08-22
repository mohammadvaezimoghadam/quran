// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AudioPlayerState {

 AudioStatus get status; String? get currentUrl; Duration get position; Duration get duration; double get speed; String? get errorMessage;
/// Create a copy of AudioPlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AudioPlayerStateCopyWith<AudioPlayerState> get copyWith => _$AudioPlayerStateCopyWithImpl<AudioPlayerState>(this as AudioPlayerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudioPlayerState&&(identical(other.status, status) || other.status == status)&&(identical(other.currentUrl, currentUrl) || other.currentUrl == currentUrl)&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,currentUrl,position,duration,speed,errorMessage);

@override
String toString() {
  return 'AudioPlayerState(status: $status, currentUrl: $currentUrl, position: $position, duration: $duration, speed: $speed, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $AudioPlayerStateCopyWith<$Res>  {
  factory $AudioPlayerStateCopyWith(AudioPlayerState value, $Res Function(AudioPlayerState) _then) = _$AudioPlayerStateCopyWithImpl;
@useResult
$Res call({
 AudioStatus status, String? currentUrl, Duration position, Duration duration, double speed, String? errorMessage
});




}
/// @nodoc
class _$AudioPlayerStateCopyWithImpl<$Res>
    implements $AudioPlayerStateCopyWith<$Res> {
  _$AudioPlayerStateCopyWithImpl(this._self, this._then);

  final AudioPlayerState _self;
  final $Res Function(AudioPlayerState) _then;

/// Create a copy of AudioPlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? currentUrl = freezed,Object? position = null,Object? duration = null,Object? speed = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AudioStatus,currentUrl: freezed == currentUrl ? _self.currentUrl : currentUrl // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AudioPlayerState].
extension AudioPlayerStatePatterns on AudioPlayerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AudioPlayerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AudioPlayerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AudioPlayerState value)  $default,){
final _that = this;
switch (_that) {
case _AudioPlayerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AudioPlayerState value)?  $default,){
final _that = this;
switch (_that) {
case _AudioPlayerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AudioStatus status,  String? currentUrl,  Duration position,  Duration duration,  double speed,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AudioPlayerState() when $default != null:
return $default(_that.status,_that.currentUrl,_that.position,_that.duration,_that.speed,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AudioStatus status,  String? currentUrl,  Duration position,  Duration duration,  double speed,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _AudioPlayerState():
return $default(_that.status,_that.currentUrl,_that.position,_that.duration,_that.speed,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AudioStatus status,  String? currentUrl,  Duration position,  Duration duration,  double speed,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _AudioPlayerState() when $default != null:
return $default(_that.status,_that.currentUrl,_that.position,_that.duration,_that.speed,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _AudioPlayerState implements AudioPlayerState {
  const _AudioPlayerState({required this.status, this.currentUrl, this.position = Duration.zero, this.duration = Duration.zero, this.speed = 1.0, this.errorMessage});
  

@override final  AudioStatus status;
@override final  String? currentUrl;
@override@JsonKey() final  Duration position;
@override@JsonKey() final  Duration duration;
@override@JsonKey() final  double speed;
@override final  String? errorMessage;

/// Create a copy of AudioPlayerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AudioPlayerStateCopyWith<_AudioPlayerState> get copyWith => __$AudioPlayerStateCopyWithImpl<_AudioPlayerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AudioPlayerState&&(identical(other.status, status) || other.status == status)&&(identical(other.currentUrl, currentUrl) || other.currentUrl == currentUrl)&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,currentUrl,position,duration,speed,errorMessage);

@override
String toString() {
  return 'AudioPlayerState(status: $status, currentUrl: $currentUrl, position: $position, duration: $duration, speed: $speed, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$AudioPlayerStateCopyWith<$Res> implements $AudioPlayerStateCopyWith<$Res> {
  factory _$AudioPlayerStateCopyWith(_AudioPlayerState value, $Res Function(_AudioPlayerState) _then) = __$AudioPlayerStateCopyWithImpl;
@override @useResult
$Res call({
 AudioStatus status, String? currentUrl, Duration position, Duration duration, double speed, String? errorMessage
});




}
/// @nodoc
class __$AudioPlayerStateCopyWithImpl<$Res>
    implements _$AudioPlayerStateCopyWith<$Res> {
  __$AudioPlayerStateCopyWithImpl(this._self, this._then);

  final _AudioPlayerState _self;
  final $Res Function(_AudioPlayerState) _then;

/// Create a copy of AudioPlayerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? currentUrl = freezed,Object? position = null,Object? duration = null,Object? speed = null,Object? errorMessage = freezed,}) {
  return _then(_AudioPlayerState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AudioStatus,currentUrl: freezed == currentUrl ? _self.currentUrl : currentUrl // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
