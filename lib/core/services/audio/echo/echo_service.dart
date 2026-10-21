import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'echo_preset.dart';
import 'native_audio_effects_bridge.dart';

final echoServiceProvider = Provider<IEchoService>((ref) {
  final service = EchoService();
  ref.onDispose(() {
    service.release();
  });
  return service;
});

abstract class IEchoService {
  /// Whether echo / sound effects are currently active and audible.
  bool get isEnabled;

  /// Current preset configured.
  EchoPreset get currentPreset;

  /// Current intensity factor (0.0 to 1.0).
  double get intensity;

  /// Updates runtime echo configuration (enabled, preset, intensity, sessionId).
  /// Can be called dynamically while audio is playing.
  void updateConfig({
    required bool enabled,
    required EchoPreset preset,
    required double intensity,
    int? sessionId,
    Duration? currentPosition,
    bool? isPlaying,
  });

  /// Updates the active audio session ID for native DSP hardware effects.
  void setAudioSessionId(int? sessionId);

  /// Preloads the audio source for the echo delay engine in sync with the primary player.
  Future<void> prepareSource(String source, {double speed = 1.0});

  /// Notified when main Quran recitation starts playback.
  void onPlaybackStarted();

  /// Notified when main Quran recitation is paused.
  void onPlaybackPaused();

  /// Notified when main Quran recitation is resumed.
  void onPlaybackResumed(Duration currentPosition);

  /// Notified when main Quran recitation is stopped or completed.
  void onPlaybackStopped();

  /// Notified when user seeks to a new timestamp in the current ayah.
  void onSeek(Duration position);

  /// Notified when user changes playback speed (e.g. 1.2x).
  void onSpeedChanged(double speed);

  /// Notified when main player volume changes.
  void onMainVolumeChanged(double volume);

  /// Legacy method for backward compatibility
  Future<bool> applyReverb({
    required int sessionId,
    required EchoPreset preset,
    required bool enabled,
  });

  /// Legacy method for backward compatibility
  Future<bool> setEnabled(bool enabled);

  /// Releases audio players and cancels all active timers.
  Future<void> release();
}

/// High-fidelity, real-time Audio Effects Engine (Reverb / Echo & Vintage Radio).
class EchoService implements IEchoService {
  final AudioPlayer _tap1Player;
  final AudioPlayer _tap2Player;
  final AudioPlayer _radioTexturePlayer;

  bool _isEnabled = false;
  EchoPreset _preset = EchoPreset.shrine;
  double _intensity = 0.7;
  double _mainVolume = 1.0;
  double _speed = 1.0;

  bool _isPlaying = false;
  String? _currentSource;
  int _loadGeneration = 0;
  bool _isRadioTextureLoaded = false;
  int? _sessionId;

  Timer? _tap1Timer;
  Timer? _tap2Timer;

  EchoService({
    AudioPlayer? tap1Player,
    AudioPlayer? tap2Player,
    AudioPlayer? radioTexturePlayer,
  })  : _tap1Player = tap1Player ??
            AudioPlayer(
              handleInterruptions: false,
              handleAudioSessionActivation: false,
              androidApplyAudioAttributes: false,
            ),
        _tap2Player = tap2Player ??
            AudioPlayer(
              handleInterruptions: false,
              handleAudioSessionActivation: false,
              androidApplyAudioAttributes: false,
            ),
        _radioTexturePlayer = radioTexturePlayer ??
            AudioPlayer(
              handleInterruptions: false,
              handleAudioSessionActivation: false,
              androidApplyAudioAttributes: false,
            ) {
    _initPlayers();
  }

  void _initPlayers() {
    // Silence initial volumes
    _tap1Player.setVolume(0.0).catchError((_) {});
    _tap2Player.setVolume(0.0).catchError((_) {});
    _radioTexturePlayer.setVolume(0.0).catchError((_) {});
  }

  Future<void> _ensureRadioTextureLoaded() async {
    if (_isRadioTextureLoaded) return;
    try {
      await _radioTexturePlayer.setAsset('assets/audio/ambient/vintage_radio_texture.mp3');
      await _radioTexturePlayer.setLoopMode(LoopMode.all);
      _isRadioTextureLoaded = true;
    } catch (e) {
      debugPrint('⚠️ [EchoEngine] Failed to load vintage_radio_texture: $e');
    }
  }

