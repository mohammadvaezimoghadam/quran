import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/search_filter_type.dart';
import '../../domain/entities/search_result_item.dart';

part 'search_state.freezed.dart';

@freezed
abstract class SearchState with _$SearchState {
  const SearchState._();

  const factory SearchState({
    @Default('') String query,
    @Default(SearchFilterType.all) SearchFilterType activeFilter,
    @Default([]) List<SearchResultItem> results,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _SearchState;

  List<SearchResultItem> get surahResults =>
      results.where((item) => item.isSurah).toList();

  List<SearchResultItem> get arabicAyahResults =>
      results.where((item) => item.isAyah && item.matchedInArabic).toList();

  List<SearchResultItem> get translationAyahResults =>
      results.where((item) => item.isAyah && item.matchedInTranslation).toList();

  List<SearchResultItem> get displayedResults {
    switch (activeFilter) {
      case SearchFilterType.all:
        return results;
      case SearchFilterType.surahs:
        return surahResults;
      case SearchFilterType.ayahs:
        return arabicAyahResults;
      case SearchFilterType.translations:
        return translationAyahResults;
    }
  }

  int get totalCount => results.length;
  int get surahCount => surahResults.length;
  int get ayahCount => arabicAyahResults.length;
  int get translationCount => translationAyahResults.length;

  bool get hasResults => results.isNotEmpty;
  bool get isEmptyQuery => query.trim().isEmpty;
}
