// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ayah_of_the_day.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AyahOfTheDay {

 int get ayahNumber; String get arabicText; String get translationText; String get surahName; int get surahNumber; String get audioUrl;
/// Create a copy of AyahOfTheDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AyahOfTheDayCopyWith<AyahOfTheDay> get copyWith => _$AyahOfTheDayCopyWithImpl<AyahOfTheDay>(this as AyahOfTheDay, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AyahOfTheDay&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber)&&(identical(other.arabicText, arabicText) || other.arabicText == arabicText)&&(identical(other.translationText, translationText) || other.translationText == translationText)&&(identical(other.surahName, surahName) || other.surahName == surahName)&&(identical(other.surahNumber, surahNumber) || other.surahNumber == surahNumber)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl));
}


@override
int get hashCode => Object.hash(runtimeType,ayahNumber,arabicText,translationText,surahName,surahNumber,audioUrl);

@override
String toString() {
  return 'AyahOfTheDay(ayahNumber: $ayahNumber, arabicText: $arabicText, translationText: $translationText, surahName: $surahName, surahNumber: $surahNumber, audioUrl: $audioUrl)';
}


}

/// @nodoc
abstract mixin class $AyahOfTheDayCopyWith<$Res>  {
  factory $AyahOfTheDayCopyWith(AyahOfTheDay value, $Res Function(AyahOfTheDay) _then) = _$AyahOfTheDayCopyWithImpl;
@useResult
$Res call({
 int ayahNumber, String arabicText, String translationText, String surahName, int surahNumber, String audioUrl
});




}
/// @nodoc
class _$AyahOfTheDayCopyWithImpl<$Res>
    implements $AyahOfTheDayCopyWith<$Res> {
  _$AyahOfTheDayCopyWithImpl(this._self, this._then);

  final AyahOfTheDay _self;
  final $Res Function(AyahOfTheDay) _then;

/// Create a copy of AyahOfTheDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ayahNumber = null,Object? arabicText = null,Object? translationText = null,Object? surahName = null,Object? surahNumber = null,Object? audioUrl = null,}) {
  return _then(_self.copyWith(
ayahNumber: null == ayahNumber ? _self.ayahNumber : ayahNumber // ignore: cast_nullable_to_non_nullable
as int,arabicText: null == arabicText ? _self.arabicText : arabicText // ignore: cast_nullable_to_non_nullable
as String,translationText: null == translationText ? _self.translationText : translationText // ignore: cast_nullable_to_non_nullable
as String,surahName: null == surahName ? _self.surahName : surahName // ignore: cast_nullable_to_non_nullable
as String,surahNumber: null == surahNumber ? _self.surahNumber : surahNumber // ignore: cast_nullable_to_non_nullable
as int,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AyahOfTheDay].
extension AyahOfTheDayPatterns on AyahOfTheDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AyahOfTheDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AyahOfTheDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AyahOfTheDay value)  $default,){
final _that = this;
switch (_that) {
case _AyahOfTheDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AyahOfTheDay value)?  $default,){
final _that = this;
switch (_that) {
case _AyahOfTheDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int ayahNumber,  String arabicText,  String translationText,  String surahName,  int surahNumber,  String audioUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AyahOfTheDay() when $default != null:
return $default(_that.ayahNumber,_that.arabicText,_that.translationText,_that.surahName,_that.surahNumber,_that.audioUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int ayahNumber,  String arabicText,  String translationText,  String surahName,  int surahNumber,  String audioUrl)  $default,) {final _that = this;
switch (_that) {
case _AyahOfTheDay():
return $default(_that.ayahNumber,_that.arabicText,_that.translationText,_that.surahName,_that.surahNumber,_that.audioUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int ayahNumber,  String arabicText,  String translationText,  String surahName,  int surahNumber,  String audioUrl)?  $default,) {final _that = this;
switch (_that) {
case _AyahOfTheDay() when $default != null:
return $default(_that.ayahNumber,_that.arabicText,_that.translationText,_that.surahName,_that.surahNumber,_that.audioUrl);case _:
  return null;

}
}

}

/// @nodoc


class _AyahOfTheDay implements AyahOfTheDay {
  const _AyahOfTheDay({required this.ayahNumber, required this.arabicText, required this.translationText, required this.surahName, required this.surahNumber, required this.audioUrl});
  

@override final  int ayahNumber;
@override final  String arabicText;
@override final  String translationText;
@override final  String surahName;
@override final  int surahNumber;
@override final  String audioUrl;

/// Create a copy of AyahOfTheDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AyahOfTheDayCopyWith<_AyahOfTheDay> get copyWith => __$AyahOfTheDayCopyWithImpl<_AyahOfTheDay>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AyahOfTheDay&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber)&&(identical(other.arabicText, arabicText) || other.arabicText == arabicText)&&(identical(other.translationText, translationText) || other.translationText == translationText)&&(identical(other.surahName, surahName) || other.surahName == surahName)&&(identical(other.surahNumber, surahNumber) || other.surahNumber == surahNumber)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl));
}


@override
int get hashCode => Object.hash(runtimeType,ayahNumber,arabicText,translationText,surahName,surahNumber,audioUrl);

@override
String toString() {
  return 'AyahOfTheDay(ayahNumber: $ayahNumber, arabicText: $arabicText, translationText: $translationText, surahName: $surahName, surahNumber: $surahNumber, audioUrl: $audioUrl)';
}


}

/// @nodoc
abstract mixin class _$AyahOfTheDayCopyWith<$Res> implements $AyahOfTheDayCopyWith<$Res> {
  factory _$AyahOfTheDayCopyWith(_AyahOfTheDay value, $Res Function(_AyahOfTheDay) _then) = __$AyahOfTheDayCopyWithImpl;
@override @useResult
$Res call({
 int ayahNumber, String arabicText, String translationText, String surahName, int surahNumber, String audioUrl
});




}
/// @nodoc
class __$AyahOfTheDayCopyWithImpl<$Res>
    implements _$AyahOfTheDayCopyWith<$Res> {
  __$AyahOfTheDayCopyWithImpl(this._self, this._then);

  final _AyahOfTheDay _self;
  final $Res Function(_AyahOfTheDay) _then;

/// Create a copy of AyahOfTheDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ayahNumber = null,Object? arabicText = null,Object? translationText = null,Object? surahName = null,Object? surahNumber = null,Object? audioUrl = null,}) {
  return _then(_AyahOfTheDay(
ayahNumber: null == ayahNumber ? _self.ayahNumber : ayahNumber // ignore: cast_nullable_to_non_nullable
as int,arabicText: null == arabicText ? _self.arabicText : arabicText // ignore: cast_nullable_to_non_nullable
as String,translationText: null == translationText ? _self.translationText : translationText // ignore: cast_nullable_to_non_nullable
as String,surahName: null == surahName ? _self.surahName : surahName // ignore: cast_nullable_to_non_nullable
as String,surahNumber: null == surahNumber ? _self.surahNumber : surahNumber // ignore: cast_nullable_to_non_nullable
as int,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
