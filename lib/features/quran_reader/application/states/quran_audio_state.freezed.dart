// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quran_audio_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QuranAudioState {

 ReciterEntity? get selectedReciter; int? get currentSurahId; int? get currentAyahNumber; int? get totalAyahsInSurah; AudioStatus get status; Duration get position; Duration get duration; bool get isAutoPlayNext; bool get isSingleAyahMode; bool get isAutoScrollSuspended; String? get errorMessage;
/// Create a copy of QuranAudioState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuranAudioStateCopyWith<QuranAudioState> get copyWith => _$QuranAudioStateCopyWithImpl<QuranAudioState>(this as QuranAudioState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuranAudioState&&(identical(other.selectedReciter, selectedReciter) || other.selectedReciter == selectedReciter)&&(identical(other.currentSurahId, currentSurahId) || other.currentSurahId == currentSurahId)&&(identical(other.currentAyahNumber, currentAyahNumber) || other.currentAyahNumber == currentAyahNumber)&&(identical(other.totalAyahsInSurah, totalAyahsInSurah) || other.totalAyahsInSurah == totalAyahsInSurah)&&(identical(other.status, status) || other.status == status)&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.isAutoPlayNext, isAutoPlayNext) || other.isAutoPlayNext == isAutoPlayNext)&&(identical(other.isSingleAyahMode, isSingleAyahMode) || other.isSingleAyahMode == isSingleAyahMode)&&(identical(other.isAutoScrollSuspended, isAutoScrollSuspended) || other.isAutoScrollSuspended == isAutoScrollSuspended)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,selectedReciter,currentSurahId,currentAyahNumber,totalAyahsInSurah,status,position,duration,isAutoPlayNext,isSingleAyahMode,isAutoScrollSuspended,errorMessage);

@override
String toString() {
  return 'QuranAudioState(selectedReciter: $selectedReciter, currentSurahId: $currentSurahId, currentAyahNumber: $currentAyahNumber, totalAyahsInSurah: $totalAyahsInSurah, status: $status, position: $position, duration: $duration, isAutoPlayNext: $isAutoPlayNext, isSingleAyahMode: $isSingleAyahMode, isAutoScrollSuspended: $isAutoScrollSuspended, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $QuranAudioStateCopyWith<$Res>  {
  factory $QuranAudioStateCopyWith(QuranAudioState value, $Res Function(QuranAudioState) _then) = _$QuranAudioStateCopyWithImpl;
@useResult
$Res call({
 ReciterEntity? selectedReciter, int? currentSurahId, int? currentAyahNumber, int? totalAyahsInSurah, AudioStatus status, Duration position, Duration duration, bool isAutoPlayNext, bool isSingleAyahMode, bool isAutoScrollSuspended, String? errorMessage
});


$ReciterEntityCopyWith<$Res>? get selectedReciter;

}
/// @nodoc
class _$QuranAudioStateCopyWithImpl<$Res>
    implements $QuranAudioStateCopyWith<$Res> {
  _$QuranAudioStateCopyWithImpl(this._self, this._then);

  final QuranAudioState _self;
  final $Res Function(QuranAudioState) _then;

/// Create a copy of QuranAudioState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedReciter = freezed,Object? currentSurahId = freezed,Object? currentAyahNumber = freezed,Object? totalAyahsInSurah = freezed,Object? status = null,Object? position = null,Object? duration = null,Object? isAutoPlayNext = null,Object? isSingleAyahMode = null,Object? isAutoScrollSuspended = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
selectedReciter: freezed == selectedReciter ? _self.selectedReciter : selectedReciter // ignore: cast_nullable_to_non_nullable
as ReciterEntity?,currentSurahId: freezed == currentSurahId ? _self.currentSurahId : currentSurahId // ignore: cast_nullable_to_non_nullable
as int?,currentAyahNumber: freezed == currentAyahNumber ? _self.currentAyahNumber : currentAyahNumber // ignore: cast_nullable_to_non_nullable
as int?,totalAyahsInSurah: freezed == totalAyahsInSurah ? _self.totalAyahsInSurah : totalAyahsInSurah // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AudioStatus,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,isAutoPlayNext: null == isAutoPlayNext ? _self.isAutoPlayNext : isAutoPlayNext // ignore: cast_nullable_to_non_nullable
as bool,isSingleAyahMode: null == isSingleAyahMode ? _self.isSingleAyahMode : isSingleAyahMode // ignore: cast_nullable_to_non_nullable
as bool,isAutoScrollSuspended: null == isAutoScrollSuspended ? _self.isAutoScrollSuspended : isAutoScrollSuspended // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of QuranAudioState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReciterEntityCopyWith<$Res>? get selectedReciter {
    if (_self.selectedReciter == null) {
    return null;
  }

  return $ReciterEntityCopyWith<$Res>(_self.selectedReciter!, (value) {
    return _then(_self.copyWith(selectedReciter: value));
  });
}
}


