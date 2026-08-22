import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/audio/audio_player_state.dart';
import '../../../quran_reader/application/controllers/quran_audio_controller.dart';
import '../states/mini_audio_player_state.dart';

final miniAudioPlayerControllerProvider =
    NotifierProvider<MiniAudioPlayerController, MiniAudioPlayerState>(() {
  return MiniAudioPlayerController();
});

class MiniAudioPlayerController extends Notifier<MiniAudioPlayerState> {
  @override
  MiniAudioPlayerState build() {
    // Automatically reset dismissal when a new surah starts or audio session restarts
    ref.listen(quranAudioControllerProvider, (previous, next) {
      if (previous?.currentSurahId != next.currentSurahId ||
          (previous?.status == AudioStatus.stopped && next.status != AudioStatus.stopped)) {
        state = state.copyWith(isDismissed: false);
      }
    });

    return const MiniAudioPlayerState();
  }

  /// Dismiss the floating mini player pill until new audio session starts
  void dismiss() {
    state = state.copyWith(isDismissed: true);
  }

  /// Re-enable visibility of the floating mini player
  void show() {
    state = state.copyWith(isDismissed: false);
  }
}
