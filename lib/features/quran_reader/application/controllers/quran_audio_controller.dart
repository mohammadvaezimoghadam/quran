import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/constants/surah_constants.dart';
import '../../../../core/services/audio/audio_error_parser.dart';
import '../../../../core/services/audio/audio_player_providers.dart';
import '../../../../core/services/audio/audio_player_state.dart';
import '../../../../core/services/audio_storage/audio_storage_providers.dart';
import '../../domain/entities/reciter_entity.dart';
import '../../infrastructure/repositories/reciter_repository.dart';
import '../../../../core/data/local/preferences/preferences_service_provider.dart';
import '../states/quran_audio_state.dart';
import 'quran_reader_controller.dart';

final quranAudioControllerProvider =
    NotifierProvider<QuranAudioController, QuranAudioState>(
  QuranAudioController.new,
);

class QuranAudioController extends Notifier<QuranAudioState> {
  StreamSubscription<AudioPlayerState>? _audioStateSubscription;
  bool _isTransitioningTrack = false;

  /// Timestamp when the current loading phase started.
  /// Used to enforce a minimum visual loading duration so the spinner
  /// is always visible (even for fast local files).
  DateTime? _loadingStartedAt;
  static const _minLoadingDuration = Duration(milliseconds: 300);

  @override
  QuranAudioState build() {
    _initDefaultReciterAndListeners();
    ref.onDispose(() {
      _audioStateSubscription?.cancel();
    });
    return const QuranAudioState();
  }

  Future<void> _initDefaultReciterAndListeners() async {
    // Register AudioHandler callbacks for notification & headset controls
    final handler = ref.read(quranAudioHandlerProvider);
    handler.onSkipNext = () async => playNextAyah();
    handler.onSkipPrevious = () async => playPreviousAyah();
    // 1. Fetch default reciter (Parhizgar by default or saved pref)
    final repo = ref.read(reciterRepositoryProvider);
    final prefs = ref.read(preferencesServiceProvider);
    final savedReciterId = prefs.getInt('selected_reciter_id');

    final result = await repo.getAllReciters();
    result.when(
      (reciters) {
        if (reciters.isNotEmpty && state.selectedReciter == null) {
          ReciterEntity defaultReciter;
          if (savedReciterId != null) {
            defaultReciter = reciters.firstWhere(
              (r) => r.id == savedReciterId,
              orElse: () => reciters.firstWhere(
                (r) => r.identifier.contains('parhizgar'),
                orElse: () => reciters.first,
              ),
            );
          } else {
            defaultReciter = reciters.firstWhere(
              (r) => r.identifier.contains('parhizgar'),
              orElse: () => reciters.first,
            );
          }
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
        _loadingStartedAt = null;
        state = state.copyWith(
          status: AudioStatus.error,
          errorMessage: playerState.errorMessage ?? 'خطا در پخش صوت',
        );
        return;
      }

      // ── While transitioning between tracks, suppress ALL intermediate
      //    states (stopped, paused, completed, loading) so the UI stays
      //    on the loading spinner. Only 'playing' (success) and 'error'
      //    (handled above) break through the guard.
      if (_isTransitioningTrack) {
        if (playerState.status == AudioStatus.playing) {
          // Track loaded & started — enforce minimum visual loading duration
          if (_loadingStartedAt != null) {
            final elapsed = DateTime.now().difference(_loadingStartedAt!);
            final remaining = _minLoadingDuration - elapsed;
            if (remaining > Duration.zero) {
              Future.delayed(remaining, () {
                _isTransitioningTrack = false;
                _loadingStartedAt = null;
                if (state.status == AudioStatus.loading) {
                  state = state.copyWith(status: AudioStatus.playing);
                }
              });
              return; // keep loading visible
            }
          }
          _isTransitioningTrack = false;
          _loadingStartedAt = null;
          state = state.copyWith(
            status: AudioStatus.playing,
            position: playerState.position,
            duration: playerState.duration,
          );
          if (state.currentAyahNumber != null) {
            ref
                .read(activeAyahProvider.notifier)
                .setActiveAyah(state.currentAyahNumber);
          }
        }
        // All other statuses (stopped, paused, loading, completed) are
        // silently swallowed — UI keeps showing loading spinner.
        return;
      }

      // ── Normal (non-transitioning) state handling ──

      // Check if transitioning to next ayah in continuous mode
      final isFinishingCurrentAyah =
          playerState.status == AudioStatus.completed;
      final hasNextAyah = state.currentAyahNumber != null &&
          state.totalAyahsInSurah != null &&
          state.currentAyahNumber! < state.totalAyahsInSurah!;
      final isWillAutoPlayNext = isFinishingCurrentAyah &&
          state.isAutoPlayNext &&
          !state.isSingleAyahMode &&
          hasNextAyah;

      if (isWillAutoPlayNext) {
        // About to auto-play next — show loading, start transition
        state = state.copyWith(status: AudioStatus.loading);
        _isTransitioningTrack = true;
        _loadingStartedAt = DateTime.now();
        playNextAyah();
        return;
      }

      // Regular state passthrough
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

      // End of track — if we shouldn't auto-play, stop cleanly
      if (playerState.status == AudioStatus.completed) {
        stop();
      }
    });
  }

