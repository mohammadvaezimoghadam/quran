// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ayah_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AyahEntity {

 int get id; int get surahId; int get ayahNumber; String get arabicText; String? get translationText; int? get page; int? get juz; int? get hizbQuarter;
/// Create a copy of AyahEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AyahEntityCopyWith<AyahEntity> get copyWith => _$AyahEntityCopyWithImpl<AyahEntity>(this as AyahEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AyahEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.surahId, surahId) || other.surahId == surahId)&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber)&&(identical(other.arabicText, arabicText) || other.arabicText == arabicText)&&(identical(other.translationText, translationText) || other.translationText == translationText)&&(identical(other.page, page) || other.page == page)&&(identical(other.juz, juz) || other.juz == juz)&&(identical(other.hizbQuarter, hizbQuarter) || other.hizbQuarter == hizbQuarter));
}


@override
int get hashCode => Object.hash(runtimeType,id,surahId,ayahNumber,arabicText,translationText,page,juz,hizbQuarter);

@override
String toString() {
  return 'AyahEntity(id: $id, surahId: $surahId, ayahNumber: $ayahNumber, arabicText: $arabicText, translationText: $translationText, page: $page, juz: $juz, hizbQuarter: $hizbQuarter)';
}


}

/// @nodoc
abstract mixin class $AyahEntityCopyWith<$Res>  {
  factory $AyahEntityCopyWith(AyahEntity value, $Res Function(AyahEntity) _then) = _$AyahEntityCopyWithImpl;
@useResult
$Res call({
 int id, int surahId, int ayahNumber, String arabicText, String? translationText, int? page, int? juz, int? hizbQuarter
});




}
/// @nodoc
class _$AyahEntityCopyWithImpl<$Res>
    implements $AyahEntityCopyWith<$Res> {
  _$AyahEntityCopyWithImpl(this._self, this._then);

  final AyahEntity _self;
  final $Res Function(AyahEntity) _then;

/// Create a copy of AyahEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? surahId = null,Object? ayahNumber = null,Object? arabicText = null,Object? translationText = freezed,Object? page = freezed,Object? juz = freezed,Object? hizbQuarter = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,surahId: null == surahId ? _self.surahId : surahId // ignore: cast_nullable_to_non_nullable
as int,ayahNumber: null == ayahNumber ? _self.ayahNumber : ayahNumber // ignore: cast_nullable_to_non_nullable
as int,arabicText: null == arabicText ? _self.arabicText : arabicText // ignore: cast_nullable_to_non_nullable
as String,translationText: freezed == translationText ? _self.translationText : translationText // ignore: cast_nullable_to_non_nullable
as String?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,juz: freezed == juz ? _self.juz : juz // ignore: cast_nullable_to_non_nullable
as int?,hizbQuarter: freezed == hizbQuarter ? _self.hizbQuarter : hizbQuarter // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AyahEntity].
extension AyahEntityPatterns on AyahEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AyahEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AyahEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AyahEntity value)  $default,){
final _that = this;
switch (_that) {
case _AyahEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AyahEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AyahEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int surahId,  int ayahNumber,  String arabicText,  String? translationText,  int? page,  int? juz,  int? hizbQuarter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AyahEntity() when $default != null:
return $default(_that.id,_that.surahId,_that.ayahNumber,_that.arabicText,_that.translationText,_that.page,_that.juz,_that.hizbQuarter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int surahId,  int ayahNumber,  String arabicText,  String? translationText,  int? page,  int? juz,  int? hizbQuarter)  $default,) {final _that = this;
switch (_that) {
case _AyahEntity():
return $default(_that.id,_that.surahId,_that.ayahNumber,_that.arabicText,_that.translationText,_that.page,_that.juz,_that.hizbQuarter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int surahId,  int ayahNumber,  String arabicText,  String? translationText,  int? page,  int? juz,  int? hizbQuarter)?  $default,) {final _that = this;
switch (_that) {
case _AyahEntity() when $default != null:
return $default(_that.id,_that.surahId,_that.ayahNumber,_that.arabicText,_that.translationText,_that.page,_that.juz,_that.hizbQuarter);case _:
  return null;

}
}

}

/// @nodoc


class _AyahEntity extends AyahEntity {
  const _AyahEntity({required this.id, required this.surahId, required this.ayahNumber, required this.arabicText, this.translationText, this.page, this.juz, this.hizbQuarter}): super._();
  

@override final  int id;
@override final  int surahId;
@override final  int ayahNumber;
@override final  String arabicText;
@override final  String? translationText;
@override final  int? page;
@override final  int? juz;
@override final  int? hizbQuarter;

/// Create a copy of AyahEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AyahEntityCopyWith<_AyahEntity> get copyWith => __$AyahEntityCopyWithImpl<_AyahEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AyahEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.surahId, surahId) || other.surahId == surahId)&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber)&&(identical(other.arabicText, arabicText) || other.arabicText == arabicText)&&(identical(other.translationText, translationText) || other.translationText == translationText)&&(identical(other.page, page) || other.page == page)&&(identical(other.juz, juz) || other.juz == juz)&&(identical(other.hizbQuarter, hizbQuarter) || other.hizbQuarter == hizbQuarter));
}


@override
int get hashCode => Object.hash(runtimeType,id,surahId,ayahNumber,arabicText,translationText,page,juz,hizbQuarter);

@override
String toString() {
  return 'AyahEntity(id: $id, surahId: $surahId, ayahNumber: $ayahNumber, arabicText: $arabicText, translationText: $translationText, page: $page, juz: $juz, hizbQuarter: $hizbQuarter)';
}


}

/// @nodoc
abstract mixin class _$AyahEntityCopyWith<$Res> implements $AyahEntityCopyWith<$Res> {
  factory _$AyahEntityCopyWith(_AyahEntity value, $Res Function(_AyahEntity) _then) = __$AyahEntityCopyWithImpl;
@override @useResult
$Res call({
 int id, int surahId, int ayahNumber, String arabicText, String? translationText, int? page, int? juz, int? hizbQuarter
});




}
/// @nodoc
class __$AyahEntityCopyWithImpl<$Res>
    implements _$AyahEntityCopyWith<$Res> {
  __$AyahEntityCopyWithImpl(this._self, this._then);

  final _AyahEntity _self;
  final $Res Function(_AyahEntity) _then;

/// Create a copy of AyahEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? surahId = null,Object? ayahNumber = null,Object? arabicText = null,Object? translationText = freezed,Object? page = freezed,Object? juz = freezed,Object? hizbQuarter = freezed,}) {
  return _then(_AyahEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,surahId: null == surahId ? _self.surahId : surahId // ignore: cast_nullable_to_non_nullable
as int,ayahNumber: null == ayahNumber ? _self.ayahNumber : ayahNumber // ignore: cast_nullable_to_non_nullable
as int,arabicText: null == arabicText ? _self.arabicText : arabicText // ignore: cast_nullable_to_non_nullable
as String,translationText: freezed == translationText ? _self.translationText : translationText // ignore: cast_nullable_to_non_nullable
as String?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,juz: freezed == juz ? _self.juz : juz // ignore: cast_nullable_to_non_nullable
as int?,hizbQuarter: freezed == hizbQuarter ? _self.hizbQuarter : hizbQuarter // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
