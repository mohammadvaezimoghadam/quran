import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/local/preferences/preferences_service_provider.dart';
import '../../../bookmarks/application/controllers/bookmarks_controller.dart';
import '../states/continue_reading_state.dart';

final continueReadingControllerProvider =
    NotifierProvider<ContinueReadingController, ContinueReadingState?>(
  ContinueReadingController.new,
);

class ContinueReadingController extends Notifier<ContinueReadingState?> {
  static const _prefsKey = 'continue_reading_state';

  @override
  ContinueReadingState? build() {
    _loadState();
    return state;
  }

  void _loadState() {
    final prefs = ref.read(preferencesServiceProvider);
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        state = ContinueReadingState.fromJson(json);
      } catch (e) {
        // Fallback gracefully on parsing error
        state = null;
      }
    } else {
      state = null;
    }
  }

  void updateStateInMemory({
    required int surahId,
    required String surahName,
    required int ayahNumber,
    required int totalAyahs,
  }) {
    state = ContinueReadingState(
      surahId: surahId,
      surahName: surahName,
      ayahNumber: ayahNumber,
      totalAyahs: totalAyahs,
    );
  }

  Future<void> saveStateToStorage() async {
    if (state != null) {
      final prefs = ref.read(preferencesServiceProvider);
      final jsonString = jsonEncode(state!.toJson());
      await prefs.setString(_prefsKey, jsonString);
    }
  }

  Future<void> clearState() async {
    final prefs = ref.read(preferencesServiceProvider);
    await prefs.remove(_prefsKey);
    state = null;
  }
}

final manualBookmarkControllerProvider =
    NotifierProvider<ManualBookmarkController, ContinueReadingState?>(
  ManualBookmarkController.new,
);

class ManualBookmarkController extends Notifier<ContinueReadingState?> {
  @override
  ContinueReadingState? build() {
    final bookmarks = ref.watch(bookmarksControllerProvider);
    if (bookmarks.isEmpty) return null;
    return bookmarks.first.toContinueReadingState();
  }

  Future<void> saveBookmark(ContinueReadingState bookmarkState) async {
    await ref.read(bookmarksControllerProvider.notifier).toggleBookmark(
          surahId: bookmarkState.surahId,
          surahName: bookmarkState.surahName,
          ayahNumber: bookmarkState.ayahNumber,
          totalAyahs: bookmarkState.totalAyahs,
        );
  }

  Future<void> clearBookmark() async {
    await ref.read(bookmarksControllerProvider.notifier).clearAll();
  }
}
