import 'package:freezed_annotation/freezed_annotation.dart';
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
    final query = searchQuery.trim().toLowerCase();
    return surahs.where((surah) {
      return surah.name.toLowerCase().contains(query) ||
          surah.englishName.toLowerCase().contains(query) ||
          surah.englishNameTranslation.toLowerCase().contains(query) ||
          surah.number.toString() == query;
    }).toList();
  }
}
