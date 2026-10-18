import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/features/khatm/application/controllers/khatm_list_controller.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';
import 'package:quran/features/khatm/domain/entities/khatm_plan.dart';
import 'package:quran/features/khatm/domain/entities/khatm_session_item.dart';
import 'package:quran/features/khatm/infrastructure/datasources/khatm_local_datasource.dart';
import 'package:quran/features/khatm/presentation/widgets/shared/khatm_home_section.dart';

void main() {
  testWidgets('KhatmHomeSection renders empty state when no plans exist',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          khatmListControllerProvider.overrideWith(
            (ref) => _MockKhatmListController([]),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: KhatmHomeSection(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('برنامه مطالعه و ختم قرآن'), findsOneWidget);
    expect(find.text('ایجاد برنامه ختم جدید'), findsOneWidget);
  });

  testWidgets('KhatmHomeSection renders active plan card when plans exist',
      (tester) async {
    final now = DateTime(2026, 3, 1);
    final samplePlan = KhatmPlan(
      id: 'khatm-test-1',
      title: 'ختم نورانی رمضان',
      unitType: KhatmUnitType.page,
      rangeFrom: 1,
      rangeTo: 604,
      planningMode: KhatmPlanningMode.bySessionCount,
      sessionCount: 30,
      quotaPerSession: 20,
      cadence: KhatmCadence.daily,
      startDateTime: now,
      endDateTime: now.add(const Duration(days: 30)),
      sessions: [
        KhatmSessionItem(
          sessionIndex: 0,
          fromUnit: 1,
          toUnit: 20,
          scheduledDate: now,
          isCompleted: true,
        ),
        KhatmSessionItem(
          sessionIndex: 1,
          fromUnit: 21,
          toUnit: 40,
          scheduledDate: now.add(const Duration(days: 1)),
          isCompleted: false,
        ),
      ],
      createdAt: now,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          khatmListControllerProvider.overrideWith(
            (ref) => _MockKhatmListController([samplePlan]),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: KhatmHomeSection(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ختم نورانی رمضان'), findsOneWidget);
    expect(find.text('مشاهده همه'), findsOneWidget);
    expect(find.text('ادامه مطالعه'), findsOneWidget);
  });
}

class _MockKhatmListController extends KhatmListController {
  final List<KhatmPlan> mockPlans;
  _MockKhatmListController(this.mockPlans)
      : super(const _FakeDatasource()) {
    state = KhatmListState(plans: mockPlans, isLoading: false);
  }

  @override
  Future<void> loadPlans({bool silent = false}) async {
    state = KhatmListState(plans: mockPlans, isLoading: false);
  }
}

class _FakeDatasource implements IKhatmLocalDataSource {
  const _FakeDatasource();

  @override
  Future<void> deletePlan(String id) async {}

  @override
  Future<List<KhatmPlan>> getAllPlans() async => [];

  @override
  Future<List<KhatmPlan>> getActivePlans() async => [];

  @override
  Future<KhatmPlan?> getPlan(String id) async => null;

  @override
  Future<void> savePlan(KhatmPlan plan) async {}

  @override
  Future<void> updateSessionStatus({
    required String planId,
    required int sessionIndex,
    required bool isCompleted,
  }) async {}

  @override
  Future<void> updateSessionProgress({
    required String planId,
    required int sessionIndex,
    required double progress,
    int? lastReadUnit,
    bool? isCompleted,
  }) async {}

  @override
  Future<void> clearAll() async {}

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}
