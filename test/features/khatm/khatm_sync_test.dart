import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/features/khatm/application/controllers/khatm_detail_controller.dart';
import 'package:quran/features/khatm/application/controllers/khatm_list_controller.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';
import 'package:quran/features/khatm/domain/entities/khatm_plan.dart';
import 'package:quran/features/khatm/domain/entities/khatm_session_item.dart';
import 'package:quran/features/khatm/infrastructure/datasources/khatm_local_datasource.dart';
import 'package:quran/features/khatm/presentation/widgets/reader/khatm_reader_bar.dart';
import 'package:quran/features/khatm/presentation/widgets/shared/khatm_home_section.dart';

class InMemoryKhatmDataSource implements IKhatmLocalDataSource {
  final Map<String, KhatmPlan> plans = {};

  InMemoryKhatmDataSource(List<KhatmPlan> initial) {
    for (final p in initial) {
      plans[p.id] = p;
    }
  }

  @override
  Future<void> clearAll() async => plans.clear();

  @override
  Future<void> deletePlan(String id) async => plans.remove(id);

  @override
  Future<List<KhatmPlan>> getActivePlans() async => plans.values.toList();

  @override
  Future<List<KhatmPlan>> getAllPlans() async => plans.values.toList();

  @override
  Future<KhatmPlan?> getPlan(String id) async => plans[id];

  @override
  Future<void> savePlan(KhatmPlan plan) async {
    plans[plan.id] = plan;
  }

  @override
  Future<void> updateSessionStatus({
    required String planId,
    required int sessionIndex,
    required bool isCompleted,
  }) async {
    final p = plans[planId];
    if (p == null) return;
    final updated = p.sessions.map((s) {
      if (s.sessionIndex == sessionIndex) {
        return s.copyWith(
          isCompleted: isCompleted,
          progress: isCompleted ? 1.0 : 0.0,
        );
      }
      return s;
    }).toList();
    plans[planId] = p.copyWith(sessions: updated);
  }

