// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WordDto {

 int get id;@JsonKey(name: 'surah_id') int get surahId;@JsonKey(name: 'ayah_number') int get ayahNumber;@JsonKey(name: 'word_position') int get position;@JsonKey(name: 'arabic_text') String get arabicText;@JsonKey(name: 'translation_fa') String get translation;
/// Create a copy of WordDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordDtoCopyWith<WordDto> get copyWith => _$WordDtoCopyWithImpl<WordDto>(this as WordDto, _$identity);

  /// Serializes this WordDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordDto&&(identical(other.id, id) || other.id == id)&&(identical(other.surahId, surahId) || other.surahId == surahId)&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber)&&(identical(other.position, position) || other.position == position)&&(identical(other.arabicText, arabicText) || other.arabicText == arabicText)&&(identical(other.translation, translation) || other.translation == translation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,surahId,ayahNumber,position,arabicText,translation);

@override
String toString() {
  return 'WordDto(id: $id, surahId: $surahId, ayahNumber: $ayahNumber, position: $position, arabicText: $arabicText, translation: $translation)';
}


}

/// @nodoc
abstract mixin class $WordDtoCopyWith<$Res>  {
  factory $WordDtoCopyWith(WordDto value, $Res Function(WordDto) _then) = _$WordDtoCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'surah_id') int surahId,@JsonKey(name: 'ayah_number') int ayahNumber,@JsonKey(name: 'word_position') int position,@JsonKey(name: 'arabic_text') String arabicText,@JsonKey(name: 'translation_fa') String translation
});




}
/// @nodoc
class _$WordDtoCopyWithImpl<$Res>
    implements $WordDtoCopyWith<$Res> {
  _$WordDtoCopyWithImpl(this._self, this._then);

  final WordDto _self;
  final $Res Function(WordDto) _then;

/// Create a copy of WordDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? surahId = null,Object? ayahNumber = null,Object? position = null,Object? arabicText = null,Object? translation = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,surahId: null == surahId ? _self.surahId : surahId // ignore: cast_nullable_to_non_nullable
as int,ayahNumber: null == ayahNumber ? _self.ayahNumber : ayahNumber // ignore: cast_nullable_to_non_nullable
as int,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,arabicText: null == arabicText ? _self.arabicText : arabicText // ignore: cast_nullable_to_non_nullable
as String,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WordDto].
extension WordDtoPatterns on WordDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordDto value)  $default,){
final _that = this;
switch (_that) {
case _WordDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordDto value)?  $default,){
final _that = this;
switch (_that) {
case _WordDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'surah_id')  int surahId, @JsonKey(name: 'ayah_number')  int ayahNumber, @JsonKey(name: 'word_position')  int position, @JsonKey(name: 'arabic_text')  String arabicText, @JsonKey(name: 'translation_fa')  String translation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordDto() when $default != null:
return $default(_that.id,_that.surahId,_that.ayahNumber,_that.position,_that.arabicText,_that.translation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'surah_id')  int surahId, @JsonKey(name: 'ayah_number')  int ayahNumber, @JsonKey(name: 'word_position')  int position, @JsonKey(name: 'arabic_text')  String arabicText, @JsonKey(name: 'translation_fa')  String translation)  $default,) {final _that = this;
switch (_that) {
case _WordDto():
return $default(_that.id,_that.surahId,_that.ayahNumber,_that.position,_that.arabicText,_that.translation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'surah_id')  int surahId, @JsonKey(name: 'ayah_number')  int ayahNumber, @JsonKey(name: 'word_position')  int position, @JsonKey(name: 'arabic_text')  String arabicText, @JsonKey(name: 'translation_fa')  String translation)?  $default,) {final _that = this;
switch (_that) {
case _WordDto() when $default != null:
return $default(_that.id,_that.surahId,_that.ayahNumber,_that.position,_that.arabicText,_that.translation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WordDto extends WordDto {
  const _WordDto({required this.id, @JsonKey(name: 'surah_id') required this.surahId, @JsonKey(name: 'ayah_number') required this.ayahNumber, @JsonKey(name: 'word_position') required this.position, @JsonKey(name: 'arabic_text') required this.arabicText, @JsonKey(name: 'translation_fa') required this.translation}): super._();
  factory _WordDto.fromJson(Map<String, dynamic> json) => _$WordDtoFromJson(json);

@override final  int id;
@override@JsonKey(name: 'surah_id') final  int surahId;
@override@JsonKey(name: 'ayah_number') final  int ayahNumber;
@override@JsonKey(name: 'word_position') final  int position;
@override@JsonKey(name: 'arabic_text') final  String arabicText;
@override@JsonKey(name: 'translation_fa') final  String translation;

/// Create a copy of WordDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordDtoCopyWith<_WordDto> get copyWith => __$WordDtoCopyWithImpl<_WordDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WordDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordDto&&(identical(other.id, id) || other.id == id)&&(identical(other.surahId, surahId) || other.surahId == surahId)&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber)&&(identical(other.position, position) || other.position == position)&&(identical(other.arabicText, arabicText) || other.arabicText == arabicText)&&(identical(other.translation, translation) || other.translation == translation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,surahId,ayahNumber,position,arabicText,translation);

@override
String toString() {
  return 'WordDto(id: $id, surahId: $surahId, ayahNumber: $ayahNumber, position: $position, arabicText: $arabicText, translation: $translation)';
}


}

/// @nodoc
abstract mixin class _$WordDtoCopyWith<$Res> implements $WordDtoCopyWith<$Res> {
  factory _$WordDtoCopyWith(_WordDto value, $Res Function(_WordDto) _then) = __$WordDtoCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'surah_id') int surahId,@JsonKey(name: 'ayah_number') int ayahNumber,@JsonKey(name: 'word_position') int position,@JsonKey(name: 'arabic_text') String arabicText,@JsonKey(name: 'translation_fa') String translation
});




}
/// @nodoc
class __$WordDtoCopyWithImpl<$Res>
    implements _$WordDtoCopyWith<$Res> {
  __$WordDtoCopyWithImpl(this._self, this._then);

  final _WordDto _self;
  final $Res Function(_WordDto) _then;

/// Create a copy of WordDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? surahId = null,Object? ayahNumber = null,Object? position = null,Object? arabicText = null,Object? translation = null,}) {
  return _then(_WordDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,surahId: null == surahId ? _self.surahId : surahId // ignore: cast_nullable_to_non_nullable
as int,ayahNumber: null == ayahNumber ? _self.ayahNumber : ayahNumber // ignore: cast_nullable_to_non_nullable
as int,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,arabicText: null == arabicText ? _self.arabicText : arabicText // ignore: cast_nullable_to_non_nullable
as String,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
