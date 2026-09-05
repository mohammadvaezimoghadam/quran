// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moezzin_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MoezzinDto _$MoezzinDtoFromJson(Map<String, dynamic> json) => _MoezzinDto(
  id: json['id'] as String,
  nameFa: json['name_fa'] as String,
  assetPath: json['asset_path'] as String,
  downloadUrl: json['download_url'] as String,
);

Map<String, dynamic> _$MoezzinDtoToJson(_MoezzinDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_fa': instance.nameFa,
      'asset_path': instance.assetPath,
      'download_url': instance.downloadUrl,
    };
