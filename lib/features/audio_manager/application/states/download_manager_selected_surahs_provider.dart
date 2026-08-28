import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadManagerSelectedSurahsNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    return {};
  }

  void toggleSurah(int surahId) {
    if (state.contains(surahId)) {
      state = {...state}..remove(surahId);
    } else {
      state = {...state}..add(surahId);
    }
  }

  void setSurahs(Set<int> surahIds) {
    state = surahIds;
  }
}

final downloadManagerSelectedSurahsProvider = NotifierProvider.autoDispose<DownloadManagerSelectedSurahsNotifier, Set<int>>(
  DownloadManagerSelectedSurahsNotifier.new,
);