/// Adds pattern-matching-related methods to [QuranAudioState].
extension QuranAudioStatePatterns on QuranAudioState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuranAudioState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuranAudioState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuranAudioState value)  $default,){
final _that = this;
switch (_that) {
case _QuranAudioState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuranAudioState value)?  $default,){
final _that = this;
switch (_that) {
case _QuranAudioState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReciterEntity? selectedReciter,  int? currentSurahId,  int? currentAyahNumber,  int? totalAyahsInSurah,  AudioStatus status,  Duration position,  Duration duration,  bool isAutoPlayNext,  bool isSingleAyahMode,  bool isAutoScrollSuspended,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuranAudioState() when $default != null:
return $default(_that.selectedReciter,_that.currentSurahId,_that.currentAyahNumber,_that.totalAyahsInSurah,_that.status,_that.position,_that.duration,_that.isAutoPlayNext,_that.isSingleAyahMode,_that.isAutoScrollSuspended,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReciterEntity? selectedReciter,  int? currentSurahId,  int? currentAyahNumber,  int? totalAyahsInSurah,  AudioStatus status,  Duration position,  Duration duration,  bool isAutoPlayNext,  bool isSingleAyahMode,  bool isAutoScrollSuspended,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _QuranAudioState():
return $default(_that.selectedReciter,_that.currentSurahId,_that.currentAyahNumber,_that.totalAyahsInSurah,_that.status,_that.position,_that.duration,_that.isAutoPlayNext,_that.isSingleAyahMode,_that.isAutoScrollSuspended,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReciterEntity? selectedReciter,  int? currentSurahId,  int? currentAyahNumber,  int? totalAyahsInSurah,  AudioStatus status,  Duration position,  Duration duration,  bool isAutoPlayNext,  bool isSingleAyahMode,  bool isAutoScrollSuspended,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _QuranAudioState() when $default != null:
return $default(_that.selectedReciter,_that.currentSurahId,_that.currentAyahNumber,_that.totalAyahsInSurah,_that.status,_that.position,_that.duration,_that.isAutoPlayNext,_that.isSingleAyahMode,_that.isAutoScrollSuspended,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _QuranAudioState implements QuranAudioState {
  const _QuranAudioState({this.selectedReciter, this.currentSurahId, this.currentAyahNumber, this.totalAyahsInSurah, this.status = AudioStatus.initial, this.position = Duration.zero, this.duration = Duration.zero, this.isAutoPlayNext = true, this.isSingleAyahMode = false, this.isAutoScrollSuspended = false, this.errorMessage});
  

@override final  ReciterEntity? selectedReciter;
@override final  int? currentSurahId;
@override final  int? currentAyahNumber;
@override final  int? totalAyahsInSurah;
@override@JsonKey() final  AudioStatus status;
@override@JsonKey() final  Duration position;
@override@JsonKey() final  Duration duration;
@override@JsonKey() final  bool isAutoPlayNext;
@override@JsonKey() final  bool isSingleAyahMode;
@override@JsonKey() final  bool isAutoScrollSuspended;
@override final  String? errorMessage;

/// Create a copy of QuranAudioState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuranAudioStateCopyWith<_QuranAudioState> get copyWith => __$QuranAudioStateCopyWithImpl<_QuranAudioState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuranAudioState&&(identical(other.selectedReciter, selectedReciter) || other.selectedReciter == selectedReciter)&&(identical(other.currentSurahId, currentSurahId) || other.currentSurahId == currentSurahId)&&(identical(other.currentAyahNumber, currentAyahNumber) || other.currentAyahNumber == currentAyahNumber)&&(identical(other.totalAyahsInSurah, totalAyahsInSurah) || other.totalAyahsInSurah == totalAyahsInSurah)&&(identical(other.status, status) || other.status == status)&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.isAutoPlayNext, isAutoPlayNext) || other.isAutoPlayNext == isAutoPlayNext)&&(identical(other.isSingleAyahMode, isSingleAyahMode) || other.isSingleAyahMode == isSingleAyahMode)&&(identical(other.isAutoScrollSuspended, isAutoScrollSuspended) || other.isAutoScrollSuspended == isAutoScrollSuspended)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,selectedReciter,currentSurahId,currentAyahNumber,totalAyahsInSurah,status,position,duration,isAutoPlayNext,isSingleAyahMode,isAutoScrollSuspended,errorMessage);

@override
String toString() {
  return 'QuranAudioState(selectedReciter: $selectedReciter, currentSurahId: $currentSurahId, currentAyahNumber: $currentAyahNumber, totalAyahsInSurah: $totalAyahsInSurah, status: $status, position: $position, duration: $duration, isAutoPlayNext: $isAutoPlayNext, isSingleAyahMode: $isSingleAyahMode, isAutoScrollSuspended: $isAutoScrollSuspended, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$QuranAudioStateCopyWith<$Res> implements $QuranAudioStateCopyWith<$Res> {
  factory _$QuranAudioStateCopyWith(_QuranAudioState value, $Res Function(_QuranAudioState) _then) = __$QuranAudioStateCopyWithImpl;
@override @useResult
$Res call({
 ReciterEntity? selectedReciter, int? currentSurahId, int? currentAyahNumber, int? totalAyahsInSurah, AudioStatus status, Duration position, Duration duration, bool isAutoPlayNext, bool isSingleAyahMode, bool isAutoScrollSuspended, String? errorMessage
});


@override $ReciterEntityCopyWith<$Res>? get selectedReciter;

}
/// @nodoc
class __$QuranAudioStateCopyWithImpl<$Res>
    implements _$QuranAudioStateCopyWith<$Res> {
  __$QuranAudioStateCopyWithImpl(this._self, this._then);

  final _QuranAudioState _self;
  final $Res Function(_QuranAudioState) _then;

/// Create a copy of QuranAudioState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedReciter = freezed,Object? currentSurahId = freezed,Object? currentAyahNumber = freezed,Object? totalAyahsInSurah = freezed,Object? status = null,Object? position = null,Object? duration = null,Object? isAutoPlayNext = null,Object? isSingleAyahMode = null,Object? isAutoScrollSuspended = null,Object? errorMessage = freezed,}) {
  return _then(_QuranAudioState(
selectedReciter: freezed == selectedReciter ? _self.selectedReciter : selectedReciter // ignore: cast_nullable_to_non_nullable
as ReciterEntity?,currentSurahId: freezed == currentSurahId ? _self.currentSurahId : currentSurahId // ignore: cast_nullable_to_non_nullable
as int?,currentAyahNumber: freezed == currentAyahNumber ? _self.currentAyahNumber : currentAyahNumber // ignore: cast_nullable_to_non_nullable
as int?,totalAyahsInSurah: freezed == totalAyahsInSurah ? _self.totalAyahsInSurah : totalAyahsInSurah // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AudioStatus,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,isAutoPlayNext: null == isAutoPlayNext ? _self.isAutoPlayNext : isAutoPlayNext // ignore: cast_nullable_to_non_nullable
as bool,isSingleAyahMode: null == isSingleAyahMode ? _self.isSingleAyahMode : isSingleAyahMode // ignore: cast_nullable_to_non_nullable
as bool,isAutoScrollSuspended: null == isAutoScrollSuspended ? _self.isAutoScrollSuspended : isAutoScrollSuspended // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of QuranAudioState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReciterEntityCopyWith<$Res>? get selectedReciter {
    if (_self.selectedReciter == null) {
    return null;
  }

  return $ReciterEntityCopyWith<$Res>(_self.selectedReciter!, (value) {
    return _then(_self.copyWith(selectedReciter: value));
  });
}
}

// dart format on
