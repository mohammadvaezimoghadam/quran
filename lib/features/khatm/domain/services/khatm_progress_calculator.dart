import 'dart:math';

import '../../../study_plan/domain/entities/study_plan.dart'
    show getGlobalAyahIndex;
import '../../../surah_list/infrastructure/datasources/static_surahs_data.dart';
import '../../infrastructure/datasources/khatm_quran_data.dart';
import '../entities/khatm_ayah_span.dart';
import '../entities/khatm_enums.dart';

/// Result of evaluating reading coverage over a Khatm unit range `[startGlobal..endGlobal]`.
class KhatmProgressEvaluation {
  final List<KhatmAyahSpan> coveredSpans;
  final double progress;
  final bool isCompleted;
  final bool hasNewCoverage;
  final bool isPositionInRange;
  final int coveredAyahsCount;
  final int totalAyahsCount;

  const KhatmProgressEvaluation({
    required this.coveredSpans,
    required this.progress,
    required this.isCompleted,
    required this.hasNewCoverage,
    required this.isPositionInRange,
    required this.coveredAyahsCount,
    required this.totalAyahsCount,
  });
}

/// Shared pure calculation service for Quran Khatm progress tracking.
///
/// Reused by both Personal Khatm sessions and Group Khatm slots so exact
/// global-ayah (1..6236) boundaries, unique-ayah coverage spans, and
/// completion checks stay strictly consistent.
abstract final class KhatmProgressCalculator {
  /// Returns the last (surahId, ayahNumber) contained on Osman Taha [page].
  ///
  /// Handles pages shared across multiple short surahs (such as page 604 containing
  /// Surahs 112, 113, and 114).
  static ({int surahId, int ayahNumber}) getLastAyahForPage(int page) {
    final p = page.clamp(1, 604);
    if (p == 604) {
      return (
        surahId: 114,
        ayahNumber: kStaticQuranSurahs[113].numberOfAyahs,
      );
    }
    final nextStart = KhatmQuranData.getStartAyahForPage(p + 1);
    final nextSurah = nextStart.$1;
    final nextAyah = nextStart.$2;
    if (nextAyah > 1) {
      return (surahId: nextSurah, ayahNumber: nextAyah - 1);
    }
    final prevSurah = (nextSurah - 1).clamp(1, 114);
    return (
      surahId: prevSurah,
      ayahNumber: kStaticQuranSurahs[prevSurah - 1].numberOfAyahs,
    );
  }

  /// Resolves the exact 1-based global ayah range `[startGlobal, endGlobal]` (1..6236)
  /// for any Khatm [unitType] and `[fromUnit..toUnit]` span directly from quran.db tables.
  static ({int startGlobal, int endGlobal}) resolveGlobalAyahRange({
    required KhatmUnitType unitType,
    required int fromUnit,
    required int toUnit,
  }) {
    final loUnit = min(fromUnit, toUnit);
    final hiUnit = max(fromUnit, toUnit);

    switch (unitType) {
      case KhatmUnitType.page:
        final startRange = KhatmQuranData.getGlobalAyahRangeForPage(
          loUnit.clamp(1, 604),
        );
        final endRange = KhatmQuranData.getGlobalAyahRangeForPage(
          hiUnit.clamp(1, 604),
        );
        return (
          startGlobal: startRange.startGlobal,
          endGlobal: endRange.endGlobal,
        );

      case KhatmUnitType.juz:
        final startRange = KhatmQuranData.getGlobalAyahRangeForJuz(
          loUnit.clamp(1, 30),
        );
        final endRange = KhatmQuranData.getGlobalAyahRangeForJuz(
          hiUnit.clamp(1, 30),
        );
        return (
          startGlobal: startRange.startGlobal,
          endGlobal: endRange.endGlobal,
        );

      case KhatmUnitType.hizb:
        final startRange = KhatmQuranData.getGlobalAyahRangeForHizb(
          loUnit.clamp(1, 120),
        );
        final endRange = KhatmQuranData.getGlobalAyahRangeForHizb(
          hiUnit.clamp(1, 120),
        );
        return (
          startGlobal: startRange.startGlobal,
          endGlobal: endRange.endGlobal,
        );

      case KhatmUnitType.surah:
        final startRange = KhatmQuranData.getGlobalAyahRangeForSurah(
          loUnit.clamp(1, 114),
        );
        final endRange = KhatmQuranData.getGlobalAyahRangeForSurah(
          hiUnit.clamp(1, 114),
        );
        return (
          startGlobal: startRange.startGlobal,
          endGlobal: endRange.endGlobal,
        );

      case KhatmUnitType.ayah:
        return (
          startGlobal: loUnit.clamp(1, 6236),
          endGlobal: hiUnit.clamp(1, 6236),
        );
    }
  }

