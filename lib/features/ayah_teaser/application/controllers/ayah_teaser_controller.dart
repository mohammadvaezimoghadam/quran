import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/local/preferences/preferences_keys.dart';
import '../../../../core/data/local/preferences/preferences_service_provider.dart';
import '../../../../features/quran_reader/application/controllers/quran_reader_controller.dart';
import '../../domain/entities/ayah_teaser_item.dart';
import '../../domain/entities/surah_teasers_result.dart';
import '../../infrastructure/repositories/ayah_teaser_repository_impl.dart';

@immutable
class AyahTeaserState {
  final int? currentSurahId;
  final int? activeAyahNumber;
  final SurahTeasersResult? surahTeasers;
  final AyahTeaserItem? activeTeaser;
  final bool isVisible;
  final bool isLoading;
  final bool isEnabled;
  final Set<int> dismissedAyahs;

  const AyahTeaserState({
    this.currentSurahId,
    this.activeAyahNumber,
    this.surahTeasers,
    this.activeTeaser,
    this.isVisible = false,
    this.isLoading = false,
    this.isEnabled = true,
    this.dismissedAyahs = const {},
  });

  AyahTeaserState copyWith({
    int? currentSurahId,
    int? activeAyahNumber,
    SurahTeasersResult? surahTeasers,
    AyahTeaserItem? activeTeaser,
    bool clearActiveTeaser = false,
    bool? isVisible,
    bool? isLoading,
    bool? isEnabled,
    Set<int>? dismissedAyahs,
  }) {
    return AyahTeaserState(
      currentSurahId: currentSurahId ?? this.currentSurahId,
      activeAyahNumber: activeAyahNumber ?? this.activeAyahNumber,
      surahTeasers: surahTeasers ?? this.surahTeasers,
      activeTeaser: clearActiveTeaser ? null : (activeTeaser ?? this.activeTeaser),
      isVisible: isVisible ?? this.isVisible,
      isLoading: isLoading ?? this.isLoading,
      isEnabled: isEnabled ?? this.isEnabled,
      dismissedAyahs: dismissedAyahs ?? this.dismissedAyahs,
    );
  }
}

class AyahTeaserController extends Notifier<AyahTeaserState> {
  Timer? _debounceTimer;
  Timer? _autoDismissTimer;

  static const Duration autoDismissDuration = Duration(seconds: 5);

  @override
  AyahTeaserState build() {
    bool isEnabled = true;
    try {
      final prefs = ref.watch(preferencesServiceProvider);
      isEnabled = prefs.getBool(PreferencesKeys.ayahTeaserEnabled) ?? true;
    } catch (_) {
      isEnabled = true;
    }

    // Listen to changes in reading position from the reader's top info bar
    ref.listen<ReadingAyahInfo?>(currentReadingAyahProvider, (prev, next) {
      if (next != null) {
        onReadingPositionChanged(next.surahId, next.ayahNumber);
      } else {
        _debounceTimer?.cancel();
        _autoDismissTimer?.cancel();
        state = state.copyWith(isVisible: false, clearActiveTeaser: true);
      }
    });

    ref.onDispose(() {
      _debounceTimer?.cancel();
      _autoDismissTimer?.cancel();
    });

    // Check if initial reading position is already set when controller initializes
    final initialPos = ref.read(currentReadingAyahProvider);
    if (initialPos != null && isEnabled) {
      Future.microtask(() {
        onReadingPositionChanged(initialPos.surahId, initialPos.ayahNumber);
      });
    }

    return AyahTeaserState(isEnabled: isEnabled);
  }