  @override
  Future<void> updateSessionProgress({
    required String planId,
    required int sessionIndex,
    required double progress,
    int? lastReadUnit,
    bool? isCompleted,
  }) async {
    final p = plans[planId];
    if (p == null) return;
    final updated = p.sessions.map((s) {
      if (s.sessionIndex == sessionIndex) {
        final completed = isCompleted ?? (progress >= 1.0 ? true : s.isCompleted);
        return s.copyWith(
          progress: progress,
          lastReadUnit: lastReadUnit ?? s.lastReadUnit,
          isCompleted: completed,
        );
      }
      return s;
    }).toList();
    plans[planId] = p.copyWith(sessions: updated);
  }
  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

void main() {
  testWidgets('Tapping complete in KhatmReaderBar updates KhatmHomeSection',
      (tester) async {
    final now = DateTime(2026, 3, 1);
    final initialPlan = KhatmPlan(
      id: 'khatm-1',
      title: 'ختم اول',
      unitType: KhatmUnitType.page,
      rangeFrom: 1,
      rangeTo: 604,
      planningMode: KhatmPlanningMode.bySessionCount,
      sessionCount: 2,
      quotaPerSession: 302,
      cadence: KhatmCadence.daily,
      startDateTime: now,
      endDateTime: now.add(const Duration(days: 2)),
      sessions: [
        KhatmSessionItem(
          sessionIndex: 0,
          fromUnit: 1,
          toUnit: 302,
          scheduledDate: now,
          isCompleted: false,
        ),
        KhatmSessionItem(
          sessionIndex: 1,
          fromUnit: 303,
          toUnit: 604,
          scheduledDate: now.add(const Duration(days: 1)),
          isCompleted: false,
        ),
      ],
      createdAt: now,
    );

    final dataSource = InMemoryKhatmDataSource([initialPlan]);

    final container = ProviderContainer(
      overrides: [
        khatmLocalDataSourceProvider.overrideWithValue(dataSource),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  KhatmHomeSection(),
                  KhatmReaderBar(khatmId: 'khatm-1', sessionIndex: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Initially: Home section has جلسه ۱ از ۲ and reader bar does not show completion badge
    expect(find.text('جلسه ۱ از ۲ • صفحه ۱ تا ۳۰۲'), findsOneWidget);
    expect(find.text('تکمیل شد'), findsNothing);

    // Complete session 0
    await container
        .read(khatmDetailControllerProvider('khatm-1').notifier)
        .toggleSession(0, true);
    await container.read(khatmListControllerProvider.notifier).loadPlans();
    await tester.pumpAndSettle();

    // In KhatmReaderBar, when the session is completed, it closes and disappears
    expect(find.text('اتمام جلسه'), findsNothing);

    // Now verify if KhatmHomeSection updated to session 2 of 2!
    expect(find.text('جلسه ۲ از ۲ • صفحه ۳۰۳ تا ۶۰۴'), findsOneWidget);
  });

  test('KhatmDetailController.recordReadingProgress auto-completes session when reaching end of session', () async {
    final now = DateTime(2026, 3, 1);
    final plan = KhatmPlan(
      id: 'khatm-auto-1',
      title: 'ختم تستی',
      unitType: KhatmUnitType.page,
      rangeFrom: 1,
      rangeTo: 10,
      planningMode: KhatmPlanningMode.bySessionCount,
      sessionCount: 2,
      quotaPerSession: 5,
      cadence: KhatmCadence.daily,
      startDateTime: now,
      endDateTime: now.add(const Duration(days: 2)),
      sessions: [
        KhatmSessionItem(
          sessionIndex: 0,
          fromUnit: 1,
          toUnit: 5,
          scheduledDate: now,
          isCompleted: false,
        ),
        KhatmSessionItem(
          sessionIndex: 1,
          fromUnit: 6,
          toUnit: 10,
          scheduledDate: now.add(const Duration(days: 1)),
          isCompleted: false,
        ),
      ],
      createdAt: now,
    );

    final dataSource = InMemoryKhatmDataSource([plan]);
    final container = ProviderContainer(
      overrides: [
        khatmLocalDataSourceProvider.overrideWithValue(dataSource),
      ],
    );

    // Keep autoDispose provider alive during the test
    final subscription = container.listen(
      khatmDetailControllerProvider('khatm-auto-1'),
      (_, _) {},
    );

    final controller =
        container.read(khatmDetailControllerProvider('khatm-auto-1').notifier);
    await container.pump();

    // 1. Reading on page 3 (not yet the end of session 0): should NOT complete, but progress is 40%
    final res1 = await controller.recordReadingProgress(
      sessionIndex: 0,
      surahId: 2,
      ayahNumber: 10,
      page: 3,
      isEndOfPage: false,
    );
    expect(res1, isFalse);
    expect(container.read(khatmDetailControllerProvider('khatm-auto-1')).plan!.sessions[0].isCompleted, isFalse);
    expect(container.read(khatmDetailControllerProvider('khatm-auto-1')).plan!.sessions[0].progressPercentInt, equals(40));

    // 2. Reading on page 5 but not yet end of page: should NOT complete, but progress is 80%
    final res2 = await controller.recordReadingProgress(
      sessionIndex: 0,
      surahId: 2,
      ayahNumber: 26,
      page: 5,
      isEndOfPage: false,
    );
    expect(res2, isFalse);
    expect(container.read(khatmDetailControllerProvider('khatm-auto-1')).plan!.sessions[0].isCompleted, isFalse);
    expect(container.read(khatmDetailControllerProvider('khatm-auto-1')).plan!.sessions[0].progressPercentInt, equals(80));

    // 3. User reaches end of page 5: should AUTO-COMPLETE session 0!
    final res3 = await controller.recordReadingProgress(
      sessionIndex: 0,
      surahId: 2,
      ayahNumber: 29,
      page: 5,
      isEndOfPage: true,
    );
    expect(res3, isTrue);
    expect(container.read(khatmDetailControllerProvider('khatm-auto-1')).plan!.sessions[0].isCompleted, isTrue);
    expect(container.read(khatmDetailControllerProvider('khatm-auto-1')).plan!.sessions[0].progressPercentInt, equals(100));

    // 4. Repeated call on already completed session: returns false (no duplicate completion)
    final res4 = await controller.recordReadingProgress(
      sessionIndex: 0,
      surahId: 2,
      ayahNumber: 29,
      page: 5,
      isEndOfPage: true,
    );
    expect(res4, isFalse);

    subscription.close();
    container.dispose();
  });

  test('KhatmDetailController.recordReadingProgress does not auto-complete session when jumping 20 pages forward (each goal is independent)', () async {
    final now = DateTime(2026, 3, 1);
    final plan = KhatmPlan(
      id: 'khatm-jump-1',
      title: 'ختم پرش',
      unitType: KhatmUnitType.page,
      rangeFrom: 1,
      rangeTo: 30,
      planningMode: KhatmPlanningMode.bySessionCount,
      sessionCount: 6,
      quotaPerSession: 5,
      cadence: KhatmCadence.daily,
      startDateTime: now,
      endDateTime: now.add(const Duration(days: 6)),
      sessions: [
        KhatmSessionItem(
          sessionIndex: 0,
          fromUnit: 1,
          toUnit: 5,
          scheduledDate: now,
          isCompleted: false,
        ),
      ],
      createdAt: now,
    );

    final dataSource = InMemoryKhatmDataSource([plan]);
    final container = ProviderContainer(
      overrides: [
        khatmLocalDataSourceProvider.overrideWithValue(dataSource),
      ],
    );

    final subscription = container.listen(
      khatmDetailControllerProvider('khatm-jump-1'),
      (_, _) {},
    );

    final controller =
        container.read(khatmDetailControllerProvider('khatm-jump-1').notifier);
    await container.pump();

    // User is reading 20 pages forward (at page 21): session 0 (pages 1-5) must NOT auto-complete!
    final res = await controller.recordReadingProgress(
      sessionIndex: 0,
      surahId: 2,
      ayahNumber: 135,
      page: 21,
      isEndOfPage: false,
    );
    expect(res, isFalse);
    expect(container.read(khatmDetailControllerProvider('khatm-jump-1')).plan!.sessions[0].isCompleted, isFalse);

    subscription.close();
    container.dispose();
  });

  test('Completing a middle session and scrolling inside it does NOT auto-complete earlier sessions', () async {
    final now = DateTime(2026, 3, 1);
    final plan = KhatmPlan(
      id: 'khatm-indep-1',
      title: 'ختم اهداف مستقل',
      unitType: KhatmUnitType.page,
      rangeFrom: 1,
      rangeTo: 60,
      planningMode: KhatmPlanningMode.bySessionCount,
      sessionCount: 6,
      quotaPerSession: 10,
      cadence: KhatmCadence.daily,
      startDateTime: now,
      endDateTime: now.add(const Duration(days: 6)),
      sessions: [
        for (int i = 0; i < 6; i++)
          KhatmSessionItem(
            sessionIndex: i,
            fromUnit: (i * 10) + 1,
            toUnit: (i + 1) * 10,
            scheduledDate: now.add(Duration(days: i)),
            isCompleted: i == 4, // Session 4 (pages 41-50) completed from the middle
            progress: i == 4 ? 1.0 : 0.0,
          ),
      ],
      createdAt: now,
    );

    final dataSource = InMemoryKhatmDataSource([plan]);
    final container = ProviderContainer(
      overrides: [
        khatmLocalDataSourceProvider.overrideWithValue(dataSource),
      ],
    );

    final subscription = container.listen(
      khatmDetailControllerProvider('khatm-indep-1'),
      (_, _) {},
    );

    final controller =
        container.read(khatmDetailControllerProvider('khatm-indep-1').notifier);
    await container.pump();

    // User is on page 45 (inside completed session 4), scrolling up and down:
    final res = await controller.recordReadingProgress(
      sessionIndex: 4,
      surahId: 2,
      ayahNumber: 260,
      page: 45,
      isEndOfPage: false,
    );

    expect(res, isFalse);
    final currentPlan = container.read(khatmDetailControllerProvider('khatm-indep-1')).plan!;
    // Earlier sessions (0, 1, 2, 3) MUST remain incomplete!
    expect(currentPlan.sessions[0].isCompleted, isFalse);
    expect(currentPlan.sessions[1].isCompleted, isFalse);
    expect(currentPlan.sessions[2].isCompleted, isFalse);
    expect(currentPlan.sessions[3].isCompleted, isFalse);
    expect(currentPlan.sessions[4].isCompleted, isTrue);
    expect(currentPlan.sessions[5].isCompleted, isFalse);

    subscription.close();
    container.dispose();
  });

  test('Reading on target page (page 60) completes session and avoids 97% trap', () async {
    final now = DateTime.now();
    final plan = KhatmPlan(
      id: 'khatm-page-60',
      title: 'ختم جزء ۳',
      unitType: KhatmUnitType.page,
      rangeFrom: 41,
      rangeTo: 60,
      planningMode: KhatmPlanningMode.byUnitQuota,
      sessionCount: 1,
      quotaPerSession: 20,
      cadence: KhatmCadence.daily,
      startDateTime: now,
      endDateTime: now.add(const Duration(days: 1)),
      sessions: [
        KhatmSessionItem(
          sessionIndex: 0,
          fromUnit: 41,
          toUnit: 60,
          scheduledDate: now,
          isCompleted: false,
        ),
      ],
      createdAt: now,
    );

    final dataSource = InMemoryKhatmDataSource([plan]);
    final container = ProviderContainer(
      overrides: [
        khatmLocalDataSourceProvider.overrideWithValue(dataSource),
      ],
    );

    final subscription = container.listen(
      khatmDetailControllerProvider('khatm-page-60'),
      (_, _) {},
    );

    final controller =
        container.read(khatmDetailControllerProvider('khatm-page-60').notifier);
    await container.pump();

    // User is on page 60 with substantial reading (pageFraction 0.75): must complete, not trap at 97%
    final res = await controller.recordReadingProgress(
      sessionIndex: 0,
      surahId: 3,
      ayahNumber: 82,
      page: 60,
      pageFraction: 0.75,
      isEndOfPage: false,
    );

    expect(res, isTrue);
    final session = container
        .read(khatmDetailControllerProvider('khatm-page-60'))
        .plan!
        .sessions[0];
    expect(session.isCompleted, isTrue);
    expect(session.progressPercentInt, equals(100));

    subscription.close();
    container.dispose();
  });

  test('Scrolling forward past completed session does NOT auto-advance or affect other sessions', () async {
    final now = DateTime.now();
    final plan = KhatmPlan(
      id: 'khatm-auto-advance',
      title: 'ختم دوره‌ای',
      unitType: KhatmUnitType.page,
      rangeFrom: 1,
      rangeTo: 40,
      planningMode: KhatmPlanningMode.byUnitQuota,
      sessionCount: 2,
      quotaPerSession: 20,
      cadence: KhatmCadence.daily,
      startDateTime: now,
      endDateTime: now.add(const Duration(days: 2)),
      sessions: [
        KhatmSessionItem(
          sessionIndex: 0,
          fromUnit: 1,
          toUnit: 20,
          scheduledDate: now,
          isCompleted: true,
          progress: 1.0,
        ),
        KhatmSessionItem(
          sessionIndex: 1,
          fromUnit: 21,
          toUnit: 40,
          scheduledDate: now.add(const Duration(days: 1)),
          isCompleted: false,
          progress: 0.0,
        ),
      ],
      createdAt: now,
    );

    final dataSource = InMemoryKhatmDataSource([plan]);
    final container = ProviderContainer(
      overrides: [
        khatmLocalDataSourceProvider.overrideWithValue(dataSource),
      ],
    );

    final subscription = container.listen(
      khatmDetailControllerProvider('khatm-auto-advance'),
      (_, _) {},
    );

    final controller =
        container.read(khatmDetailControllerProvider('khatm-auto-advance').notifier);
    await container.pump();

    // User is on page 25 (inside session 1): recordReadingProgress for session 0 returns false and touches nothing
    final res = await controller.recordReadingProgress(
      sessionIndex: 0,
      surahId: 2,
      ayahNumber: 164,
      page: 25,
      pageFraction: 0.3,
    );
    expect(res, isFalse);

    // Session 1 must remain untouched and incomplete
    final currentPlan = container.read(khatmDetailControllerProvider('khatm-auto-advance')).plan!;
    expect(currentPlan.sessions[1].isCompleted, isFalse);
    expect(currentPlan.sessions[1].progress, equals(0.0));

    subscription.close();
    container.dispose();
  });

  test('Scrolling backward before active session does NOT compute percentage or touch previous sessions', () async {
    final now = DateTime.now();
    final plan = KhatmPlan(
      id: 'khatm-backward-scroll',
      title: 'ختم اسکرول معکوس',
      unitType: KhatmUnitType.page,
      rangeFrom: 1,
      rangeTo: 40,
      planningMode: KhatmPlanningMode.byUnitQuota,
      sessionCount: 2,
      quotaPerSession: 20,
      cadence: KhatmCadence.daily,
      startDateTime: now,
      endDateTime: now.add(const Duration(days: 2)),
      sessions: [
        KhatmSessionItem(
          sessionIndex: 0,
          fromUnit: 1,
          toUnit: 20,
          scheduledDate: now,
          isCompleted: false,
          progress: 0.0,
        ),
        KhatmSessionItem(
          sessionIndex: 1,
          fromUnit: 21,
          toUnit: 40,
          scheduledDate: now.add(const Duration(days: 1)),
          isCompleted: false,
          progress: 0.5,
        ),
      ],
      createdAt: now,
    );

    final dataSource = InMemoryKhatmDataSource([plan]);
    final container = ProviderContainer(
      overrides: [
        khatmLocalDataSourceProvider.overrideWithValue(dataSource),
      ],
    );

    final subscription = container.listen(
      khatmDetailControllerProvider('khatm-backward-scroll'),
      (_, _) {},
    );

    final controller =
        container.read(khatmDetailControllerProvider('khatm-backward-scroll').notifier);
    await container.pump();

    // User is reading session 1, but scrolls backward to page 10 (inside session 0):
    final res = await controller.recordReadingProgress(
      sessionIndex: 1,
      surahId: 2,
      ayahNumber: 62,
      page: 10,
    );

    expect(res, isFalse);
    final currentPlan = container.read(khatmDetailControllerProvider('khatm-backward-scroll')).plan!;
    // Session 0 must NOT be modified or have percentages added:
    expect(currentPlan.sessions[0].isCompleted, isFalse);
    expect(currentPlan.sessions[0].progress, equals(0.0));
    // Session 1 preserves its progress:
    expect(currentPlan.sessions[1].progress, equals(0.5));

    subscription.close();
    container.dispose();
  });

  testWidgets('KhatmReaderBar animates height and tapping collapsed bar expands it',
      (tester) async {
    final now = DateTime(2026, 3, 1);
    final plan = KhatmPlan(
      id: 'khatm-collapse-test',
      title: 'ختم تستی اسکرول',
      unitType: KhatmUnitType.page,
      rangeFrom: 1,
      rangeTo: 20,
      sessionCount: 1,
      quotaPerSession: 20,
      cadence: KhatmCadence.daily,
      planningMode: KhatmPlanningMode.bySessionCount,
      startDateTime: now,
      endDateTime: now.add(const Duration(days: 1)),
      sessions: [
        KhatmSessionItem(
          sessionIndex: 0,
          fromUnit: 1,
          toUnit: 20,
          scheduledDate: now,
          isCompleted: false,
          progress: 0.3,
        ),
      ],
      createdAt: now,
    );

    final dataSource = InMemoryKhatmDataSource([plan]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          khatmLocalDataSourceProvider.overrideWithValue(dataSource),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                KhatmReaderBar(
                  khatmId: 'khatm-collapse-test',
                  sessionIndex: 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initially expanded
    expect(find.text('ختم تستی اسکرول: جلسه ۱ از ۱ (صفحه ۱ تا ۲۰)'), findsOneWidget);
    final animatedContainerFinder = find.byType(AnimatedContainer);
    expect(animatedContainerFinder, findsOneWidget);
    AnimatedContainer containerWidget = tester.widget(animatedContainerFinder);
    expect(containerWidget.constraints?.maxHeight, equals(KhatmReaderBar.barHeight));

    // Collapse the bar
    final element = tester.element(animatedContainerFinder);
    final container = ProviderScope.containerOf(element);
    container.read(isKhatmReaderBarCollapsedProvider.notifier).setCollapsed(true);
    await tester.pumpAndSettle();

    // Verify height collapsed to collapsedHeight (3.0)
    containerWidget = tester.widget(animatedContainerFinder);
    expect(containerWidget.constraints?.maxHeight, equals(KhatmReaderBar.collapsedHeight));

    // Tap the collapsed bar to expand it
    await tester.tap(animatedContainerFinder);
    await tester.pumpAndSettle();

    // Verify it expanded back
    expect(container.read(isKhatmReaderBarCollapsedProvider), isFalse);
    containerWidget = tester.widget(animatedContainerFinder);
    expect(containerWidget.constraints?.maxHeight, equals(KhatmReaderBar.barHeight));
  });

  test('Single-page session (fromUnit == toUnit) does NOT auto-complete on initial open, only when endOfPage is reached', () async {
    final now = DateTime.now();
    final plan = KhatmPlan(
      id: 'khatm-single-page',
      title: 'ختم تک صفحه‌ای',
      unitType: KhatmUnitType.page,
      rangeFrom: 5,
      rangeTo: 5,
      planningMode: KhatmPlanningMode.byUnitQuota,
      sessionCount: 1,
      quotaPerSession: 1,
      cadence: KhatmCadence.daily,
      startDateTime: now,
      endDateTime: now,
      sessions: [
        KhatmSessionItem(
          sessionIndex: 0,
          fromUnit: 5,
          toUnit: 5,
          scheduledDate: now,
          isCompleted: false,
        ),
      ],
      createdAt: now,
    );

    final dataSource = InMemoryKhatmDataSource([plan]);
    final container = ProviderContainer(
      overrides: [
        khatmLocalDataSourceProvider.overrideWithValue(dataSource),
      ],
    );

    final subscription = container.listen(
      khatmDetailControllerProvider('khatm-single-page'),
      (_, _) {},
    );

    final controller =
        container.read(khatmDetailControllerProvider('khatm-single-page').notifier);
    await container.pump();

    // 1. Initial entry to page 5 (isEndOfPage: false, pageFraction: 0.1): must NOT complete!
    final res1 = await controller.recordReadingProgress(
      sessionIndex: 0,
      surahId: 2,
      ayahNumber: 25,
      page: 5,
      pageFraction: 0.1,
      isEndOfPage: false,
    );
    expect(res1, isFalse);
    expect(container.read(khatmDetailControllerProvider('khatm-single-page')).plan!.sessions[0].isCompleted, isFalse);

    // 2. User finishes reading page 5 (isEndOfPage: true): must complete!
    final res2 = await controller.recordReadingProgress(
      sessionIndex: 0,
      surahId: 2,
      ayahNumber: 29,
      page: 5,
      pageFraction: 1.0,
      isEndOfPage: true,
    );
    expect(res2, isTrue);
    expect(container.read(khatmDetailControllerProvider('khatm-single-page')).plan!.sessions[0].isCompleted, isTrue);

    subscription.close();
    container.dispose();
  });

  test('Single-surah session does NOT auto-complete on initial open, only when user finishes reading it', () async {
    final now = DateTime.now();
    final plan = KhatmPlan(
      id: 'khatm-single-surah',
      title: 'ختم سوره فاتحه',
      unitType: KhatmUnitType.surah,
      rangeFrom: 1,
      rangeTo: 1,
      planningMode: KhatmPlanningMode.byUnitQuota,
      sessionCount: 1,
      quotaPerSession: 1,
      cadence: KhatmCadence.daily,
      startDateTime: now,
      endDateTime: now,
      sessions: [
        KhatmSessionItem(
          sessionIndex: 0,
          fromUnit: 1,
          toUnit: 1,
          scheduledDate: now,
          isCompleted: false,
        ),
      ],
      createdAt: now,
    );

    final dataSource = InMemoryKhatmDataSource([plan]);
    final container = ProviderContainer(
      overrides: [
        khatmLocalDataSourceProvider.overrideWithValue(dataSource),
      ],
    );

    final subscription = container.listen(
      khatmDetailControllerProvider('khatm-single-surah'),
      (_, _) {},
    );

    final controller =
        container.read(khatmDetailControllerProvider('khatm-single-surah').notifier);
    await container.pump();

    // 1. Initial entry to Surah 1 at ayah 1 (isEndOfPage: false): must NOT complete!
    final res1 = await controller.recordReadingProgress(
      sessionIndex: 0,
      surahId: 1,
      ayahNumber: 1,
      page: 1,
      pageFraction: 0.14,
      isEndOfPage: false,
    );
    expect(res1, isFalse);
    expect(container.read(khatmDetailControllerProvider('khatm-single-surah')).plan!.sessions[0].isCompleted, isFalse);

    // 2. User reaches last ayah 7 with isEndOfPage: true: must complete!
    final res2 = await controller.recordReadingProgress(
      sessionIndex: 0,
      surahId: 1,
      ayahNumber: 7,
      page: 1,
      pageFraction: 1.0,
      isEndOfPage: true,
    );
    expect(res2, isTrue);
    expect(container.read(khatmDetailControllerProvider('khatm-single-surah')).plan!.sessions[0].isCompleted, isTrue);

    subscription.close();
    container.dispose();
  });
}
