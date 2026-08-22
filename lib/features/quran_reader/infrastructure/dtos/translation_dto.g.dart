// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TranslationDto _$TranslationDtoFromJson(Map<String, dynamic> json) =>
    _TranslationDto(
      id: (json['id'] as num).toInt(),
      translationId: json['translation_id'] as String,
      ayahId: (json['ayah_id'] as num).toInt(),
      ayahNumber: (json['number_in_surah'] as num).toInt(),
      text: json['text'] as String,
    );

Map<String, dynamic> _$TranslationDtoToJson(_TranslationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'translation_id': instance.translationId,
      'ayah_id': instance.ayahId,
      'number_in_surah': instance.ayahNumber,
      'text': instance.text,
    };
