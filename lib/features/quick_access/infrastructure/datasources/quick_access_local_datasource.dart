import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/data/local/preferences/preferences_service_provider.dart';

const String _prefQuickAccessSlotsKey = 'pref_quick_access_slots_v1';
const String _prefPinnedSurahIdKey = 'pref_pinned_surah_id_v1';

final quickAccessLocalDataSourceProvider =
    Provider<IQuickAccessLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesInstanceProvider);
  return QuickAccessLocalDataSourceImpl(prefs);
});

abstract class IQuickAccessLocalDataSource {
  List<String?> getSavedSlotIds();
  Future<void> saveSlotIds(List<String?> slotIds);
  int? getPinnedSurahId();
  Future<void> savePinnedSurahId(int? surahId);
}

class QuickAccessLocalDataSourceImpl implements IQuickAccessLocalDataSource {
  final SharedPreferences _prefs;

  // Smart defaults: downloads, last_read, bookmarks, and an empty slot (+)
  static const List<String?> defaultSlots = [
    'downloads',
    'last_read',
    'bookmarks',
    null,
  ];

  QuickAccessLocalDataSourceImpl(this._prefs);

  @override
  List<String?> getSavedSlotIds() {
    final rawList = _prefs.getStringList(_prefQuickAccessSlotsKey);
    if (rawList == null || rawList.length != 4) {
      return List<String?>.from(defaultSlots);
    }
    return rawList.map((e) => e == '__EMPTY__' ? null : e).toList();
  }

  @override
  Future<void> saveSlotIds(List<String?> slotIds) async {
    final listToSave = slotIds.map((e) => e ?? '__EMPTY__').toList();
    await _prefs.setStringList(_prefQuickAccessSlotsKey, listToSave);
  }

  @override
  int? getPinnedSurahId() {
    final id = _prefs.getInt(_prefPinnedSurahIdKey);
    return (id != null && id >= 1 && id <= 114) ? id : null;
  }

  @override
  Future<void> savePinnedSurahId(int? surahId) async {
    if (surahId == null) {
      await _prefs.remove(_prefPinnedSurahIdKey);
    } else {
      await _prefs.setInt(_prefPinnedSurahIdKey, surahId);
    }
  }
}

