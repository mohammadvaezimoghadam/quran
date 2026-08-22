// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reciter_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReciterDto {

 int get id; String get identifier; String get name;@JsonKey(name: 'english_name') String get englishName;@JsonKey(name: 'arabic_name') String get arabicName; String get subfolder; String get bitrate;@JsonKey(name: 'style_id') int get styleId;@JsonKey(name: 'style_name') String? get styleName;@JsonKey(name: 'image_url') String? get imageUrl;
/// Create a copy of ReciterDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReciterDtoCopyWith<ReciterDto> get copyWith => _$ReciterDtoCopyWithImpl<ReciterDto>(this as ReciterDto, _$identity);

  /// Serializes this ReciterDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReciterDto&&(identical(other.id, id) || other.id == id)&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.name, name) || other.name == name)&&(identical(other.englishName, englishName) || other.englishName == englishName)&&(identical(other.arabicName, arabicName) || other.arabicName == arabicName)&&(identical(other.subfolder, subfolder) || other.subfolder == subfolder)&&(identical(other.bitrate, bitrate) || other.bitrate == bitrate)&&(identical(other.styleId, styleId) || other.styleId == styleId)&&(identical(other.styleName, styleName) || other.styleName == styleName)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,identifier,name,englishName,arabicName,subfolder,bitrate,styleId,styleName,imageUrl);

