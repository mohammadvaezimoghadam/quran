import 'ambient_sound_track.dart';

/// Immutable state for ambient background sound
class AmbientSoundState {
  final bool isEnabled;
  final double volume; // 0.0 to 1.0 (default: 0.20 for gentle background)
  final AmbientSoundTrack selectedTrack;
  final bool isPlaying;
  final bool isAudioLoaded;

  const AmbientSoundState({
    this.isEnabled = false,
    this.volume = 0.20,
    required this.selectedTrack,
    this.isPlaying = false,
    this.isAudioLoaded = false,
  });

  AmbientSoundState copyWith({
    bool? isEnabled,
    double? volume,
    AmbientSoundTrack? selectedTrack,
    bool? isPlaying,
    bool? isAudioLoaded,
  }) {
    return AmbientSoundState(
      isEnabled: isEnabled ?? this.isEnabled,
      volume: volume ?? this.volume,
      selectedTrack: selectedTrack ?? this.selectedTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      isAudioLoaded: isAudioLoaded ?? this.isAudioLoaded,
    );
  }
}
