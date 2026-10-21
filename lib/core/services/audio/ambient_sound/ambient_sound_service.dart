import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'ambient_sound_track.dart';

/// Dedicated audio service for background ambient sounds (rain, soft melody, nature, serenity).
/// Runs completely independently from the Quran recitation player, looping seamlessly
/// without stuttering or restarting across ayah transitions.
class AmbientSoundService {
  final AudioPlayer _player;
  Timer? _fadeTimer;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  AmbientSoundTrack? _currentTrack;
  bool _isAudioLoaded = false;
  double _targetVolume = 0.20;
  int _loadGeneration = 0;
  Future<bool>? _activeLoadFuture;
  String? _loadingTrackId;
  bool _isDesiredPlaying = false;

  AmbientSoundService({AudioPlayer? player})
      : _player = player ??
            AudioPlayer(
              handleInterruptions: false,
              handleAudioSessionActivation: false,
              androidApplyAudioAttributes: false,
            ) {
    _init();
  }

  bool get isAudioLoaded => _isAudioLoaded;
  bool get isPlaying => _player.playing;
  double get currentVolume => _player.volume;
  AmbientSoundTrack? get currentTrack => _currentTrack;

  Stream<bool> get playingStream => _player.playingStream;

  void _init() {
    _player.setLoopMode(LoopMode.all);

    // Listen for player errors/state changes to catch silent failures
    _playerStateSubscription = _player.playerStateStream.listen((playerState) {
      // Idle state alone does not mean audio is unloaded if audioSource is still set
      if (playerState.processingState == ProcessingState.idle &&
          _isAudioLoaded &&
          _player.audioSource == null) {
        _isAudioLoaded = false;
      }
    }, onError: (Object e, StackTrace st) {
      debugPrint('AmbientSoundService: Player stream error: $e');
      _isAudioLoaded = false;
    });
  }

  /// Preload an ambient track into the dedicated player.
  Future<bool> loadTrack(AmbientSoundTrack track) async {
    // Only skip reload if truly the same track AND confirmed loaded
    if (_currentTrack?.id == track.id &&
        _isAudioLoaded &&
        _player.audioSource != null &&
        _player.processingState != ProcessingState.idle) {
      debugPrint('AmbientSoundService: Track ${track.id} already loaded, skipping');
      return true;
    }

    // Deduplicate in-flight load requests for the exact same track
    if (_loadingTrackId == track.id && _activeLoadFuture != null) {
      debugPrint('AmbientSoundService: Track ${track.id} is already loading, waiting for completion...');
      return await _activeLoadFuture!;
    }

    final generation = ++_loadGeneration;
    _loadingTrackId = track.id;
    _activeLoadFuture = _executeLoadTrack(track, generation);

    try {
      return await _activeLoadFuture!;
    } finally {
      if (_loadingTrackId == track.id) {
        _loadingTrackId = null;
        _activeLoadFuture = null;
      }
    }
  }

  Future<bool> _executeLoadTrack(AmbientSoundTrack track, int generation) async {
    try {
      _fadeTimer?.cancel();
      _currentTrack = track;
      _isAudioLoaded = false;

      debugPrint('AmbientSoundService: Loading asset ${track.assetPath} (gen $generation)...');
      await _player.setAsset(track.assetPath);

      if (_loadGeneration != generation) {
        debugPrint('AmbientSoundService: Superseded by newer load request');
        return false;
      }

      await _player.setLoopMode(LoopMode.all);
      await _player.setVolume(_targetVolume);
      _isAudioLoaded = true;
      debugPrint('AmbientSoundService: ✅ Successfully loaded ${track.id} (${track.assetPath})');
      return true;
    } catch (e, st) {
      final isInterrupted = e.toString().toLowerCase().contains('interrupted') ||
          e.toString().toLowerCase().contains('abort');
      if (isInterrupted) {
        debugPrint('AmbientSoundService: Load of ${track.id} was interrupted by a newer operation.');
        return false;
      }
      _isAudioLoaded = false;
      _currentTrack = null;
      debugPrint('AmbientSoundService: ❌ Failed to load ${track.id} (${track.assetPath}): $e');
      debugPrint('AmbientSoundService: Stack trace: $st');
      return false;
    }
  }

  /// Seamlessly switches to a new ambient sound track with cross-fade.
  Future<void> switchToTrack(AmbientSoundTrack track, {required double targetVolume}) async {
    _targetVolume = targetVolume;
    _isDesiredPlaying = true;

    // If already playing this exact track, just ensure target volume
    if (_currentTrack?.id == track.id && _isAudioLoaded && _player.playing) {
      _fadeIn(targetVolume, const Duration(milliseconds: 400));
      return;
    }

    _fadeTimer?.cancel();
    _fadeTimer = null;

    final wasPlaying = _player.playing;

    try {
      if (wasPlaying) {
        await _player.pause();
      }
    } catch (_) {}

    _isAudioLoaded = false;
    _currentTrack = track;

    final ok = await loadTrack(track);
    if (!ok || !_isDesiredPlaying) return;

    try {
      await _player.seek(Duration.zero);
      _player.setVolume(0.0);
      _fadeIn(targetVolume, const Duration(milliseconds: 700));
      unawaited(_player.play().catchError((e) {
        debugPrint('AmbientSoundService: Error playing switched track: $e');
      }));
      debugPrint('AmbientSoundService: ▶ Switched and started playing ${track.id}');
    } catch (e) {
      debugPrint('AmbientSoundService: Error starting switched track: $e');
    }
  }