  /// Toggle whether Ayah teaser notifications are enabled or muted.
  /// Persists the setting in local preferences.
  Future<void> toggleEnabled([bool? enable]) async {
    final target = enable ?? !state.isEnabled;
    if (state.isEnabled == target) return;

    try {
      final prefs = ref.read(preferencesServiceProvider);
      await prefs.setBool(PreferencesKeys.ayahTeaserEnabled, target);
    } catch (_) {}

    if (!target) {
      _debounceTimer?.cancel();
      _autoDismissTimer?.cancel();
      state = state.copyWith(
        isEnabled: false,
        isVisible: false,
        clearActiveTeaser: true,
      );
    } else {
      state = state.copyWith(isEnabled: true);
      // Immediately evaluate for current position if available
      final curAyah = state.activeAyahNumber ?? ref.read(currentReadingAyahProvider)?.ayahNumber;
      final curSurah = state.currentSurahId ?? ref.read(currentReadingAyahProvider)?.surahId;
      if (curSurah != null && curAyah != null) {
        if (state.surahTeasers == null) {
          await _loadSurahTeasers(curSurah);
        }
        _debounceTimer?.cancel();
        _autoDismissTimer?.cancel();
        _evaluateAyahTeaser(curSurah, curAyah);
      }
    }
  }

