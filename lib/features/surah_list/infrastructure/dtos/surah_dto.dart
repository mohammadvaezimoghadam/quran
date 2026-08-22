import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/surah_entity.dart';

part 'surah_dto.freezed.dart';
part 'surah_dto.g.dart';

@freezed
abstract class SurahDto with _$SurahDto {
  const factory SurahDto({
    required int number,
    required String name,
    required String englishName,
    required String englishNameTranslation,
    required int numberOfAyahs,
    required String revelationType,
    @Default(1) int startPage,
    @Default(1) int startJuz,
  }) = _SurahDto;

  factory SurahDto.fromJson(Map<String, dynamic> json) =>
      _$SurahDtoFromJson(json);

  factory SurahDto.fromSqlite(Map<String, dynamic> map) {
    return SurahDto(
      number: map['id'] as int,
      name: map['name'] as String,
      englishName: map['english_name'] as String,
      englishNameTranslation: map['english_name_translation'] as String,
      numberOfAyahs: map['number_of_ayahs'] as int,
      revelationType: map['revelation_type'] as String,
      startPage: (map['start_page'] as int?) ?? 1,
      startJuz: (map['start_juz'] as int?) ?? 1,
    );
  }
}

extension SurahDtoMapper on SurahDto {
  SurahEntity toDomain() {
    return SurahEntity(
      number: number,
      name: name,
      englishName: englishName,
      englishNameTranslation: englishNameTranslation,
      numberOfAyahs: numberOfAyahs,
      revelationType: revelationType,
      startPage: startPage,
      startJuz: startJuz,
    );
  }
}
