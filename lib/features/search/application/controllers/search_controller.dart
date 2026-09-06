import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/search_filter_type.dart';
import '../../domain/repositories/i_search_repository.dart';
import '../../infrastructure/repositories/search_repository_impl.dart';
import '../states/search_state.dart';
import 'recent_searches_controller.dart';

final searchControllerProvider =
    NotifierProvider.autoDispose<QuranSearchController, SearchState>(
  QuranSearchController.new,
);

class QuranSearchController extends Notifier<SearchState> {
  late final ISearchRepository _repository;
  Timer? _debounceSearchTimer;
  Timer? _historySaveTimer;

  // Search debounce delay: wait until user pauses typing
  static const Duration _searchDebounce = Duration(milliseconds: 400);

  // History save delay: wait 2.5 seconds of inactivity before committing to history
  static const Duration _historyDebounce = Duration(milliseconds: 2500);

  @override
  SearchState build() {
    _repository = ref.watch(searchRepositoryProvider);

    ref.onDispose(() {
      _debounceSearchTimer?.cancel();
      _historySaveTimer?.cancel();
    });

    return const SearchState();
  }

  void setFilter(SearchFilterType filter) {
    if (state.activeFilter == filter) return;
    state = state.copyWith(activeFilter: filter);
  }

  void onQueryChanged(String query) {
    final trimmed = query.trim();

    // Cancel pending history save on every keystroke
    _historySaveTimer?.cancel();

    if (trimmed.isEmpty) {
      _debounceSearchTimer?.cancel();
      state = state.copyWith(
        query: query,
        results: const [],
        isLoading: false,
        errorMessage: null,
      );
      return;
    }

    state = state.copyWith(query: query, isLoading: true);

    // 1. Debounce Search Execution
    _debounceSearchTimer?.cancel();
    _debounceSearchTimer = Timer(_searchDebounce, () {
      _executeSearch(query);
    });

    // 2. Debounce History Save (wait 2.5 seconds to see if user has finished their sentence)
    if (trimmed.length >= 2) {
      _historySaveTimer = Timer(_historyDebounce, () {
        _commitCurrentQueryToHistory();
      });
    }
  }

  /// Manually commit query to history (e.g. when user presses Enter or taps a result)
  void commitQueryToHistoryNow() {
    _historySaveTimer?.cancel();
    _commitCurrentQueryToHistory();
  }

  void _commitCurrentQueryToHistory() {
    final clean = state.query.trim();
    if (clean.length >= 2 && state.hasResults) {
      ref.read(recentSearchesProvider.notifier).addSearch(clean);
    }
  }

  Future<void> searchImmediate(String query) async {
    _debounceSearchTimer?.cancel();
    _historySaveTimer?.cancel();
    state = state.copyWith(query: query, isLoading: true);
    await _executeSearch(query);
    _commitCurrentQueryToHistory();
  }

  Future<void> _executeSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      state = state.copyWith(results: const [], isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final results = await _repository.search(query: clean, filter: SearchFilterType.all);
      state = state.copyWith(
        results: results,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'خطا در انجام جستجو: $e',
      );
    }
  }

  void clearSearch() {
    _debounceSearchTimer?.cancel();
    _historySaveTimer?.cancel();
    state = const SearchState();
  }
}
