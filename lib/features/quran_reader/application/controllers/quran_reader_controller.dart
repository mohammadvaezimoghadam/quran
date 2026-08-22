import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ayah_service.dart';
import '../states/quran_reader_state.dart';

final quranReaderControllerProvider =
    NotifierProvider<QuranReaderController, QuranReaderState>(
  QuranReaderController.new,
);

class QuranReaderController extends Notifier<QuranReaderState> {
  int? _currentSurahId;

  @override
  QuranReaderState build() {
    return const QuranReaderState();
  }

  Future<void> fetchAyahs(int surahId) async {
    _currentSurahId = surahId;
    state = state.copyWith(isLoading: true, errorMessage: null);

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
    if (_currentSurahId != null) {
      fetchAyahs(_currentSurahId!);
    }
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

