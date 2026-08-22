// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'surah_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SurahEntity {

 int get number; String get name; String get englishName; String get englishNameTranslation; int get numberOfAyahs; String get revelationType; int get startPage; int get startJuz;
/// Create a copy of SurahEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SurahEntityCopyWith<SurahEntity> get copyWith => _$SurahEntityCopyWithImpl<SurahEntity>(this as SurahEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SurahEntity&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&(identical(other.englishName, englishName) || other.englishName == englishName)&&(identical(other.englishNameTranslation, englishNameTranslation) || other.englishNameTranslation == englishNameTranslation)&&(identical(other.numberOfAyahs, numberOfAyahs) || other.numberOfAyahs == numberOfAyahs)&&(identical(other.revelationType, revelationType) || other.revelationType == revelationType)&&(identical(other.startPage, startPage) || other.startPage == startPage)&&(identical(other.startJuz, startJuz) || other.startJuz == startJuz));
}


@override
int get hashCode => Object.hash(runtimeType,number,name,englishName,englishNameTranslation,numberOfAyahs,revelationType,startPage,startJuz);

@override
String toString() {
  return 'SurahEntity(number: $number, name: $name, englishName: $englishName, englishNameTranslation: $englishNameTranslation, numberOfAyahs: $numberOfAyahs, revelationType: $revelationType, startPage: $startPage, startJuz: $startJuz)';
}


}

/// @nodoc
abstract mixin class $SurahEntityCopyWith<$Res>  {
  factory $SurahEntityCopyWith(SurahEntity value, $Res Function(SurahEntity) _then) = _$SurahEntityCopyWithImpl;
@useResult
$Res call({
 int number, String name, String englishName, String englishNameTranslation, int numberOfAyahs, String revelationType, int startPage, int startJuz
});




}
/// @nodoc
class _$SurahEntityCopyWithImpl<$Res>
    implements $SurahEntityCopyWith<$Res> {
  _$SurahEntityCopyWithImpl(this._self, this._then);

  final SurahEntity _self;
  final $Res Function(SurahEntity) _then;

/// Create a copy of SurahEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? name = null,Object? englishName = null,Object? englishNameTranslation = null,Object? numberOfAyahs = null,Object? revelationType = null,Object? startPage = null,Object? startJuz = null,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,englishName: null == englishName ? _self.englishName : englishName // ignore: cast_nullable_to_non_nullable
as String,englishNameTranslation: null == englishNameTranslation ? _self.englishNameTranslation : englishNameTranslation // ignore: cast_nullable_to_non_nullable
as String,numberOfAyahs: null == numberOfAyahs ? _self.numberOfAyahs : numberOfAyahs // ignore: cast_nullable_to_non_nullable
as int,revelationType: null == revelationType ? _self.revelationType : revelationType // ignore: cast_nullable_to_non_nullable
as String,startPage: null == startPage ? _self.startPage : startPage // ignore: cast_nullable_to_non_nullable
as int,startJuz: null == startJuz ? _self.startJuz : startJuz // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SurahEntity].
extension SurahEntityPatterns on SurahEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SurahEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SurahEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SurahEntity value)  $default,){
final _that = this;
switch (_that) {
case _SurahEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SurahEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SurahEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int number,  String name,  String englishName,  String englishNameTranslation,  int numberOfAyahs,  String revelationType,  int startPage,  int startJuz)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SurahEntity() when $default != null:
return $default(_that.number,_that.name,_that.englishName,_that.englishNameTranslation,_that.numberOfAyahs,_that.revelationType,_that.startPage,_that.startJuz);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int number,  String name,  String englishName,  String englishNameTranslation,  int numberOfAyahs,  String revelationType,  int startPage,  int startJuz)  $default,) {final _that = this;
switch (_that) {
case _SurahEntity():
return $default(_that.number,_that.name,_that.englishName,_that.englishNameTranslation,_that.numberOfAyahs,_that.revelationType,_that.startPage,_that.startJuz);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int number,  String name,  String englishName,  String englishNameTranslation,  int numberOfAyahs,  String revelationType,  int startPage,  int startJuz)?  $default,) {final _that = this;
switch (_that) {
case _SurahEntity() when $default != null:
return $default(_that.number,_that.name,_that.englishName,_that.englishNameTranslation,_that.numberOfAyahs,_that.revelationType,_that.startPage,_that.startJuz);case _:
  return null;

}
}

}

