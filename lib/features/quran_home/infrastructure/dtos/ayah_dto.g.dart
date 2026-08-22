// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ayah_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AyahDto _$AyahDtoFromJson(Map<String, dynamic> json) => _AyahDto(
  number: (json['number'] as num).toInt(),
  text: json['text'] as String,
  numberInSurah: (json['numberInSurah'] as num).toInt(),
  juz: (json['juz'] as num).toInt(),
  audio: json['audio'] as String?,
  surah: json['surah'] == null
      ? null
      : SurahInfoDto.fromJson(json['surah'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AyahDtoToJson(_AyahDto instance) => <String, dynamic>{
  'number': instance.number,
  'text': instance.text,
  'numberInSurah': instance.numberInSurah,
  'juz': instance.juz,
  'audio': instance.audio,
  'surah': instance.surah,
};

_SurahInfoDto _$SurahInfoDtoFromJson(Map<String, dynamic> json) =>
    _SurahInfoDto(
      number: (json['number'] as num).toInt(),
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      englishNameTranslation: json['englishNameTranslation'] as String,
      revelationType: json['revelationType'] as String,
      numberOfAyahs: (json['numberOfAyahs'] as num).toInt(),
    );

Map<String, dynamic> _$SurahInfoDtoToJson(_SurahInfoDto instance) =>
    <String, dynamic>{
      'number': instance.number,
      'name': instance.name,
      'englishName': instance.englishName,
      'englishNameTranslation': instance.englishNameTranslation,
      'revelationType': instance.revelationType,
      'numberOfAyahs': instance.numberOfAyahs,
    };
