// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WordDto _$WordDtoFromJson(Map<String, dynamic> json) => _WordDto(
  id: (json['id'] as num).toInt(),
  surahId: (json['surah_id'] as num).toInt(),
  ayahNumber: (json['ayah_number'] as num).toInt(),
  position: (json['word_position'] as num).toInt(),
  arabicText: json['arabic_text'] as String,
  translation: json['translation_fa'] as String,
);

Map<String, dynamic> _$WordDtoToJson(_WordDto instance) => <String, dynamic>{
  'id': instance.id,
  'surah_id': instance.surahId,
  'ayah_number': instance.ayahNumber,
  'word_position': instance.position,
  'arabic_text': instance.arabicText,
  'translation_fa': instance.translation,
};
