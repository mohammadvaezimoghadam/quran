// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'city_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CityEntity {

 String get id; String get namePersian; String get nameEnglish; String get province; double get latitude; double get longitude; bool get isDefault; bool get isGpsLocation;
/// Create a copy of CityEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CityEntityCopyWith<CityEntity> get copyWith => _$CityEntityCopyWithImpl<CityEntity>(this as CityEntity, _$identity);

  /// Serializes this CityEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CityEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.namePersian, namePersian) || other.namePersian == namePersian)&&(identical(other.nameEnglish, nameEnglish) || other.nameEnglish == nameEnglish)&&(identical(other.province, province) || other.province == province)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.isGpsLocation, isGpsLocation) || other.isGpsLocation == isGpsLocation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,namePersian,nameEnglish,province,latitude,longitude,isDefault,isGpsLocation);

@override
String toString() {
  return 'CityEntity(id: $id, namePersian: $namePersian, nameEnglish: $nameEnglish, province: $province, latitude: $latitude, longitude: $longitude, isDefault: $isDefault, isGpsLocation: $isGpsLocation)';
}


}

/// @nodoc
abstract mixin class $CityEntityCopyWith<$Res>  {
  factory $CityEntityCopyWith(CityEntity value, $Res Function(CityEntity) _then) = _$CityEntityCopyWithImpl;
@useResult
$Res call({
 String id, String namePersian, String nameEnglish, String province, double latitude, double longitude, bool isDefault, bool isGpsLocation
});




}
/// @nodoc
class _$CityEntityCopyWithImpl<$Res>
    implements $CityEntityCopyWith<$Res> {
  _$CityEntityCopyWithImpl(this._self, this._then);

  final CityEntity _self;
  final $Res Function(CityEntity) _then;

/// Create a copy of CityEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? namePersian = null,Object? nameEnglish = null,Object? province = null,Object? latitude = null,Object? longitude = null,Object? isDefault = null,Object? isGpsLocation = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,namePersian: null == namePersian ? _self.namePersian : namePersian // ignore: cast_nullable_to_non_nullable
as String,nameEnglish: null == nameEnglish ? _self.nameEnglish : nameEnglish // ignore: cast_nullable_to_non_nullable
as String,province: null == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,isGpsLocation: null == isGpsLocation ? _self.isGpsLocation : isGpsLocation // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CityEntity].
extension CityEntityPatterns on CityEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CityEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CityEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CityEntity value)  $default,){
final _that = this;
switch (_that) {
case _CityEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CityEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CityEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String namePersian,  String nameEnglish,  String province,  double latitude,  double longitude,  bool isDefault,  bool isGpsLocation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CityEntity() when $default != null:
return $default(_that.id,_that.namePersian,_that.nameEnglish,_that.province,_that.latitude,_that.longitude,_that.isDefault,_that.isGpsLocation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String namePersian,  String nameEnglish,  String province,  double latitude,  double longitude,  bool isDefault,  bool isGpsLocation)  $default,) {final _that = this;
switch (_that) {
case _CityEntity():
return $default(_that.id,_that.namePersian,_that.nameEnglish,_that.province,_that.latitude,_that.longitude,_that.isDefault,_that.isGpsLocation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String namePersian,  String nameEnglish,  String province,  double latitude,  double longitude,  bool isDefault,  bool isGpsLocation)?  $default,) {final _that = this;
switch (_that) {
case _CityEntity() when $default != null:
return $default(_that.id,_that.namePersian,_that.nameEnglish,_that.province,_that.latitude,_that.longitude,_that.isDefault,_that.isGpsLocation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CityEntity implements CityEntity {
  const _CityEntity({required this.id, required this.namePersian, required this.nameEnglish, required this.province, required this.latitude, required this.longitude, this.isDefault = false, this.isGpsLocation = false});
  factory _CityEntity.fromJson(Map<String, dynamic> json) => _$CityEntityFromJson(json);

@override final  String id;
@override final  String namePersian;
@override final  String nameEnglish;
@override final  String province;
@override final  double latitude;
@override final  double longitude;
@override@JsonKey() final  bool isDefault;
@override@JsonKey() final  bool isGpsLocation;

/// Create a copy of CityEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CityEntityCopyWith<_CityEntity> get copyWith => __$CityEntityCopyWithImpl<_CityEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CityEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CityEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.namePersian, namePersian) || other.namePersian == namePersian)&&(identical(other.nameEnglish, nameEnglish) || other.nameEnglish == nameEnglish)&&(identical(other.province, province) || other.province == province)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.isGpsLocation, isGpsLocation) || other.isGpsLocation == isGpsLocation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,namePersian,nameEnglish,province,latitude,longitude,isDefault,isGpsLocation);

@override
String toString() {
  return 'CityEntity(id: $id, namePersian: $namePersian, nameEnglish: $nameEnglish, province: $province, latitude: $latitude, longitude: $longitude, isDefault: $isDefault, isGpsLocation: $isGpsLocation)';
}


}

/// @nodoc
abstract mixin class _$CityEntityCopyWith<$Res> implements $CityEntityCopyWith<$Res> {
  factory _$CityEntityCopyWith(_CityEntity value, $Res Function(_CityEntity) _then) = __$CityEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String namePersian, String nameEnglish, String province, double latitude, double longitude, bool isDefault, bool isGpsLocation
});




}
/// @nodoc
class __$CityEntityCopyWithImpl<$Res>
    implements _$CityEntityCopyWith<$Res> {
  __$CityEntityCopyWithImpl(this._self, this._then);

  final _CityEntity _self;
  final $Res Function(_CityEntity) _then;

/// Create a copy of CityEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? namePersian = null,Object? nameEnglish = null,Object? province = null,Object? latitude = null,Object? longitude = null,Object? isDefault = null,Object? isGpsLocation = null,}) {
  return _then(_CityEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,namePersian: null == namePersian ? _self.namePersian : namePersian // ignore: cast_nullable_to_non_nullable
as String,nameEnglish: null == nameEnglish ? _self.nameEnglish : nameEnglish // ignore: cast_nullable_to_non_nullable
as String,province: null == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,isGpsLocation: null == isGpsLocation ? _self.isGpsLocation : isGpsLocation // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
