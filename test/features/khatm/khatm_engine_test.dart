import 'package:flutter_test/flutter_test.dart';
import 'package:quran/common/utils/jalali_date.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';
import 'package:quran/features/khatm/domain/entities/khatm_plan.dart';
import 'package:quran/features/khatm/domain/entities/khatm_session_item.dart';
import 'package:quran/features/khatm/domain/services/khatm_date_engine.dart';
import 'package:quran/features/khatm/domain/services/khatm_quran_resolver.dart';
import 'package:quran/features/khatm/domain/services/khatm_slicing_engine.dart';

void main() {
  group('JalaliDate bidirectional conversion', () {
    test('round-trip conversion between Gregorian and Jalali', () {
      final datesToTest = [
        DateTime(2024, 3, 20), // 1403/01/01
        DateTime(2026, 10, 18),
        DateTime(2020, 1, 1),
        DateTime(2025, 2, 28),
      ];

      for (final dt in datesToTest) {
        final j = JalaliDate.fromDateTime(dt);
        final back = j.toDateTime();
        expect(back.year, equals(dt.year));
        expect(back.month, equals(dt.month));
        expect(back.day, equals(dt.day));
      }
    });

    test('formatLong and monthName', () {
      final dt = DateTime(2026, 10, 18); // 1405/07/26 (یکشنبه)
      final j = JalaliDate.fromDateTime(dt);
      expect(j.monthName, equals('مهر'));
      expect(j.weekdayName, equals('یکشنبه'));
      expect(j.daysInMonth, equals(30));
    });
  });

  group('KhatmSlicingEngine', () {
    test('sliceBySessionCount remainder balanced (604 pages in 5 sessions)', () {
      final slices = KhatmSlicingEngine.sliceBySessionCount(
        rangeFrom: 1,
        rangeTo: 604,
        sessionCount: 5,
      );

      expect(slices.length, equals(5));
      // Base = 120, remainder = 4 -> 121, 121, 121, 121, 120
      expect(slices[0], equals(const KhatmSliceRange(fromUnit: 1, toUnit: 121)));
      expect(slices[1], equals(const KhatmSliceRange(fromUnit: 122, toUnit: 242)));
      expect(slices[2], equals(const KhatmSliceRange(fromUnit: 243, toUnit: 363)));
      expect(slices[3], equals(const KhatmSliceRange(fromUnit: 364, toUnit: 484)));
      expect(slices[4], equals(const KhatmSliceRange(fromUnit: 485, toUnit: 604)));

      final total = slices.fold<int>(0, (sum, s) => sum + s.count);
      expect(total, equals(604));
    });

    test('sliceByUnitQuota (604 pages with quota 10)', () {
      final slices = KhatmSlicingEngine.sliceByUnitQuota(
        rangeFrom: 1,
        rangeTo: 604,
        quotaPerSession: 10,
      );

      // 60 sessions of 10 + 1 session of 4 = 61 sessions
      expect(slices.length, equals(61));
      expect(slices.first, equals(const KhatmSliceRange(fromUnit: 1, toUnit: 10)));
      expect(slices[59], equals(const KhatmSliceRange(fromUnit: 591, toUnit: 600)));
      expect(slices.last, equals(const KhatmSliceRange(fromUnit: 601, toUnit: 604)));
      expect(slices.last.count, equals(4));

      final total = slices.fold<int>(0, (sum, s) => sum + s.count);
      expect(total, equals(604));
    });
  });

  group('KhatmDateEngine', () {
    test('generate daily session dates', () {
      final start = DateTime(2026, 10, 18);
      final dates = KhatmDateEngine.generateSessionDates(
        startDate: start,
        sessionCount: 3,
        cadence: KhatmCadence.daily,
      );

      expect(dates.length, equals(3));
      expect(dates[0], equals(DateTime(2026, 10, 18)));
      expect(dates[1], equals(DateTime(2026, 10, 19)));
      expect(dates[2], equals(DateTime(2026, 10, 20)));
    });

    test('custom weekdays snaps start date if start weekday is not selected', () {
      // 2026-10-18 is Sunday (weekday 7)
      // Selected weekdays: Monday (1) and Thursday (4)
      final start = DateTime(2026, 10, 18);
      final dates = KhatmDateEngine.generateSessionDates(
        startDate: start,
        sessionCount: 2,
        cadence: KhatmCadence.customWeekdays,
        selectedWeekdays: [1, 4],
      );

      expect(dates.length, equals(2));
      // First session should snap to Monday (2026-10-19)
      expect(dates[0], equals(DateTime(2026, 10, 19)));
      expect(dates[0].weekday, equals(1));
      // Second session should be Thursday (2026-10-22)
      expect(dates[1], equals(DateTime(2026, 10, 22)));
      expect(dates[1].weekday, equals(4));
    });
  });

  group('KhatmQuranResolver', () {
    test('resolves page correctly', () {
      final target1 = KhatmQuranResolver.resolveUnit(
        unitType: KhatmUnitType.page,
        unitNumber: 1,
      );
      expect(target1.surahId, equals(1));
      expect(target1.ayahNumber, equals(1));
      expect(target1.pageNumber, equals(1));

      // Page 10 must resolve to Baqarah (surah 2) ayah 62, NOT ayah 1!
      final target10 = KhatmQuranResolver.resolveUnit(
        unitType: KhatmUnitType.page,
        unitNumber: 10,
      );
      expect(target10.surahId, equals(2));
      expect(target10.ayahNumber, equals(62));
      expect(target10.pageNumber, equals(10));

      // Page 49 must resolve to Baqarah (surah 2) ayah 283
      final target49 = KhatmQuranResolver.resolveUnit(
        unitType: KhatmUnitType.page,
        unitNumber: 49,
      );
      expect(target49.surahId, equals(2));
      expect(target49.ayahNumber, equals(283));
      expect(target49.pageNumber, equals(49));
    });

    test('resolves juz correctly', () {
      final target = KhatmQuranResolver.resolveUnit(
        unitType: KhatmUnitType.juz,
        unitNumber: 30,
      );
      expect(target.pageNumber, equals(582));
      expect(target.surahId, equals(78));
      expect(target.ayahNumber, equals(1));
    });

    test('resolves hizb correctly (120 Ahzab)', () {
      final target = KhatmQuranResolver.resolveUnit(
        unitType: KhatmUnitType.hizb,
        unitNumber: 2,
      );
      expect(target.pageNumber, equals(7));
      expect(target.surahId, equals(2));
      expect(target.ayahNumber, equals(38));
    });
  });

  group('KhatmPlan serialization & progress', () {
    test('toMap and fromMap preserves all fields and computes progress', () {
      final now = DateTime(2026, 10, 18);
      final sessions = [
        KhatmSessionItem(
          sessionIndex: 0,
          fromUnit: 1,
          toUnit: 10,
          scheduledDate: now,
          isCompleted: true,
          completedAt: now,
        ),
        KhatmSessionItem(
          sessionIndex: 1,
          fromUnit: 11,
          toUnit: 20,
          scheduledDate: now.add(const Duration(days: 1)),
          isCompleted: false,
        ),
      ];

      final plan = KhatmPlan(
        id: 'test-khatm-1',
        title: 'ختم سلامتی',
        unitType: KhatmUnitType.page,
        rangeFrom: 1,
        rangeTo: 20,
        planningMode: KhatmPlanningMode.bySessionCount,
        sessionCount: 2,
        quotaPerSession: 10,
        cadence: KhatmCadence.daily,
        startDateTime: now,
        endDateTime: now.add(const Duration(days: 1)),
        sessions: sessions,
        createdAt: now,
      );

      expect(plan.totalUnits, equals(20));
      expect(plan.completedUnits, equals(10));
      expect(plan.remainingUnits, equals(10));
      expect(plan.progressPercentage, equals(0.5));
      expect(plan.progressPercentInt, equals(50));
      expect(plan.isCompleted, isFalse);
      expect(plan.nextPendingSession?.sessionIndex, equals(1));

      final map = plan.toMap();
      final restored = KhatmPlan.fromMap(map);

      expect(restored.id, equals(plan.id));
      expect(restored.title, equals(plan.title));
      expect(restored.unitType, equals(plan.unitType));
      expect(restored.sessions.length, equals(2));
      expect(restored.sessions[0].isCompleted, isTrue);
      expect(restored.sessions[1].isCompleted, isFalse);
    });
  });
}
