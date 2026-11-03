import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran/core/data/local/preferences/preferences_service_provider.dart';

import '../domain/walkthrough_target_id.dart';

final walkthroughControllerProvider =
    NotifierProvider<WalkthroughController, Map<WalkthroughTourKey, bool>>(
  WalkthroughController.new,
);

class WalkthroughController extends Notifier<Map<WalkthroughTourKey, bool>> {
  late SharedPreferences _prefs;

  @override
  Map<WalkthroughTourKey, bool> build() {
    _prefs = ref.watch(sharedPreferencesInstanceProvider);
    final map = <WalkthroughTourKey, bool>{};
    for (final key in WalkthroughTourKey.values) {
      map[key] = _prefs.getBool(key.storageKey) ?? false;
    }
    return map;
  }

  /// Returns whether the specified walkthrough tour has already been seen or skipped.
  bool hasSeenTour(WalkthroughTourKey key) {
    return _prefs.getBool(key.storageKey) ?? state[key] ?? false;
  }

  /// Marks the walkthrough tour as completed so it will not show automatically again.
  Future<void> markCompleted(WalkthroughTourKey key) async {
    state = {...state, key: true};
    await _prefs.setBool(key.storageKey, true);
  }

  /// Resets all walkthrough tours so the user can re-trigger them from Settings.
  Future<void> resetAll() async {
    for (final key in WalkthroughTourKey.values) {
      await _prefs.remove(key.storageKey);
    }
    state = {
      for (final key in WalkthroughTourKey.values) key: false,
    };
  }
}

