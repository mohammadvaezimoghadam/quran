// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_download_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AudioDownloadTask {

 int get surahId; int get reciterId; double get progress; DownloadTaskStatus get status; int get currentAyah; int get totalAyahs; int get completedAyahs; String? get errorMessage;
/// Create a copy of AudioDownloadTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AudioDownloadTaskCopyWith<AudioDownloadTask> get copyWith => _$AudioDownloadTaskCopyWithImpl<AudioDownloadTask>(this as AudioDownloadTask, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudioDownloadTask&&(identical(other.surahId, surahId) || other.surahId == surahId)&&(identical(other.reciterId, reciterId) || other.reciterId == reciterId)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentAyah, currentAyah) || other.currentAyah == currentAyah)&&(identical(other.totalAyahs, totalAyahs) || other.totalAyahs == totalAyahs)&&(identical(other.completedAyahs, completedAyahs) || other.completedAyahs == completedAyahs)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,surahId,reciterId,progress,status,currentAyah,totalAyahs,completedAyahs,errorMessage);

@override
String toString() {
  return 'AudioDownloadTask(surahId: $surahId, reciterId: $reciterId, progress: $progress, status: $status, currentAyah: $currentAyah, totalAyahs: $totalAyahs, completedAyahs: $completedAyahs, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $AudioDownloadTaskCopyWith<$Res>  {
  factory $AudioDownloadTaskCopyWith(AudioDownloadTask value, $Res Function(AudioDownloadTask) _then) = _$AudioDownloadTaskCopyWithImpl;
@useResult
$Res call({
 int surahId, int reciterId, double progress, DownloadTaskStatus status, int currentAyah, int totalAyahs, int completedAyahs, String? errorMessage
});




}
/// @nodoc
class _$AudioDownloadTaskCopyWithImpl<$Res>
    implements $AudioDownloadTaskCopyWith<$Res> {
  _$AudioDownloadTaskCopyWithImpl(this._self, this._then);

  final AudioDownloadTask _self;
  final $Res Function(AudioDownloadTask) _then;

/// Create a copy of AudioDownloadTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? surahId = null,Object? reciterId = null,Object? progress = null,Object? status = null,Object? currentAyah = null,Object? totalAyahs = null,Object? completedAyahs = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
surahId: null == surahId ? _self.surahId : surahId // ignore: cast_nullable_to_non_nullable
as int,reciterId: null == reciterId ? _self.reciterId : reciterId // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloadTaskStatus,currentAyah: null == currentAyah ? _self.currentAyah : currentAyah // ignore: cast_nullable_to_non_nullable
as int,totalAyahs: null == totalAyahs ? _self.totalAyahs : totalAyahs // ignore: cast_nullable_to_non_nullable
as int,completedAyahs: null == completedAyahs ? _self.completedAyahs : completedAyahs // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AudioDownloadTask].
extension AudioDownloadTaskPatterns on AudioDownloadTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AudioDownloadTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AudioDownloadTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AudioDownloadTask value)  $default,){
final _that = this;
switch (_that) {
case _AudioDownloadTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AudioDownloadTask value)?  $default,){
final _that = this;
switch (_that) {
case _AudioDownloadTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int surahId,  int reciterId,  double progress,  DownloadTaskStatus status,  int currentAyah,  int totalAyahs,  int completedAyahs,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AudioDownloadTask() when $default != null:
return $default(_that.surahId,_that.reciterId,_that.progress,_that.status,_that.currentAyah,_that.totalAyahs,_that.completedAyahs,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int surahId,  int reciterId,  double progress,  DownloadTaskStatus status,  int currentAyah,  int totalAyahs,  int completedAyahs,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _AudioDownloadTask():
return $default(_that.surahId,_that.reciterId,_that.progress,_that.status,_that.currentAyah,_that.totalAyahs,_that.completedAyahs,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int surahId,  int reciterId,  double progress,  DownloadTaskStatus status,  int currentAyah,  int totalAyahs,  int completedAyahs,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _AudioDownloadTask() when $default != null:
return $default(_that.surahId,_that.reciterId,_that.progress,_that.status,_that.currentAyah,_that.totalAyahs,_that.completedAyahs,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _AudioDownloadTask implements AudioDownloadTask {
  const _AudioDownloadTask({required this.surahId, required this.reciterId, this.progress = 0.0, this.status = DownloadTaskStatus.idle, this.currentAyah = 0, this.totalAyahs = 0, this.completedAyahs = 0, this.errorMessage});
  

@override final  int surahId;
@override final  int reciterId;
@override@JsonKey() final  double progress;
@override@JsonKey() final  DownloadTaskStatus status;
@override@JsonKey() final  int currentAyah;
@override@JsonKey() final  int totalAyahs;
@override@JsonKey() final  int completedAyahs;
@override final  String? errorMessage;

/// Create a copy of AudioDownloadTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AudioDownloadTaskCopyWith<_AudioDownloadTask> get copyWith => __$AudioDownloadTaskCopyWithImpl<_AudioDownloadTask>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AudioDownloadTask&&(identical(other.surahId, surahId) || other.surahId == surahId)&&(identical(other.reciterId, reciterId) || other.reciterId == reciterId)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentAyah, currentAyah) || other.currentAyah == currentAyah)&&(identical(other.totalAyahs, totalAyahs) || other.totalAyahs == totalAyahs)&&(identical(other.completedAyahs, completedAyahs) || other.completedAyahs == completedAyahs)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,surahId,reciterId,progress,status,currentAyah,totalAyahs,completedAyahs,errorMessage);

@override
String toString() {
  return 'AudioDownloadTask(surahId: $surahId, reciterId: $reciterId, progress: $progress, status: $status, currentAyah: $currentAyah, totalAyahs: $totalAyahs, completedAyahs: $completedAyahs, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$AudioDownloadTaskCopyWith<$Res> implements $AudioDownloadTaskCopyWith<$Res> {
  factory _$AudioDownloadTaskCopyWith(_AudioDownloadTask value, $Res Function(_AudioDownloadTask) _then) = __$AudioDownloadTaskCopyWithImpl;
@override @useResult
$Res call({
 int surahId, int reciterId, double progress, DownloadTaskStatus status, int currentAyah, int totalAyahs, int completedAyahs, String? errorMessage
});




}
/// @nodoc
class __$AudioDownloadTaskCopyWithImpl<$Res>
    implements _$AudioDownloadTaskCopyWith<$Res> {
  __$AudioDownloadTaskCopyWithImpl(this._self, this._then);

  final _AudioDownloadTask _self;
  final $Res Function(_AudioDownloadTask) _then;

/// Create a copy of AudioDownloadTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? surahId = null,Object? reciterId = null,Object? progress = null,Object? status = null,Object? currentAyah = null,Object? totalAyahs = null,Object? completedAyahs = null,Object? errorMessage = freezed,}) {
  return _then(_AudioDownloadTask(
surahId: null == surahId ? _self.surahId : surahId // ignore: cast_nullable_to_non_nullable
as int,reciterId: null == reciterId ? _self.reciterId : reciterId // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloadTaskStatus,currentAyah: null == currentAyah ? _self.currentAyah : currentAyah // ignore: cast_nullable_to_non_nullable
as int,totalAyahs: null == totalAyahs ? _self.totalAyahs : totalAyahs // ignore: cast_nullable_to_non_nullable
as int,completedAyahs: null == completedAyahs ? _self.completedAyahs : completedAyahs // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
