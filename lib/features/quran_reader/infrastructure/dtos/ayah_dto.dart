import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/ayah_entity.dart';

part 'ayah_dto.freezed.dart';
part 'ayah_dto.g.dart';

@freezed
abstract class AyahDto with _$AyahDto {
  const AyahDto._();

  const factory AyahDto({
    required int id,
    @JsonKey(name: 'surah_id') required int surahId,
    @JsonKey(name: 'ayah_number') required int ayahNumber,
    @JsonKey(name: 'text') required String arabicText,
    @JsonKey(name: 'translation') String? translationText,
    int? page,
    int? juz,
    @JsonKey(name: 'hizb_quarter') int? hizbQuarter,
  }) = _AyahDto;

  factory AyahDto.fromJson(Map<String, dynamic> json) => _$AyahDtoFromJson(json);

  // Mapping from SQLite raw map
  factory AyahDto.fromSqlite(Map<String, dynamic> map) {
    return AyahDto(
      id: map['id'] as int,
      surahId: map['surah_number'] as int,
      ayahNumber: map['number_in_surah'] as int,
      arabicText: map['text_uthmani'] as String,
      translationText: map['translation'] as String?, // Note: May not be in this table
      page: map['page'] as int?,
      juz: map['juz'] as int?,
      hizbQuarter: map['hizb_quarter'] as int?,
    );
  }

  // Mapper to Domain Entity
  AyahEntity toDomain() {
    return AyahEntity(
      id: id,
      surahId: surahId,
      ayahNumber: ayahNumber,
      arabicText: arabicText,
      translationText: translationText,
      page: page,
      juz: juz,
      hizbQuarter: hizbQuarter,
    );
  }
}
// Touch file to trigger build_runner
