import 'package:freezed_annotation/freezed_annotation.dart';

part 'ayah_entity.freezed.dart';

@freezed
abstract class AyahEntity with _$AyahEntity {
  const AyahEntity._();

  const factory AyahEntity({
    required int id,
    required int surahId,
    required int ayahNumber,
    required String arabicText,
    String? translationText,
    int? page,
    int? juz,
    int? hizbQuarter,
  }) = _AyahEntity;
}

extension AyahEntityHizb on AyahEntity {
  int? get hizb => hizbQuarter != null ? ((hizbQuarter! + 1) ~/ 2) : null;
}