/// @nodoc


class _SurahEntity implements SurahEntity {
  const _SurahEntity({required this.number, required this.name, required this.englishName, required this.englishNameTranslation, required this.numberOfAyahs, required this.revelationType, required this.startPage, required this.startJuz});
  

@override final  int number;
@override final  String name;
@override final  String englishName;
@override final  String englishNameTranslation;
@override final  int numberOfAyahs;
@override final  String revelationType;
@override final  int startPage;
@override final  int startJuz;

/// Create a copy of SurahEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SurahEntityCopyWith<_SurahEntity> get copyWith => __$SurahEntityCopyWithImpl<_SurahEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SurahEntity&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&(identical(other.englishName, englishName) || other.englishName == englishName)&&(identical(other.englishNameTranslation, englishNameTranslation) || other.englishNameTranslation == englishNameTranslation)&&(identical(other.numberOfAyahs, numberOfAyahs) || other.numberOfAyahs == numberOfAyahs)&&(identical(other.revelationType, revelationType) || other.revelationType == revelationType)&&(identical(other.startPage, startPage) || other.startPage == startPage)&&(identical(other.startJuz, startJuz) || other.startJuz == startJuz));
}


@override
int get hashCode => Object.hash(runtimeType,number,name,englishName,englishNameTranslation,numberOfAyahs,revelationType,startPage,startJuz);

@override
String toString() {
  return 'SurahEntity(number: $number, name: $name, englishName: $englishName, englishNameTranslation: $englishNameTranslation, numberOfAyahs: $numberOfAyahs, revelationType: $revelationType, startPage: $startPage, startJuz: $startJuz)';
}


}

/// @nodoc
abstract mixin class _$SurahEntityCopyWith<$Res> implements $SurahEntityCopyWith<$Res> {
  factory _$SurahEntityCopyWith(_SurahEntity value, $Res Function(_SurahEntity) _then) = __$SurahEntityCopyWithImpl;
@override @useResult
$Res call({
 int number, String name, String englishName, String englishNameTranslation, int numberOfAyahs, String revelationType, int startPage, int startJuz
});




}
/// @nodoc
class __$SurahEntityCopyWithImpl<$Res>
    implements _$SurahEntityCopyWith<$Res> {
  __$SurahEntityCopyWithImpl(this._self, this._then);

  final _SurahEntity _self;
  final $Res Function(_SurahEntity) _then;

/// Create a copy of SurahEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? name = null,Object? englishName = null,Object? englishNameTranslation = null,Object? numberOfAyahs = null,Object? revelationType = null,Object? startPage = null,Object? startJuz = null,}) {
  return _then(_SurahEntity(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,englishName: null == englishName ? _self.englishName : englishName // ignore: cast_nullable_to_non_nullable
as String,englishNameTranslation: null == englishNameTranslation ? _self.englishNameTranslation : englishNameTranslation // ignore: cast_nullable_to_non_nullable
as String,numberOfAyahs: null == numberOfAyahs ? _self.numberOfAyahs : numberOfAyahs // ignore: cast_nullable_to_non_nullable
as int,revelationType: null == revelationType ? _self.revelationType : revelationType // ignore: cast_nullable_to_non_nullable
as String,startPage: null == startPage ? _self.startPage : startPage // ignore: cast_nullable_to_non_nullable
as int,startJuz: null == startJuz ? _self.startJuz : startJuz // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
