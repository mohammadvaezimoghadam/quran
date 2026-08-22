// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'surah_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SurahDto _$SurahDtoFromJson(Map<String, dynamic> json) => _SurahDto(
  number: (json['number'] as num).toInt(),
  name: json['name'] as String,
  englishName: json['englishName'] as String,
  englishNameTranslation: json['englishNameTranslation'] as String,
  numberOfAyahs: (json['numberOfAyahs'] as num).toInt(),
  revelationType: json['revelationType'] as String,
  startPage: (json['startPage'] as num?)?.toInt() ?? 1,
  startJuz: (json['startJuz'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$SurahDtoToJson(_SurahDto instance) => <String, dynamic>{
  'number': instance.number,
  'name': instance.name,
  'englishName': instance.englishName,
  'englishNameTranslation': instance.englishNameTranslation,
  'numberOfAyahs': instance.numberOfAyahs,
  'revelationType': instance.revelationType,
  'startPage': instance.startPage,
  'startJuz': instance.startJuz,
};
