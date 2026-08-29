import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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

class ActiveItemPositionsListenerNotifier
    extends Notifier<ItemPositionsListener?> {
  @override
  ItemPositionsListener? build() => null;

  void setListener(ItemPositionsListener? listener) {
    state = listener;
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

  void revealControls() {
    if (state.isFullScreen) {
      state = state.copyWith(
        isControlsVisible: true,
        isAudioBarCollapsed: false,
      );
    }
  }

  void toggleControls() {
    if (state.isFullScreen) {
      final nextVisible = !state.isControlsVisible;
      state = state.copyWith(
        isControlsVisible: nextVisible,
        isAudioBarCollapsed: !nextVisible,
      );
    }
  }
}

final readerControlsProvider =
    NotifierProvider<ReaderControlsNotifier, ReaderControlsState>(
  ReaderControlsNotifier.new,
);


