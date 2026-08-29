import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../domain/entities/surah_entity.dart';
import '../../domain/enums/surah_sort_options.dart';

part 'surah_list_state.freezed.dart';

@freezed
abstract class SurahListState with _$SurahListState {
  const SurahListState._();

  const factory SurahListState({
    @Default(true) bool isLoading,
    @Default([]) List<SurahEntity> surahs,
    @Default('') String searchQuery,
    @Default(false) bool isOnlyFavorites,
    @Default(SurahSortBy.number) SurahSortBy sortBy,
    @Default(SortOrder.ascending) SortOrder sortOrder,
    String? errorMessage,
  }) = _SurahListState;

  /// Computed property for sorted and filtered surahs based on search query, sort criteria and order
  List<SurahEntity> get filteredSurahs {
    List<SurahEntity> result = List.from(surahs);

    if (searchQuery.trim().isNotEmpty) {
      final normalizedQuery = searchQuery.normalizeForSearch();
      if (normalizedQuery.isNotEmpty) {
        result = result.where((surah) {
          final normalizedName = surah.name.normalizeForSearch();
          final normalizedEnglishName = surah.englishName.normalizeForSearch();
          final normalizedTranslation =
              surah.englishNameTranslation.normalizeForSearch();
          final numberStr = surah.number.toString();

          return normalizedName.contains(normalizedQuery) ||
              normalizedEnglishName.contains(normalizedQuery) ||
              normalizedTranslation.contains(normalizedQuery) ||
              numberStr == normalizedQuery;
        }).toList();
      }
    }

    result.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case SurahSortBy.number:
          comparison = a.number.compareTo(b.number);
          break;
        case SurahSortBy.name:
          comparison = a.name.compareTo(b.name);
          break;
        case SurahSortBy.revelationOrder:
          comparison = a.revelationOrder.compareTo(b.revelationOrder);
          break;
        case SurahSortBy.juz:
          comparison = a.startJuz.compareTo(b.startJuz);
          break;
        case SurahSortBy.ayahCount:
          comparison = a.numberOfAyahs.compareTo(b.numberOfAyahs);
          break;
      }
      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    return result;
  }
}
