// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CityEntity _$CityEntityFromJson(Map<String, dynamic> json) => _CityEntity(
  id: json['id'] as String,
  namePersian: json['namePersian'] as String,
  nameEnglish: json['nameEnglish'] as String,
  province: json['province'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  isDefault: json['isDefault'] as bool? ?? false,
  isGpsLocation: json['isGpsLocation'] as bool? ?? false,
);

Map<String, dynamic> _$CityEntityToJson(_CityEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'namePersian': instance.namePersian,
      'nameEnglish': instance.nameEnglish,
      'province': instance.province,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isDefault': instance.isDefault,
      'isGpsLocation': instance.isGpsLocation,
    };
