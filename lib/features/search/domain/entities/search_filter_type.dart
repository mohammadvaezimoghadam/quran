/// Filter types available for Quran search
enum SearchFilterType {
  all,
  surahs,
  ayahs,
  translations,
}

extension SearchFilterTypeX on SearchFilterType {
  String get label {
    switch (this) {
      case SearchFilterType.all:
        return 'همه';
      case SearchFilterType.surahs:
        return 'سوره‌ها';
      case SearchFilterType.ayahs:
        return 'متن آیات';
      case SearchFilterType.translations:
        return 'ترجمه فارسی';
    }
  }
}
