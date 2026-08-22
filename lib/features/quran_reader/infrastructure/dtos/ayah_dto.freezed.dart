// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ayah_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AyahDto {

 int get id;@JsonKey(name: 'surah_id') int get surahId;@JsonKey(name: 'ayah_number') int get ayahNumber;@JsonKey(name: 'text') String get arabicText;@JsonKey(name: 'translation') String? get translationText; int? get page; int? get juz;@JsonKey(name: 'hizb_quarter') int? get hizbQuarter;
/// Create a copy of AyahDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AyahDtoCopyWith<AyahDto> get copyWith => _$AyahDtoCopyWithImpl<AyahDto>(this as AyahDto, _$identity);

  /// Serializes this AyahDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AyahDto&&(identical(other.id, id) || other.id == id)&&(identical(other.surahId, surahId) || other.surahId == surahId)&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber)&&(identical(other.arabicText, arabicText) || other.arabicText == arabicText)&&(identical(other.translationText, translationText) || other.translationText == translationText)&&(identical(other.page, page) || other.page == page)&&(identical(other.juz, juz) || other.juz == juz)&&(identical(other.hizbQuarter, hizbQuarter) || other.hizbQuarter == hizbQuarter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,surahId,ayahNumber,arabicText,translationText,page,juz,hizbQuarter);

@override
String toString() {
  return 'AyahDto(id: $id, surahId: $surahId, ayahNumber: $ayahNumber, arabicText: $arabicText, translationText: $translationText, page: $page, juz: $juz, hizbQuarter: $hizbQuarter)';
}


}

/// @nodoc
abstract mixin class $AyahDtoCopyWith<$Res>  {
  factory $AyahDtoCopyWith(AyahDto value, $Res Function(AyahDto) _then) = _$AyahDtoCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'surah_id') int surahId,@JsonKey(name: 'ayah_number') int ayahNumber,@JsonKey(name: 'text') String arabicText,@JsonKey(name: 'translation') String? translationText, int? page, int? juz,@JsonKey(name: 'hizb_quarter') int? hizbQuarter
});




}
/// @nodoc
class _$AyahDtoCopyWithImpl<$Res>
    implements $AyahDtoCopyWith<$Res> {
  _$AyahDtoCopyWithImpl(this._self, this._then);

  final AyahDto _self;
  final $Res Function(AyahDto) _then;

/// Create a copy of AyahDto
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


/// Adds pattern-matching-related methods to [AyahDto].
extension AyahDtoPatterns on AyahDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AyahDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AyahDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AyahDto value)  $default,){
final _that = this;
switch (_that) {
case _AyahDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AyahDto value)?  $default,){
final _that = this;
switch (_that) {
case _AyahDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'surah_id')  int surahId, @JsonKey(name: 'ayah_number')  int ayahNumber, @JsonKey(name: 'text')  String arabicText, @JsonKey(name: 'translation')  String? translationText,  int? page,  int? juz, @JsonKey(name: 'hizb_quarter')  int? hizbQuarter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AyahDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'surah_id')  int surahId, @JsonKey(name: 'ayah_number')  int ayahNumber, @JsonKey(name: 'text')  String arabicText, @JsonKey(name: 'translation')  String? translationText,  int? page,  int? juz, @JsonKey(name: 'hizb_quarter')  int? hizbQuarter)  $default,) {final _that = this;
switch (_that) {
case _AyahDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'surah_id')  int surahId, @JsonKey(name: 'ayah_number')  int ayahNumber, @JsonKey(name: 'text')  String arabicText, @JsonKey(name: 'translation')  String? translationText,  int? page,  int? juz, @JsonKey(name: 'hizb_quarter')  int? hizbQuarter)?  $default,) {final _that = this;
switch (_that) {
case _AyahDto() when $default != null:
return $default(_that.id,_that.surahId,_that.ayahNumber,_that.arabicText,_that.translationText,_that.page,_that.juz,_that.hizbQuarter);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AyahDto extends AyahDto {
  const _AyahDto({required this.id, @JsonKey(name: 'surah_id') required this.surahId, @JsonKey(name: 'ayah_number') required this.ayahNumber, @JsonKey(name: 'text') required this.arabicText, @JsonKey(name: 'translation') this.translationText, this.page, this.juz, @JsonKey(name: 'hizb_quarter') this.hizbQuarter}): super._();
  factory _AyahDto.fromJson(Map<String, dynamic> json) => _$AyahDtoFromJson(json);

@override final  int id;
@override@JsonKey(name: 'surah_id') final  int surahId;
@override@JsonKey(name: 'ayah_number') final  int ayahNumber;
@override@JsonKey(name: 'text') final  String arabicText;
@override@JsonKey(name: 'translation') final  String? translationText;
@override final  int? page;
@override final  int? juz;
@override@JsonKey(name: 'hizb_quarter') final  int? hizbQuarter;

/// Create a copy of AyahDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AyahDtoCopyWith<_AyahDto> get copyWith => __$AyahDtoCopyWithImpl<_AyahDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AyahDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AyahDto&&(identical(other.id, id) || other.id == id)&&(identical(other.surahId, surahId) || other.surahId == surahId)&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber)&&(identical(other.arabicText, arabicText) || other.arabicText == arabicText)&&(identical(other.translationText, translationText) || other.translationText == translationText)&&(identical(other.page, page) || other.page == page)&&(identical(other.juz, juz) || other.juz == juz)&&(identical(other.hizbQuarter, hizbQuarter) || other.hizbQuarter == hizbQuarter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,surahId,ayahNumber,arabicText,translationText,page,juz,hizbQuarter);

@override
String toString() {
  return 'AyahDto(id: $id, surahId: $surahId, ayahNumber: $ayahNumber, arabicText: $arabicText, translationText: $translationText, page: $page, juz: $juz, hizbQuarter: $hizbQuarter)';
}


}

/// @nodoc
abstract mixin class _$AyahDtoCopyWith<$Res> implements $AyahDtoCopyWith<$Res> {
  factory _$AyahDtoCopyWith(_AyahDto value, $Res Function(_AyahDto) _then) = __$AyahDtoCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'surah_id') int surahId,@JsonKey(name: 'ayah_number') int ayahNumber,@JsonKey(name: 'text') String arabicText,@JsonKey(name: 'translation') String? translationText, int? page, int? juz,@JsonKey(name: 'hizb_quarter') int? hizbQuarter
});




}
/// @nodoc
class __$AyahDtoCopyWithImpl<$Res>
    implements _$AyahDtoCopyWith<$Res> {
  __$AyahDtoCopyWithImpl(this._self, this._then);

  final _AyahDto _self;
  final $Res Function(_AyahDto) _then;

/// Create a copy of AyahDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? surahId = null,Object? ayahNumber = null,Object? arabicText = null,Object? translationText = freezed,Object? page = freezed,Object? juz = freezed,Object? hizbQuarter = freezed,}) {
  return _then(_AyahDto(
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
