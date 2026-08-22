import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../domain/entities/surah_entity.dart';

part 'surah_list_state.freezed.dart';

@freezed
abstract class SurahListState with _$SurahListState {
  const SurahListState._();

  const factory SurahListState({
    @Default(true) bool isLoading,
    @Default([]) List<SurahEntity> surahs,
    @Default('') String searchQuery,
    String? errorMessage,
  }) = _SurahListState;

  /// Computed property for filtered surahs based on search query
  List<SurahEntity> get filteredSurahs {
    if (searchQuery.trim().isEmpty) return surahs;
    final normalizedQuery = searchQuery.normalizeForSearch();
    if (normalizedQuery.isEmpty) return surahs;

    return surahs.where((surah) {
      final normalizedName = surah.name.normalizeForSearch();
      final normalizedEnglishName = surah.englishName.normalizeForSearch();
      final normalizedTranslation = surah.englishNameTranslation.normalizeForSearch();
      final numberStr = surah.number.toString();

      return normalizedName.contains(normalizedQuery) ||
          normalizedEnglishName.contains(normalizedQuery) ||
          normalizedTranslation.contains(normalizedQuery) ||
          numberStr == normalizedQuery;
    }).toList();
  }
}
