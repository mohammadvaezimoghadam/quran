import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/enums/surah_sort_options.dart';
import '../states/surah_list_state.dart';
import '../surah_service.dart';

final surahListControllerProvider = NotifierProvider<SurahListController, SurahListState>(() {
  return SurahListController();
});

class SurahListController extends Notifier<SurahListState> {
  @override
  SurahListState build() {
    // Start fetching data as soon as the controller is created
    Future.microtask(() => _fetchSurahs());
    return const SurahListState();
  }

  Future<void> _fetchSurahs() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final service = ref.read(surahServiceProvider);
    final result = await service.getSurahs();

    result.when(
      (surahs) {
        state = state.copyWith(isLoading: false, surahs: surahs);
      },
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  /// Search action to filter surahs list in application state
  void searchSurahs(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Toggles filtering only favorite/starred surahs
  void toggleOnlyFavorites() {
    state = state.copyWith(isOnlyFavorites: !state.isOnlyFavorites);
  }

  void setOnlyFavorites(bool value) {
    state = state.copyWith(isOnlyFavorites: value);
  }

  /// Sets the sort criterion
  void setSortBy(SurahSortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  /// Sets the sort order (ascending / descending)
  void setSortOrder(SortOrder sortOrder) {
    state = state.copyWith(sortOrder: sortOrder);
  }
}
