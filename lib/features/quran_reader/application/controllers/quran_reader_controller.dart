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