  /// Resolves the Osman Taha start/end page span covering `[fromUnit..toUnit]`.
  static ({int startPage, int endPage}) resolvePageRange({
    required KhatmUnitType unitType,
    required int fromUnit,
    required int toUnit,
  }) {
    final globalRange = resolveGlobalAyahRange(
      unitType: unitType,
      fromUnit: fromUnit,
      toUnit: toUnit,
    );
    return (
      startPage: KhatmQuranData.getPageForGlobalAyah(globalRange.startGlobal),
      endPage: KhatmQuranData.getPageForGlobalAyah(globalRange.endGlobal),
    );
  }

  /// Checks whether `([surahId], [ayahNumber])` falls inside `[fromUnit..toUnit]`
  /// using exact 1-based global-ayah boundaries.
  static bool isPositionInRange({
    required KhatmUnitType unitType,
    required int fromUnit,
    required int toUnit,
    required int surahId,
    required int ayahNumber,
    int? page,
  }) {
    final range = resolveGlobalAyahRange(
      unitType: unitType,
      fromUnit: fromUnit,
      toUnit: toUnit,
    );
    final globalAyah = getGlobalAyahIndex(surahId, ayahNumber);
    return globalAyah >= range.startGlobal && globalAyah <= range.endGlobal;
  }

  /// Evaluates unique-ayah coverage over `[startGlobal..endGlobal]` without
  /// premature threshold shortcuts or out-of-range completion triggers.
  static KhatmProgressEvaluation evaluateProgress({
    required KhatmUnitType unitType,
    required int fromUnit,
    required int toUnit,
    required List<KhatmAyahSpan> existingSpans,
    required double existingProgress,
    required int surahId,
    required int ayahNumber,
    int? coverStartGlobal,
    int? coverEndGlobal,
    bool isAlreadyCompleted = false,
  }) {
    final range = resolveGlobalAyahRange(
      unitType: unitType,
      fromUnit: fromUnit,
      toUnit: toUnit,
    );
    final totalAyahs = (range.endGlobal - range.startGlobal + 1).clamp(1, 6236);
    final clampedExisting = KhatmAyahSpan.mergeSpans(
      existingSpans,
      minGlobal: range.startGlobal,
      maxGlobal: range.endGlobal,
    );

    if (isAlreadyCompleted) {
      return KhatmProgressEvaluation(
        coveredSpans: clampedExisting,
        progress: 1.0,
        isCompleted: false,
        hasNewCoverage: false,
        isPositionInRange: false,
        coveredAyahsCount: totalAyahs,
        totalAyahsCount: totalAyahs,
      );
    }

    final currentGlobal = getGlobalAyahIndex(surahId, ayahNumber);
    final posInRange =
        currentGlobal >= range.startGlobal && currentGlobal <= range.endGlobal;

    final int rawStart;
    final int rawEnd;
    if (coverStartGlobal != null && coverEndGlobal != null) {
      rawStart = min(coverStartGlobal, coverEndGlobal);
      rawEnd = max(coverStartGlobal, coverEndGlobal);
    } else {
      rawStart = currentGlobal;
      rawEnd = currentGlobal;
    }

    final overlapStart = max(rawStart, range.startGlobal);
    final overlapEnd = min(rawEnd, range.endGlobal);

    if (overlapStart > overlapEnd) {
      final existingCount = KhatmAyahSpan.countUniqueAyahs(clampedExisting);
      return KhatmProgressEvaluation(
        coveredSpans: clampedExisting,
        progress: existingProgress.clamp(0.0, 1.0),
        isCompleted: false,
        hasNewCoverage: false,
        isPositionInRange: posInRange,
        coveredAyahsCount: existingCount,
        totalAyahsCount: totalAyahs,
      );
    }

    // Legacy migration: if a session/slot already had scalar progress before
    // `coveredSpans` existed, seed equivalent leading ayahs so progress never drops.
    List<KhatmAyahSpan> baseSpans = clampedExisting;
    if (baseSpans.isEmpty && existingProgress > 0.0) {
      final legacyCount = (existingProgress.clamp(0.0, 0.999) * totalAyahs)
          .floor()
          .clamp(0, totalAyahs - 1);
      if (legacyCount > 0) {
        baseSpans = [
          KhatmAyahSpan(
            start: range.startGlobal,
            end: range.startGlobal + legacyCount - 1,
          ),
        ];
      }
    }

    final nextSpans = KhatmAyahSpan.mergeSpans(
      [
        ...baseSpans,
        KhatmAyahSpan(start: overlapStart, end: overlapEnd),
      ],
      minGlobal: range.startGlobal,
      maxGlobal: range.endGlobal,
    );

    final coveredCount = KhatmAyahSpan.countUniqueAyahs(nextSpans);
    final isCompleted = coveredCount >= totalAyahs;
    final spanProgress = isCompleted
        ? 1.0
        : (coveredCount / totalAyahs).clamp(0.0, 0.9999);
    final nextProgress = isCompleted
        ? 1.0
        : max(existingProgress.clamp(0.0, 0.9999), spanProgress);

    final hasNewCoverage =
        !KhatmAyahSpan.listEquals(nextSpans, clampedExisting) ||
            nextProgress > existingProgress;

    return KhatmProgressEvaluation(
      coveredSpans: nextSpans,
      progress: nextProgress,
      isCompleted: isCompleted,
      hasNewCoverage: hasNewCoverage,
      isPositionInRange: posInRange,
      coveredAyahsCount: coveredCount,
      totalAyahsCount: totalAyahs,
    );
  }

