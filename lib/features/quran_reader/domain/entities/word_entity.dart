import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_entity.freezed.dart';

@freezed
abstract class WordEntity with _$WordEntity {
  const factory WordEntity({
    required int id,
    required int surahId,
    required int ayahNumber,
    required int position,
    required String arabicText,
    required String translation,
  }) = _WordEntity;
}
