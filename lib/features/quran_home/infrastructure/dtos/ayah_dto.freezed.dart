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

@JsonKey(name: 'number') int get number;@JsonKey(name: 'text') String get text;@JsonKey(name: 'numberInSurah') int get numberInSurah;@JsonKey(name: 'juz') int get juz;@JsonKey(name: 'audio') String? get audio;@JsonKey(name: 'surah') SurahInfoDto? get surah;
/// Create a copy of AyahDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AyahDtoCopyWith<AyahDto> get copyWith => _$AyahDtoCopyWithImpl<AyahDto>(this as AyahDto, _$identity);

  /// Serializes this AyahDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AyahDto&&(identical(other.number, number) || other.number == number)&&(identical(other.text, text) || other.text == text)&&(identical(other.numberInSurah, numberInSurah) || other.numberInSurah == numberInSurah)&&(identical(other.juz, juz) || other.juz == juz)&&(identical(other.audio, audio) || other.audio == audio)&&(identical(other.surah, surah) || other.surah == surah));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,text,numberInSurah,juz,audio,surah);

@override
String toString() {
  return 'AyahDto(number: $number, text: $text, numberInSurah: $numberInSurah, juz: $juz, audio: $audio, surah: $surah)';
}


}

/// @nodoc
abstract mixin class $AyahDtoCopyWith<$Res>  {
  factory $AyahDtoCopyWith(AyahDto value, $Res Function(AyahDto) _then) = _$AyahDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'number') int number,@JsonKey(name: 'text') String text,@JsonKey(name: 'numberInSurah') int numberInSurah,@JsonKey(name: 'juz') int juz,@JsonKey(name: 'audio') String? audio,@JsonKey(name: 'surah') SurahInfoDto? surah
});


$SurahInfoDtoCopyWith<$Res>? get surah;

}
/// @nodoc
class _$AyahDtoCopyWithImpl<$Res>
    implements $AyahDtoCopyWith<$Res> {
  _$AyahDtoCopyWithImpl(this._self, this._then);

  final AyahDto _self;
  final $Res Function(AyahDto) _then;

/// Create a copy of AyahDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? text = null,Object? numberInSurah = null,Object? juz = null,Object? audio = freezed,Object? surah = freezed,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,numberInSurah: null == numberInSurah ? _self.numberInSurah : numberInSurah // ignore: cast_nullable_to_non_nullable
as int,juz: null == juz ? _self.juz : juz // ignore: cast_nullable_to_non_nullable
as int,audio: freezed == audio ? _self.audio : audio // ignore: cast_nullable_to_non_nullable
as String?,surah: freezed == surah ? _self.surah : surah // ignore: cast_nullable_to_non_nullable
as SurahInfoDto?,
  ));
}
/// Create a copy of AyahDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SurahInfoDtoCopyWith<$Res>? get surah {
    if (_self.surah == null) {
    return null;
  }

  return $SurahInfoDtoCopyWith<$Res>(_self.surah!, (value) {
    return _then(_self.copyWith(surah: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'number')  int number, @JsonKey(name: 'text')  String text, @JsonKey(name: 'numberInSurah')  int numberInSurah, @JsonKey(name: 'juz')  int juz, @JsonKey(name: 'audio')  String? audio, @JsonKey(name: 'surah')  SurahInfoDto? surah)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AyahDto() when $default != null:
return $default(_that.number,_that.text,_that.numberInSurah,_that.juz,_that.audio,_that.surah);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'number')  int number, @JsonKey(name: 'text')  String text, @JsonKey(name: 'numberInSurah')  int numberInSurah, @JsonKey(name: 'juz')  int juz, @JsonKey(name: 'audio')  String? audio, @JsonKey(name: 'surah')  SurahInfoDto? surah)  $default,) {final _that = this;
switch (_that) {
case _AyahDto():
return $default(_that.number,_that.text,_that.numberInSurah,_that.juz,_that.audio,_that.surah);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'number')  int number, @JsonKey(name: 'text')  String text, @JsonKey(name: 'numberInSurah')  int numberInSurah, @JsonKey(name: 'juz')  int juz, @JsonKey(name: 'audio')  String? audio, @JsonKey(name: 'surah')  SurahInfoDto? surah)?  $default,) {final _that = this;
switch (_that) {
case _AyahDto() when $default != null:
return $default(_that.number,_that.text,_that.numberInSurah,_that.juz,_that.audio,_that.surah);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AyahDto implements AyahDto {
  const _AyahDto({@JsonKey(name: 'number') required this.number, @JsonKey(name: 'text') required this.text, @JsonKey(name: 'numberInSurah') required this.numberInSurah, @JsonKey(name: 'juz') required this.juz, @JsonKey(name: 'audio') this.audio, @JsonKey(name: 'surah') this.surah});
  factory _AyahDto.fromJson(Map<String, dynamic> json) => _$AyahDtoFromJson(json);

@override@JsonKey(name: 'number') final  int number;
@override@JsonKey(name: 'text') final  String text;
@override@JsonKey(name: 'numberInSurah') final  int numberInSurah;
@override@JsonKey(name: 'juz') final  int juz;
@override@JsonKey(name: 'audio') final  String? audio;
@override@JsonKey(name: 'surah') final  SurahInfoDto? surah;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AyahDto&&(identical(other.number, number) || other.number == number)&&(identical(other.text, text) || other.text == text)&&(identical(other.numberInSurah, numberInSurah) || other.numberInSurah == numberInSurah)&&(identical(other.juz, juz) || other.juz == juz)&&(identical(other.audio, audio) || other.audio == audio)&&(identical(other.surah, surah) || other.surah == surah));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,text,numberInSurah,juz,audio,surah);

@override
String toString() {
  return 'AyahDto(number: $number, text: $text, numberInSurah: $numberInSurah, juz: $juz, audio: $audio, surah: $surah)';
}


}

