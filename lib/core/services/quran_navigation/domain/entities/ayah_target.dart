import 'package:freezed_annotation/freezed_annotation.dart';

part 'ayah_target.freezed.dart';

@freezed
abstract class AyahTarget with _$AyahTarget {
  const factory AyahTarget({
    required int surahId,
    required int ayahNumber,
  }) = _AyahTarget;
}