  /// Calculates progress fraction (0.0 to 1.0) preserving [currentProgress] if out of range.
  static double calculateProgress({
    required KhatmUnitType unitType,
    required int fromUnit,
    required int toUnit,
    required double currentProgress,
    required int surahId,
    required int ayahNumber,
    int? page,
    bool isEndOfPage = false,
    double pageFraction = 0.0,
    bool isAlreadyCompleted = false,
    List<KhatmAyahSpan> existingSpans = const [],
    int? coverStartGlobal,
    int? coverEndGlobal,
  }) {
    final eval = evaluateProgress(
      unitType: unitType,
      fromUnit: fromUnit,
      toUnit: toUnit,
      existingSpans: existingSpans,
      existingProgress: currentProgress,
      surahId: surahId,
      ayahNumber: ayahNumber,
      coverStartGlobal: coverStartGlobal,
      coverEndGlobal: coverEndGlobal,
      isAlreadyCompleted: isAlreadyCompleted,
    );
    return eval.progress;
  }

  /// Determines whether the target unit range `[fromUnit..toUnit]` is completed.
  ///
  /// When [coveredSpans] is provided, requires 100% unique-ayah coverage across
  /// `[startGlobal..endGlobal]`. When omitted (stateless check), requires reaching
  /// the exact final global ayah of the range (`endGlobal`) with explicit completion
  /// confirmation (`isEndOfPage` or `computedProgress >= 1.0`).
  static bool checkEndReached({
    required KhatmUnitType unitType,
    required int fromUnit,
    required int toUnit,
    required int surahId,
    required int ayahNumber,
    int? page,
    bool isEndOfPage = false,
    double pageFraction = 0.0,
    double? computedProgress,
    bool isAlreadyCompleted = false,
    List<KhatmAyahSpan>? coveredSpans,
  }) {
    if (isAlreadyCompleted) return false;

    final range = resolveGlobalAyahRange(
      unitType: unitType,
      fromUnit: fromUnit,
      toUnit: toUnit,
    );
    final totalAyahs = (range.endGlobal - range.startGlobal + 1).clamp(1, 6236);

    if (coveredSpans != null) {
      final merged = KhatmAyahSpan.mergeSpans(
        coveredSpans,
        minGlobal: range.startGlobal,
        maxGlobal: range.endGlobal,
      );
      return KhatmAyahSpan.countUniqueAyahs(merged) >= totalAyahs;
    }

    final currentGlobal = getGlobalAyahIndex(surahId, ayahNumber);
    if (currentGlobal != range.endGlobal) {
      return false;
    }

    return isEndOfPage || (computedProgress != null && computedProgress >= 1.0);
  }

  /// Maps the current reading coordinate to the unit-level integer saved in `lastReadUnit`.
  static int resolveUnitValue({
    required KhatmUnitType unitType,
    required int surahId,
    required int ayahNumber,
    int? page,
    int? juz,
    int? hizb,
  }) {
    final globalAyah = getGlobalAyahIndex(surahId, ayahNumber);
    switch (unitType) {
      case KhatmUnitType.page:
        return page ?? KhatmQuranData.getPageForAyah(surahId, ayahNumber);
      case KhatmUnitType.surah:
        return surahId;
      case KhatmUnitType.juz:
        return juz ?? KhatmQuranData.getJuzForGlobalAyah(globalAyah);
      case KhatmUnitType.hizb:
        return hizb ?? KhatmQuranData.getHizbForGlobalAyah(globalAyah);
      case KhatmUnitType.ayah:
        return globalAyah;
    }
  }
}
