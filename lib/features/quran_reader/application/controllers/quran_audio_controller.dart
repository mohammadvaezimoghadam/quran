import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/audio/audio_error_parser.dart';
import '../../../../core/services/audio/audio_player_providers.dart';
import '../../../../core/services/audio/audio_player_state.dart';
import '../../../../core/services/audio/audio_url_helper.dart';
import '../../domain/entities/reciter_entity.dart';
import '../../infrastructure/repositories/reciter_repository.dart';
import '../states/quran_audio_state.dart';
import 'quran_reader_controller.dart';

final quranAudioControllerProvider =
    NotifierProvider<QuranAudioController, QuranAudioState>(
  QuranAudioController.new,
);

class QuranAudioController extends Notifier<QuranAudioState> {
  StreamSubscription<AudioPlayerState>? _audioStateSubscription;
  bool _isTransitioningTrack = false;

  @override
  QuranAudioState build() {
    _initDefaultReciterAndListeners();
    ref.onDispose(() {
      _audioStateSubscription?.cancel();
    });
    return const QuranAudioState();
  }

  Future<void> _initDefaultReciterAndListeners() async {
    // 1. Fetch default reciter (Parhizgar by default)
    final repo = ref.read(reciterRepositoryProvider);
    final result = await repo.getAllReciters();
    result.when(
      (reciters) {
        if (reciters.isNotEmpty && state.selectedReciter == null) {
          final defaultReciter = reciters.firstWhere(
            (r) => r.identifier.contains('parhizgar'),
            orElse: () => reciters.first,
          );
          state = state.copyWith(selectedReciter: defaultReciter);
        }
      },
      (error) {},
    );

    // 2. Listen to core AudioPlayerService state changes
    final audioService = ref.read(audioPlayerServiceProvider);
    _audioStateSubscription = audioService.stateStream.listen((playerState) {
      // Do NOT trigger continuous auto-play if stream is in error state!
      if (playerState.status == AudioStatus.error) {
        _isTransitioningTrack = false;
        state = state.copyWith(
          status: AudioStatus.error,
          errorMessage: playerState.errorMessage ?? 'خطا در پخش صوت',
        );
        return;
      }

      state = state.copyWith(
        status: playerState.status,
        position: playerState.position,
        duration: playerState.duration,
        errorMessage: playerState.errorMessage,
      );

      if (playerState.status == AudioStatus.playing &&
          state.currentAyahNumber != null) {
        ref
            .read(activeAyahProvider.notifier)
            .setActiveAyah(state.currentAyahNumber);
      }

      // Handle continuous playback when current ayah finishes cleanly!
      if (playerState.status == AudioStatus.completed) {
        if (state.isAutoPlayNext &&
            !state.isSingleAyahMode &&
            state.currentAyahNumber != null &&
            !_isTransitioningTrack) {
          _isTransitioningTrack = true;
          _playNextAyah();
        }
      } else if (playerState.status == AudioStatus.playing) {
        // Only reset when the NEW track is confirmed playing — prevents
        // late-arriving codec events from triggering duplicate _playNextAyah().
        _isTransitioningTrack = false;
      } else if (playerState.status == AudioStatus.stopped) {
        _isTransitioningTrack = false;
      }
    });
  }

  /// Select reciter safely without stream interruption crashes
  Future<void> selectReciter(ReciterEntity reciter) async {
    final wasPlaying = state.status == AudioStatus.playing;
    state = state.copyWith(selectedReciter: reciter);

    // Cleanly stop any existing stream
    final audioService = ref.read(audioPlayerServiceProvider);
    await audioService.stop();

    // If previously playing, restart current ayah with new reciter voice
    if (wasPlaying && state.currentSurahId != null && state.currentAyahNumber != null) {
      await playAyah(
        surahId: state.currentSurahId!,
        ayahNumber: state.currentAyahNumber!,
        totalAyahsInSurah: state.totalAyahsInSurah ?? 286,
        isSingleAyahMode: state.isSingleAyahMode,
      );
    }
  }

