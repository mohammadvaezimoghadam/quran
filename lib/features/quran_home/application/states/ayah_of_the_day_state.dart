import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/ayah_of_the_day.dart';

part 'ayah_of_the_day_state.freezed.dart';

/// State representation for Ayah of the Day UI widget
@freezed
abstract class AyahOfTheDayState with _$AyahOfTheDayState {
  const factory AyahOfTheDayState({
    @Default(true) bool isLoading,
    AyahOfTheDay? ayah,
    String? errorMessage,
    @Default(false) bool isPlayingAudio,
  }) = _AyahOfTheDayState;
}
