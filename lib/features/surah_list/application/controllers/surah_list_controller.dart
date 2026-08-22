import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}
