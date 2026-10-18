import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/common/widgets/app_modal_header.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';
import 'package:quran/features/khatm/domain/entities/khatm_session_item.dart';
import 'package:quran/features/khatm/presentation/widgets/report/khatm_continue_button.dart';
import 'package:quran/features/khatm/presentation/widgets/report/khatm_date_range_card.dart';
import 'package:quran/features/khatm/presentation/widgets/report/khatm_progress_donut_chart.dart';
import 'package:quran/features/khatm/presentation/widgets/report/khatm_session_tile.dart';
import 'package:quran/features/khatm/presentation/widgets/wizard/khatm_live_preview_card.dart';
import 'package:quran/features/khatm/presentation/widgets/wizard/khatm_planning_mode_radio.dart';
import 'package:quran/features/khatm/presentation/widgets/wizard/khatm_cadence_selector.dart';
import 'package:quran/features/khatm/presentation/widgets/wizard/khatm_step_indicator.dart';
import 'package:quran/features/khatm/presentation/widgets/wizard/khatm_unit_type_selector.dart';

void main() {
  group('Khatm Wizard Widgets', () {
    testWidgets('KhatmStepIndicator renders 3 steps and active step', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KhatmStepIndicator(currentStep: 1),
          ),
        ),
      );

      expect(find.text('اطلاعات ختم'), findsOneWidget);
      expect(find.text('برنامه‌ریزی ختم'), findsOneWidget);
      expect(find.text('تایید نهایی'), findsOneWidget);
    });

    testWidgets('KhatmPlanningModeRadio switches planning mode', (tester) async {
      KhatmPlanningMode selected = KhatmPlanningMode.bySessionCount;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return KhatmPlanningModeRadio(
                  selected: selected,
                  unitLabel: 'حزب',
                  onChanged: (mode) => setState(() => selected = mode),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('براساس جلسه'), findsOneWidget);
      expect(find.text('براساس حزب'), findsOneWidget);

      await tester.tap(find.text('براساس حزب'));
      await tester.pump();

      expect(selected, equals(KhatmPlanningMode.byUnitQuota));
    });

    testWidgets('KhatmLivePreviewCard displays preview text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KhatmLivePreviewCard(
              previewText: 'تعداد صفحه در هر جلسه ≈ 121',
            ),
          ),
        ),
      );

      // Digits are converted to Persian in KhatmLivePreviewCard
      expect(find.text('تعداد صفحه در هر جلسه ≈ ۱۲۱'), findsOneWidget);
    });

    testWidgets('KhatmUnitTypeSelector opens modal with AppModalHeader and selects type', (tester) async {
      KhatmUnitType selected = KhatmUnitType.page;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return KhatmUnitTypeSelector(
                  selected: selected,
                  onChanged: (type) => setState(() => selected = type),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('نوع ختم'), findsOneWidget);
      expect(find.text('صفحه'), findsOneWidget);

      // Open bottom sheet
      await tester.tap(find.text('صفحه'));
      await tester.pumpAndSettle();

      // Check modal header and title
      expect(find.text('انتخاب نوع ختم'), findsOneWidget);
      expect(find.byType(AppModalHeader), findsOneWidget);

      // Select 'حزب'
      await tester.tap(find.text('حزب'));
      await tester.pumpAndSettle();

      expect(selected, equals(KhatmUnitType.hizb));
      expect(find.text('انتخاب نوع ختم'), findsNothing);
    });

    testWidgets('KhatmCadenceSelector opens modal with AppModalHeader and selects cadence', (tester) async {
      KhatmCadence selected = KhatmCadence.daily;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return KhatmCadenceSelector(
                  selected: selected,
                  onChanged: (c) => setState(() => selected = c),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('نحوه برگزاری'), findsOneWidget);
      expect(find.text('روزانه'), findsOneWidget);

      // Open bottom sheet
      await tester.tap(find.text('روزانه'));
      await tester.pumpAndSettle();

      // Check modal header and title
      expect(find.byType(AppModalHeader), findsOneWidget);
      expect(find.text('دوره زمانی و تکرار جلسات ختم را انتخاب کنید'), findsOneWidget);

      // Select 'یک‌روزدرمیان'
      await tester.tap(find.text('یک‌روزدرمیان'));
      await tester.pumpAndSettle();

      expect(selected, equals(KhatmCadence.everyOtherDay));
      expect(find.text('دوره زمانی و تکرار جلسات ختم را انتخاب کنید'), findsNothing);
    });
  });

  group('Khatm Report Widgets', () {
    testWidgets('KhatmProgressDonutChart renders title and legends', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KhatmProgressDonutChart(
              title: 'تست',
              totalUnits: 604,
              completedUnits: 121,
              unitLabel: 'صفحه',
            ),
          ),
        ),
      );

      expect(find.text('گزارش "تست"'), findsOneWidget);
      expect(find.textContaining('باقی مانده'), findsOneWidget);
      expect(find.textContaining('تلاوت شده'), findsOneWidget);
    });

    testWidgets('KhatmDateRangeCard displays start and end dates', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KhatmDateRangeCard(
              startDateFa: '1405/07/23',
              endDateFa: '1405/07/27',
            ),
          ),
        ),
      );

      expect(find.text('تاریخ شروع'), findsOneWidget);
      expect(find.text('تاریخ پایان'), findsOneWidget);
    });

    testWidgets('KhatmSessionTile displays session info and triggers toggle', (tester) async {
      bool toggled = false;
      final session = KhatmSessionItem(
        sessionIndex: 0,
        fromUnit: 1,
        toUnit: 121,
        scheduledDate: DateTime(2026, 10, 18),
        isCompleted: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KhatmSessionTile(
              session: session,
              unitType: KhatmUnitType.page,
              onToggle: (val) => toggled = val,
            ),
          ),
        ),
      );

      expect(find.text('صفحه ۱ تا ۱۲۱'), findsOneWidget);
      await tester.tap(find.text('صفحه ۱ تا ۱۲۱'));
      await tester.pump();

      expect(toggled, isTrue);
    });

    testWidgets('KhatmContinueButton triggers onPressed', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KhatmContinueButton(
              isEnabled: true,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('ادامه ختم'));
      await tester.pump();

      expect(pressed, isTrue);
    });
  });
}
