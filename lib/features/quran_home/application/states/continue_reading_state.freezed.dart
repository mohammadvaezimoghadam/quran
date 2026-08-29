// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'continue_reading_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContinueReadingState {

 int get surahId; String get surahName; int get ayahNumber; int get totalAyahs;
/// Create a copy of ContinueReadingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContinueReadingStateCopyWith<ContinueReadingState> get copyWith => _$ContinueReadingStateCopyWithImpl<ContinueReadingState>(this as ContinueReadingState, _$identity);

  /// Serializes this ContinueReadingState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContinueReadingState&&(identical(other.surahId, surahId) || other.surahId == surahId)&&(identical(other.surahName, surahName) || other.surahName == surahName)&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber)&&(identical(other.totalAyahs, totalAyahs) || other.totalAyahs == totalAyahs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,surahId,surahName,ayahNumber,totalAyahs);

@override
String toString() {
  return 'ContinueReadingState(surahId: $surahId, surahName: $surahName, ayahNumber: $ayahNumber, totalAyahs: $totalAyahs)';
}


}

/// @nodoc
abstract mixin class $ContinueReadingStateCopyWith<$Res>  {
  factory $ContinueReadingStateCopyWith(ContinueReadingState value, $Res Function(ContinueReadingState) _then) = _$ContinueReadingStateCopyWithImpl;
@useResult
$Res call({
 int surahId, String surahName, int ayahNumber, int totalAyahs
});




}
/// @nodoc
class _$ContinueReadingStateCopyWithImpl<$Res>
    implements $ContinueReadingStateCopyWith<$Res> {
  _$ContinueReadingStateCopyWithImpl(this._self, this._then);

  final ContinueReadingState _self;
  final $Res Function(ContinueReadingState) _then;

/// Create a copy of ContinueReadingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? surahId = null,Object? surahName = null,Object? ayahNumber = null,Object? totalAyahs = null,}) {
  return _then(_self.copyWith(
surahId: null == surahId ? _self.surahId : surahId // ignore: cast_nullable_to_non_nullable
as int,surahName: null == surahName ? _self.surahName : surahName // ignore: cast_nullable_to_non_nullable
as String,ayahNumber: null == ayahNumber ? _self.ayahNumber : ayahNumber // ignore: cast_nullable_to_non_nullable
as int,totalAyahs: null == totalAyahs ? _self.totalAyahs : totalAyahs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ContinueReadingState].
extension ContinueReadingStatePatterns on ContinueReadingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContinueReadingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContinueReadingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContinueReadingState value)  $default,){
final _that = this;
switch (_that) {
case _ContinueReadingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContinueReadingState value)?  $default,){
final _that = this;
switch (_that) {
case _ContinueReadingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int surahId,  String surahName,  int ayahNumber,  int totalAyahs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContinueReadingState() when $default != null:
return $default(_that.surahId,_that.surahName,_that.ayahNumber,_that.totalAyahs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int surahId,  String surahName,  int ayahNumber,  int totalAyahs)  $default,) {final _that = this;
switch (_that) {
case _ContinueReadingState():
return $default(_that.surahId,_that.surahName,_that.ayahNumber,_that.totalAyahs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int surahId,  String surahName,  int ayahNumber,  int totalAyahs)?  $default,) {final _that = this;
switch (_that) {
case _ContinueReadingState() when $default != null:
return $default(_that.surahId,_that.surahName,_that.ayahNumber,_that.totalAyahs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContinueReadingState implements ContinueReadingState {
  const _ContinueReadingState({required this.surahId, required this.surahName, required this.ayahNumber, required this.totalAyahs});
  factory _ContinueReadingState.fromJson(Map<String, dynamic> json) => _$ContinueReadingStateFromJson(json);

@override final  int surahId;
@override final  String surahName;
@override final  int ayahNumber;
@override final  int totalAyahs;

/// Create a copy of ContinueReadingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContinueReadingStateCopyWith<_ContinueReadingState> get copyWith => __$ContinueReadingStateCopyWithImpl<_ContinueReadingState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContinueReadingStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContinueReadingState&&(identical(other.surahId, surahId) || other.surahId == surahId)&&(identical(other.surahName, surahName) || other.surahName == surahName)&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber)&&(identical(other.totalAyahs, totalAyahs) || other.totalAyahs == totalAyahs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,surahId,surahName,ayahNumber,totalAyahs);

@override
String toString() {
  return 'ContinueReadingState(surahId: $surahId, surahName: $surahName, ayahNumber: $ayahNumber, totalAyahs: $totalAyahs)';
}


}

/// @nodoc
abstract mixin class _$ContinueReadingStateCopyWith<$Res> implements $ContinueReadingStateCopyWith<$Res> {
  factory _$ContinueReadingStateCopyWith(_ContinueReadingState value, $Res Function(_ContinueReadingState) _then) = __$ContinueReadingStateCopyWithImpl;
@override @useResult
$Res call({
 int surahId, String surahName, int ayahNumber, int totalAyahs
});




}
/// @nodoc
class __$ContinueReadingStateCopyWithImpl<$Res>
    implements _$ContinueReadingStateCopyWith<$Res> {
  __$ContinueReadingStateCopyWithImpl(this._self, this._then);

  final _ContinueReadingState _self;
  final $Res Function(_ContinueReadingState) _then;

/// Create a copy of ContinueReadingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? surahId = null,Object? surahName = null,Object? ayahNumber = null,Object? totalAyahs = null,}) {
  return _then(_ContinueReadingState(
surahId: null == surahId ? _self.surahId : surahId // ignore: cast_nullable_to_non_nullable
as int,surahName: null == surahName ? _self.surahName : surahName // ignore: cast_nullable_to_non_nullable
as String,ayahNumber: null == ayahNumber ? _self.ayahNumber : ayahNumber // ignore: cast_nullable_to_non_nullable
as int,totalAyahs: null == totalAyahs ? _self.totalAyahs : totalAyahs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