/// @nodoc
abstract mixin class _$AyahDtoCopyWith<$Res> implements $AyahDtoCopyWith<$Res> {
  factory _$AyahDtoCopyWith(_AyahDto value, $Res Function(_AyahDto) _then) = __$AyahDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'number') int number,@JsonKey(name: 'text') String text,@JsonKey(name: 'numberInSurah') int numberInSurah,@JsonKey(name: 'juz') int juz,@JsonKey(name: 'audio') String? audio,@JsonKey(name: 'surah') SurahInfoDto? surah
});


@override $SurahInfoDtoCopyWith<$Res>? get surah;

}
/// @nodoc
class __$AyahDtoCopyWithImpl<$Res>
    implements _$AyahDtoCopyWith<$Res> {
  __$AyahDtoCopyWithImpl(this._self, this._then);

  final _AyahDto _self;
  final $Res Function(_AyahDto) _then;

/// Create a copy of AyahDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? text = null,Object? numberInSurah = null,Object? juz = null,Object? audio = freezed,Object? surah = freezed,}) {
  return _then(_AyahDto(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,numberInSurah: null == numberInSurah ? _self.numberInSurah : numberInSurah // ignore: cast_nullable_to_non_nullable
as int,juz: null == juz ? _self.juz : juz // ignore: cast_nullable_to_non_nullable
as int,audio: freezed == audio ? _self.audio : audio // ignore: cast_nullable_to_non_nullable
as String?,surah: freezed == surah ? _self.surah : surah // ignore: cast_nullable_to_non_nullable
as SurahInfoDto?,
  ));
}

/// Create a copy of AyahDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SurahInfoDtoCopyWith<$Res>? get surah {
    if (_self.surah == null) {
    return null;
  }

  return $SurahInfoDtoCopyWith<$Res>(_self.surah!, (value) {
    return _then(_self.copyWith(surah: value));
  });
}
}


