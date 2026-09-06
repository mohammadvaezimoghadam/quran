enum SearchResultKind {
  surah,
  ayah,
}

class SearchResultItem {
  final SearchResultKind kind;
  final int surahNumber;
  final String surahName;
  final String englishName;
  final int? numberOfAyahs;
  final String? revelationType;
  final int? ayahNumber;
  final String? arabicText;
  final String? translationText;
  final int? pageNumber;
  final int? juzNumber;
  final bool matchedInArabic;
  final bool matchedInTranslation;

  const SearchResultItem({
    required this.kind,
    required this.surahNumber,
    required this.surahName,
    required this.englishName,
    this.numberOfAyahs,
    this.revelationType,
    this.ayahNumber,
    this.arabicText,
    this.translationText,
    this.pageNumber,
    this.juzNumber,
    this.matchedInArabic = true,
    this.matchedInTranslation = false,
  });

  bool get isSurah => kind == SearchResultKind.surah;
  bool get isAyah => kind == SearchResultKind.ayah;
}
