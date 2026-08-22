import 'package:freezed_annotation/freezed_annotation.dart';

part 'ayah_of_the_day.freezed.dart';

/// Domain entity representing the "Verse of the Day"
@freezed
abstract class AyahOfTheDay with _$AyahOfTheDay {
  const factory AyahOfTheDay({
    required int ayahNumber,
    required String arabicText,
    required String translationText,
    required String surahName,
    required int surahNumber,
    required String audioUrl,
  }) = _AyahOfTheDay;
}