/// @nodoc
mixin _$SurahInfoDto {

@JsonKey(name: 'number') int get number;@JsonKey(name: 'name') String get name;@JsonKey(name: 'englishName') String get englishName;@JsonKey(name: 'englishNameTranslation') String get englishNameTranslation;@JsonKey(name: 'revelationType') String get revelationType;@JsonKey(name: 'numberOfAyahs') int get numberOfAyahs;
/// Create a copy of SurahInfoDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SurahInfoDtoCopyWith<SurahInfoDto> get copyWith => _$SurahInfoDtoCopyWithImpl<SurahInfoDto>(this as SurahInfoDto, _$identity);

  /// Serializes this SurahInfoDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SurahInfoDto&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&(identical(other.englishName, englishName) || other.englishName == englishName)&&(identical(other.englishNameTranslation, englishNameTranslation) || other.englishNameTranslation == englishNameTranslation)&&(identical(other.revelationType, revelationType) || other.revelationType == revelationType)&&(identical(other.numberOfAyahs, numberOfAyahs) || other.numberOfAyahs == numberOfAyahs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,name,englishName,englishNameTranslation,revelationType,numberOfAyahs);

@override
String toString() {
  return 'SurahInfoDto(number: $number, name: $name, englishName: $englishName, englishNameTranslation: $englishNameTranslation, revelationType: $revelationType, numberOfAyahs: $numberOfAyahs)';
}


}