  /// Play a specific Ayah of a Surah
  Future<void> playAyah({
    required int surahId,
    required int ayahNumber,
    required int totalAyahsInSurah,
    bool isSingleAyahMode = false,
  }) async {
    _isTransitioningTrack = true;

    var reciter = state.selectedReciter;

    // Fallback if reciter is not yet loaded
    if (reciter == null) {
      final repo = ref.read(reciterRepositoryProvider);
      final result = await repo.getAllReciters();
      result.when(
        (reciters) {
          if (reciters.isNotEmpty) {
            reciter = reciters.firstWhere(
              (r) => r.identifier.contains('parhizgar'),
              orElse: () => reciters.first,
            );
          }
        },
        (error) {},
      );
    }

    // Default hardcoded Parhizgar fallback so play button NEVER fails on initial load
    final activeReciter = reciter ??
        const ReciterEntity(
          id: 1,
          name: 'شهریار پرهیزگار',
          englishName: 'Parhizgar',
          arabicName: 'شهريار پرهيزگار',
          subfolder: 'Parhizgar_48kbps',
          bitrate: '48kbps',
          identifier: 'ar.parhizgar',
          styleId: 1,
          styleName: 'مرتل',
        );

    state = state.copyWith(
      selectedReciter: activeReciter,
      currentSurahId: surahId,
      currentAyahNumber: ayahNumber,
      totalAyahsInSurah: totalAyahsInSurah,
      isSingleAyahMode: isSingleAyahMode,
    );

    // Set UI active highlight
    ref.read(activeAyahProvider.notifier).setActiveAyah(ayahNumber);

    // Build URL and play
    final url = AudioUrlHelper.buildAyahUrl(
      subfolder: activeReciter.subfolder,
      surahNumber: surahId,
      ayahNumber: ayahNumber,
    );

    try {
      final audioService = ref.read(audioPlayerServiceProvider);
      await audioService.play(url);
    } catch (e) {
      _isTransitioningTrack = false;
      state = state.copyWith(
        status: AudioStatus.error,
        errorMessage: AudioErrorParser.parseError(e),
      );
    }
  }

  /// Play next ayah automatically
  void _playNextAyah() {
    final currentAyah = state.currentAyahNumber;
    final totalAyahs = state.totalAyahsInSurah;
    final surahId = state.currentSurahId;

    if (currentAyah != null && totalAyahs != null && surahId != null) {
      if (currentAyah < totalAyahs) {
        playAyah(
          surahId: surahId,
          ayahNumber: currentAyah + 1,
          totalAyahsInSurah: totalAyahs,
        );
      } else {
        // End of Surah reached!
        state = state.copyWith(status: AudioStatus.completed);
        ref.read(activeAyahProvider.notifier).setActiveAyah(null);
      }
    }
  }

  /// Pause audio
  Future<void> pause() async {
    final audioService = ref.read(audioPlayerServiceProvider);
    await audioService.pause();
  }

  /// Resume audio
  Future<void> resume() async {
    final audioService = ref.read(audioPlayerServiceProvider);
    await audioService.resume();
  }

  /// Stop audio
  Future<void> stop() async {
    final audioService = ref.read(audioPlayerServiceProvider);
    await audioService.stop();
    ref.read(activeAyahProvider.notifier).setActiveAyah(null);
    state = state.copyWith(
      currentAyahNumber: null,
      status: AudioStatus.stopped,
      isAutoScrollSuspended: false,
    );
  }

  /// Toggle AutoPlayNext
  void toggleAutoPlayNext() {
    state = state.copyWith(isAutoPlayNext: !state.isAutoPlayNext);
  }

  /// Suspend auto-scroll (e.g. when user interacts with an Ayah for copy/share/bookmark)
  void suspendAutoScroll() {
    if (!state.isAutoScrollSuspended) {
      state = state.copyWith(isAutoScrollSuspended: true);
    }
  }

  /// Resume auto-scroll and sync viewport immediately back to active playing Ayah
  void resumeAutoScrollAndSync() {
    state = state.copyWith(isAutoScrollSuspended: false);
    if (state.currentAyahNumber != null) {
      ref.read(activeAyahProvider.notifier).setActiveAyah(state.currentAyahNumber);
    }
    if (state.status == AudioStatus.paused) {
      resume();
    }
  }
}
