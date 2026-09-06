import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/local/hive/hive_service_provider.dart';
import '../../../../core/data/local/hive/i_hive_service.dart';
import '../../../../core/data/local/preferences/i_preferences_service.dart';
import '../../../../core/data/local/preferences/preferences_service_provider.dart';
import '../../domain/entities/bookmark_item.dart';

abstract class IBookmarkLocalDataSource {
  Future<void> saveBookmark(BookmarkItem bookmark);
  Future<void> removeBookmark(int surahId, int ayahNumber);
  bool isBookmarked(int surahId, int ayahNumber);
  List<BookmarkItem> getAllBookmarks();
  Future<void> clearAllBookmarks();
  Future<void> checkAndMigrateOldPreferencesBookmark();
}

class BookmarkLocalDataSource implements IBookmarkLocalDataSource {
  static const String boxName = 'bookmarks_box';
  static const String _legacyPrefsKey = 'manual_bookmark_state';

  final IHiveService _hiveService;
  final IPreferencesService _preferencesService;

  BookmarkLocalDataSource(this._hiveService, this._preferencesService);

  @override
  Future<void> saveBookmark(BookmarkItem bookmark) async {
    await _hiveService.put(
      bookmark.key,
      bookmark.toMap(),
      boxName: boxName,
    );
  }

  @override
  Future<void> removeBookmark(int surahId, int ayahNumber) async {
    await _hiveService.delete(
      '${surahId}_$ayahNumber',
      boxName: boxName,
    );
  }

  @override
  bool isBookmarked(int surahId, int ayahNumber) {
    return _hiveService.containsKey(
      '${surahId}_$ayahNumber',
      boxName: boxName,
    );
  }

  @override
  List<BookmarkItem> getAllBookmarks() {
    final values = _hiveService.getValues(boxName: boxName);
    final items = <BookmarkItem>[];

    for (final val in values) {
      if (val is Map) {
        try {
          items.add(BookmarkItem.fromMap(val));
        } catch (_) {}
      }
    }

    // Sort descending by creation timestamp (newest bookmark first)
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<void> clearAllBookmarks() async {
    await _hiveService.clear(boxName: boxName);
  }

  @override
  Future<void> checkAndMigrateOldPreferencesBookmark() async {
    try {
      final legacyJson = _preferencesService.getString(_legacyPrefsKey);
      if (legacyJson != null && legacyJson.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(legacyJson);
        final surahId = data['surahId'] as int? ?? 1;
        final ayahNumber = data['ayahNumber'] as int? ?? 1;

        // If not already in Hive, migrate it seamlessly
        if (!isBookmarked(surahId, ayahNumber)) {
          final migratedItem = BookmarkItem(
            surahId: surahId,
            surahName: data['surahName'] as String? ?? '',
            ayahNumber: ayahNumber,
            totalAyahs: data['totalAyahs'] as int? ?? 0,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          );
          await saveBookmark(migratedItem);
        }
        // Remove legacy key after successful migration
        await _preferencesService.remove(_legacyPrefsKey);
      }
    } catch (_) {
      // Ignored for safety
    }
  }
}

final bookmarkLocalDataSourceProvider = Provider<IBookmarkLocalDataSource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final prefs = ref.watch(preferencesServiceProvider);
  return BookmarkLocalDataSource(hiveService, prefs);
});
