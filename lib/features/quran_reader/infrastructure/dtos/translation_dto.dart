import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../common/extensions/string_extension.dart';
import '../../domain/entities/translation_entity.dart';

part 'translation_dto.freezed.dart';
part 'translation_dto.g.dart';

@freezed
abstract class TranslationDto with _$TranslationDto {
  const TranslationDto._();

  const factory TranslationDto({
    required int id,
    @JsonKey(name: 'translation_id') required String translationId,
    @JsonKey(name: 'ayah_id') required int ayahId,
    @JsonKey(name: 'number_in_surah') required int ayahNumber,
    required String text,
  }) = _TranslationDto;

  factory TranslationDto.fromJson(Map<String, dynamic> json) =>
      _$TranslationDtoFromJson(json);

  factory TranslationDto.fromSqlite(Map<String, dynamic> map) {
    return TranslationDto(
      id: map['id'] as int,
      translationId: (map['translation_id'] as String?) ?? '',
      ayahId: (map['ayah_id'] as int?) ?? 0,
      ayahNumber: (map['number_in_surah'] as int?) ?? 0,
      text: map['text'] as String,
    );
  }

  TranslationEntity toDomain() {
    return TranslationEntity(
      id: id,
      translationId: translationId,
      ayahId: ayahId,
      ayahNumber: ayahNumber,
      text: text.removeTranslatorExplanations(),
    );
  }
}
