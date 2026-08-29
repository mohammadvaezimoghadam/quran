import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../common/constants/app_constants.dart';

part 'surah_entity.freezed.dart';

/// Domain entity representing a Surah
@freezed
abstract class SurahEntity with _$SurahEntity {
  const factory SurahEntity({
    required int number,
    required String name,
    required String englishName,
    required String englishNameTranslation,
    required int numberOfAyahs,
    required String revelationType,
    required int startPage,
    required int startJuz,
  }) = _SurahEntity;
}

extension SurahEntityX on SurahEntity {
  bool get isMeccan =>
      revelationType.toLowerCase().contains('meccan') ||
      revelationType.contains('مك') ||
      revelationType.contains('مکی');

  String get revelationTypeFa => isMeccan ? 'مکی' : 'مدنی';

  int get startHizb => ((startJuz - 1) * 2) + 1;

  int get revelationOrder =>
      AppConstants.surahRevelationOrderMap[number] ?? number;
}