  @override
  bool get isEnabled => _isEnabled;

  @override
  EchoPreset get currentPreset => _preset;

  @override
  double get intensity => _intensity;

  @override
  void setAudioSessionId(int? sessionId) {
    if (sessionId != null && sessionId > 0 && _sessionId != sessionId) {
      _sessionId = sessionId;
      _syncNativeEffects();
    }
  }

  void _syncNativeEffects() {
    final sid = _sessionId ?? 0;
    if (sid <= 0) return;

    if (_isEnabled && _preset.isRadio) {
      unawaited(NativeAudioEffectsBridge.applyRadioFilter(sessionId: sid, enabled: true));
      unawaited(NativeAudioEffectsBridge.applyReverb(sessionId: sid, preset: 0, enabled: false));
    } else if (_isEnabled) {
      unawaited(NativeAudioEffectsBridge.applyRadioFilter(sessionId: sid, enabled: false));
      unawaited(NativeAudioEffectsBridge.applyReverb(sessionId: sid, preset: _preset.nativePresetId, enabled: true));
    } else {
      unawaited(NativeAudioEffectsBridge.applyRadioFilter(sessionId: sid, enabled: false));
      unawaited(NativeAudioEffectsBridge.applyReverb(sessionId: sid, preset: 0, enabled: false));
    }
  }

  @override
  void updateConfig({
    required bool enabled,
    required EchoPreset preset,
    required double intensity,
    int? sessionId,
    Duration? currentPosition,
    bool? isPlaying,
  }) {
    final wasEnabled = _isEnabled;
    final prevPreset = _preset;

    _isEnabled = enabled;
    _preset = preset;
    _intensity = intensity.clamp(0.0, 1.0);
    if (sessionId != null && sessionId > 0) {
      _sessionId = sessionId;
    }

    if (isPlaying != null) {
      _isPlaying = isPlaying;
    }

    _updateVolumes();
    _syncNativeEffects();

    if (_preset.isRadio && _isEnabled) {
      // Vintage Radio mode: mute echo taps and activate radio static texture
      _cancelTimers();
      _tap1Player.pause().catchError((_) {});
      _tap2Player.pause().catchError((_) {});

      unawaited(_ensureRadioTextureLoaded().then((_) {
        if (_isPlaying && _isEnabled && _preset.isRadio) {
          _radioTexturePlayer.play().catchError((_) {});
        }
      }));
    } else {
      // Reverb / Echo mode: mute radio texture and use dual-tap echo engine
      _radioTexturePlayer.pause().catchError((_) {});

      if (!wasEnabled && _isEnabled) {
        if (_currentSource != null) {
          unawaited(prepareSource(_currentSource!, speed: _speed));
        }
        if (_isPlaying && currentPosition != null && _currentSource != null) {
          onSeek(currentPosition);
        }
      } else if (wasEnabled && !_isEnabled) {
        _cancelTimers();
        _tap1Player.pause().catchError((_) {});
        _tap2Player.pause().catchError((_) {});
      } else if (_isEnabled && prevPreset != preset) {
        if (_isPlaying && currentPosition != null) {
          onSeek(currentPosition);
        }
      }
    }
  }

