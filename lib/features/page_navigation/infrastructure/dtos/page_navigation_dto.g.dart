// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_navigation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PageNavigationDto _$PageNavigationDtoFromJson(Map<String, dynamic> json) =>
    _PageNavigationDto(
      surahId: (json['surah_id'] as num).toInt(),
      surahName: json['surah_name'] as String,
      ayahNumber: (json['ayah_number'] as num).toInt(),
    );

Map<String, dynamic> _$PageNavigationDtoToJson(_PageNavigationDto instance) =>
    <String, dynamic>{
      'surah_id': instance.surahId,
      'surah_name': instance.surahName,
      'ayah_number': instance.ayahNumber,
    };
