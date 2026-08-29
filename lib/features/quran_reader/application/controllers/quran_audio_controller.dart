import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/constants/surah_constants.dart';
import '../../../../core/services/audio/audio_error_parser.dart';
import '../../../../core/services/audio/audio_player_providers.dart';
import '../../../../core/services/audio/audio_player_state.dart';
import '../../../../core/services/audio_storage/audio_storage_providers.dart';
import '../../domain/entities/reciter_entity.dart';
import '../../domain/enums/audio_playback_mode.dart';
import '../../domain/enums/current_track_type.dart';
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

    final repo = ref.read(reciterRepositoryProvider);
    final prefs = ref.read(preferencesServiceProvider);
    final savedReciterId = prefs.getInt('selected_reciter_id');
    final savedTranslationReciterId = prefs.getInt('selected_translation_reciter_id');
    final savedModeIndex = prefs.getInt('audio_playback_mode');

    AudioPlaybackMode initialMode = AudioPlaybackMode.onlyQuran;
    if (savedModeIndex != null && savedModeIndex >= 0 && savedModeIndex < AudioPlaybackMode.values.length) {
      initialMode = AudioPlaybackMode.values[savedModeIndex];
    }

    final result = await repo.getAllReciters();
    result.when(
      (reciters) {
        if (reciters.isNotEmpty) {
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

          ReciterEntity defaultTranslationReciter;
          final translationReciters = reciters.where((r) => r.styleId == 4).toList();
          if (savedTranslationReciterId != null && translationReciters.isNotEmpty) {
            defaultTranslationReciter = translationReciters.firstWhere(
              (r) => r.id == savedTranslationReciterId,
              orElse: () => translationReciters.first,
            );
          } else if (translationReciters.isNotEmpty) {
            defaultTranslationReciter = translationReciters.first;
          } else {
            defaultTranslationReciter = defaultReciter;
          }

          state = state.copyWith(
            selectedReciter: defaultReciter,
            selectedTranslationReciter: defaultTranslationReciter,
            playbackMode: initialMode,
          );
        }
      },
      (error) {},
    );

    // Listen to core AudioPlayerService state changes
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

      // ── While transitioning between tracks, suppress intermediate states
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
              return;
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
        return;
      }

      // ── Normal (non-transitioning) state handling ──
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

      // End of track — handle mode sequence transitions
      if (playerState.status == AudioStatus.completed) {
        _onTrackCompleted();
      }
    });
  }

  CurrentTrackType _getInitialTrackType(AudioPlaybackMode mode) {
    switch (mode) {
      case AudioPlaybackMode.onlyQuran:
      case AudioPlaybackMode.quranThenTranslation:
        return CurrentTrackType.quran;
      case AudioPlaybackMode.onlyTranslation:
      case AudioPlaybackMode.translationThenQuran:
        return CurrentTrackType.translation;
    }
  }

  Future<void> _onTrackCompleted() async {
    final currentAyah = state.currentAyahNumber;
    final surahId = state.currentSurahId;
    final totalAyahs = state.totalAyahsInSurah;
    final mode = state.playbackMode;
    final trackType = state.currentTrackType;

    if (currentAyah == null || surahId == null || totalAyahs == null) {
      await stop();
      return;
    }

    switch (mode) {
      case AudioPlaybackMode.onlyQuran:
        await _advanceNextAyah(
          surahId: surahId,
          currentAyah: currentAyah,
          totalAyahs: totalAyahs,
          targetTrack: CurrentTrackType.quran,
        );
        break;

      case AudioPlaybackMode.onlyTranslation:
        await _advanceNextAyah(
          surahId: surahId,
          currentAyah: currentAyah,
          totalAyahs: totalAyahs,
          targetTrack: CurrentTrackType.translation,
        );
        break;

      case AudioPlaybackMode.quranThenTranslation:
        if (trackType == CurrentTrackType.quran) {
          // Play translation for SAME ayah
          await _playTrack(
            surahId: surahId,
            ayahNumber: currentAyah,
            totalAyahsInSurah: totalAyahs,
            trackType: CurrentTrackType.translation,
            isSingleAyahMode: state.isSingleAyahMode,
          );
        } else {
          // Finished translation -> Move to next ayah, play quran
          await _advanceNextAyah(
            surahId: surahId,
            currentAyah: currentAyah,
            totalAyahs: totalAyahs,
            targetTrack: CurrentTrackType.quran,
          );
        }
        break;

      case AudioPlaybackMode.translationThenQuran:
        if (trackType == CurrentTrackType.translation) {
          // Play quran for SAME ayah
          await _playTrack(
            surahId: surahId,
            ayahNumber: currentAyah,
            totalAyahsInSurah: totalAyahs,
            trackType: CurrentTrackType.quran,
            isSingleAyahMode: state.isSingleAyahMode,
          );
        } else {
          // Finished quran -> Move to next ayah, play translation
          await _advanceNextAyah(
            surahId: surahId,
            currentAyah: currentAyah,
            totalAyahs: totalAyahs,
            targetTrack: CurrentTrackType.translation,
          );
        }
        break;
    }
  }

  Future<void> _advanceNextAyah({
    required int surahId,
    required int currentAyah,
    required int totalAyahs,
    required CurrentTrackType targetTrack,
  }) async {
    if (!state.isAutoPlayNext || state.isSingleAyahMode || currentAyah >= totalAyahs) {
      _isTransitioningTrack = false;
      _loadingStartedAt = null;
      await stop();
      return;
    }

    final nextAyah = currentAyah + 1;
    state = state.copyWith(status: AudioStatus.loading);
    _isTransitioningTrack = true;
    _loadingStartedAt = DateTime.now();

    await _playTrack(
      surahId: surahId,
      ayahNumber: nextAyah,
      totalAyahsInSurah: totalAyahs,
      trackType: targetTrack,
      isSingleAyahMode: state.isSingleAyahMode,
    );
  }

  /// Select reciter safely without stream interruption crashes
  Future<void> selectReciter(ReciterEntity reciter) async {
    final wasPlaying = state.status == AudioStatus.playing;
    state = state.copyWith(selectedReciter: reciter);
    ref.read(preferencesServiceProvider).setInt('selected_reciter_id', reciter.id);

    if (wasPlaying && state.currentTrackType == CurrentTrackType.quran && state.currentSurahId != null && state.currentAyahNumber != null) {
      final audioService = ref.read(audioPlayerServiceProvider);
      await audioService.stop();
      await _playTrack(
        surahId: state.currentSurahId!,
        ayahNumber: state.currentAyahNumber!,
        totalAyahsInSurah: state.totalAyahsInSurah ?? 286,
        trackType: CurrentTrackType.quran,
        isSingleAyahMode: state.isSingleAyahMode,
      );
    }
  }

  /// Select translation reciter (گوینده ترجمه صوتی)
  Future<void> selectTranslationReciter(ReciterEntity reciter) async {
    final wasPlaying = state.status == AudioStatus.playing;
    state = state.copyWith(selectedTranslationReciter: reciter);
    ref.read(preferencesServiceProvider).setInt('selected_translation_reciter_id', reciter.id);

    if (wasPlaying && state.currentTrackType == CurrentTrackType.translation && state.currentSurahId != null && state.currentAyahNumber != null) {
      final audioService = ref.read(audioPlayerServiceProvider);
      await audioService.stop();
      await _playTrack(
        surahId: state.currentSurahId!,
        ayahNumber: state.currentAyahNumber!,
        totalAyahsInSurah: state.totalAyahsInSurah ?? 286,
        trackType: CurrentTrackType.translation,
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
    final initialTrack = _getInitialTrackType(state.playbackMode);
    await _playTrack(
      surahId: surahId,
      ayahNumber: ayahNumber,
      totalAyahsInSurah: totalAyahsInSurah,
      trackType: initialTrack,
      isSingleAyahMode: isSingleAyahMode,
    );
  }

  Future<void> _playTrack({
    required int surahId,
    required int ayahNumber,
    required int totalAyahsInSurah,
    required CurrentTrackType trackType,
    bool isSingleAyahMode = false,
  }) async {
    _isTransitioningTrack = true;
    _loadingStartedAt = DateTime.now();

    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }

    ReciterEntity? activeReciter;
    if (trackType == CurrentTrackType.quran) {
      activeReciter = state.selectedReciter;
      activeReciter ??= await _getFallbackReciter(isTranslation: false);
    } else {
      activeReciter = state.selectedTranslationReciter;
      activeReciter ??= await _getFallbackReciter(isTranslation: true);
    }

    // Update the correct reciter slot based on track type
    state = state.copyWith(
      selectedReciter: trackType == CurrentTrackType.quran
          ? activeReciter
          : state.selectedReciter,
      selectedTranslationReciter: trackType == CurrentTrackType.translation
          ? activeReciter
          : state.selectedTranslationReciter,
      currentSurahId: surahId,
      currentAyahNumber: ayahNumber,
      totalAyahsInSurah: totalAyahsInSurah,
      currentTrackType: trackType,
      isSingleAyahMode: isSingleAyahMode,
      status: AudioStatus.loading,
    );

    final surahName = SurahConstants.getSurahName(surahId);
    final displayReciterName = trackType == CurrentTrackType.translation
        ? '${activeReciter.name} (ترجمه)'
        : activeReciter.name;

    ref.read(quranAudioHandlerProvider).updateAyahMediaItem(
          id: 'surah_${surahId}_ayah_${ayahNumber}_${trackType.name}',
          surahName: surahName,
          ayahNumber: ayahNumber,
          reciterName: displayReciterName,
        );

    ref.read(activeAyahProvider.notifier).setActiveAyah(ayahNumber);

    final audioStorage = ref.read(audioStorageServiceProvider);
    final localPath = await audioStorage.getLocalAyahAudioPath(
      reciterId: activeReciter.id,
      surahId: surahId,
      ayahNumber: ayahNumber,
    );

    if (localPath == null) {
      _isTransitioningTrack = false;
      await stop();
      final errorPrefix = trackType == CurrentTrackType.translation
          ? 'صوت ترجمه آیه $ayahNumber'
          : 'صوت آیه $ayahNumber';
      state = state.copyWith(
        errorMessage: '$errorPrefix دانلود نشده است. لطفاً ابتدا دانلود کنید.',
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

  Future<ReciterEntity> _getFallbackReciter({required bool isTranslation}) async {
    final repo = ref.read(reciterRepositoryProvider);
    final result = await repo.getAllReciters();
    ReciterEntity? found;
    result.when(
      (reciters) {
        if (reciters.isNotEmpty) {
          if (isTranslation) {
            found = reciters.firstWhere(
              (r) => r.styleId == 4,
              orElse: () => reciters.first,
            );
          } else {
            found = reciters.firstWhere(
              (r) => r.identifier.contains('parhizgar'),
              orElse: () => reciters.first,
            );
          }
        }
      },
      (error) {},
    );
    return found ??
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
  }

  /// Play previous ayah automatically or manually
  Future<void> playPreviousAyah() async {
    final currentAyah = state.currentAyahNumber;
    final totalAyahs = state.totalAyahsInSurah;
    final surahId = state.currentSurahId;

    if (currentAyah != null && totalAyahs != null && surahId != null && currentAyah > 1) {
      final prevAyah = currentAyah - 1;
      final initialTrack = _getInitialTrackType(state.playbackMode);
      await _playTrack(
        surahId: surahId,
        ayahNumber: prevAyah,
        totalAyahsInSurah: totalAyahs,
        trackType: initialTrack,
      );
    }
  }

  /// Play next ayah automatically or manually
  Future<void> playNextAyah() async {
    final currentAyah = state.currentAyahNumber;
    final totalAyahs = state.totalAyahsInSurah;
    final surahId = state.currentSurahId;

    if (currentAyah != null && totalAyahs != null && surahId != null) {
      if (currentAyah < totalAyahs) {
        final nextAyah = currentAyah + 1;
        final initialTrack = _getInitialTrackType(state.playbackMode);
        await _playTrack(
          surahId: surahId,
          ayahNumber: nextAyah,
          totalAyahsInSurah: totalAyahs,
          trackType: initialTrack,
        );
      } else {
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

  /// Change audio playback mode
  void setPlaybackMode(AudioPlaybackMode mode) {
    state = state.copyWith(playbackMode: mode);
    ref.read(preferencesServiceProvider).setInt('audio_playback_mode', mode.index);
  }
}
