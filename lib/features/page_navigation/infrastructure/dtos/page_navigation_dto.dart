import 'package:freezed_annotation/freezed_annotation.dart';
part 'page_navigation_dto.freezed.dart';
part 'page_navigation_dto.g.dart';

@freezed
abstract class PageNavigationDto with _$PageNavigationDto {
  const factory PageNavigationDto({
    @JsonKey(name: 'surah_id') required int surahId,
    @JsonKey(name: 'surah_name') required String surahName,
    @JsonKey(name: 'ayah_number') required int ayahNumber,
  }) = _PageNavigationDto;

  factory PageNavigationDto.fromJson(Map<String, dynamic> json) =>
      _$PageNavigationDtoFromJson(json);

  factory PageNavigationDto.fromSqlite(Map<String, dynamic> map) {
    return PageNavigationDto(
      surahId: map['surah_id'] as int,
      surahName: map['surah_name'] as String,
      ayahNumber: map['ayah_number'] as int,
    );
  }
}


