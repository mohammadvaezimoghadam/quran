import '../../../study_plan/domain/entities/study_plan.dart'
    show getSurahAndAyahFromGlobalIndex;
import '../../../surah_list/infrastructure/datasources/static_surahs_data.dart';
import '../../infrastructure/datasources/khatm_quran_data.dart';
import '../entities/khatm_enums.dart';
import '../entities/khatm_session_item.dart';
import 'khatm_progress_calculator.dart';

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
  /// into a precise [KhatmNavigationTarget] using exact quran.db global-ayah boundaries.
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
        final startGlobal =
            KhatmQuranData.getGlobalAyahRangeForHizb(hizb).startGlobal;
        final pos = getSurahAndAyahFromGlobalIndex(startGlobal);
        final page = KhatmQuranData.getPageForAyah(pos.surahId, pos.ayahNumber);
        return KhatmNavigationTarget(
          surahId: pos.surahId,
          ayahNumber: pos.ayahNumber,
          pageNumber: page,
        );

      case KhatmUnitType.juz:
        final juz = unitNumber.clamp(1, 30);
        final startGlobal =
            KhatmQuranData.getGlobalAyahRangeForJuz(juz).startGlobal;
        final pos = getSurahAndAyahFromGlobalIndex(startGlobal);
        final page = KhatmQuranData.getPageForAyah(pos.surahId, pos.ayahNumber);
        return KhatmNavigationTarget(
          surahId: pos.surahId,
          ayahNumber: pos.ayahNumber,
          pageNumber: page,
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

  /// Resolves the best resume target for a Personal Khatm [session], preferring
  /// exact `(lastSurahId, lastAyahNumber)` coordinates when in range, then
  /// `lastReadUnit`, and finally `session.fromUnit`.
  static KhatmNavigationTarget resolveSessionResumeTarget({
    required KhatmUnitType unitType,
    required KhatmSessionItem session,
  }) {
    if (!session.isCompleted &&
        session.lastSurahId != null &&
        session.lastAyahNumber != null) {
      final inRange = KhatmProgressCalculator.isPositionInRange(
        unitType: unitType,
        fromUnit: session.fromUnit,
        toUnit: session.toUnit,
        surahId: session.lastSurahId!,
        ayahNumber: session.lastAyahNumber!,
      );
      if (inRange) {
        return KhatmNavigationTarget(
          surahId: session.lastSurahId!,
          ayahNumber: session.lastAyahNumber!,
          pageNumber: KhatmQuranData.getPageForAyah(
            session.lastSurahId!,
            session.lastAyahNumber!,
          ),
        );
      }
    }

    final unitToNavigate =
        (!session.isCompleted &&
                session.lastReadUnit != null &&
                session.lastReadUnit! >= session.fromUnit &&
                session.lastReadUnit! <= session.toUnit)
            ? session.lastReadUnit!
            : session.fromUnit;

    return resolveUnit(
      unitType: unitType,
      unitNumber: unitToNavigate,
    );
  }
}
