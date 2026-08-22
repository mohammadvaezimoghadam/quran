import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/services/audio/audio_player_state.dart';
import '../../domain/entities/reciter_entity.dart';

part 'quran_audio_state.freezed.dart';

@freezed
abstract class QuranAudioState with _$QuranAudioState {
  const factory QuranAudioState({
    ReciterEntity? selectedReciter,
    int? currentSurahId,
    int? currentAyahNumber,
    int? totalAyahsInSurah,
    @Default(AudioStatus.initial) AudioStatus status,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    @Default(true) bool isAutoPlayNext,
    @Default(false) bool isSingleAyahMode,
    @Default(false) bool isAutoScrollSuspended,
    String? errorMessage,
  }) = _QuranAudioState;
}