  /// Select reciter safely without stream interruption crashes
  Future<void> selectReciter(ReciterEntity reciter) async {
    final wasPlaying = state.status == AudioStatus.playing;
    state = state.copyWith(selectedReciter: reciter);

    // Persist to SharedPreferences
    ref.read(preferencesServiceProvider).setInt('selected_reciter_id', reciter.id);

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
    _loadingStartedAt = DateTime.now();

    // Reset previous error message so new error events trigger UI listeners cleanly
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }

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
      status: AudioStatus.loading,
    );

    // Update system notification & Lock Screen metadata via AudioHandler
    final surahName = SurahConstants.getSurahName(surahId);
    ref.read(quranAudioHandlerProvider).updateAyahMediaItem(
          id: 'surah_${surahId}_ayah_$ayahNumber',
          surahName: surahName,
          ayahNumber: ayahNumber,
          reciterName: activeReciter.name,
        );

    // Set UI active highlight
    ref.read(activeAyahProvider.notifier).setActiveAyah(ayahNumber);

    // Build URL and play
    final audioStorage = ref.read(audioStorageServiceProvider);
    final localPath = await audioStorage.getLocalAyahAudioPath(
      reciterId: activeReciter.id,
      surahId: surahId,
      ayahNumber: ayahNumber,
    );
    
    // -- Online Streaming Fallback (Commented out as requested) --
    // final url = localPath ?? AudioUrlHelper.buildAyahUrl(
    //   subfolder: activeReciter.subfolder,
    //   surahNumber: surahId,
    //   ayahNumber: ayahNumber,
    // );
    // -------------------------------------------------------------
    
    if (localPath == null) {
      _isTransitioningTrack = false;
      await stop();
      state = state.copyWith(
        errorMessage: 'صوت آیه $ayahNumber دانلود نشده است. لطفاً ابتدا دانلود کنید.',
      );
      return;
    }

    try {
      final audioService = ref.read(audioPlayerServiceProvider);
      await audioService.play(localPath);
    } catch (e) {
      _isTransitioningTrack = false;
      await stop();
      state = state.copyWith(
        errorMessage: AudioErrorParser.parseError(e),
      );
    }
  }

  /// Play previous ayah automatically or manually
  Future<void> playPreviousAyah() async {
    final currentAyah = state.currentAyahNumber;
    final totalAyahs = state.totalAyahsInSurah;
    final surahId = state.currentSurahId;

    if (currentAyah != null && totalAyahs != null && surahId != null && currentAyah > 1) {
      playAyah(
        surahId: surahId,
        ayahNumber: currentAyah - 1,
        totalAyahsInSurah: totalAyahs,
      );
    }
  }

  /// Play next ayah automatically or manually — first checks if the file exists
  Future<void> playNextAyah() async {
    final currentAyah = state.currentAyahNumber;
    final totalAyahs = state.totalAyahsInSurah;
    final surahId = state.currentSurahId;

    if (currentAyah != null && totalAyahs != null && surahId != null) {
      if (currentAyah < totalAyahs) {
        final nextAyah = currentAyah + 1;
        // Pre-check: does the next ayah's file exist?
        final reciter = state.selectedReciter;
        if (reciter != null) {
          final audioStorage = ref.read(audioStorageServiceProvider);
          final nextPath = await audioStorage.getLocalAyahAudioPath(
            reciterId: reciter.id,
            surahId: surahId,
            ayahNumber: nextAyah,
          );
          if (nextPath == null) {
            // Next ayah not downloaded — stop cleanly with resume message
            _isTransitioningTrack = false;
            await stop();
            state = state.copyWith(
              errorMessage:
                  'صوت آیه $nextAyah به بعد دانلود نشده است. لطفاً ادامه صوت را دانلود کنید.',
            );
            return;
          }
        }
        playAyah(
          surahId: surahId,
          ayahNumber: nextAyah,
          totalAyahsInSurah: totalAyahs,
        );
      } else {
        // End of Surah reached!
        _isTransitioningTrack = false;
        _loadingStartedAt = null;
        stop();
      }
    }
  }

  /// Pause audio
  Future<void> pause() async {
    _isTransitioningTrack = false;
    _loadingStartedAt = null;
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
    _isTransitioningTrack = false;
    _loadingStartedAt = null;
    final audioService = ref.read(audioPlayerServiceProvider);
    await audioService.stop();
    
    // Explicitly tell the Android MediaSession (AudioHandler) to stop and dismiss the notification
    await ref.read(quranAudioHandlerProvider).stop();
    
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

  /// Toggle SingleAyahMode
  void toggleSingleAyahMode() {
    state = state.copyWith(isSingleAyahMode: !state.isSingleAyahMode);
  }

  /// Clear any error message state
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
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
