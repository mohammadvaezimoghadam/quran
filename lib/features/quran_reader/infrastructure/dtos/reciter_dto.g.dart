// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reciter_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReciterDto _$ReciterDtoFromJson(Map<String, dynamic> json) => _ReciterDto(
  id: (json['id'] as num).toInt(),
  identifier: json['identifier'] as String,
  name: json['name'] as String,
  englishName: json['english_name'] as String,
  arabicName: json['arabic_name'] as String,
  subfolder: json['subfolder'] as String,
  bitrate: json['bitrate'] as String,
  styleId: (json['style_id'] as num).toInt(),
  styleName: json['style_name'] as String?,
  imageUrl: json['image_url'] as String?,
);

Map<String, dynamic> _$ReciterDtoToJson(_ReciterDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'identifier': instance.identifier,
      'name': instance.name,
      'english_name': instance.englishName,
      'arabic_name': instance.arabicName,
      'subfolder': instance.subfolder,
      'bitrate': instance.bitrate,
      'style_id': instance.styleId,
      'style_name': instance.styleName,
      'image_url': instance.imageUrl,
    };
