import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../core/services/quran_navigation/domain/entities/ayah_target.dart';
import '../ayah_service.dart';
import '../states/quran_reader_state.dart';

final quranReaderControllerProvider =
    NotifierProvider<QuranReaderController, QuranReaderState>(
  QuranReaderController.new,
);

class QuranReaderController extends Notifier<QuranReaderState> {
  @override
  QuranReaderState build() {
    return const QuranReaderState();
  }

  Future<void> fetchAyahs(int surahId) async {
    state = state.copyWith(
      currentSurahId: surahId,
      isLoading: true,
      errorMessage: null,
    );

    final service = ref.read(ayahServiceProvider);
    final result = await service.getAyahsBySurah(surahId);

    result.when(
      (ayahs) {
        state = state.copyWith(isLoading: false, ayahs: ayahs);
      },
      (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        );
      },
    );
  }

  void retry() {
    fetchAyahs(state.currentSurahId);
  }
}

class ActiveAyahNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setActiveAyah(int? ayahNumber) {
    state = ayahNumber;
  }
}

final activeAyahProvider = NotifierProvider<ActiveAyahNotifier, int?>(
  ActiveAyahNotifier.new,
);

/// Represents the currently active reading Ayah (surahId, ayahNumber)
/// computed by the reader's info bar across both audio playing and manual scrolling.
class ReadingAyahInfo {
  final int surahId;
  final int ayahNumber;

  const ReadingAyahInfo({
    required this.surahId,
    required this.ayahNumber,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingAyahInfo &&
          runtimeType == other.runtimeType &&
          surahId == other.surahId &&
          ayahNumber == other.ayahNumber;

  @override
  int get hashCode => surahId.hashCode ^ ayahNumber.hashCode;

  @override
  String toString() => 'ReadingAyahInfo(surah: , ayah: )';
}

class CurrentReadingAyahNotifier extends Notifier<ReadingAyahInfo?> {
  @override
  ReadingAyahInfo? build() => null;

  void updateAyah(int surahId, int ayahNumber) {
    if (state?.surahId != surahId || state?.ayahNumber != ayahNumber) {
      state = ReadingAyahInfo(surahId: surahId, ayahNumber: ayahNumber);
    }
  }

  void clear() {
    state = null;
  }
}

final currentReadingAyahProvider =
    NotifierProvider<CurrentReadingAyahNotifier, ReadingAyahInfo?>(
  CurrentReadingAyahNotifier.new,
);

class NavigationTargetNotifier extends Notifier<AyahTarget?> {
  @override
  AyahTarget? build() => null;

  void setTarget(AyahTarget? target) {
    state = target;
  }

  void forceTarget(AyahTarget target) {
    state = null;
    state = target;
  }
}

final navigationTargetProvider =
    NotifierProvider<NavigationTargetNotifier, AyahTarget?>(
  NavigationTargetNotifier.new,
);

class ActiveItemPositionsListenerNotifier
    extends Notifier<ItemPositionsListener?> {
  @override
  ItemPositionsListener? build() => null;

  void setListener(ItemPositionsListener? listener) {
    state = listener;
  }

  void clearIfMatches(ItemPositionsListener listener) {
    try {
      if (state == listener) {
        Future.microtask(() {
          try {
            if (state == listener) {
              state = null;
            }
          } catch (_) {}
        });
      }
    } catch (_) {}
  }
}

final activeItemPositionsListenerProvider = NotifierProvider<
    ActiveItemPositionsListenerNotifier, ItemPositionsListener?>(
  ActiveItemPositionsListenerNotifier.new,
);

/// Manages full-screen mode & controls visibility state in QuranReaderScreen
class ReaderControlsState {
  final bool isFullScreen;
  final bool isControlsVisible;
  final bool isAudioBarCollapsed;

  const ReaderControlsState({
    this.isFullScreen = false,
    this.isControlsVisible = true,
    this.isAudioBarCollapsed = false,
  });

  bool get isControlsHidden => isFullScreen && !isControlsVisible;

  ReaderControlsState copyWith({
    bool? isFullScreen,
    bool? isControlsVisible,
    bool? isAudioBarCollapsed,
  }) {
    return ReaderControlsState(
      isFullScreen: isFullScreen ?? this.isFullScreen,
      isControlsVisible: isControlsVisible ?? this.isControlsVisible,
      isAudioBarCollapsed: isAudioBarCollapsed ?? this.isAudioBarCollapsed,
    );
  }
}

class ReaderControlsNotifier extends Notifier<ReaderControlsState> {
  @override
  ReaderControlsState build() => const ReaderControlsState();

  void updateState({
    bool? isFullScreen,
    bool? isControlsVisible,
    bool? isAudioBarCollapsed,
  }) {
    state = state.copyWith(
      isFullScreen: isFullScreen,
      isControlsVisible: isControlsVisible,
      isAudioBarCollapsed: isAudioBarCollapsed,
    );
  }

  void enterFullScreen() {
    // Full-screen mode temporarily commented out
    /*
    state = const ReaderControlsState(
      isFullScreen: true,
      isControlsVisible: false,
      isAudioBarCollapsed: true,
    );
    */
  }

  void exitFullScreen() {
    state = const ReaderControlsState(
      isFullScreen: false,
      isControlsVisible: true,
      isAudioBarCollapsed: false,
    );
  }

  void revealControls() {
    if (state.isFullScreen) {
      state = state.copyWith(
        isControlsVisible: true,
        isAudioBarCollapsed: false,
      );
    }
  }

  void toggleControls() {
    if (!state.isFullScreen) {
      return;
    }
    final nextVisible = !state.isControlsVisible;
    state = state.copyWith(
      isControlsVisible: nextVisible,
      isAudioBarCollapsed: !nextVisible,
    );
  }

  void toggleFullScreenOrControls() {
    // Full-screen mode temporarily commented out
    /*
    if (state.isFullScreen && !state.isControlsVisible) {
      exitFullScreen();
    } else {
      enterFullScreen();
    }
    */
  }

  void reset() {
    state = const ReaderControlsState();
  }
}

final readerControlsProvider =
    NotifierProvider.autoDispose<ReaderControlsNotifier, ReaderControlsState>(
  ReaderControlsNotifier.new,
);


