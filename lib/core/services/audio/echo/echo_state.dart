import 'echo_preset.dart';

/// Immutable state representing user's echo / reverb configuration.
class EchoState {
  final bool isEnabled;
  final EchoPreset preset;
  final double intensity; // 0.0 to 1.0 (wet mix / intensity)
  final int? audioSessionId;
  final bool isSupported;

  const EchoState({
    this.isEnabled = false,
    this.preset = EchoPreset.shrine,
    this.intensity = 0.7,
    this.audioSessionId,
    this.isSupported = true,
  });

  EchoState copyWith({
    bool? isEnabled,
    EchoPreset? preset,
    double? intensity,
    int? audioSessionId,
    bool? isSupported,
  }) {
    return EchoState(
      isEnabled: isEnabled ?? this.isEnabled,
      preset: preset ?? this.preset,
      intensity: intensity ?? this.intensity,
      audioSessionId: audioSessionId ?? this.audioSessionId,
      isSupported: isSupported ?? this.isSupported,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EchoState &&
          runtimeType == other.runtimeType &&
          isEnabled == other.isEnabled &&
          preset == other.preset &&
          intensity == other.intensity &&
          audioSessionId == other.audioSessionId &&
          isSupported == other.isSupported;

  @override
  int get hashCode =>
      isEnabled.hashCode ^
      preset.hashCode ^
      intensity.hashCode ^
      audioSessionId.hashCode ^
      isSupported.hashCode;
}
