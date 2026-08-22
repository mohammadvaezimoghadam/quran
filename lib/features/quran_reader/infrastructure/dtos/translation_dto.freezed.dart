// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'translation_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TranslationDto {

 int get id;@JsonKey(name: 'translation_id') String get translationId;@JsonKey(name: 'ayah_id') int get ayahId;@JsonKey(name: 'number_in_surah') int get ayahNumber; String get text;
/// Create a copy of TranslationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslationDtoCopyWith<TranslationDto> get copyWith => _$TranslationDtoCopyWithImpl<TranslationDto>(this as TranslationDto, _$identity);

  /// Serializes this TranslationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.translationId, translationId) || other.translationId == translationId)&&(identical(other.ayahId, ayahId) || other.ayahId == ayahId)&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,translationId,ayahId,ayahNumber,text);

@override
String toString() {
  return 'TranslationDto(id: $id, translationId: $translationId, ayahId: $ayahId, ayahNumber: $ayahNumber, text: $text)';
}


}

/// @nodoc
abstract mixin class $TranslationDtoCopyWith<$Res>  {
  factory $TranslationDtoCopyWith(TranslationDto value, $Res Function(TranslationDto) _then) = _$TranslationDtoCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'translation_id') String translationId,@JsonKey(name: 'ayah_id') int ayahId,@JsonKey(name: 'number_in_surah') int ayahNumber, String text
});




}
/// @nodoc
class _$TranslationDtoCopyWithImpl<$Res>
    implements $TranslationDtoCopyWith<$Res> {
  _$TranslationDtoCopyWithImpl(this._self, this._then);

  final TranslationDto _self;
  final $Res Function(TranslationDto) _then;

/// Create a copy of TranslationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? translationId = null,Object? ayahId = null,Object? ayahNumber = null,Object? text = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,translationId: null == translationId ? _self.translationId : translationId // ignore: cast_nullable_to_non_nullable
as String,ayahId: null == ayahId ? _self.ayahId : ayahId // ignore: cast_nullable_to_non_nullable
as int,ayahNumber: null == ayahNumber ? _self.ayahNumber : ayahNumber // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TranslationDto].
extension TranslationDtoPatterns on TranslationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranslationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranslationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranslationDto value)  $default,){
final _that = this;
switch (_that) {
case _TranslationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranslationDto value)?  $default,){
final _that = this;
switch (_that) {
case _TranslationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'translation_id')  String translationId, @JsonKey(name: 'ayah_id')  int ayahId, @JsonKey(name: 'number_in_surah')  int ayahNumber,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslationDto() when $default != null:
return $default(_that.id,_that.translationId,_that.ayahId,_that.ayahNumber,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'translation_id')  String translationId, @JsonKey(name: 'ayah_id')  int ayahId, @JsonKey(name: 'number_in_surah')  int ayahNumber,  String text)  $default,) {final _that = this;
switch (_that) {
case _TranslationDto():
return $default(_that.id,_that.translationId,_that.ayahId,_that.ayahNumber,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'translation_id')  String translationId, @JsonKey(name: 'ayah_id')  int ayahId, @JsonKey(name: 'number_in_surah')  int ayahNumber,  String text)?  $default,) {final _that = this;
switch (_that) {
case _TranslationDto() when $default != null:
return $default(_that.id,_that.translationId,_that.ayahId,_that.ayahNumber,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranslationDto extends TranslationDto {
  const _TranslationDto({required this.id, @JsonKey(name: 'translation_id') required this.translationId, @JsonKey(name: 'ayah_id') required this.ayahId, @JsonKey(name: 'number_in_surah') required this.ayahNumber, required this.text}): super._();
  factory _TranslationDto.fromJson(Map<String, dynamic> json) => _$TranslationDtoFromJson(json);

@override final  int id;
@override@JsonKey(name: 'translation_id') final  String translationId;
@override@JsonKey(name: 'ayah_id') final  int ayahId;
@override@JsonKey(name: 'number_in_surah') final  int ayahNumber;
@override final  String text;

/// Create a copy of TranslationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslationDtoCopyWith<_TranslationDto> get copyWith => __$TranslationDtoCopyWithImpl<_TranslationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranslationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.translationId, translationId) || other.translationId == translationId)&&(identical(other.ayahId, ayahId) || other.ayahId == ayahId)&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,translationId,ayahId,ayahNumber,text);

@override
String toString() {
  return 'TranslationDto(id: $id, translationId: $translationId, ayahId: $ayahId, ayahNumber: $ayahNumber, text: $text)';
}


}

/// @nodoc
abstract mixin class _$TranslationDtoCopyWith<$Res> implements $TranslationDtoCopyWith<$Res> {
  factory _$TranslationDtoCopyWith(_TranslationDto value, $Res Function(_TranslationDto) _then) = __$TranslationDtoCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'translation_id') String translationId,@JsonKey(name: 'ayah_id') int ayahId,@JsonKey(name: 'number_in_surah') int ayahNumber, String text
});




}
/// @nodoc
class __$TranslationDtoCopyWithImpl<$Res>
    implements _$TranslationDtoCopyWith<$Res> {
  __$TranslationDtoCopyWithImpl(this._self, this._then);

  final _TranslationDto _self;
  final $Res Function(_TranslationDto) _then;

/// Create a copy of TranslationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? translationId = null,Object? ayahId = null,Object? ayahNumber = null,Object? text = null,}) {
  return _then(_TranslationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,translationId: null == translationId ? _self.translationId : translationId // ignore: cast_nullable_to_non_nullable
as String,ayahId: null == ayahId ? _self.ayahId : ayahId // ignore: cast_nullable_to_non_nullable
as int,ayahNumber: null == ayahNumber ? _self.ayahNumber : ayahNumber // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
