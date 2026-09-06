import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/data/local/preferences/preferences_service_provider.dart';
import '../../domain/entities/search_filter_type.dart';
import '../../domain/entities/search_result_item.dart';
import '../../domain/repositories/i_search_repository.dart';
import '../datasources/search_local_datasource.dart';

final searchRepositoryProvider = Provider<ISearchRepository>((ref) {
  final dataSource = ref.watch(searchLocalDataSourceProvider);
  final prefs = ref.watch(sharedPreferencesInstanceProvider);
  return SearchRepositoryImpl(dataSource, prefs);
});

class SearchRepositoryImpl implements ISearchRepository {
  final ISearchLocalDataSource _dataSource;
  final SharedPreferences _prefs;

  static const String _recentSearchesKey = 'quran_recent_searches_list';
  static const int _maxRecentSearches = 15;

  SearchRepositoryImpl(this._dataSource, this._prefs);

  @override
  Future<List<SearchResultItem>> search({
    required String query,
    SearchFilterType filter = SearchFilterType.all,
  }) {
    return _dataSource.search(query: query, filter: filter);
  }

  @override
  Future<List<String>> getRecentSearches() async {
    return _prefs.getStringList(_recentSearchesKey) ?? [];
  }

  @override
  Future<void> saveRecentSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    final current = List<String>.from(await getRecentSearches());
    current.removeWhere((item) => item.trim().toLowerCase() == clean.toLowerCase());
    current.insert(0, clean);

    if (current.length > _maxRecentSearches) {
      current.removeRange(_maxRecentSearches, current.length);
    }

    await _prefs.setStringList(_recentSearchesKey, current);
  }

  @override
  Future<void> removeRecentSearch(String query) async {
    final current = List<String>.from(await getRecentSearches());
    current.removeWhere((item) => item.trim().toLowerCase() == query.trim().toLowerCase());
    await _prefs.setStringList(_recentSearchesKey, current);
  }

  @override
  Future<void> clearRecentSearches() async {
    await _prefs.remove(_recentSearchesKey);
  }
}