  /// Start playing with smooth volume fade-in (default 800ms).
  /// If already playing, maintains playback without stuttering or restarting.
  Future<void> playWithFadeIn({
    required double targetVolume,
    AmbientSoundTrack? track,
    Duration duration = const Duration(milliseconds: 800),
  }) async {
    _targetVolume = targetVolume;
    _isDesiredPlaying = true;
    final trackToPlay = track ?? _currentTrack;

    if (trackToPlay == null) {
      debugPrint('AmbientSoundService: No track to play');
      return;
    }

    _fadeTimer?.cancel();
    _fadeTimer = null;

    // If track changed while playing or requested a different track, switch smoothly
    if (_currentTrack != null && _currentTrack!.id != trackToPlay.id && _isAudioLoaded) {
      await switchToTrack(trackToPlay, targetVolume: targetVolume);
      return;
    }

    // Load if not loaded or track changed
    final needsLoad = !_isAudioLoaded ||
        _currentTrack?.id != trackToPlay.id ||
        _player.audioSource == null ||
        _player.processingState == ProcessingState.idle;

    if (needsLoad) {
      debugPrint('AmbientSoundService: Need to load track ${trackToPlay.id} '
          '(loaded=$_isAudioLoaded, current=${_currentTrack?.id})');
      final ok = await loadTrack(trackToPlay);
      if (!ok || !_isDesiredPlaying) {
        debugPrint('AmbientSoundService: Failed to load or superseded, aborting playback');
        return;
      }
    }

    // If already playing the exact track, smoothly adjust to target volume
    if (_player.playing) {
      _fadeIn(targetVolume, duration);
      return;
    }

    try {
      _player.setVolume(0.0);
      _fadeIn(targetVolume, duration);
      unawaited(_player.play().catchError((e) {
        debugPrint('AmbientSoundService: Error playing ${trackToPlay.id}: $e');
      }));
      debugPrint('AmbientSoundService: ▶ Started playing ${trackToPlay.id}');
    } catch (e) {
      debugPrint('AmbientSoundService: Error starting ${trackToPlay.id}: $e');
    }
  }

  /// Pause playback with smooth volume fade-out (default 250ms).
  void pauseWithFadeOut({
    Duration duration = const Duration(milliseconds: 250),
  }) {
    _isDesiredPlaying = false;
    if (!_player.playing) return;

    _fadeOut(duration, onComplete: () async {
      if (!_isDesiredPlaying) {
        try {
          await _player.pause();
        } catch (e) {
          debugPrint('AmbientSoundService: Error pausing: $e');
        }
      }
    });
  }

  /// Stop playback with smooth fade-out and reset position to beginning.
  void stopWithFadeOut({
    Duration duration = const Duration(milliseconds: 250),
  }) {
    _isDesiredPlaying = false;
    if (!_player.playing) return;

    _fadeOut(duration, onComplete: () async {
      if (!_isDesiredPlaying) {
        try {
          await _player.pause();
          await _player.seek(Duration.zero);
        } catch (e) {
          debugPrint('AmbientSoundService: Error stopping: $e');
        }
      }
    });
  }

  /// Immediately update the volume or smoothly transition if playing.
  void setVolume(double newVolume) {
    _targetVolume = newVolume.clamp(0.0, 1.0);
    if (_player.playing && (_fadeTimer == null || !_fadeTimer!.isActive)) {
      _player.setVolume(_targetVolume);
    }
  }

  void _fadeIn(double targetVolume, Duration duration) {
    _fadeTimer?.cancel();
    final steps = (duration.inMilliseconds / 30).round();
    if (steps <= 0) {
      _player.setVolume(targetVolume);
      return;
    }

    int currentStep = 0;
    final startVol = _player.volume;
    _fadeTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      currentStep++;
      final double progress = (currentStep / steps).clamp(0.0, 1.0);
      final double vol = startVol + ((targetVolume - startVol) * progress);
      _player.setVolume(vol.clamp(0.0, 1.0));

      if (progress >= 1.0) {
        timer.cancel();
      }
    });
  }

  void _fadeOut(Duration duration, {VoidCallback? onComplete}) {
    _fadeTimer?.cancel();
    final startVolume = _player.volume;
    final steps = (duration.inMilliseconds / 30).round();
    if (steps <= 0) {
      _player.setVolume(0.0);
      onComplete?.call();
      return;
    }

    int currentStep = 0;
    _fadeTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      currentStep++;
      final double progress = (currentStep / steps).clamp(0.0, 1.0);
      final double currentVol = (startVolume * (1.0 - progress)).clamp(0.0, 1.0);
      _player.setVolume(currentVol);

      if (progress >= 1.0) {
        timer.cancel();
        _player.setVolume(0.0);
        onComplete?.call();
      }
    });
  }

  void dispose() {
    _isDesiredPlaying = false;
    _fadeTimer?.cancel();
    _playerStateSubscription?.cancel();
    _player.dispose();
  }
}
