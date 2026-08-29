import 'package:freezed_annotation/freezed_annotation.dart';

part 'continue_reading_state.freezed.dart';
part 'continue_reading_state.g.dart';

@freezed
abstract class ContinueReadingState with _$ContinueReadingState {
  const factory ContinueReadingState({
    required int surahId,
    required String surahName,
    required int ayahNumber,
    required int totalAyahs,
  }) = _ContinueReadingState;

  factory ContinueReadingState.fromJson(Map<String, dynamic> json) =>
      _$ContinueReadingStateFromJson(json);
}
