import 'package:freezed_annotation/freezed_annotation.dart';

part 'mini_audio_player_state.freezed.dart';

@freezed
abstract class MiniAudioPlayerState with _$MiniAudioPlayerState {
  const factory MiniAudioPlayerState({
    @Default(false) bool isDismissed,
  }) = _MiniAudioPlayerState;
}