@override
String toString() {
  return 'ReciterDto(id: $id, identifier: $identifier, name: $name, englishName: $englishName, arabicName: $arabicName, subfolder: $subfolder, bitrate: $bitrate, styleId: $styleId, styleName: $styleName, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $ReciterDtoCopyWith<$Res>  {
  factory $ReciterDtoCopyWith(ReciterDto value, $Res Function(ReciterDto) _then) = _$ReciterDtoCopyWithImpl;
@useResult
$Res call({
 int id, String identifier, String name,@JsonKey(name: 'english_name') String englishName,@JsonKey(name: 'arabic_name') String arabicName, String subfolder, String bitrate,@JsonKey(name: 'style_id') int styleId,@JsonKey(name: 'style_name') String? styleName,@JsonKey(name: 'image_url') String? imageUrl
});




}
/// @nodoc
class _$ReciterDtoCopyWithImpl<$Res>
    implements $ReciterDtoCopyWith<$Res> {
  _$ReciterDtoCopyWithImpl(this._self, this._then);

  final ReciterDto _self;
  final $Res Function(ReciterDto) _then;

/// Create a copy of ReciterDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? identifier = null,Object? name = null,Object? englishName = null,Object? arabicName = null,Object? subfolder = null,Object? bitrate = null,Object? styleId = null,Object? styleName = freezed,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,englishName: null == englishName ? _self.englishName : englishName // ignore: cast_nullable_to_non_nullable
as String,arabicName: null == arabicName ? _self.arabicName : arabicName // ignore: cast_nullable_to_non_nullable
as String,subfolder: null == subfolder ? _self.subfolder : subfolder // ignore: cast_nullable_to_non_nullable
as String,bitrate: null == bitrate ? _self.bitrate : bitrate // ignore: cast_nullable_to_non_nullable
as String,styleId: null == styleId ? _self.styleId : styleId // ignore: cast_nullable_to_non_nullable
as int,styleName: freezed == styleName ? _self.styleName : styleName // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReciterDto].
extension ReciterDtoPatterns on ReciterDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReciterDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReciterDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReciterDto value)  $default,){
final _that = this;
switch (_that) {
case _ReciterDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReciterDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReciterDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String identifier,  String name, @JsonKey(name: 'english_name')  String englishName, @JsonKey(name: 'arabic_name')  String arabicName,  String subfolder,  String bitrate, @JsonKey(name: 'style_id')  int styleId, @JsonKey(name: 'style_name')  String? styleName, @JsonKey(name: 'image_url')  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReciterDto() when $default != null:
return $default(_that.id,_that.identifier,_that.name,_that.englishName,_that.arabicName,_that.subfolder,_that.bitrate,_that.styleId,_that.styleName,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String identifier,  String name, @JsonKey(name: 'english_name')  String englishName, @JsonKey(name: 'arabic_name')  String arabicName,  String subfolder,  String bitrate, @JsonKey(name: 'style_id')  int styleId, @JsonKey(name: 'style_name')  String? styleName, @JsonKey(name: 'image_url')  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _ReciterDto():
return $default(_that.id,_that.identifier,_that.name,_that.englishName,_that.arabicName,_that.subfolder,_that.bitrate,_that.styleId,_that.styleName,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String identifier,  String name, @JsonKey(name: 'english_name')  String englishName, @JsonKey(name: 'arabic_name')  String arabicName,  String subfolder,  String bitrate, @JsonKey(name: 'style_id')  int styleId, @JsonKey(name: 'style_name')  String? styleName, @JsonKey(name: 'image_url')  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _ReciterDto() when $default != null:
return $default(_that.id,_that.identifier,_that.name,_that.englishName,_that.arabicName,_that.subfolder,_that.bitrate,_that.styleId,_that.styleName,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReciterDto extends ReciterDto {
  const _ReciterDto({required this.id, required this.identifier, required this.name, @JsonKey(name: 'english_name') required this.englishName, @JsonKey(name: 'arabic_name') required this.arabicName, required this.subfolder, required this.bitrate, @JsonKey(name: 'style_id') required this.styleId, @JsonKey(name: 'style_name') this.styleName, @JsonKey(name: 'image_url') this.imageUrl}): super._();
  factory _ReciterDto.fromJson(Map<String, dynamic> json) => _$ReciterDtoFromJson(json);

@override final  int id;
@override final  String identifier;
@override final  String name;
@override@JsonKey(name: 'english_name') final  String englishName;
@override@JsonKey(name: 'arabic_name') final  String arabicName;
@override final  String subfolder;
@override final  String bitrate;
@override@JsonKey(name: 'style_id') final  int styleId;
@override@JsonKey(name: 'style_name') final  String? styleName;
@override@JsonKey(name: 'image_url') final  String? imageUrl;

/// Create a copy of ReciterDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReciterDtoCopyWith<_ReciterDto> get copyWith => __$ReciterDtoCopyWithImpl<_ReciterDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReciterDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReciterDto&&(identical(other.id, id) || other.id == id)&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.name, name) || other.name == name)&&(identical(other.englishName, englishName) || other.englishName == englishName)&&(identical(other.arabicName, arabicName) || other.arabicName == arabicName)&&(identical(other.subfolder, subfolder) || other.subfolder == subfolder)&&(identical(other.bitrate, bitrate) || other.bitrate == bitrate)&&(identical(other.styleId, styleId) || other.styleId == styleId)&&(identical(other.styleName, styleName) || other.styleName == styleName)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,identifier,name,englishName,arabicName,subfolder,bitrate,styleId,styleName,imageUrl);

@override
String toString() {
  return 'ReciterDto(id: $id, identifier: $identifier, name: $name, englishName: $englishName, arabicName: $arabicName, subfolder: $subfolder, bitrate: $bitrate, styleId: $styleId, styleName: $styleName, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$ReciterDtoCopyWith<$Res> implements $ReciterDtoCopyWith<$Res> {
  factory _$ReciterDtoCopyWith(_ReciterDto value, $Res Function(_ReciterDto) _then) = __$ReciterDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String identifier, String name,@JsonKey(name: 'english_name') String englishName,@JsonKey(name: 'arabic_name') String arabicName, String subfolder, String bitrate,@JsonKey(name: 'style_id') int styleId,@JsonKey(name: 'style_name') String? styleName,@JsonKey(name: 'image_url') String? imageUrl
});




}
/// @nodoc
class __$ReciterDtoCopyWithImpl<$Res>
    implements _$ReciterDtoCopyWith<$Res> {
  __$ReciterDtoCopyWithImpl(this._self, this._then);

  final _ReciterDto _self;
  final $Res Function(_ReciterDto) _then;

/// Create a copy of ReciterDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? identifier = null,Object? name = null,Object? englishName = null,Object? arabicName = null,Object? subfolder = null,Object? bitrate = null,Object? styleId = null,Object? styleName = freezed,Object? imageUrl = freezed,}) {
  return _then(_ReciterDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,englishName: null == englishName ? _self.englishName : englishName // ignore: cast_nullable_to_non_nullable
as String,arabicName: null == arabicName ? _self.arabicName : arabicName // ignore: cast_nullable_to_non_nullable
as String,subfolder: null == subfolder ? _self.subfolder : subfolder // ignore: cast_nullable_to_non_nullable
as String,bitrate: null == bitrate ? _self.bitrate : bitrate // ignore: cast_nullable_to_non_nullable
as String,styleId: null == styleId ? _self.styleId : styleId // ignore: cast_nullable_to_non_nullable
as int,styleName: freezed == styleName ? _self.styleName : styleName // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
