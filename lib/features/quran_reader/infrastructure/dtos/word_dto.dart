import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/word_entity.dart';

part 'word_dto.freezed.dart';
part 'word_dto.g.dart';

@freezed
abstract class WordDto with _$WordDto {
  const WordDto._();

  const factory WordDto({
    required int id,
    @JsonKey(name: 'surah_id') required int surahId,
    @JsonKey(name: 'ayah_number') required int ayahNumber,
    @JsonKey(name: 'word_position') required int position,
    @JsonKey(name: 'arabic_text') required String arabicText,
    @JsonKey(name: 'translation_fa') required String translation,
  }) = _WordDto;

  factory WordDto.fromJson(Map<String, dynamic> json) => _$WordDtoFromJson(json);

  factory WordDto.fromSqlite(Map<String, dynamic> map) {
    return WordDto(
      id: map['id'] as int,
      surahId: map['surah_id'] as int,
      ayahNumber: map['ayah_number'] as int,
      position: map['word_position'] as int,
      arabicText: map['arabic_text'] as String,
      translation: map['translation_fa'] as String,
    );
  }

  WordEntity toDomain() {
    return WordEntity(
      id: id,
      surahId: surahId,
      ayahNumber: ayahNumber,
      position: position,
      arabicText: arabicText,
      translation: translation,
    );
  }
}
