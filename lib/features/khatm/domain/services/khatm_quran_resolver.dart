import '../../../study_plan/domain/entities/study_plan.dart'
    show getSurahAndAyahFromGlobalIndex;
import '../../../surah_list/infrastructure/datasources/static_surahs_data.dart';
import '../../infrastructure/datasources/khatm_quran_data.dart';
import '../entities/khatm_enums.dart';

/// Navigation target resolved from a Khatm unit number to open in [QuranReaderScreen].
class KhatmNavigationTarget {
  final int surahId;
  final int ayahNumber;
  final int pageNumber;

  const KhatmNavigationTarget({
    required this.surahId,
    required this.ayahNumber,
    required this.pageNumber,
  });

  @override
  String toString() =>
      'KhatmNavigationTarget(surah: $surahId, ayah: $ayahNumber, page: $pageNumber)';
}

/// Service resolving any unit type & unit number into a concrete Quran reader target.
class KhatmQuranResolver {
  /// Resolves a unit number (e.g. page 122, or hizb 5, or juz 30, or surah 18, or ayah 1500)
  /// into a precise [KhatmNavigationTarget].
  static KhatmNavigationTarget resolveUnit({
    required KhatmUnitType unitType,
    required int unitNumber,
  }) {
    switch (unitType) {
      case KhatmUnitType.page:
        final page = unitNumber.clamp(1, 604);
        final startAyah = KhatmQuranData.getStartAyahForPage(page);
        return KhatmNavigationTarget(
          surahId: startAyah.$1,
          ayahNumber: startAyah.$2,
          pageNumber: page,
        );

      case KhatmUnitType.hizb:
        final hizb = unitNumber.clamp(1, 120);
        final page = KhatmQuranData.getPageForHizb(hizb);
        return resolveUnit(
          unitType: KhatmUnitType.page,
          unitNumber: page,
        );

      case KhatmUnitType.juz:
        final juz = unitNumber.clamp(1, 30);
        final page = KhatmQuranData.getPageForJuz(juz);
        return resolveUnit(
          unitType: KhatmUnitType.page,
          unitNumber: page,
        );

      case KhatmUnitType.surah:
        final surahId = unitNumber.clamp(1, 114);
        final surah = kStaticQuranSurahs[surahId - 1];
        return KhatmNavigationTarget(
          surahId: surahId,
          ayahNumber: 1,
          pageNumber: surah.startPage,
        );

      case KhatmUnitType.ayah:
        final ayahGlobal = unitNumber.clamp(1, 6236);
        final pos = getSurahAndAyahFromGlobalIndex(ayahGlobal);
        final page = KhatmQuranData.getPageForAyah(pos.surahId, pos.ayahNumber);
        return KhatmNavigationTarget(
          surahId: pos.surahId,
          ayahNumber: pos.ayahNumber,
          pageNumber: page,
        );
    }
  }
}