  @override
  Future<void> prepareSource(String source, {double speed = 1.0}) async {
    final generation = ++_loadGeneration;
    _currentSource = source;
    _speed = speed;
    _cancelTimers();

    final isRemote = source.startsWith('http://') || source.startsWith('https://');
    final cleanPath = source.startsWith('file://') ? Uri.parse(source).toFilePath() : source;

    if (isRemote && (!_isEnabled || _preset.isRadio)) {
      return;
    }

    try {
      if (isRemote) {
        try {
          await _tap1Player.setUrl(source).timeout(const Duration(seconds: 6));
        } catch (e) {
          debugPrint('⚠️ [EchoEngine] Tap1 remote stream warning: $e');
        }
        if (_preset.hasSecondTap && _loadGeneration == generation) {
          try {
            await _tap2Player.setUrl(source).timeout(const Duration(seconds: 6));
          } catch (e) {
            debugPrint('⚠️ [EchoEngine] Tap2 remote stream warning: $e');
          }
        }
      } else {
        final futures = <Future>[
          _tap1Player.setFilePath(cleanPath),
          if (_preset.hasSecondTap) _tap2Player.setFilePath(cleanPath),
        ];
        await Future.wait(futures).timeout(
          const Duration(seconds: 8),
          onTimeout: () => [],
        );
      }

      if (_loadGeneration != generation) return;

      await _tap1Player.setSpeed(_speed).catchError((_) {});
      if (_preset.hasSecondTap) {
        await _tap2Player.setSpeed(_speed).catchError((_) {});
      }
      _updateVolumes();
    } catch (e) {
      debugPrint('⚠️ [EchoEngine] prepareSource error (graceful fallback): $e');
    }
  }

  @override
  void onPlaybackStarted() {
    _isPlaying = true;
    _cancelTimers();

    if (!_isEnabled) return;
    _updateVolumes();
    _syncNativeEffects();

    if (_preset.isRadio) {
      unawaited(_ensureRadioTextureLoaded().then((_) {
        if (_isPlaying && _isEnabled && _preset.isRadio) {
          _radioTexturePlayer.play().catchError((_) {});
        }
      }));
      return;
    }

    // Primary delay tap (e.g. 130ms - 160ms)
    final tap1Ms = (_preset.tap1DelayMs / _speed).round();
    _tap1Timer = Timer(Duration(milliseconds: tap1Ms), () async {
      if (!_isPlaying || !_isEnabled || _preset.isRadio) return;
      try {
        await _tap1Player.seek(Duration.zero);
        unawaited(_tap1Player.play().catchError((e) {
          debugPrint('⚠️ [EchoEngine] Tap1 play error: $e');
        }));
      } catch (_) {}
    });

    // Secondary delay tap
    if (_preset.hasSecondTap) {
      final tap2Ms = (_preset.tap2DelayMs / _speed).round();
      _tap2Timer = Timer(Duration(milliseconds: tap2Ms), () async {
        if (!_isPlaying || !_isEnabled || _preset.isRadio) return;
        try {
          await _tap2Player.seek(Duration.zero);
          unawaited(_tap2Player.play().catchError((e) {
            debugPrint('⚠️ [EchoEngine] Tap2 play error: $e');
          }));
        } catch (_) {}
      });
    }
  }

  @override
  void onPlaybackPaused() {
    _isPlaying = false;
    _cancelTimers();
    _tap1Player.pause().catchError((_) {});
    _tap2Player.pause().catchError((_) {});
    _radioTexturePlayer.pause().catchError((_) {});
  }

  @override
  void onPlaybackResumed(Duration currentPosition) {
    _isPlaying = true;
    if (!_isEnabled) return;

    _updateVolumes();
    _syncNativeEffects();

    if (_preset.isRadio) {
      unawaited(_ensureRadioTextureLoaded().then((_) {
        if (_isPlaying && _isEnabled && _preset.isRadio) {
          _radioTexturePlayer.play().catchError((_) {});
        }
      }));
      return;
    }

    onSeek(currentPosition);
  }

  @override
  void onPlaybackStopped() {
    _isPlaying = false;
    _cancelTimers();
    _tap1Player.stop().catchError((_) {});
    _tap2Player.stop().catchError((_) {});
    _radioTexturePlayer.pause().catchError((_) {});
    _radioTexturePlayer.seek(Duration.zero).catchError((_) {});
  }

