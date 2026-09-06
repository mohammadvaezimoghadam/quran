import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/i_search_repository.dart';
import '../../infrastructure/repositories/search_repository_impl.dart';

final recentSearchesProvider =
    NotifierProvider<RecentSearchesController, List<String>>(
  RecentSearchesController.new,
);

class RecentSearchesController extends Notifier<List<String>> {
  late final ISearchRepository _repository;

  @override
  List<String> build() {
    _repository = ref.watch(searchRepositoryProvider);
    _loadRecentSearches();
    return const [];
  }

  Future<void> _loadRecentSearches() async {
    final list = await _repository.getRecentSearches();
    state = list;
  }

  Future<void> addSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;
    await _repository.saveRecentSearch(clean);
    await _loadRecentSearches();
  }

  Future<void> removeSearch(String query) async {
    await _repository.removeRecentSearch(query);
    await _loadRecentSearches();
  }

  Future<void> clearAll() async {
    await _repository.clearRecentSearches();
    state = const [];
  }
}
