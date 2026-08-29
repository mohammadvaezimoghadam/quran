import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/local/preferences/preferences_service_provider.dart';

/// Provider for managing the list of favorite/starred surah IDs using SharedPreferences.
final favoriteSurahsProvider =
    NotifierProvider<FavoriteSurahsNotifier, Set<int>>(() {
  return FavoriteSurahsNotifier();
});

class FavoriteSurahsNotifier extends Notifier<Set<int>> {
  static const String _key = 'favorite_surah_ids';

  @override
  Set<int> build() {
    final prefs = ref.watch(preferencesServiceProvider);
    final list = prefs.getStringList(_key);
    if (list != null) {
      return list
          .map((e) => int.tryParse(e))
          .whereType<int>()
          .toSet();
    }
    return {};
  }

  Future<void> toggleFavorite(int surahId) async {
    final updated = Set<int>.from(state);
    if (updated.contains(surahId)) {
      updated.remove(surahId);
    } else {
      updated.add(surahId);
    }
    state = updated;
    final prefs = ref.read(preferencesServiceProvider);
    await prefs.setStringList(
      _key,
      updated.map((e) => e.toString()).toList(),
    );
  }

  bool isFavorite(int surahId) => state.contains(surahId);
}