  @override
  void onSeek(Duration position) {
    _cancelTimers();
    if (!_isEnabled || _preset.isRadio) return;

    final tap1OffsetMs = position.inMilliseconds - (_preset.tap1DelayMs / _speed).round();
    if (tap1OffsetMs > 0) {
      _tap1Player.seek(Duration(milliseconds: tap1OffsetMs)).catchError((_) {});
      if (_isPlaying) {
        unawaited(_tap1Player.play().catchError((_) {}));
      }
    } else {
      _tap1Player.pause().catchError((_) {});
      _tap1Player.seek(Duration.zero).catchError((_) {});
      if (_isPlaying) {
        final remainingMs = (_preset.tap1DelayMs / _speed).round() - position.inMilliseconds;
        _tap1Timer = Timer(Duration(milliseconds: remainingMs.clamp(0, 10000)), () {
          if (_isPlaying && _isEnabled && !_preset.isRadio) {
            unawaited(_tap1Player.play().catchError((_) {}));
          }
        });
      }
    }

    if (_preset.hasSecondTap) {
      final tap2OffsetMs = position.inMilliseconds - (_preset.tap2DelayMs / _speed).round();
      if (tap2OffsetMs > 0) {
        _tap2Player.seek(Duration(milliseconds: tap2OffsetMs)).catchError((_) {});
        if (_isPlaying) {
          unawaited(_tap2Player.play().catchError((_) {}));
        }
      } else {
        _tap2Player.pause().catchError((_) {});
        _tap2Player.seek(Duration.zero).catchError((_) {});
        if (_isPlaying) {
          final remainingMs = (_preset.tap2DelayMs / _speed).round() - position.inMilliseconds;
          _tap2Timer = Timer(Duration(milliseconds: remainingMs.clamp(0, 10000)), () {
            if (_isPlaying && _isEnabled && !_preset.isRadio) {
              unawaited(_tap2Player.play().catchError((_) {}));
            }
          });
        }
      }
    } else {
      _tap2Player.pause().catchError((_) {});
    }
  }

  @override
  void onSpeedChanged(double speed) {
    _speed = speed <= 0 ? 1.0 : speed;
    _tap1Player.setSpeed(_speed).catchError((_) {});
    _tap2Player.setSpeed(_speed).catchError((_) {});
  }

  @override
  void onMainVolumeChanged(double volume) {
    _mainVolume = volume.clamp(0.0, 1.0);
    _updateVolumes();
  }

  void _updateVolumes() {
    if (!_isEnabled) {
      _tap1Player.setVolume(0.0).catchError((_) {});
      _tap2Player.setVolume(0.0).catchError((_) {});
      _radioTexturePlayer.setVolume(0.0).catchError((_) {});
      return;
    }

    if (_preset.isRadio) {
      _tap1Player.setVolume(0.0).catchError((_) {});
      _tap2Player.setVolume(0.0).catchError((_) {});
      final radioVol = (0.24 * _intensity * _mainVolume).clamp(0.0, 1.0);
      _radioTexturePlayer.setVolume(radioVol).catchError((_) {});
      return;
    }

    _radioTexturePlayer.setVolume(0.0).catchError((_) {});
    final tap1Vol = (_preset.tap1VolumeFactor * _intensity * _mainVolume).clamp(0.0, 1.0);
    _tap1Player.setVolume(tap1Vol).catchError((_) {});

    if (_preset.hasSecondTap) {
      final tap2Vol = (_preset.tap2VolumeFactor * _intensity * _mainVolume).clamp(0.0, 1.0);
      _tap2Player.setVolume(tap2Vol).catchError((_) {});
    } else {
      _tap2Player.setVolume(0.0).catchError((_) {});
    }
  }

  void _cancelTimers() {
    _tap1Timer?.cancel();
    _tap1Timer = null;
    _tap2Timer?.cancel();
    _tap2Timer = null;
  }

  @override
  Future<bool> applyReverb({
    required int sessionId,
    required EchoPreset preset,
    required bool enabled,
  }) async {
    updateConfig(
      enabled: enabled,
      preset: preset,
      intensity: _intensity,
      sessionId: sessionId,
    );
    return true;
  }

  @override
  Future<bool> setEnabled(bool enabled) async {
    updateConfig(
      enabled: enabled,
      preset: _preset,
      intensity: _intensity,
    );
    return true;
  }

  @override
  Future<void> release() async {
    _cancelTimers();
    try {
      await _tap1Player.dispose();
      await _tap2Player.dispose();
      await _radioTexturePlayer.dispose();
    } catch (e) {
      debugPrint('⚠️ [EchoEngine] dispose error: $e');
    }
    unawaited(NativeAudioEffectsBridge.release());
  }
}
