import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/local/preferences/preferences_service_provider.dart';
import '../../../../features/quran_reader/application/controllers/quran_audio_controller.dart';
import '../audio_player_state.dart';
import 'ambient_sound_service.dart';
import 'ambient_sound_state.dart';
import 'ambient_sound_track.dart';

final ambientSoundServiceProvider = Provider<AmbientSoundService>((ref) {
  final service = AmbientSoundService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

final ambientSoundControllerProvider =
    NotifierProvider<AmbientSoundController, AmbientSoundState>(
  AmbientSoundController.new,
);

class AmbientSoundController extends Notifier<AmbientSoundState> {
  static const String _prefKeyEnabled = 'ambient_sound_enabled';
  static const String _prefKeyVolume = 'ambient_sound_volume';
  static const String _prefKeyTrackId = 'ambient_sound_track_id';
  static const String _prefKeyPreAmbientSpeed = 'ambient_sound_previous_speed';

  /// Optimal calm reading speed recommended for ambient background music
  static const double ambientRecommendedSpeed = 0.85;

  late final AmbientSoundService _service;
  StreamSubscription<bool>? _playingSubscription;

  @override
  AmbientSoundState build() {
    _service = ref.watch(ambientSoundServiceProvider);

    final prefs = ref.read(preferencesServiceProvider);
    final savedEnabled = prefs.getBool(_prefKeyEnabled) ?? false;
    final savedVolume = prefs.getDouble(_prefKeyVolume) ?? 0.20;
    final savedTrackId = prefs.getString(_prefKeyTrackId);

    final track = AmbientSoundTrack.fromId(savedTrackId);

    // Subscribe to ambient player state changes
    _playingSubscription?.cancel();
    _playingSubscription = _service.playingStream.listen((isPlaying) {
      if (state.isPlaying != isPlaying) {
        state = state.copyWith(isPlaying: isPlaying);
      }
    });

    bool isDisposed = false;
    ref.onDispose(() {
      isDisposed = true;
      _playingSubscription?.cancel();
      _quranCompletionTimer?.cancel();
    });

    // Automatically synchronize with the main Quran player status
    ref.listen<AudioStatus>(
      quranAudioControllerProvider.select((s) => s.status),
      (previous, next) {
        if (previous == next) return;
        _handleQuranStateChange(previous, next);
      },
    );

    // Initial async track preloading
    Future.microtask(() async {
      final loaded = await _service.loadTrack(track);
      if (!isDisposed) {
        state = state.copyWith(isAudioLoaded: loaded);
      }
    });

    // If Quran audio is actively playing at the time this controller is built
    // (e.g. user entered reader screen with auto-playing audio or toggled bottom sheet),
    // immediately trigger ambient sound without waiting for next status change event.
    final currentQuranStatus = ref.read(quranAudioControllerProvider).status;
    if (savedEnabled && currentQuranStatus == AudioStatus.playing) {
      Future.microtask(() async {
        if (!isDisposed) {
          await _service.playWithFadeIn(
            targetVolume: savedVolume,
            track: track,
          );
        }
      });
    }

    return AmbientSoundState(
      isEnabled: savedEnabled,
      volume: savedVolume,
      selectedTrack: track,
      isPlaying: _service.isPlaying,
      isAudioLoaded: _service.isAudioLoaded,
    );
  }

  Timer? _quranCompletionTimer;

  /// Syncs ambient playback with the master Quran recitation status.
  void _handleQuranStateChange(AudioStatus? previous, AudioStatus next) {
    if (!state.isEnabled || previous == next) return;

    switch (next) {
      case AudioStatus.playing:
        _quranCompletionTimer?.cancel();
        _quranCompletionTimer = null;
        _service.playWithFadeIn(
          targetVolume: state.volume,
          track: state.selectedTrack,
        );
        break;
      case AudioStatus.paused:
        _quranCompletionTimer?.cancel();
        _quranCompletionTimer = null;
        _service.pauseWithFadeOut();
        break;
      case AudioStatus.completed:
        // When an ayah completes and advances to next ayah, do not stop ambient music!
        // Allow a 2.5s grace window for the next ayah to begin seamlessly.
        _quranCompletionTimer?.cancel();
        _quranCompletionTimer = Timer(const Duration(milliseconds: 2500), () {
          final currentQuranStatus = ref.read(quranAudioControllerProvider).status;
          if (currentQuranStatus != AudioStatus.playing &&
              currentQuranStatus != AudioStatus.loading) {
            _service.stopWithFadeOut();
          }
        });
        break;
      case AudioStatus.stopped:
      case AudioStatus.error:
        _quranCompletionTimer?.cancel();
        _quranCompletionTimer = null;
        _service.stopWithFadeOut();
        break;
      case AudioStatus.loading:
      case AudioStatus.initial:
        // Maintain continuous ambient ambience during track transitions
        break;
    }
  }

  /// Toggle ambient sound feature on/off.
  Future<void> toggleEnabled() async {
    await setEnabled(!state.isEnabled);
  }

  /// Set ambient sound enabled or disabled.
  Future<void> setEnabled(bool enabled) async {
    final prefs = ref.read(preferencesServiceProvider);
    await prefs.setBool(_prefKeyEnabled, enabled);
    state = state.copyWith(isEnabled: enabled);

    final quranAudioController = ref.read(quranAudioControllerProvider.notifier);
    final currentQuranAudioState = ref.read(quranAudioControllerProvider);
    final isQuranPlaying = currentQuranAudioState.status == AudioStatus.playing;

    if (enabled) {
      // 1. Automatically switch Quran playback speed to 0.85x (ambient recommended speed)
      // Save user's current speed before switching so it can be restored when ambient sound is turned off.
      final currentSpeed = currentQuranAudioState.speed;
      if ((currentSpeed - ambientRecommendedSpeed).abs() > 0.03) {
        await prefs.setDouble(_prefKeyPreAmbientSpeed, currentSpeed);
      }
      await quranAudioController.setPlaybackSpeed(ambientRecommendedSpeed);

      if (isQuranPlaying) {
        await _service.playWithFadeIn(
          targetVolume: state.volume,
          track: state.selectedTrack,
        );
      }
    } else {
      // 2. Ambient sound disabled: restore the user's previous playback speed
      final savedPreSpeed = prefs.getDouble(_prefKeyPreAmbientSpeed);
      if (savedPreSpeed != null) {
        await quranAudioController.setPlaybackSpeed(savedPreSpeed);
        await prefs.remove(_prefKeyPreAmbientSpeed);
      } else {
        // Fallback: if currently at 0.85x and no previous speed recorded, revert to 1.0x
        if ((currentQuranAudioState.speed - ambientRecommendedSpeed).abs() <= 0.03) {
          await quranAudioController.setPlaybackSpeed(1.0);
        }
      }

      _service.stopWithFadeOut();
    }
  }

  /// Update ambient volume level (0.0 to 1.0, typical 0.05 to 0.40).
  void setVolume(double volume) {
    final clamped = volume.clamp(0.0, 1.0);
    ref.read(preferencesServiceProvider).setDouble(_prefKeyVolume, clamped);
    state = state.copyWith(volume: clamped);
    _service.setVolume(clamped);
  }

  /// Select a different ambient sound track.
  Future<void> selectTrack(AmbientSoundTrack track) async {
    if (state.selectedTrack.id == track.id && state.isAudioLoaded) return;

    ref.read(preferencesServiceProvider).setString(_prefKeyTrackId, track.id);
    state = state.copyWith(selectedTrack: track);

    final wasPlaying = _service.isPlaying;
    final quranState = ref.read(quranAudioControllerProvider);
    final isQuranPlaying = quranState.status == AudioStatus.playing;

    if ((wasPlaying || isQuranPlaying) && state.isEnabled) {
      await _service.switchToTrack(track, targetVolume: state.volume);
      state = state.copyWith(isAudioLoaded: _service.isAudioLoaded);
    } else {
      final loaded = await _service.loadTrack(track);
      state = state.copyWith(isAudioLoaded: loaded);
    }
  }

  /// Standalone preview test without needing to run Quran audio.
  Future<void> previewToggle() async {
    debugPrint('AmbientSoundController: previewToggle called '
        '(isPlaying=${_service.isPlaying}, '
        'track=${state.selectedTrack.id}, '
        'loaded=${_service.isAudioLoaded})');

    if (_service.isPlaying) {
      _service.pauseWithFadeOut();
    } else {
      // Ensure track is loaded before playing
      if (!_service.isAudioLoaded || _service.currentTrack?.id != state.selectedTrack.id) {
        debugPrint('AmbientSoundController: Loading track before preview...');
        final loaded = await _service.loadTrack(state.selectedTrack);
        state = state.copyWith(isAudioLoaded: loaded);
        if (!loaded) {
          debugPrint('AmbientSoundController: ❌ Failed to load track for preview');
          return;
        }
      }
      await _service.playWithFadeIn(
        targetVolume: state.volume,
        track: state.selectedTrack,
      );
    }
  }
}
