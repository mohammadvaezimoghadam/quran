import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_entity.freezed.dart';

@freezed
abstract class TranslationEntity with _$TranslationEntity {
  const factory TranslationEntity({
    required int id,
    required String translationId,
    required int ayahId,
    required int ayahNumber,
    required String text,
  }) = _TranslationEntity;
}
