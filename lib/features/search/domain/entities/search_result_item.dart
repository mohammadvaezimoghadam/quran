import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_result_item.freezed.dart';

enum SearchResultKind {
  surah,
  ayah,
}

@freezed
abstract class SearchResultItem with _$SearchResultItem {
  const SearchResultItem._();

  const factory SearchResultItem({
    required SearchResultKind kind,
    required int surahNumber,
    required String surahName,
    required String englishName,
    int? numberOfAyahs,
    String? revelationType,
    int? ayahNumber,
    String? arabicText,
    String? translationText,
    int? pageNumber,
    int? juzNumber,
    @Default(false) bool matchedInTranslation,
  }) = _SearchResultItem;

  bool get isSurah => kind == SearchResultKind.surah;
  bool get isAyah => kind == SearchResultKind.ayah;
}
