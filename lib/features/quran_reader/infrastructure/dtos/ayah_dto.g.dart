// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ayah_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AyahDto _$AyahDtoFromJson(Map<String, dynamic> json) => _AyahDto(
  id: (json['id'] as num).toInt(),
  surahId: (json['surah_id'] as num).toInt(),
  ayahNumber: (json['ayah_number'] as num).toInt(),
  arabicText: json['text'] as String,
  translationText: json['translation'] as String?,
  page: (json['page'] as num?)?.toInt(),
  juz: (json['juz'] as num?)?.toInt(),
  hizbQuarter: (json['hizb_quarter'] as num?)?.toInt(),
);

Map<String, dynamic> _$AyahDtoToJson(_AyahDto instance) => <String, dynamic>{
  'id': instance.id,
  'surah_id': instance.surahId,
  'ayah_number': instance.ayahNumber,
  'text': instance.arabicText,
  'translation': instance.translationText,
  'page': instance.page,
  'juz': instance.juz,
  'hizb_quarter': instance.hizbQuarter,
};
