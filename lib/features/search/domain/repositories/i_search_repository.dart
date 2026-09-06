import '../entities/search_filter_type.dart';
import '../entities/search_result_item.dart';

abstract class ISearchRepository {
  /// Searches for matching surahs and ayahs based on the query and active filter
  Future<List<SearchResultItem>> search({
    required String query,
    SearchFilterType filter = SearchFilterType.all,
  });

  /// Retrieves list of past searches from local storage
  Future<List<String>> getRecentSearches();

  /// Saves a search query to the recent searches history
  Future<void> saveRecentSearch(String query);

  /// Deletes a specific query from recent history
  Future<void> removeRecentSearch(String query);

  /// Clears all recent search history
  Future<void> clearRecentSearches();
}