  /// Called whenever user changes Surah or scrolls/listens to a specific Ayah.
  Future<void> onReadingPositionChanged(int surahId, int ayahNumber) async {
    debugPrint('[AyahTeaser] onReadingPositionChanged: surah $surahId, ayah $ayahNumber');

    if (!state.isEnabled) {
      _debounceTimer?.cancel();
      _autoDismissTimer?.cancel();
      state = state.copyWith(
        currentSurahId: surahId,
        activeAyahNumber: ayahNumber,
        isVisible: false,
        clearActiveTeaser: true,
      );
      return;
    }

    final ayahChanged = state.activeAyahNumber != ayahNumber || state.currentSurahId != surahId;

    // When moving away to a different Ayah, hide previous card immediately so it animates out
    if (ayahChanged && state.isVisible) {
      _autoDismissTimer?.cancel();
      state = state.copyWith(isVisible: false);
    }

    // 1. If Surah changed, fetch new Surah teasers and reset dismissed list
    if (state.currentSurahId != surahId || state.surahTeasers == null) {
      _debounceTimer?.cancel();
      _autoDismissTimer?.cancel();
      state = state.copyWith(
        currentSurahId: surahId,
        activeAyahNumber: ayahNumber,
        surahTeasers: state.currentSurahId == surahId ? state.surahTeasers : null,
        clearActiveTeaser: true,
        isVisible: false,
        dismissedAyahs: state.currentSurahId == surahId ? state.dismissedAyahs : {},
      );
      await _loadSurahTeasers(surahId);
    } else {
      state = state.copyWith(
        activeAyahNumber: ayahNumber,
      );
    }

    // 2. Cancel previous timers
    _debounceTimer?.cancel();
    _autoDismissTimer?.cancel();

    // If user explicitly dismissed teaser for this Ayah, skip
    if (state.currentSurahId == surahId && state.dismissedAyahs.contains(ayahNumber)) {
      if (state.isVisible) {
        state = state.copyWith(isVisible: false);
      }
      return;
    }

    // 3. Start 1-second debounce timer
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      _evaluateAyahTeaser(surahId, ayahNumber);
    });
  }

  Future<void> _loadSurahTeasers(int surahId, {bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, currentSurahId: surahId);
    final repo = ref.read(ayahTeaserRepositoryProvider);
    final result = await repo.getSurahLatestPosts(surahNumber: surahId, forceRefresh: forceRefresh);

    result.when(
      (teasers) {
        debugPrint('[AyahTeaser] Loaded ${teasers.items.length} teasers for Surah $surahId');
        if (!state.isEnabled) {
          state = state.copyWith(
            currentSurahId: surahId,
            surahTeasers: teasers,
            isLoading: false,
            isVisible: false,
            clearActiveTeaser: true,
          );
          return;
        }
        state = state.copyWith(
          currentSurahId: surahId,
          surahTeasers: teasers,
          isLoading: false,
        );
      },
      (error) {
        debugPrint('[AyahTeaser] Failed to load teasers for Surah $surahId: ${error.message}');
        state = state.copyWith(
          currentSurahId: surahId,
          surahTeasers: SurahTeasersResult.empty,
          isLoading: false,
        );
      },
    );
  }

  void _evaluateAyahTeaser(int surahId, int ayahNumber) {
    if (!state.isEnabled) {
      if (state.isVisible || state.activeTeaser != null) {
        state = state.copyWith(
          isVisible: false,
          clearActiveTeaser: true,
        );
      }
      return;
    }
    if (state.currentSurahId != null && state.currentSurahId != surahId) {
      return;
    }
    if (state.activeAyahNumber != null && state.activeAyahNumber != ayahNumber) {
      return;
    }

    _autoDismissTimer?.cancel();

    final teasers = state.surahTeasers;
    if (teasers != null && teasers.hasTeaserForAyah(ayahNumber)) {
      final item = teasers.getForAyah(ayahNumber);
      if (item != null) {
        debugPrint('[AyahTeaser] Showing teaser for Surah $surahId Ayah $ayahNumber (postId: ${item.postId})');
        state = state.copyWith(
          currentSurahId: surahId,
          activeAyahNumber: ayahNumber,
          activeTeaser: item,
          isVisible: true,
        );

        // Auto-dismiss after 5 seconds if user stays on this Ayah without moving
        _autoDismissTimer = Timer(autoDismissDuration, () {
          if (state.currentSurahId == surahId &&
              state.activeAyahNumber == ayahNumber &&
              state.isVisible) {
            debugPrint('[AyahTeaser] Auto-dismissing teaser for Ayah $ayahNumber after ${autoDismissDuration.inSeconds}s timeout');
            state = state.copyWith(isVisible: false);
          }
        });
        return;
      }
    }

    debugPrint('[AyahTeaser] No teaser for Surah $surahId Ayah $ayahNumber');
    state = state.copyWith(
      currentSurahId: surahId,
      activeAyahNumber: ayahNumber,
      clearActiveTeaser: true,
      isVisible: false,
    );
  }

  /// Dismiss the current teaser card (e.g. user closed it or tapped away)
  void dismiss() {
    _autoDismissTimer?.cancel();
    final curAyah = state.activeAyahNumber;
    final updatedDismissed = Set<int>.from(state.dismissedAyahs);
    if (curAyah != null) {
      updatedDismissed.add(curAyah);
    }
    state = state.copyWith(
      isVisible: false,
      dismissedAyahs: updatedDismissed,
    );
  }

  /// Reset controller state when exiting QuranReaderScreen
  void reset() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    final currentEnabled = state.isEnabled;
    if (state.isVisible || state.activeTeaser != null || state.currentSurahId != null) {
      Future.microtask(() {
        state = AyahTeaserState(isEnabled: currentEnabled);
      });
    }
  }

  /// Explicitly pre-load teasers for a Surah (defaults to fresh fetch when opening a Surah)
  Future<void> prefetchSurah(int surahId, {bool forceRefresh = true}) async {
    if (!state.isEnabled) return;
    debugPrint('[AyahTeaser] prefetchSurah $surahId called (forceRefresh: $forceRefresh)');
    if (forceRefresh || state.currentSurahId != surahId || state.surahTeasers == null) {
      await _loadSurahTeasers(surahId, forceRefresh: forceRefresh);
    }
    final currentAyah = state.activeAyahNumber ?? ref.read(currentReadingAyahProvider)?.ayahNumber;
    if (currentAyah != null && !state.isVisible) {
      _debounceTimer?.cancel();
      _autoDismissTimer?.cancel();
      _debounceTimer = Timer(const Duration(seconds: 1), () {
        _evaluateAyahTeaser(surahId, currentAyah);
      });
    }
  }
}

final ayahTeaserControllerProvider =
    NotifierProvider<AyahTeaserController, AyahTeaserState>(
  AyahTeaserController.new,
);

