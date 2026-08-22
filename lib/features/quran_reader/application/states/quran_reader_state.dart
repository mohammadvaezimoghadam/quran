import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/ayah_entity.dart';

part 'quran_reader_state.freezed.dart';

@freezed
abstract class QuranReaderState with _$QuranReaderState {
  const factory QuranReaderState({
    @Default(true) bool isLoading,
    @Default(1) int currentSurahId,
    @Default([]) List<AyahEntity> ayahs,
    String? errorMessage,
  }) = _QuranReaderState;
}
