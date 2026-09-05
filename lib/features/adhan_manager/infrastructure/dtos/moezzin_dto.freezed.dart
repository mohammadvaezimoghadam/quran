// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'moezzin_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MoezzinDto {

 String get id;@JsonKey(name: 'name_fa') String get nameFa;@JsonKey(name: 'asset_path') String get assetPath;@JsonKey(name: 'download_url') String get downloadUrl;
/// Create a copy of MoezzinDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoezzinDtoCopyWith<MoezzinDto> get copyWith => _$MoezzinDtoCopyWithImpl<MoezzinDto>(this as MoezzinDto, _$identity);

  /// Serializes this MoezzinDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoezzinDto&&(identical(other.id, id) || other.id == id)&&(identical(other.nameFa, nameFa) || other.nameFa == nameFa)&&(identical(other.assetPath, assetPath) || other.assetPath == assetPath)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameFa,assetPath,downloadUrl);

@override
String toString() {
  return 'MoezzinDto(id: $id, nameFa: $nameFa, assetPath: $assetPath, downloadUrl: $downloadUrl)';
}


}

/// @nodoc
abstract mixin class $MoezzinDtoCopyWith<$Res>  {
  factory $MoezzinDtoCopyWith(MoezzinDto value, $Res Function(MoezzinDto) _then) = _$MoezzinDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'name_fa') String nameFa,@JsonKey(name: 'asset_path') String assetPath,@JsonKey(name: 'download_url') String downloadUrl
});




}
/// @nodoc
class _$MoezzinDtoCopyWithImpl<$Res>
    implements $MoezzinDtoCopyWith<$Res> {
  _$MoezzinDtoCopyWithImpl(this._self, this._then);

  final MoezzinDto _self;
  final $Res Function(MoezzinDto) _then;

/// Create a copy of MoezzinDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameFa = null,Object? assetPath = null,Object? downloadUrl = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameFa: null == nameFa ? _self.nameFa : nameFa // ignore: cast_nullable_to_non_nullable
as String,assetPath: null == assetPath ? _self.assetPath : assetPath // ignore: cast_nullable_to_non_nullable
as String,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MoezzinDto].
extension MoezzinDtoPatterns on MoezzinDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoezzinDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoezzinDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoezzinDto value)  $default,){
final _that = this;
switch (_that) {
case _MoezzinDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoezzinDto value)?  $default,){
final _that = this;
switch (_that) {
case _MoezzinDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'name_fa')  String nameFa, @JsonKey(name: 'asset_path')  String assetPath, @JsonKey(name: 'download_url')  String downloadUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MoezzinDto() when $default != null:
return $default(_that.id,_that.nameFa,_that.assetPath,_that.downloadUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'name_fa')  String nameFa, @JsonKey(name: 'asset_path')  String assetPath, @JsonKey(name: 'download_url')  String downloadUrl)  $default,) {final _that = this;
switch (_that) {
case _MoezzinDto():
return $default(_that.id,_that.nameFa,_that.assetPath,_that.downloadUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'name_fa')  String nameFa, @JsonKey(name: 'asset_path')  String assetPath, @JsonKey(name: 'download_url')  String downloadUrl)?  $default,) {final _that = this;
switch (_that) {
case _MoezzinDto() when $default != null:
return $default(_that.id,_that.nameFa,_that.assetPath,_that.downloadUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MoezzinDto extends MoezzinDto {
  const _MoezzinDto({required this.id, @JsonKey(name: 'name_fa') required this.nameFa, @JsonKey(name: 'asset_path') required this.assetPath, @JsonKey(name: 'download_url') required this.downloadUrl}): super._();
  factory _MoezzinDto.fromJson(Map<String, dynamic> json) => _$MoezzinDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'name_fa') final  String nameFa;
@override@JsonKey(name: 'asset_path') final  String assetPath;
@override@JsonKey(name: 'download_url') final  String downloadUrl;

/// Create a copy of MoezzinDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoezzinDtoCopyWith<_MoezzinDto> get copyWith => __$MoezzinDtoCopyWithImpl<_MoezzinDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoezzinDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoezzinDto&&(identical(other.id, id) || other.id == id)&&(identical(other.nameFa, nameFa) || other.nameFa == nameFa)&&(identical(other.assetPath, assetPath) || other.assetPath == assetPath)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameFa,assetPath,downloadUrl);

@override
String toString() {
  return 'MoezzinDto(id: $id, nameFa: $nameFa, assetPath: $assetPath, downloadUrl: $downloadUrl)';
}


}

/// @nodoc
abstract mixin class _$MoezzinDtoCopyWith<$Res> implements $MoezzinDtoCopyWith<$Res> {
  factory _$MoezzinDtoCopyWith(_MoezzinDto value, $Res Function(_MoezzinDto) _then) = __$MoezzinDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'name_fa') String nameFa,@JsonKey(name: 'asset_path') String assetPath,@JsonKey(name: 'download_url') String downloadUrl
});




}
/// @nodoc
class __$MoezzinDtoCopyWithImpl<$Res>
    implements _$MoezzinDtoCopyWith<$Res> {
  __$MoezzinDtoCopyWithImpl(this._self, this._then);

  final _MoezzinDto _self;
  final $Res Function(_MoezzinDto) _then;

/// Create a copy of MoezzinDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameFa = null,Object? assetPath = null,Object? downloadUrl = null,}) {
  return _then(_MoezzinDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameFa: null == nameFa ? _self.nameFa : nameFa // ignore: cast_nullable_to_non_nullable
as String,assetPath: null == assetPath ? _self.assetPath : assetPath // ignore: cast_nullable_to_non_nullable
as String,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
