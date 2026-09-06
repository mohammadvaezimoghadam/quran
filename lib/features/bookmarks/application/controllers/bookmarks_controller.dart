import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/bookmark_item.dart';
import '../../infrastructure/datasources/bookmark_local_datasource.dart';

final bookmarksControllerProvider =
    NotifierProvider<BookmarksController, List<BookmarkItem>>(
  BookmarksController.new,
);

class BookmarksController extends Notifier<List<BookmarkItem>> {
  late final IBookmarkLocalDataSource _dataSource;

  @override
  List<BookmarkItem> build() {
    _dataSource = ref.watch(bookmarkLocalDataSourceProvider);
    _initAndMigrate();
    return _dataSource.getAllBookmarks();
  }

  Future<void> _initAndMigrate() async {
    await _dataSource.checkAndMigrateOldPreferencesBookmark();
    final reloaded = _dataSource.getAllBookmarks();
    if (reloaded.length != state.length) {
      state = reloaded;
    }
  }

  /// Toggles the bookmark for the specified Ayah.
  /// Returns `true` if newly added, `false` if removed.
  Future<bool> toggleBookmark({
    required int surahId,
    required String surahName,
    required int ayahNumber,
    required int totalAyahs,
    String? arabicText,
    bool isAyahBookmark = false,
  }) async {
    final existingIndex = state.indexWhere(
      (b) => b.surahId == surahId && b.ayahNumber == ayahNumber,
    );

    if (existingIndex != -1) {
      // Remove bookmark
      await _dataSource.removeBookmark(surahId, ayahNumber);
      state = [
        ...state.sublist(0, existingIndex),
        ...state.sublist(existingIndex + 1),
      ];
      return false;
    } else {
      // Add new bookmark at the front (newest first)
      final newItem = BookmarkItem(
        surahId: surahId,
        surahName: surahName,
        ayahNumber: ayahNumber,
        totalAyahs: totalAyahs,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        arabicText: arabicText,
        isAyahBookmark: isAyahBookmark,
      );

      await _dataSource.saveBookmark(newItem);
      state = [newItem, ...state];
      return true;
    }
  }

  /// Removes a single bookmark by surah ID and ayah number.
  Future<void> removeBookmark(int surahId, int ayahNumber) async {
    await _dataSource.removeBookmark(surahId, ayahNumber);
    state = state
        .where((b) => !(b.surahId == surahId && b.ayahNumber == ayahNumber))
        .toList();
  }

  /// Clears all bookmarks from Hive and memory.
  Future<void> clearAll() async {
    await _dataSource.clearAllBookmarks();
    state = const [];
  }

  /// Checks if a specific Ayah is currently bookmarked.
  bool isAyahBookmarked(int surahId, int ayahNumber) {
    return state.any((b) => b.surahId == surahId && b.ayahNumber == ayahNumber);
  }
}
