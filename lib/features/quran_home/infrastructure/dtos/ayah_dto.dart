import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/ayah_of_the_day.dart';

part 'ayah_dto.freezed.dart';
part 'ayah_dto.g.dart';

/// Data Transfer Object for Ayah API response with explicit JsonKey annotations
@freezed
abstract class AyahDto with _$AyahDto {
  const factory AyahDto({
    @JsonKey(name: 'number') required int number,
    @JsonKey(name: 'text') required String text,
    @JsonKey(name: 'numberInSurah') required int numberInSurah,
    @JsonKey(name: 'juz') required int juz,
    @JsonKey(name: 'audio') String? audio,
    @JsonKey(name: 'surah') SurahInfoDto? surah,
  }) = _AyahDto;

  factory AyahDto.fromJson(Map<String, dynamic> json) => _$AyahDtoFromJson(json);
}

@freezed
abstract class SurahInfoDto with _$SurahInfoDto {
  const factory SurahInfoDto({
    @JsonKey(name: 'number') required int number,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'englishName') required String englishName,
    @JsonKey(name: 'englishNameTranslation') required String englishNameTranslation,
    @JsonKey(name: 'revelationType') required String revelationType,
    @JsonKey(name: 'numberOfAyahs') required int numberOfAyahs,
  }) = _SurahInfoDto;

  factory SurahInfoDto.fromJson(Map<String, dynamic> json) => _$SurahInfoDtoFromJson(json);
}

/// Mapper extension to convert AyahDto to AyahOfTheDay domain entity
extension AyahDtoMapper on AyahDto {
  AyahOfTheDay toDomain({
    required String translation,
    required String audioUrl,
  }) {
    return AyahOfTheDay(
      ayahNumber: numberInSurah,
      arabicText: text,
      translationText: translation,
      surahName: surah?.name ?? '',
      surahNumber: surah?.number ?? 1,
      audioUrl: audioUrl,
    );
  }
}
