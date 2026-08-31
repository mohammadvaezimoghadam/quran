// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ayah_target.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AyahTarget {

 int get surahId; int get ayahNumber;
/// Create a copy of AyahTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AyahTargetCopyWith<AyahTarget> get copyWith => _$AyahTargetCopyWithImpl<AyahTarget>(this as AyahTarget, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AyahTarget&&(identical(other.surahId, surahId) || other.surahId == surahId)&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber));
}


@override
int get hashCode => Object.hash(runtimeType,surahId,ayahNumber);

@override
String toString() {
  return 'AyahTarget(surahId: $surahId, ayahNumber: $ayahNumber)';
}


}

/// @nodoc
abstract mixin class $AyahTargetCopyWith<$Res>  {
  factory $AyahTargetCopyWith(AyahTarget value, $Res Function(AyahTarget) _then) = _$AyahTargetCopyWithImpl;
@useResult
$Res call({
 int surahId, int ayahNumber
});




}
/// @nodoc
class _$AyahTargetCopyWithImpl<$Res>
    implements $AyahTargetCopyWith<$Res> {
  _$AyahTargetCopyWithImpl(this._self, this._then);

  final AyahTarget _self;
  final $Res Function(AyahTarget) _then;

/// Create a copy of AyahTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? surahId = null,Object? ayahNumber = null,}) {
  return _then(_self.copyWith(
surahId: null == surahId ? _self.surahId : surahId // ignore: cast_nullable_to_non_nullable
as int,ayahNumber: null == ayahNumber ? _self.ayahNumber : ayahNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AyahTarget].
extension AyahTargetPatterns on AyahTarget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AyahTarget value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AyahTarget() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AyahTarget value)  $default,){
final _that = this;
switch (_that) {
case _AyahTarget():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AyahTarget value)?  $default,){
final _that = this;
switch (_that) {
case _AyahTarget() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int surahId,  int ayahNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AyahTarget() when $default != null:
return $default(_that.surahId,_that.ayahNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int surahId,  int ayahNumber)  $default,) {final _that = this;
switch (_that) {
case _AyahTarget():
return $default(_that.surahId,_that.ayahNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int surahId,  int ayahNumber)?  $default,) {final _that = this;
switch (_that) {
case _AyahTarget() when $default != null:
return $default(_that.surahId,_that.ayahNumber);case _:
  return null;

}
}

}

/// @nodoc


class _AyahTarget implements AyahTarget {
  const _AyahTarget({required this.surahId, required this.ayahNumber});
  

@override final  int surahId;
@override final  int ayahNumber;

/// Create a copy of AyahTarget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AyahTargetCopyWith<_AyahTarget> get copyWith => __$AyahTargetCopyWithImpl<_AyahTarget>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AyahTarget&&(identical(other.surahId, surahId) || other.surahId == surahId)&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber));
}


@override
int get hashCode => Object.hash(runtimeType,surahId,ayahNumber);

@override
String toString() {
  return 'AyahTarget(surahId: $surahId, ayahNumber: $ayahNumber)';
}


}

/// @nodoc
abstract mixin class _$AyahTargetCopyWith<$Res> implements $AyahTargetCopyWith<$Res> {
  factory _$AyahTargetCopyWith(_AyahTarget value, $Res Function(_AyahTarget) _then) = __$AyahTargetCopyWithImpl;
@override @useResult
$Res call({
 int surahId, int ayahNumber
});




}
/// @nodoc
class __$AyahTargetCopyWithImpl<$Res>
    implements _$AyahTargetCopyWith<$Res> {
  __$AyahTargetCopyWithImpl(this._self, this._then);

  final _AyahTarget _self;
  final $Res Function(_AyahTarget) _then;

/// Create a copy of AyahTarget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? surahId = null,Object? ayahNumber = null,}) {
  return _then(_AyahTarget(
surahId: null == surahId ? _self.surahId : surahId // ignore: cast_nullable_to_non_nullable
as int,ayahNumber: null == ayahNumber ? _self.ayahNumber : ayahNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
