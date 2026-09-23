import '../domain/entities/ayah_target.dart';
import '../domain/quran_navigation_service.dart';

/// Web implementation of [IQuranNavigationService] using static Quran metadata
class WebQuranNavigationServiceImpl implements IQuranNavigationService {
  const WebQuranNavigationServiceImpl();

  @override
  Future<AyahTarget?> getTargetBySurah(int surahId, {int ayahNumber = 1}) async {
    if (surahId < 1 || surahId > 114) return null;
    return AyahTarget(
      surahId: surahId,
      ayahNumber: ayahNumber < 1 ? 1 : ayahNumber,
    );
  }

  @override
  Future<AyahTarget?> getTargetByPage(int page) async {
    if (page < 1 || page > 604) return null;
    // Medina Mushaf page mappings
    for (int i = _surahStartPages.length - 1; i >= 0; i--) {
      if (page >= _surahStartPages[i]) {
        return AyahTarget(
          surahId: i + 1,
          ayahNumber: 1,
        );
      }
    }
    return const AyahTarget(surahId: 1, ayahNumber: 1);
  }

  @override
  Future<AyahTarget?> getTargetByJuz(int juz) async {
    if (juz < 1 || juz > 30) return null;
    final surahId = _juzStartSurahs[juz - 1];
    final ayahNumber = _juzStartAyahs[juz - 1];
    return AyahTarget(
      surahId: surahId,
      ayahNumber: ayahNumber,
    );
  }

  @override
  Future<AyahTarget?> getTargetByHizb(int hizb) async {
    if (hizb < 1 || hizb > 60) return null;
    final juz = ((hizb - 1) ~/ 2) + 1;
    return getTargetByJuz(juz);
  }

  static const List<int> _surahStartPages = [
    1, 2, 50, 77, 106, 128, 151, 177, 187, 208, 221, 235, 249, 255, 262, 267,
    282, 293, 305, 312, 322, 332, 342, 350, 359, 367, 377, 385, 396, 404, 411,
    415, 418, 428, 434, 440, 446, 453, 458, 467, 477, 483, 489, 496, 499, 502,
    507, 511, 515, 518, 520, 523, 526, 528, 531, 534, 537, 542, 545, 549, 551,
    553, 554, 556, 558, 560, 562, 564, 566, 568, 570, 572, 574, 575, 577, 578,
    580, 582, 583, 585, 586, 587, 587, 589, 590, 591, 591, 592, 593, 594, 595,
    595, 596, 596, 597, 597, 598, 598, 599, 599, 600, 600, 601, 601, 601, 602,
    602, 602, 603, 603, 603, 604, 604, 604
  ];

  static const List<int> _juzStartSurahs = [
    1, 2, 2, 3, 4, 4, 5, 6, 7, 8, 9, 11, 12, 15, 17, 18,
    21, 23, 25, 27, 29, 33, 36, 39, 41, 46, 51, 58, 67, 78
  ];

  static const List<int> _juzStartAyahs = [
    1, 142, 253, 93, 24, 148, 82, 111, 88, 41, 93, 6, 53, 1, 1, 75,
    1, 1, 21, 56, 46, 31, 28, 32, 47, 1, 31, 1, 1, 1
  ];
}