/// @nodoc
abstract mixin class $SurahInfoDtoCopyWith<$Res>  {
  factory $SurahInfoDtoCopyWith(SurahInfoDto value, $Res Function(SurahInfoDto) _then) = _$SurahInfoDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'number') int number,@JsonKey(name: 'name') String name,@JsonKey(name: 'englishName') String englishName,@JsonKey(name: 'englishNameTranslation') String englishNameTranslation,@JsonKey(name: 'revelationType') String revelationType,@JsonKey(name: 'numberOfAyahs') int numberOfAyahs
});




}
/// @nodoc
class _$SurahInfoDtoCopyWithImpl<$Res>
    implements $SurahInfoDtoCopyWith<$Res> {
  _$SurahInfoDtoCopyWithImpl(this._self, this._then);

  final SurahInfoDto _self;
  final $Res Function(SurahInfoDto) _then;

/// Create a copy of SurahInfoDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? name = null,Object? englishName = null,Object? englishNameTranslation = null,Object? revelationType = null,Object? numberOfAyahs = null,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,englishName: null == englishName ? _self.englishName : englishName // ignore: cast_nullable_to_non_nullable
as String,englishNameTranslation: null == englishNameTranslation ? _self.englishNameTranslation : englishNameTranslation // ignore: cast_nullable_to_non_nullable
as String,revelationType: null == revelationType ? _self.revelationType : revelationType // ignore: cast_nullable_to_non_nullable
as String,numberOfAyahs: null == numberOfAyahs ? _self.numberOfAyahs : numberOfAyahs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SurahInfoDto].
extension SurahInfoDtoPatterns on SurahInfoDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SurahInfoDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SurahInfoDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SurahInfoDto value)  $default,){
final _that = this;
switch (_that) {
case _SurahInfoDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SurahInfoDto value)?  $default,){
final _that = this;
switch (_that) {
case _SurahInfoDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'number')  int number, @JsonKey(name: 'name')  String name, @JsonKey(name: 'englishName')  String englishName, @JsonKey(name: 'englishNameTranslation')  String englishNameTranslation, @JsonKey(name: 'revelationType')  String revelationType, @JsonKey(name: 'numberOfAyahs')  int numberOfAyahs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SurahInfoDto() when $default != null:
return $default(_that.number,_that.name,_that.englishName,_that.englishNameTranslation,_that.revelationType,_that.numberOfAyahs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'number')  int number, @JsonKey(name: 'name')  String name, @JsonKey(name: 'englishName')  String englishName, @JsonKey(name: 'englishNameTranslation')  String englishNameTranslation, @JsonKey(name: 'revelationType')  String revelationType, @JsonKey(name: 'numberOfAyahs')  int numberOfAyahs)  $default,) {final _that = this;
switch (_that) {
case _SurahInfoDto():
return $default(_that.number,_that.name,_that.englishName,_that.englishNameTranslation,_that.revelationType,_that.numberOfAyahs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'number')  int number, @JsonKey(name: 'name')  String name, @JsonKey(name: 'englishName')  String englishName, @JsonKey(name: 'englishNameTranslation')  String englishNameTranslation, @JsonKey(name: 'revelationType')  String revelationType, @JsonKey(name: 'numberOfAyahs')  int numberOfAyahs)?  $default,) {final _that = this;
switch (_that) {
case _SurahInfoDto() when $default != null:
return $default(_that.number,_that.name,_that.englishName,_that.englishNameTranslation,_that.revelationType,_that.numberOfAyahs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SurahInfoDto implements SurahInfoDto {
  const _SurahInfoDto({@JsonKey(name: 'number') required this.number, @JsonKey(name: 'name') required this.name, @JsonKey(name: 'englishName') required this.englishName, @JsonKey(name: 'englishNameTranslation') required this.englishNameTranslation, @JsonKey(name: 'revelationType') required this.revelationType, @JsonKey(name: 'numberOfAyahs') required this.numberOfAyahs});
  factory _SurahInfoDto.fromJson(Map<String, dynamic> json) => _$SurahInfoDtoFromJson(json);

@override@JsonKey(name: 'number') final  int number;
@override@JsonKey(name: 'name') final  String name;
@override@JsonKey(name: 'englishName') final  String englishName;
@override@JsonKey(name: 'englishNameTranslation') final  String englishNameTranslation;
@override@JsonKey(name: 'revelationType') final  String revelationType;
@override@JsonKey(name: 'numberOfAyahs') final  int numberOfAyahs;

/// Create a copy of SurahInfoDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SurahInfoDtoCopyWith<_SurahInfoDto> get copyWith => __$SurahInfoDtoCopyWithImpl<_SurahInfoDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SurahInfoDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SurahInfoDto&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&(identical(other.englishName, englishName) || other.englishName == englishName)&&(identical(other.englishNameTranslation, englishNameTranslation) || other.englishNameTranslation == englishNameTranslation)&&(identical(other.revelationType, revelationType) || other.revelationType == revelationType)&&(identical(other.numberOfAyahs, numberOfAyahs) || other.numberOfAyahs == numberOfAyahs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,name,englishName,englishNameTranslation,revelationType,numberOfAyahs);

@override
String toString() {
  return 'SurahInfoDto(number: $number, name: $name, englishName: $englishName, englishNameTranslation: $englishNameTranslation, revelationType: $revelationType, numberOfAyahs: $numberOfAyahs)';
}


}

/// @nodoc
abstract mixin class _$SurahInfoDtoCopyWith<$Res> implements $SurahInfoDtoCopyWith<$Res> {
  factory _$SurahInfoDtoCopyWith(_SurahInfoDto value, $Res Function(_SurahInfoDto) _then) = __$SurahInfoDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'number') int number,@JsonKey(name: 'name') String name,@JsonKey(name: 'englishName') String englishName,@JsonKey(name: 'englishNameTranslation') String englishNameTranslation,@JsonKey(name: 'revelationType') String revelationType,@JsonKey(name: 'numberOfAyahs') int numberOfAyahs
});




}
/// @nodoc
class __$SurahInfoDtoCopyWithImpl<$Res>
    implements _$SurahInfoDtoCopyWith<$Res> {
  __$SurahInfoDtoCopyWithImpl(this._self, this._then);

  final _SurahInfoDto _self;
  final $Res Function(_SurahInfoDto) _then;

/// Create a copy of SurahInfoDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? name = null,Object? englishName = null,Object? englishNameTranslation = null,Object? revelationType = null,Object? numberOfAyahs = null,}) {
  return _then(_SurahInfoDto(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,englishName: null == englishName ? _self.englishName : englishName // ignore: cast_nullable_to_non_nullable
as String,englishNameTranslation: null == englishNameTranslation ? _self.englishNameTranslation : englishNameTranslation // ignore: cast_nullable_to_non_nullable
as String,revelationType: null == revelationType ? _self.revelationType : revelationType // ignore: cast_nullable_to_non_nullable
as String,numberOfAyahs: null == numberOfAyahs ? _self.numberOfAyahs : numberOfAyahs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
