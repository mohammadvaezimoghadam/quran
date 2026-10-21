import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/local/preferences/preferences_service_provider.dart';
import '../audio_player_providers.dart';
import 'echo_preset.dart';
import 'echo_service.dart';
import 'echo_state.dart';

final echoControllerProvider =
    NotifierProvider<EchoController, EchoState>(
  EchoController.new,
);

class EchoController extends Notifier<EchoState> {
  static const String _prefKeyEnabled = 'quran_echo_enabled';
  static const String _prefKeyPresetId = 'quran_echo_preset_id';
  static const String _prefKeyIntensity = 'quran_echo_intensity';

  late final IEchoService _service;

  @override
  EchoState build() {
    _service = ref.watch(echoServiceProvider);
    final rawPlayer = ref.watch(rawAudioPlayerProvider);

    final prefs = ref.read(preferencesServiceProvider);
    final savedEnabled = prefs.getBool(_prefKeyEnabled) ?? false;
    final savedPresetId = prefs.getString(_prefKeyPresetId);
    final savedIntensity = prefs.getDouble(_prefKeyIntensity) ?? 0.7;

    final preset = EchoPreset.fromId(savedPresetId);

    final initialState = EchoState(
      isEnabled: savedEnabled,
      preset: preset,
      intensity: savedIntensity,
      audioSessionId: rawPlayer.androidAudioSessionId,
    );

    // Initial sync of config to echo engine
    _service.updateConfig(
      enabled: savedEnabled,
      preset: preset,
      intensity: savedIntensity,
      sessionId: rawPlayer.androidAudioSessionId,
      currentPosition: rawPlayer.position,
      isPlaying: rawPlayer.playing,
    );

    return initialState;
  }

  /// Toggles echo / audio effects on or off
  Future<void> toggleEcho() async {
    await setEnabled(!state.isEnabled);
  }

  /// Sets echo state explicitly
  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(isEnabled: enabled);

    final prefs = ref.read(preferencesServiceProvider);
    await prefs.setBool(_prefKeyEnabled, enabled);

    final rawPlayer = ref.read(rawAudioPlayerProvider);
    _service.updateConfig(
      enabled: enabled,
      preset: state.preset,
      intensity: state.intensity,
      sessionId: rawPlayer.androidAudioSessionId,
      currentPosition: rawPlayer.position,
      isPlaying: rawPlayer.playing,
    );
  }

  /// Changes the active preset (e.g., Shrine, Mosque, Studio, Room, Vintage Radio)
  Future<void> setPreset(EchoPreset preset) async {
    if (state.preset == preset) return;
    state = state.copyWith(preset: preset);

    final prefs = ref.read(preferencesServiceProvider);
    await prefs.setString(_prefKeyPresetId, preset.id);

    final rawPlayer = ref.read(rawAudioPlayerProvider);
    _service.updateConfig(
      enabled: state.isEnabled,
      preset: preset,
      intensity: state.intensity,
      sessionId: rawPlayer.androidAudioSessionId,
      currentPosition: rawPlayer.position,
      isPlaying: rawPlayer.playing,
    );
  }

  /// Updates intensity level (0.0 to 1.0)
  Future<void> setIntensity(double intensity) async {
    final clamped = intensity.clamp(0.0, 1.0);
    state = state.copyWith(intensity: clamped);

    final prefs = ref.read(preferencesServiceProvider);
    await prefs.setDouble(_prefKeyIntensity, clamped);

    final rawPlayer = ref.read(rawAudioPlayerProvider);
    _service.updateConfig(
      enabled: state.isEnabled,
      preset: state.preset,
      intensity: clamped,
      sessionId: rawPlayer.androidAudioSessionId,
    );
  }
}
