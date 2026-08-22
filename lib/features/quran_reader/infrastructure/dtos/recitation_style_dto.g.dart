// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recitation_style_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecitationStyleDto _$RecitationStyleDtoFromJson(Map<String, dynamic> json) =>
    _RecitationStyleDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      englishName: json['english_name'] as String,
    );

Map<String, dynamic> _$RecitationStyleDtoToJson(_RecitationStyleDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'english_name': instance.englishName,
    };
