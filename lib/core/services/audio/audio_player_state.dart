import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_player_state.freezed.dart';

enum AudioStatus {
  initial,
  loading,
  playing,
  paused,
  stopped,
  completed,
  error,
}

@freezed
abstract class AudioPlayerState with _$AudioPlayerState {
  const factory AudioPlayerState({
    required AudioStatus status,
    String? currentUrl,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    @Default(1.0) double speed,
    String? errorMessage,
  }) = _AudioPlayerState;

  factory AudioPlayerState.initial() => const AudioPlayerState(
        status: AudioStatus.initial,
      );
}
