import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home_service.dart';
import '../states/ayah_of_the_day_state.dart';

/// Provider for AyahOfTheDay controller
final ayahOfTheDayControllerProvider =
    NotifierProvider<AyahOfTheDayNotifier, AyahOfTheDayState>(
  AyahOfTheDayNotifier.new,
);

/// Controller managing the state and actions of the Ayah of the Day widget
class AyahOfTheDayNotifier extends Notifier<AyahOfTheDayState> {
  @override
  AyahOfTheDayState build() {
    // Automatically trigger initial fetch after initial build completes safely
    Future.microtask(() => fetchAyahOfTheDay());
    return const AyahOfTheDayState();
  }

  /// Fetches Ayah of the Day from the application service
  Future<void> fetchAyahOfTheDay() async {
    if (!state.isLoading) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    final homeService = ref.read(homeServiceProvider);
    final result = await homeService.getAyahOfTheDay();

    result.when(
      (ayah) {
        state = state.copyWith(
          isLoading: false,
          ayah: ayah,
          errorMessage: null,
        );
      },
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Toggles audio playback state
  void toggleAudioPlayback() {
    state = state.copyWith(isPlayingAudio: !state.isPlayingAudio);
  }
}
