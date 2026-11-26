import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quran/common/constants/app_constants.dart';
import 'package:quran/common/exceptions/failure.dart';
import 'package:quran/common/widgets/auto_scroll_text.dart';
import 'package:quran/core/data/local/preferences/preferences_service_provider.dart';
import 'package:quran/features/khatm/application/controllers/group_khatm_detail_controller.dart';
import 'package:quran/features/khatm/application/controllers/group_khatm_list_controller.dart';
import 'package:quran/features/khatm/application/controllers/group_khatm_reading_controller.dart';
import 'package:quran/features/khatm/application/controllers/khatm_detail_controller.dart';
import 'package:quran/features/khatm/application/controllers/khatm_list_controller.dart';
import 'package:quran/features/khatm/application/controllers/personal_khatm_sync_controller.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_campaign.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_category.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_slot.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_slot_progress.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';
import 'package:quran/features/khatm/domain/entities/khatm_plan.dart';
import 'package:quran/features/khatm/domain/entities/khatm_session_item.dart';
import 'package:quran/features/khatm/domain/repositories/i_khatm_repository.dart';
import 'package:quran/features/khatm/domain/services/khatm_progress_calculator.dart';
import 'package:quran/features/khatm/infrastructure/datasources/group_khatm_progress_local_datasource.dart';
import 'package:quran/features/khatm/infrastructure/datasources/khatm_local_datasource.dart';
import 'package:quran/features/khatm/infrastructure/repositories/khatm_repository_impl.dart';
import 'package:quran/features/khatm/presentation/ui/group_khatm_detail_screen.dart';
import 'package:quran/features/khatm/presentation/ui/khatm_list_screen.dart';
import 'package:quran/features/khatm/presentation/widgets/group_detail/group_khatm_bottom_cta.dart';
import 'package:quran/features/khatm/presentation/widgets/group_detail/group_khatm_detail_header.dart';
import 'package:quran/features/khatm/presentation/widgets/group_detail/group_khatm_detail_skeleton.dart';
import 'package:quran/features/khatm/presentation/widgets/group_detail/group_khatm_my_slot_card.dart';
import 'package:quran/features/khatm/presentation/widgets/group_detail/group_khatm_participants_sheet.dart';
import 'package:quran/features/khatm/presentation/widgets/group_detail/group_khatm_slot_grid.dart';
import 'package:quran/features/khatm/presentation/widgets/group_detail/group_khatm_slot_progress_ring.dart';
import 'package:quran/features/khatm/presentation/widgets/group_detail/group_khatm_surah_picker.dart';
import 'package:quran/features/khatm/presentation/widgets/group_detail/group_khatm_surah_slots_section.dart';
import 'package:quran/features/khatm/presentation/widgets/reader/group_khatm_reader_bar.dart';
import 'package:pinput/pinput.dart';
import 'package:quran/common/utils/persian_number_formatter.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/khatm/presentation/widgets/shared/complete_name_bottom_sheet.dart';
import 'package:quran/features/khatm/presentation/widgets/shared/group_khatm_card.dart';
import 'package:quran/features/khatm/presentation/widgets/shared/guest_otp_bottom_sheet.dart';
import 'package:quran/features/khatm/presentation/widgets/shared/khatm_circular_progress_ring.dart';
import 'package:quran/features/khatm/presentation/widgets/shared/khatm_skeleton.dart';
import 'package:quran/features/profile/presentation/ui/profile_screen.dart';
import 'package:quran/features/subscription/application/vip_subscription_controller.dart';
import 'package:quran/features/subscription/domain/models/vip_subscription_state.dart';
import 'package:quran/features/tafakor/domain/entities/tafakor_user.dart';
import 'package:quran/features/tafakor/domain/repositories/i_tafakor_auth_repository.dart';
import 'package:quran/features/tafakor/infrastructure/dtos/tafakor_user_dto.dart';
import 'package:quran/features/tafakor/infrastructure/repositories/tafakor_auth_repository_impl.dart';
import 'package:quran/features/study_plan/domain/entities/study_plan.dart'
    show getGlobalAyahIndex;

import 'khatm_sync_test.dart';

class _FakeTafakorAuthRepository implements ITafakorAuthRepository {
  TafakorUser? currentUser;
  String? updatedFirstName;
  String? updatedLastName;
  Failure? verifyOtpError;

  _FakeTafakorAuthRepository({this.currentUser, this.verifyOtpError});

  @override
  Future<Result<TafakorUser?, Failure>> getCurrentUser() async =>
      Success(currentUser);

  @override
  TafakorUser? getCurrentUserSync() => currentUser;

  @override
  Future<Result<void, Failure>> logout() async {
    currentUser = null;
    return const Success(null);
  }

  @override
  Future<Result<TafakorUser, Failure>> refreshProfile() async {
    final user = currentUser;
    if (user == null) {
      return const Error(Failure(message: 'not logged in'));
    }
    return Success(user);
  }

  @override
  Future<Result<bool, Failure>> requestOtp(String phone) async =>
      const Success(true);

  @override
  Future<Result<TafakorUser, Failure>> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    updatedFirstName = firstName;
    updatedLastName = lastName;
    currentUser =
        (currentUser ?? const TafakorUser(phone: '09120000000', token: 'tok'))
            .copyWith(firstName: firstName, lastName: lastName);
    return Success(currentUser!);
  }

  @override
  Future<Result<TafakorUser, Failure>> verifyOtp(
    String phone,
    String otp,
  ) async {
    if (verifyOtpError != null) {
      return Error(verifyOtpError!);
    }
    return Success(currentUser ?? TafakorUser(phone: phone, token: 'tok'));
  }
}

class _FakeSyncKhatmRepository implements IKhatmRepository {
  List<Map<String, dynamic>> lastSentPlans = [];
  String? lastSentSyncedAt;
  int syncCallCount = 0;
  Map<String, dynamic> Function(
    List<Map<String, dynamic>> plans,
    String? lastSyncedAt,
  )?
  onSync;

  @override
  Future<Result<Map<String, dynamic>, Failure>> syncPersonalPlans({
    required List<Map<String, dynamic>> plans,
    String? lastSyncedAt,
  }) async {
    syncCallCount++;
    lastSentPlans = plans;
    lastSentSyncedAt = lastSyncedAt;
    if (onSync != null) {
      return Success(onSync!(plans, lastSyncedAt));
    }
    return const Success({'server_time': '2026-11-24T12:00:00Z', 'plans': []});
  }

  @override
  Future<Result<PaginatedCampaignsPage, Failure>> getCampaignsPage({
    int? categoryId,
    String? unitType,
    String? status,
    String? search,
    int page = 1,
    int pageSize = 10,
  }) => throw UnimplementedError();

  @override
  Future<Result<List<GroupKhatmCampaign>, Failure>> getCampaigns({
    int? categoryId,
    String? unitType,
    String? status,
    String? search,
    int page = 1,
  }) => throw UnimplementedError();

  @override
  Future<Result<PaginatedCampaignsPage, Failure>> getMyCampaignsPage({
    required String tab,
    int page = 1,
    int pageSize = 10,
  }) => throw UnimplementedError();

  @override
  Future<Result<List<GroupKhatmCampaign>, Failure>> getMyCampaigns({
    required String tab,
  }) => throw UnimplementedError();

  @override
  Future<Result<GroupKhatmCampaign, Failure>> getCampaignDetail(
    String inviteCode,
  ) => throw UnimplementedError();

  @override
  Future<Result<GroupKhatmCampaign, Failure>> reserveSlot(
    String inviteCode, {
    int? unitNumber,
    int quantity = 1,
  }) => throw UnimplementedError();

  @override
  Future<Result<GroupKhatmCampaign, Failure>> completeSlot(
    String inviteCode, {
    int? slotId,
    int? unitNumber,
  }) => throw UnimplementedError();

  @override
  Future<Result<GroupKhatmCampaign, Failure>> releaseSlot(
    String inviteCode, {
    int? slotId,
    int? unitNumber,
  }) => throw UnimplementedError();

  @override
  Future<Result<GroupKhatmCampaign, Failure>> createCampaign({
    required String title,
    String? description,
    required String unitType,
    int? targetSurah,
    int? targetCount,
    int? categoryId,
    String? deadline,
    bool isPublic = true,
    int? topicId,
  }) => throw UnimplementedError();

  @override
  Future<Result<List<GroupKhatmCategory>, Failure>> getCategories() =>
      throw UnimplementedError();

  @override
  Future<List<KhatmPlan>> getLocalPlans() => throw UnimplementedError();

  @override
  Future<void> saveLocalPlan(KhatmPlan plan) => throw UnimplementedError();

  @override
  Future<void> deleteLocalPlan(String planId) => throw UnimplementedError();
}

class _MockVipSubscriptionController extends VipSubscriptionController {
  @override
  VipSubscriptionState build() =>
      const VipSubscriptionState(isVip: false, isLoading: false);
}

KhatmPlan _buildSamplePlan({
  required String id,
  String title = 'ختم تست',
  DateTime? createdAt,
  DateTime? clientUpdatedAt,
  DateTime? deletedAt,
  bool isDirty = true,
  bool sessionCompleted = false,
}) {
  final base = createdAt ?? DateTime.utc(2026, 3, 1, 10, 0);
  return KhatmPlan(
    id: id,
    title: title,
    unitType: KhatmUnitType.page,
    rangeFrom: 1,
    rangeTo: 20,
    planningMode: KhatmPlanningMode.bySessionCount,
    sessionCount: 1,
    quotaPerSession: 20,
    cadence: KhatmCadence.daily,
    startDateTime: base,
    endDateTime: base.add(const Duration(days: 1)),
    sessions: [
      KhatmSessionItem(
        sessionIndex: 0,
        fromUnit: 1,
        toUnit: 20,
        scheduledDate: base,
        isCompleted: sessionCompleted,
        completedAt: sessionCompleted ? clientUpdatedAt ?? base : null,
        progress: sessionCompleted ? 1.0 : 0.0,
      ),
    ],
    createdAt: base,
    clientUpdatedAt: clientUpdatedAt,
    deletedAt: deletedAt,
    isDirty: isDirty,
  );
}

void main() {
  group('Package 1: TafakorUser & Group Khatm Privacy', () {
    test(
      'TafakorUserDto & TafakorUser parse names and enforce hasFullName',
      () {
        final completeDto = TafakorUserDto.fromJson({
          'phone': '09120000000',
          'first_name': 'علی',
          'last_name': 'رضایی',
        });
        final completeUser = completeDto.toDomain(token: 'tok');
        expect(completeUser.firstName, 'علی');
        expect(completeUser.lastName, 'رضایی');
        expect(completeUser.fullName, 'علی رضایی');
        expect(completeUser.hasFullName, isTrue);

        final partialDto = TafakorUserDto.fromJson({
          'phone': '09120000001',
          'first_name': 'علی',
          'last_name': '   ',
        });
        expect(partialDto.hasFullName, isFalse);
        expect(partialDto.toDomain().hasFullName, isFalse);

        const emptyUser = TafakorUser(phone: '09120000002');
        expect(emptyUser.hasFullName, isFalse);
        expect(emptyUser.fullName, isEmpty);
      },
    );

    testWidgets(
      'GroupKhatmSlotGrid hides user names for guests and displays 1-line names for authenticated users',
      (tester) async {
        final campaign = GroupKhatmCampaign(
          id: 1,
          inviteCode: 'TEST1234',
          creatorDisplayName: 'بانی ختم',
          title: 'ختم تستی',
          unitType: 'juz',
          targetUnits: 3,
          reservedUnits: 1,
          completedUnits: 1,
          remainingUnits: 1,
          progressPercentage: 33.3,
          status: GroupKhatmStatus.active,
          createdAt: DateTime(2026, 3, 1),
          slots: [
            const GroupKhatmSlot(
              id: 1,
              campaignId: 1,
              unitNumber: 1,
              status: GroupKhatmSlotStatus.completed,
              userId: 10,
              userDisplayName: 'محمدرضا حسینی',
            ),
            const GroupKhatmSlot(
              id: 2,
              campaignId: 1,
              unitNumber: 2,
              status: GroupKhatmSlotStatus.reserved,
              userId: 11,
              userDisplayName: 'فاطمه کریمی',
            ),
            const GroupKhatmSlot(
              id: 3,
              campaignId: 1,
              unitNumber: 3,
              status: GroupKhatmSlotStatus.available,
            ),
          ],
        );

        // Guest mode: status only, no names
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              groupKhatmProgressLocalDataSourceProvider.overrideWithValue(
                _FakeGroupProgressLocalDataSource(),
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: GroupKhatmSlotGrid(
                    campaign: campaign,
                    isAuthenticated: false,
                    onSlotTap: (_) {},
                  ),
                ),
              ),
            ),
          ),
        );
        expect(find.text('محمدرضا حسینی'), findsNothing);
        expect(find.text('فاطمه کریمی'), findsNothing);
        expect(find.text('قرائت شده'), findsOneWidget);
        expect(find.text('در حال قرائت'), findsOneWidget);

        // Authenticated mode: shows full names single-line in 3-column grid
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              groupKhatmProgressLocalDataSourceProvider.overrideWithValue(
                _FakeGroupProgressLocalDataSource(),
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: GroupKhatmSlotGrid(
                    campaign: campaign,
                    isAuthenticated: true,
                    onSlotTap: (_) {},
                  ),
                ),
              ),
            ),
          ),
        );
        expect(find.text('محمدرضا حسینی'), findsOneWidget);
        expect(find.text('فاطمه کریمی'), findsOneWidget);
      },
    );

    testWidgets(
      'GroupKhatmParticipantsSheet shows full names for authenticated user and hides names for guests',
      (tester) async {
        final campaign = GroupKhatmCampaign(
          id: 2,
          inviteCode: 'PART1234',
          creatorDisplayName: 'علی رضایی',
          title: 'ختم همراهان',
          unitType: 'juz',
          targetUnits: 2,
          reservedUnits: 1,
          completedUnits: 0,
          remainingUnits: 1,
          progressPercentage: 0,
          status: GroupKhatmStatus.active,
          createdAt: DateTime(2026, 3, 1),
          slots: const [
            GroupKhatmSlot(
              id: 1,
              campaignId: 2,
              unitNumber: 1,
              status: GroupKhatmSlotStatus.reserved,
              userId: 20,
              userDisplayName: 'سارا محمدی تبریزی',
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GroupKhatmParticipantsSheet(
                campaign: campaign,
                isAuthenticated: false,
              ),
            ),
          ),
        );
        expect(find.text('سارا محمدی تبریزی'), findsNothing);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GroupKhatmParticipantsSheet(
                campaign: campaign,
                isAuthenticated: true,
              ),
            ),
          ),
        );
        expect(find.text('سارا محمدی تبریزی'), findsOneWidget);
      },
    );
  });

  group('Package 2: Personal Khatm Sync & Soft Delete', () {
    test(
      'KhatmPlan preserves real clientUpdatedAt, deletedAt, isDirty and legacy Hive compatibility',
      () {
        final created = DateTime.utc(2026, 1, 1, 8, 0);
        final updated = DateTime.utc(2026, 2, 10, 14, 30);

        final plan = _buildSamplePlan(
          id: 'p1',
          createdAt: created,
          clientUpdatedAt: updated,
          isDirty: false,
        );

        final serverMap = plan.toServerMap();
        expect(serverMap['client_updated_at'], updated.toIso8601String());
        expect(serverMap['deleted_at'], isNull);

        final legacyHiveMap = {
          'id': 'legacy-1',
          'title': 'ختم قدیمی',
          'unitType': 'page',
          'rangeFrom': 1,
          'rangeTo': 10,
          'planningMode': 'bySessionCount',
          'sessionCount': 1,
          'quotaPerSession': 10,
          'cadence': 'daily',
          'startDateTime': created.toIso8601String(),
          'endDateTime': created.toIso8601String(),
          'createdAt': created.toIso8601String(),
          'sessions': [
            {
              'sessionIndex': 0,
              'fromUnit': 1,
              'toUnit': 10,
              'scheduledDate': created.toIso8601String(),
              'isCompleted': true,
              'completedAt': updated.toIso8601String(),
            },
          ],
        };

        final parsedLegacy = KhatmPlan.fromMap(legacyHiveMap);
        expect(parsedLegacy.isDirty, isTrue);
        expect(parsedLegacy.deletedAt, isNull);
        expect(parsedLegacy.clientUpdatedAt, updated);
      },
    );

    test(
      'Two-way sync persists server_time, uploads only dirty plans, merges LWW updates & soft deletes',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final t0 = DateTime.utc(2026, 3, 1, 10, 0);
        final t1 = DateTime.utc(2026, 3, 1, 11, 0);
        final t2 = DateTime.utc(2026, 3, 1, 12, 0);

        final cleanLocal = _buildSamplePlan(
          id: 'clean-plan',
          title: 'ختم تمیز',
          createdAt: t0,
          clientUpdatedAt: t0,
          isDirty: false,
        );
        final dirtyLocal = _buildSamplePlan(
          id: 'dirty-plan',
          title: 'ختم تغییریافته',
          createdAt: t0,
          clientUpdatedAt: t1,
          isDirty: true,
        );
        final toDeleteOnServer = _buildSamplePlan(
          id: 'server-deleted-plan',
          title: 'حذف از گوشی دیگر',
          createdAt: t0,
          clientUpdatedAt: t0,
          isDirty: false,
        );

        final localDataSource = InMemoryKhatmDataSource([
          cleanLocal,
          dirtyLocal,
          toDeleteOnServer,
        ]);
        final repo = _FakeSyncKhatmRepository();
        final listController = KhatmListController(localDataSource);

        // Seed prior server_time so this runs as incremental sync
        await prefs.setString(
          PersonalKhatmSyncController.lastSyncedAtPrefKey,
          t0.toIso8601String(),
        );

        final syncController = PersonalKhatmSyncController(
          repo,
          localDataSource,
          prefs,
        );

        expect(syncController.state.lastSyncedAt, t0);

        repo.onSync = (plans, lastSyncedAt) {
          return {
            'server_time': t2.toIso8601String(),
            'plans': [
              // Existing local plan updated remotely on another device
              _buildSamplePlan(
                id: 'clean-plan',
                title: 'ختم تمیز',
                createdAt: t0,
                clientUpdatedAt: t2,
                sessionCompleted: true,
              ).toServerMap(),
              // New plan created on another device
              _buildSamplePlan(
                id: 'cloud-new-plan',
                title: 'ختم جدید ابری',
                createdAt: t1,
                clientUpdatedAt: t1,
              ).toServerMap(),
              // Plan deleted on another device
              _buildSamplePlan(
                id: 'server-deleted-plan',
                title: 'حذف از گوشی دیگر',
                createdAt: t0,
                clientUpdatedAt: t2,
                deletedAt: t2,
              ).toServerMap(),
            ],
          };
        };

        final ok = await syncController.syncWithBackend();
        expect(ok, isTrue);

        // Incremental sync must only send dirty plans
        expect(repo.lastSentSyncedAt, t0.toIso8601String());
        expect(repo.lastSentPlans.length, 1);
        expect(repo.lastSentPlans.first['client_id'], 'dirty-plan');

        // server_time persisted in state & prefs
        expect(syncController.state.lastSyncedAt, t2);
        expect(
          prefs.getString(PersonalKhatmSyncController.lastSyncedAtPrefKey),
          t2.toIso8601String(),
        );

        // Clean plan updated with server session completion & stays clean
        final updatedClean = await localDataSource.getPlan('clean-plan');
        expect(updatedClean, isNotNull);
        expect(updatedClean!.sessions.first.isCompleted, isTrue);
        expect(updatedClean.isDirty, isFalse);

        // Dirty plan marked clean after upload
        final updatedDirty = await localDataSource.getPlan('dirty-plan');
        expect(updatedDirty!.isDirty, isFalse);

        // New cloud plan imported locally
        final imported = await localDataSource.getPlan('cloud-new-plan');
        expect(imported, isNotNull);
        expect(imported!.isDirty, isFalse);

        // Server-deleted plan removed locally
        expect(await localDataSource.getPlan('server-deleted-plan'), isNull);

        // Soft-delete via list controller hides from UI but retains deletedAt + isDirty for upload
        await listController.deletePlan('dirty-plan');
        await listController.loadPlans();
        expect(
          listController.state.plans.any((p) => p.id == 'dirty-plan'),
          isFalse,
        );
        final softDeleted = await localDataSource.getPlan('dirty-plan');
        expect(softDeleted?.deletedAt, isNotNull);
        expect(softDeleted?.isDirty, isTrue);

        // clearSyncState resets lastSyncedAt on logout
        await syncController.clearSyncState();
        expect(syncController.state.lastSyncedAt, isNull);
        expect(
          prefs.getString(PersonalKhatmSyncController.lastSyncedAtPrefKey),
          isNull,
        );

        syncController.dispose();
        listController.dispose();
      },
    );

    test(
      'PersonalKhatmSyncController.scheduleSync debounces for 4 seconds',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final localDataSource = InMemoryKhatmDataSource([]);
        final repo = _FakeSyncKhatmRepository();
        final syncController = PersonalKhatmSyncController(
          repo,
          localDataSource,
          prefs,
        );

        syncController.scheduleSync();
        await Future<void>.delayed(const Duration(milliseconds: 500));
        syncController.scheduleSync();
        await Future<void>.delayed(const Duration(seconds: 2));
        expect(repo.syncCallCount, 0);

        await Future<void>.delayed(const Duration(seconds: 3));
        expect(repo.syncCallCount, 1);

        syncController.dispose();
      },
    );
  });

  group('Package 1 UI Widgets: ProfileScreen & CompleteNameBottomSheet', () {
    testWidgets(
      'ProfileScreen displays real fullName when authenticated and fallback for guest',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final authRepo = _FakeTafakorAuthRepository(
          currentUser: const TafakorUser(
            phone: '09121112233',
            firstName: 'محمد',
            lastName: 'احمدی',
            token: 'tok-1',
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesInstanceProvider.overrideWithValue(prefs),
              tafakorAuthRepositoryProvider.overrideWithValue(authRepo),
              vipSubscriptionControllerProvider.overrideWith(
                () => _MockVipSubscriptionController(),
              ),
              hasVipAccessProvider.overrideWithValue(false),
            ],
            child: const MaterialApp(
              home: ProfileScreen(showBackButton: false),
            ),
          ),
        );
        await tester.pump();
        expect(find.text('محمد احمدی'), findsOneWidget);
        expect(find.text('کاربر قرآن تفکر'), findsNothing);

        final guestRepo = _FakeTafakorAuthRepository(currentUser: null);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesInstanceProvider.overrideWithValue(prefs),
              tafakorAuthRepositoryProvider.overrideWithValue(guestRepo),
              vipSubscriptionControllerProvider.overrideWith(
                () => _MockVipSubscriptionController(),
              ),
              hasVipAccessProvider.overrideWithValue(false),
            ],
            child: const MaterialApp(
              home: ProfileScreen(showBackButton: false),
            ),
          ),
        );
        await tester.pump();
        expect(find.text('کاربر قرآن تفکر'), findsOneWidget);
      },
    );

    testWidgets(
      'GuestOtpBottomSheet transitions to name completion after OTP when hasFullName is false and only returns true after save',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final authRepo = _FakeTafakorAuthRepository(currentUser: null);

        bool? sheetResult;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesInstanceProvider.overrideWithValue(prefs),
              tafakorAuthRepositoryProvider.overrideWithValue(authRepo),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () async {
                      sheetResult = await GuestOtpBottomSheet.show(
                        context,
                        title: 'ورود',
                        description: 'توضیح',
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('open'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        // Enter phone & request OTP
        await tester.enterText(find.byType(TextField).first, '09123456789');
        await tester.tap(find.text('دریافت کد تأیید'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        // Enter 4-digit OTP -> verifyOtp returns user without firstName/lastName
        await tester.enterText(find.byType(EditableText).first, '1234');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        // Sheet must NOT close yet; it must show name completion step inside same sheet
        expect(sheetResult, isNull);
        expect(find.text('ذخیره و ادامه'), findsOneWidget);

        // Fill first & last name -> save -> now sheet returns true
        final nameFields = find.byType(TextField);
        await tester.enterText(nameFields.at(0), 'مهدی');
        await tester.enterText(nameFields.at(1), 'رضایی');
        await tester.tap(find.text('ذخیره و ادامه'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(sheetResult, isTrue);
        expect(authRepo.updatedFirstName, 'مهدی');
        expect(authRepo.updatedLastName, 'رضایی');
      },
    );

    testWidgets(
      'CompleteNameBottomSheet validates required fields and saves via updateProfile',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final authRepo = _FakeTafakorAuthRepository(
          currentUser: const TafakorUser(phone: '09121112233', token: 'tok-1'),
        );

        bool completed = false;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesInstanceProvider.overrideWithValue(prefs),
              tafakorAuthRepositoryProvider.overrideWithValue(authRepo),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: CompleteNameFormContent(
                  title: 'تکمیل نام و نام خانوادگی',
                  description: 'توضیح',
                  onCompleted: () => completed = true,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('ذخیره و ادامه'));
        await tester.pump();
        expect(completed, isFalse);
        expect(find.textContaining('نام و نام خانوادگی'), findsWidgets);

        final fields = find.byType(TextField);
        await tester.enterText(fields.at(0), 'حسن');
        await tester.enterText(fields.at(1), 'کریمی');
        await tester.tap(find.text('ذخیره و ادامه'));
        await tester.pumpAndSettle();

        expect(completed, isTrue);
        expect(authRepo.updatedFirstName, 'حسن');
        expect(authRepo.updatedLastName, 'کریمی');
      },
    );
  });

  group('Package 3: Responsive Layout Overflow Prevention', () {
    testWidgets(
      'Group Khatm cards, pickers, slot grid, participants sheet, and skeletons render without RenderFlex overflow at 320px width',
      (tester) async {
        final now = DateTime(2026, 3, 25, 10, 0);
        final category = const GroupKhatmCategory(
          id: 2,
          title: 'شادی روح اموات و درگذشتگان',
          slug: 'amvat',
        );
        final mySlot = GroupKhatmSlot(
          id: 1,
          campaignId: 10,
          unitNumber: 120,
          status: GroupKhatmSlotStatus.reserved,
          userId: 1,
          userDisplayName: 'محمدرضا حسینی تبریزی',
          isMine: true,
          reservedAt: now,
          expiresAt: now.add(const Duration(hours: 36)),
        );
        final campaign = GroupKhatmCampaign(
          id: 10,
          inviteCode: 'OVF12345',
          category: category,
          creatorDisplayName: 'محمد واعظی مقدم',
          title: 'ختم قرآن هدیه به تمام شهدای راه حق و اموات مسلمانان',
          description: 'توضیحات نمونه',
          unitType: 'hizb',
          targetUnits: 120,
          targetSurahName: 'آل‌عمران و المائده',
          reservedUnits: 3,
          completedUnits: 12,
          remainingUnits: 105,
          progressPercentage: 10.0,
          status: GroupKhatmStatus.active,
          deadline: now.add(const Duration(days: 15)),
          createdAt: now,
          isPublic: true,
          slots: [
            mySlot,
            const GroupKhatmSlot(
              id: 2,
              campaignId: 10,
              unitNumber: 2,
              status: GroupKhatmSlotStatus.completed,
              userId: 2,
              userDisplayName: 'سیده‌زهرا موسوی لاریجانی',
            ),
            const GroupKhatmSlot(
              id: 3,
              campaignId: 10,
              unitNumber: 3,
              status: GroupKhatmSlotStatus.available,
            ),
          ],
        );
        final surahCampaign = GroupKhatmCampaign(
          id: 11,
          inviteCode: 'SUR12345',
          category: category,
          creatorDisplayName: 'محمد واعظی مقدم',
          title: 'ختم سوره طولانی نمونه',
          unitType: 'surah',
          targetUnits: 100,
          targetSurahName: 'آل‌عمران و المائده',
          reservedUnits: 10,
          completedUnits: 20,
          remainingUnits: 70,
          progressPercentage: 20.0,
          status: GroupKhatmStatus.active,
          createdAt: now,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              groupKhatmProgressLocalDataSourceProvider.overrideWithValue(
                _FakeGroupProgressLocalDataSource(),
              ),
            ],
            child: MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: MediaQuery(
                  data: const MediaQueryData(
                    size: Size(320, 800),
                    textScaler: TextScaler.linear(1.2),
                  ),
                  child: Scaffold(
                    body: SingleChildScrollView(
                      child: SizedBox(
                        width: 320,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Column(
                            children: [
                              GroupKhatmMySlotCard(
                                slot: mySlot,
                                campaign: campaign,
                                onStartReading: () {},
                                onComplete: () {},
                                onRelease: () {},
                              ),
                              GroupKhatmDetailHeader(campaign: campaign),
                              GroupKhatmSurahPicker(
                                campaign: surahCampaign,
                                onReserve: (_) {},
                              ),
                              GroupKhatmSlotGrid(
                                campaign: campaign,
                                isAuthenticated: true,
                                onSlotTap: (_) {},
                                onCompleteSlot: (_) {},
                                onReleaseSlot: (_) {},
                              ),
                              GroupKhatmCard(campaign: campaign, onTap: () {}),
                              GroupKhatmBottomCta(
                                campaign: campaign,
                                myActiveSlot: mySlot,
                                firstFreeSlot: null,
                                onStartReading: () {},
                                onAutoSelectFree: () {},
                              ),
                              GroupKhatmParticipantsSheet(
                                campaign: campaign,
                                isAuthenticated: true,
                              ),
                              const KhatmSkeletonScope(
                                child: KhatmSkeletonRing(
                                  size: 40,
                                  strokeWidth: 3.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(GroupKhatmMySlotCard), findsOneWidget);
      },
    );

    testWidgets(
      'AutoScrollText stays static when text fits and smoothly scrolls when long name overflows',
      (tester) async {
        // 1. Short text fits inside 200px: no SingleChildScrollView created, settles cleanly
        await tester.pumpWidget(
          const MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: SizedBox(
                  width: 220,
                  child: AutoScrollText(
                    'علی رضایی',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(SingleChildScrollView), findsNothing);
        expect(find.text('علی رضایی'), findsOneWidget);

        // 2. Long name overflows 90px card: renders marquee scroller, pauses at start, then advances scroll offset
        await tester.pumpWidget(
          const MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: SizedBox(
                  width: 90,
                  child: AutoScrollText(
                    'سید محمدحسین حسینی لاریجانی تبریزی',
                    style: TextStyle(fontSize: 13),
                    pauseDuration: Duration(milliseconds: 500),
                    velocityPxPerSecond: 40,
                  ),
                ),
              ),
            ),
          ),
        );
        // Frame 1 + post-frame callback initializes controller
        await tester.pump();
        await tester.pump();

        expect(find.byType(SingleChildScrollView), findsOneWidget);
        final scroller = tester.widget<SingleChildScrollView>(
          find.byType(SingleChildScrollView),
        );
        final controller = scroller.controller!;
        expect(controller.offset, equals(0.0));

        // Pump past the 500ms initial pause into active scroll
        await tester.pump(const Duration(milliseconds: 1200));
        expect(controller.offset, greaterThan(0.0));
      },
    );

    testWidgets(
      'GroupKhatmCampaign.remainingTimeLabel and GroupKhatmCard show remaining time instead of deadline date',
      (tester) async {
        final baseNow = DateTime(2026, 3, 1, 10, 0);
        GroupKhatmCampaign makeCampaign(DateTime? deadline) =>
            GroupKhatmCampaign(
              id: 20,
              inviteCode: 'REM12345',
              creatorDisplayName: 'علی رضایی',
              title: 'ختم گروهی تستی',
              unitType: 'juz',
              targetUnits: 30,
              remainingUnits: 25,
              progressPercentage: 10.0,
              status: GroupKhatmStatus.active,
              deadline: deadline,
              createdAt: baseNow,
            );

        expect(
          makeCampaign(
            baseNow.add(const Duration(days: 5)),
          ).remainingTimeLabel(now: baseNow),
          'زمان باقی‌مانده: ۵ روز',
        );
        expect(
          makeCampaign(
            baseNow.add(const Duration(days: 2, hours: 4)),
          ).remainingTimeLabel(now: baseNow, short: true),
          '۲ روز باقی‌مانده',
        );
        expect(
          makeCampaign(
            baseNow.add(const Duration(hours: 7)),
          ).remainingTimeLabel(now: baseNow),
          'زمان باقی‌مانده: ۷ ساعت',
        );
        expect(
          makeCampaign(
            baseNow.subtract(const Duration(minutes: 5)),
          ).remainingTimeLabel(now: baseNow),
          'زمان باقی‌مانده: پایان‌یافته',
        );
        expect(makeCampaign(null).remainingTimeLabel(now: baseNow), isNull);

        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: GroupKhatmCard(
                  campaign: makeCampaign(
                    DateTime.now().add(const Duration(days: 10, hours: 3)),
                  ),
                ),
              ),
            ),
          ),
        );
        expect(find.textContaining('زمان باقی‌مانده:'), findsOneWidget);
        expect(find.textContaining('مهلت پایان:'), findsNothing);
      },
    );

    testWidgets(
      'GroupKhatmDetailHeader places title, description, and stats box to the right of donut ring in RTL and skeleton fits 320px',
      (tester) async {
        final campaign = GroupKhatmCampaign(
          id: 30,
          inviteCode: 'HDR12345',
          category: const GroupKhatmCategory(
            id: 1,
            title: 'شفای بیماران',
            slug: 'shafa',
          ),
          creatorDisplayName: 'علی رضایی',
          title: 'ختم هدیه به شهدا',
          description: 'توضیحات کوتاه نیت ختم',
          unitType: 'juz',
          targetUnits: 30,
          reservedUnits: 4,
          completedUnits: 10,
          remainingUnits: 16,
          progressPercentage: 33.3,
          status: GroupKhatmStatus.active,
          createdAt: DateTime(2026, 3, 1),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: SizedBox(
                  width: 360,
                  child: Column(
                    children: [
                      GroupKhatmDetailHeader(campaign: campaign),
                      const Expanded(
                        child: SizedBox(
                          width: 320,
                          child: GroupKhatmDetailSkeleton(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final titleCenter = tester.getCenter(find.text('ختم هدیه به شهدا'));
        final descCenter = tester.getCenter(find.text('توضیحات کوتاه نیت ختم'));
        final statsCenter = tester.getCenter(find.text('در حال قرائت'));
        final ringPercentCenter = tester.getCenter(find.text('۳۳٪'));

        expect(titleCenter.dx, greaterThan(ringPercentCenter.dx));
        expect(descCenter.dx, greaterThan(ringPercentCenter.dx));
        expect(statsCenter.dx, greaterThan(ringPercentCenter.dx));
      },
    );

    test(
      'KhatmProgressCalculator detects Juz 30 shared final page (604) at An-Nas only',
      () {
        final lastOn604 = KhatmProgressCalculator.getLastAyahForPage(604);
        expect(lastOn604.surahId, 114);
        expect(lastOn604.ayahNumber, 6);

        // Entering page 604 via Surah 112 (Al-Ikhlas) must NOT complete Juz 30
        final partial604 = KhatmProgressCalculator.checkEndReached(
          unitType: KhatmUnitType.juz,
          fromUnit: 30,
          toUnit: 30,
          surahId: 112,
          ayahNumber: 4,
          page: 604,
          isEndOfPage: false,
          pageFraction: 0.3,
          computedProgress: 0.96,
        );
        expect(partial604, isFalse);

        // Reaching Surah 114 Ayah 6 on page 604 completes Juz 30
        final full604 = KhatmProgressCalculator.checkEndReached(
          unitType: KhatmUnitType.juz,
          fromUnit: 30,
          toUnit: 30,
          surahId: 114,
          ayahNumber: 6,
          page: 604,
          isEndOfPage: true,
          pageFraction: 1.0,
          computedProgress: 1.0,
        );
        expect(full604, isTrue);
      },
    );

    test(
      'GroupKhatmReadingController tracks Juz progress offline, resumes exact ayah, and handles 3-pass Surah',
      () async {
        final fakeProgressDs = _FakeGroupProgressLocalDataSource();
        final fakeRepo = _FakeGroupCampaignKhatmRepository();
        final container = ProviderContainer(
          overrides: [
            groupKhatmProgressLocalDataSourceProvider.overrideWithValue(
              fakeProgressDs,
            ),
            khatmRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );
        addTearDown(container.dispose);

        final ctrl = container.read(
          groupKhatmReadingControllerProvider.notifier,
        );

        // 1. Juz 1 mid-progress & exact resume + offline complete sync retry
        final juzCampaign = GroupKhatmCampaign(
          id: 50,
          inviteCode: 'GRPJUZ01',
          creatorDisplayName: 'مریم',
          title: 'ختم اول',
          unitType: 'juz',
          targetUnits: 30,
          reservedUnits: 1,
          completedUnits: 0,
          remainingUnits: 29,
          progressPercentage: 0,
          status: GroupKhatmStatus.active,
          createdAt: DateTime(2026, 3, 1),
        );
        const juzSlot = GroupKhatmSlot(
          id: 101,
          campaignId: 50,
          unitNumber: 1,
          status: GroupKhatmSlotStatus.reserved,
          isMine: true,
        );
        const activeJuz = ActiveGroupKhatmSlot(
          inviteCode: 'GRPJUZ01',
          slotId: 101,
          unitType: GroupKhatmUnitType.juz,
          unitNumber: 1,
          targetQuantity: 1,
        );

        final midEvent = await ctrl.recordReadingProgress(
          activeSlot: activeJuz,
          surahId: 2,
          ayahNumber: 50,
          page: 8,
          isEndOfPage: false,
          pageFraction: 0.4,
          coverStartGlobal: getGlobalAyahIndex(1, 1),
          coverEndGlobal: getGlobalAyahIndex(2, 50),
        );
        expect(midEvent, GroupKhatmProgressEvent.progressed);

        final savedMid = ctrl.progressFor('GRPJUZ01', 101)!;
        expect(savedMid.lastSurahId, 2);
        expect(savedMid.lastAyahNumber, 50);
        expect(savedMid.overallProgress, greaterThan(0.2));

        // Backward scroll keeps high-water mark & resume uses exact saved ayah
        await ctrl.recordReadingProgress(
          activeSlot: activeJuz,
          surahId: 2,
          ayahNumber: 10,
          page: 3,
          pageFraction: 0.1,
        );
        expect(
          ctrl.progressFor('GRPJUZ01', 101)!.overallProgress,
          closeTo(savedMid.overallProgress, 0.0001),
        );
        final resumeTarget = ctrl.resolveResumeTarget(
          campaign: juzCampaign,
          slot: juzSlot,
        );
        expect(resumeTarget.surahId, 2);
        expect(resumeTarget.ayahNumber, 50);

        // Simulate offline completion -> pendingServerSync stays true, then syncs when online
        fakeRepo.shouldFailComplete = true;
        final doneEvent = await ctrl.recordReadingProgress(
          activeSlot: activeJuz,
          surahId: 2,
          ayahNumber: 141,
          page: 21,
          isEndOfPage: true,
          pageFraction: 1.0,
          coverStartGlobal: getGlobalAyahIndex(2, 51),
          coverEndGlobal: getGlobalAyahIndex(2, 141),
        );
        expect(doneEvent, GroupKhatmProgressEvent.slotCompleted);
        expect(ctrl.progressFor('GRPJUZ01', 101)!.isCompletedLocally, isTrue);
        expect(ctrl.progressFor('GRPJUZ01', 101)!.pendingServerSync, isTrue);

        fakeRepo.shouldFailComplete = false;
        await ctrl.syncPendingCompletions('GRPJUZ01');
        expect(ctrl.progressFor('GRPJUZ01', 101)!.pendingServerSync, isFalse);
        expect(fakeRepo.completedSlotIds, contains(101));

        // 2. Surah 3-pass repetition tracking (Surah Al-Ikhlas = 112, 4 ayahs)
        const activeSurah = ActiveGroupKhatmSlot(
          inviteCode: 'GRPSUR03',
          slotId: 202,
          unitType: GroupKhatmUnitType.surah,
          unitNumber: 112,
          targetQuantity: 3,
        );

        final ikhlasStart = getGlobalAyahIndex(112, 1);
        final ikhlasEnd = getGlobalAyahIndex(112, 4);

        // Pass 1 complete
        final pass1 = await ctrl.recordReadingProgress(
          activeSlot: activeSurah,
          surahId: 112,
          ayahNumber: 4,
          page: 604,
          isEndOfPage: true,
          pageFraction: 1.0,
          coverStartGlobal: ikhlasStart,
          coverEndGlobal: ikhlasEnd,
        );
        expect(pass1, GroupKhatmProgressEvent.passCompleted);
        final afterP1 = ctrl.progressFor('GRPSUR03', 202)!;
        expect(afterP1.completedRepetitions, 1);
        expect(afterP1.currentRepetitionNumber, 2);
        expect(afterP1.isCompletedLocally, isFalse);
        expect(afterP1.overallProgress, closeTo(1 / 3, 0.001));

        // Immediate duplicate scroll at Ayah 4 must NOT cascade pass 2
        final cascadeGuard = await ctrl.recordReadingProgress(
          activeSlot: activeSurah,
          surahId: 112,
          ayahNumber: 4,
          page: 604,
          isEndOfPage: true,
          pageFraction: 1.0,
          coverStartGlobal: ikhlasStart,
          coverEndGlobal: ikhlasEnd,
        );
        expect(cascadeGuard, GroupKhatmProgressEvent.none);
        expect(ctrl.progressFor('GRPSUR03', 202)!.completedRepetitions, 1);

        // Start Pass 2 explicitly -> complete Pass 2 -> Start Pass 3 -> complete slot!
        ctrl.beginNextPass('GRPSUR03', 202);
        final pass2 = await ctrl.recordReadingProgress(
          activeSlot: activeSurah,
          surahId: 112,
          ayahNumber: 4,
          page: 604,
          isEndOfPage: true,
          pageFraction: 1.0,
          coverStartGlobal: ikhlasStart,
          coverEndGlobal: ikhlasEnd,
        );
        expect(pass2, GroupKhatmProgressEvent.passCompleted);
        expect(ctrl.progressFor('GRPSUR03', 202)!.completedRepetitions, 2);

        ctrl.beginNextPass('GRPSUR03', 202);
        final pass3 = await ctrl.recordReadingProgress(
          activeSlot: activeSurah,
          surahId: 112,
          ayahNumber: 4,
          page: 604,
          isEndOfPage: true,
          pageFraction: 1.0,
          coverStartGlobal: ikhlasStart,
          coverEndGlobal: ikhlasEnd,
        );
        expect(pass3, GroupKhatmProgressEvent.slotCompleted);
        expect(ctrl.progressFor('GRPSUR03', 202)!.completedRepetitions, 3);
        expect(ctrl.progressFor('GRPSUR03', 202)!.isCompletedLocally, isTrue);
      },
    );

    testWidgets(
      'GroupKhatmSlotGrid embeds progress ring, continue & complete on user slots and disables clicks on others',
      (tester) async {
        final fakeProgressDs = _FakeGroupProgressLocalDataSource();
        await fakeProgressDs.saveProgress(
          GroupKhatmSlotProgress(
            inviteCode: 'CARDTEST',
            slotId: 10,
            unitType: GroupKhatmUnitType.juz,
            unitNumber: 1,
            currentPassProgress: 0.45,
            lastSurahId: 2,
            lastAyahNumber: 55,
            lastPage: 9,
            updatedAt: DateTime(2026, 3, 1),
          ),
        );

        final tappedSlots = <int>[];
        final completedSlots = <int>[];

        final campaign = GroupKhatmCampaign(
          id: 99,
          inviteCode: 'CARDTEST',
          creatorDisplayName: 'بانی ختم',
          title: 'ختم تستی کارت',
          unitType: 'juz',
          targetUnits: 3,
          reservedUnits: 2,
          completedUnits: 1,
          remainingUnits: 0,
          progressPercentage: 33.3,
          status: GroupKhatmStatus.active,
          createdAt: DateTime(2026, 3, 1),
          slots: [
            const GroupKhatmSlot(
              id: 10,
              campaignId: 99,
              unitNumber: 1,
              status: GroupKhatmSlotStatus.reserved,
              isMine: true,
              userDisplayName: 'خودم',
            ),
            const GroupKhatmSlot(
              id: 11,
              campaignId: 99,
              unitNumber: 2,
              status: GroupKhatmSlotStatus.reserved,
              isMine: false,
              userDisplayName: 'زهرا محمدی',
            ),
            const GroupKhatmSlot(
              id: 12,
              campaignId: 99,
              unitNumber: 3,
              status: GroupKhatmSlotStatus.completed,
              isMine: false,
              userDisplayName: 'حسن کریمی',
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              groupKhatmProgressLocalDataSourceProvider.overrideWithValue(
                fakeProgressDs,
              ),
            ],
            child: MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  body: SingleChildScrollView(
                    child: SizedBox(
                      width: 320,
                      child: GroupKhatmSlotGrid(
                        campaign: campaign,
                        isAuthenticated: true,
                        onSlotTap: (s) => tappedSlots.add(s.id),
                        onCompleteSlot: (s) => completedSlots.add(s.id),
                        onReleaseSlot: (_) {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        // User's slot renders circular %, name BELOW circle, styled play & undo chips on the right of تموم شد
        expect(find.byType(GroupKhatmSlotProgressRing), findsOneWidget);
        expect(find.text('۴۵٪'), findsOneWidget);
        expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
        expect(find.byIcon(Icons.undo_rounded), findsOneWidget);
        expect(find.text('تموم شد'), findsOneWidget);

        // Reader name sits vertically BELOW the progress ring, and action icons sit to the right of تموم شد in RTL
        final ringCenter = tester.getCenter(
          find.byType(GroupKhatmSlotProgressRing),
        );
        final nameCenter = tester.getCenter(find.text('خودم').first);
        final playCenter = tester.getCenter(
          find.byIcon(Icons.play_arrow_rounded),
        );
        final undoCenter = tester.getCenter(find.byIcon(Icons.undo_rounded));
        final doneCenter = tester.getCenter(find.text('تموم شد'));
        expect(nameCenter.dy, greaterThan(ringCenter.dy));
        expect(playCenter.dx, greaterThan(undoCenter.dx));
        expect(undoCenter.dx, greaterThan(doneCenter.dx));

        // Tapping another user's reserved/completed card triggers NO callback
        await tester.tap(find.text('زهرا محمدی').first);
        await tester.tap(find.text('حسن کریمی').first);
        await tester.pump();
        expect(tappedSlots, isEmpty);
        expect(completedSlots, isEmpty);

        // Tapping continue icon opens user's slot, tapping تموم شد calls onCompleteSlot
        await tester.tap(find.byIcon(Icons.play_arrow_rounded));
        await tester.tap(find.text('تموم شد'));
        await tester.pump();
        expect(tappedSlots, [10]);
        expect(completedSlots, [10]);
      },
    );

    testWidgets(
      'GroupKhatmDetailScreen omits GroupKhatmMySlotCard and shows Surah repetition card',
      (tester) async {
        final fakeRepo = _FakeGroupCampaignKhatmRepository(
          campaignToReturn: GroupKhatmCampaign(
            id: 77,
            inviteCode: 'SURAH777',
            creatorDisplayName: 'مهدی',
            title: 'ختم سوره توحید',
            unitType: 'surah',
            targetSurahId: 112,
            targetUnits: 10,
            reservedUnits: 3,
            completedUnits: 0,
            remainingUnits: 7,
            progressPercentage: 0,
            status: GroupKhatmStatus.active,
            createdAt: DateTime(2026, 3, 1),
            slots: const [
              GroupKhatmSlot(
                id: 301,
                campaignId: 77,
                quantity: 3,
                status: GroupKhatmSlotStatus.reserved,
                isMine: true,
                userDisplayName: 'کاربر تست',
              ),
            ],
          ),
        );
        final fakeProgressDs = _FakeGroupProgressLocalDataSource();
        await fakeProgressDs.saveProgress(
          GroupKhatmSlotProgress(
            inviteCode: 'SURAH777',
            slotId: 301,
            unitType: GroupKhatmUnitType.surah,
            unitNumber: 112,
            targetQuantity: 3,
            completedRepetitions: 1,
            currentPassProgress: 0.5,
            updatedAt: DateTime(2026, 3, 1),
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              khatmRepositoryProvider.overrideWithValue(fakeRepo),
              groupKhatmProgressLocalDataSourceProvider.overrideWithValue(
                fakeProgressDs,
              ),
              tafakorAuthRepositoryProvider.overrideWithValue(
                _FakeTafakorAuthRepository(
                  currentUser: const TafakorUser(
                    phone: '09120000000',
                    token: 'tok',
                    firstName: 'تست',
                  ),
                ),
              ),
            ],
            child: const MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: GroupKhatmDetailScreen(inviteCode: 'SURAH777'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(GroupKhatmMySlotCard), findsNothing);
        expect(find.byType(GroupKhatmSurahSlotsSection), findsOneWidget);
        expect(find.textContaining('دور ۲ از ۳'), findsOneWidget);
        expect(find.text('۵۰٪'), findsOneWidget);
        expect(find.text('تموم شد'), findsOneWidget);
      },
    );

    test(
      'GroupKhatmDetailController keeps slots non-empty when mutation omits slots and reloads latest state on 409 conflict',
      () async {
        final fakeRepo = _FakeGroupCampaignKhatmRepository(
          campaignToReturn: GroupKhatmCampaign(
            id: 88,
            inviteCode: 'MUTATE88',
            creatorDisplayName: 'سارا',
            title: 'ختم تستی جهش',
            unitType: 'juz',
            targetUnits: 2,
            reservedUnits: 0,
            completedUnits: 0,
            remainingUnits: 2,
            progressPercentage: 0,
            status: GroupKhatmStatus.active,
            createdAt: DateTime(2026, 3, 1),
            slots: const [
              GroupKhatmSlot(
                id: 1,
                campaignId: 88,
                unitNumber: 1,
                status: GroupKhatmSlotStatus.available,
              ),
              GroupKhatmSlot(
                id: 2,
                campaignId: 88,
                unitNumber: 2,
                status: GroupKhatmSlotStatus.available,
              ),
            ],
          ),
        );

        // Backend reserve endpoint omits `slots` list, while detail GET has updated slots
        fakeRepo.returnSummaryWithoutSlotsOnReserve = true;

        final container = ProviderContainer(
          overrides: [khatmRepositoryProvider.overrideWithValue(fakeRepo)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(
          groupKhatmDetailControllerProvider('MUTATE88').notifier,
        );
        await notifier.loadCampaign();
        expect(
          container
              .read(groupKhatmDetailControllerProvider('MUTATE88'))
              .campaign!
              .slots
              .length,
          2,
        );

        // Reserve unit 1: must NOT blank slots even though POST returned empty slots!
        final reserved = await notifier.reserveSlot(unitNumber: 1);
        expect(reserved, isTrue);
        final afterReserve = container
            .read(groupKhatmDetailControllerProvider('MUTATE88'))
            .campaign!;
        expect(afterReserve.slots.length, 2);
        expect(
          afterReserve.slots.firstWhere((s) => s.unitNumber == 1).isMine,
          isTrue,
        );
        expect(
          afterReserve.slots.firstWhere((s) => s.unitNumber == 1).isReserved,
          isTrue,
        );

        // Simulate concurrent 409 on unit 2 (someone else reserved unit 2 meanwhile)
        fakeRepo.shouldReturnConflictOnReserve = true;
        fakeRepo.conflictMessage = 'این سهم توسط کاربر دیگری برداشته شد';
        fakeRepo.campaignToReturn = GroupKhatmCampaign(
          id: 88,
          inviteCode: 'MUTATE88',
          creatorDisplayName: 'سارا',
          title: 'ختم تستی جهش',
          unitType: 'juz',
          targetUnits: 2,
          reservedUnits: 2,
          completedUnits: 0,
          remainingUnits: 0,
          progressPercentage: 0,
          status: GroupKhatmStatus.active,
          createdAt: DateTime(2026, 3, 1),
          slots: const [
            GroupKhatmSlot(
              id: 1,
              campaignId: 88,
              unitNumber: 1,
              status: GroupKhatmSlotStatus.reserved,
              isMine: true,
              userDisplayName: 'خودم',
            ),
            GroupKhatmSlot(
              id: 2,
              campaignId: 88,
              unitNumber: 2,
              status: GroupKhatmSlotStatus.reserved,
              isMine: false,
              userDisplayName: 'کاربر رقیب',
            ),
          ],
        );

        final ok2 = await notifier.reserveSlot(unitNumber: 2);
        expect(ok2, isFalse);
        final stateAfterConflict = container.read(
          groupKhatmDetailControllerProvider('MUTATE88'),
        );
        expect(
          stateAfterConflict.conflictError,
          'این سهم توسط کاربر دیگری برداشته شد',
        );
        expect(
          stateAfterConflict.campaign!.slots
              .firstWhere((s) => s.unitNumber == 2)
              .userDisplayName,
          'کاربر رقیب',
        );
      },
    );

    testWidgets(
      'GroupKhatmDetailScreen shows confirmation dialog with in-dialog loading before reserving and preserves cards',
      (tester) async {
        final reserveCompleter = Completer<void>();
        final fakeRepo = _FakeGroupCampaignKhatmRepository(
          campaignToReturn: GroupKhatmCampaign(
            id: 91,
            inviteCode: 'CONF9191',
            creatorDisplayName: 'مهدی',
            title: 'ختم تأییدیه',
            unitType: 'juz',
            targetUnits: 2,
            reservedUnits: 0,
            completedUnits: 0,
            remainingUnits: 2,
            progressPercentage: 0,
            status: GroupKhatmStatus.active,
            createdAt: DateTime(2026, 3, 1),
            slots: const [
              GroupKhatmSlot(
                id: 11,
                campaignId: 91,
                unitNumber: 1,
                status: GroupKhatmSlotStatus.available,
              ),
              GroupKhatmSlot(
                id: 12,
                campaignId: 91,
                unitNumber: 2,
                status: GroupKhatmSlotStatus.available,
              ),
            ],
          ),
          reserveGate: reserveCompleter.future,
        );
        final fakeProgressDs = _FakeGroupProgressLocalDataSource();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              khatmRepositoryProvider.overrideWithValue(fakeRepo),
              groupKhatmProgressLocalDataSourceProvider.overrideWithValue(
                fakeProgressDs,
              ),
              tafakorAuthRepositoryProvider.overrideWithValue(
                _FakeTafakorAuthRepository(
                  currentUser: const TafakorUser(
                    phone: '09120000000',
                    token: 'tok',
                    firstName: 'رضا',
                    lastName: 'احمدی',
                  ),
                ),
              ),
            ],
            child: const MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: GroupKhatmDetailScreen(inviteCode: 'CONF9191'),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        // Tap available Juz 1 -> opens confirmation dialog first (no reserve yet)
        await tester.tap(find.text('جزء ۱'));
        await tester.pumpAndSettle();

        expect(find.text('تأیید برداشتن سهم'), findsOneWidget);
        expect(find.text('بله، برمی‌دارم'), findsOneWidget);
        expect(fakeRepo.reserveCallCount, 0);

        // Tap Confirm -> shows inline loading indicator while network is in-flight
        await tester.tap(find.text('بله، برمی‌دارم'));
        await tester.pump();

        expect(fakeRepo.reserveCallCount, 1);
        expect(find.text('تأیید برداشتن سهم'), findsOneWidget);

        // Finish network call -> dialog closes, cards remain visible with updated state!
        reserveCompleter.complete();
        await tester.pumpAndSettle();

        expect(find.text('تأیید برداشتن سهم'), findsNothing);
        expect(find.text('تموم شد'), findsOneWidget);
        expect(find.text('آزاد'), findsOneWidget);
      },
    );

    testWidgets(
      'GroupKhatmCampaign.fromJson and GroupKhatmSlotGrid keep strict ascending unitNumber order regardless of claimed status or server row order',
      (tester) async {
        // Simulate Postgres returning updated Hizb 15 at the end after Hizb 77 & Hizb 120
        final parsed = GroupKhatmCampaign.fromJson({
          'id': 200,
          'invite_code': 'HIZB200',
          'creator_display_name': 'بانی',
          'title': 'ختم حزبی مرتب',
          'unit_type': 'hizb',
          'target_units': 120,
          'reserved_units': 1,
          'completed_units': 0,
          'remaining_units': 119,
          'progress_percentage': 0,
          'status': 'active',
          'created_at': '2026-03-01T10:00:00Z',
          'slots': [
            {
              'id': 77,
              'campaign_id': 200,
              'unit_number': 77,
              'status': 'available',
            },
            {
              'id': 1,
              'campaign_id': 200,
              'unit_number': 1,
              'status': 'available',
            },
            {
              'id': 120,
              'campaign_id': 200,
              'unit_number': 120,
              'status': 'completed',
            },
            {
              'id': 15,
              'campaign_id': 200,
              'unit_number': 15,
              'status': 'reserved',
              'is_mine': true,
              'user_display_name': 'خودم',
            },
          ],
        });

        expect(parsed.slots.map((s) => s.unitNumber).toList(), [
          1,
          15,
          77,
          120,
        ]);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              groupKhatmProgressLocalDataSourceProvider.overrideWithValue(
                _FakeGroupProgressLocalDataSource(),
              ),
            ],
            child: MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  body: SingleChildScrollView(
                    child: SizedBox(
                      width: 360,
                      child: GroupKhatmSlotGrid(
                        campaign: parsed,
                        isAuthenticated: true,
                        onSlotTap: (_) {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // In RTL 3-column grid, row 1 is [1 (right), 15 (center), 77 (left)] and row 2 is [120]
        final center1 = tester.getCenter(find.text('حزب ۱'));
        final center15 = tester.getCenter(find.text('حزب ۱۵'));
        final center77 = tester.getCenter(find.text('حزب ۷۷'));
        final center120 = tester.getCenter(find.text('حزب ۱۲۰'));

        expect(center1.dx, greaterThan(center15.dx));
        expect(center15.dx, greaterThan(center77.dx));
        expect(center1.dy, closeTo(center77.dy, 12));
        expect(center120.dy, greaterThan(center77.dy));
      },
    );

    testWidgets(
      'GroupKhatmReaderBar animates collapse <-> expand without RenderFlex overflow at intermediate frames',
      (tester) async {
        final fakeRepo = _FakeGroupCampaignKhatmRepository(
          campaignToReturn: GroupKhatmCampaign(
            id: 2,
            inviteCode: '1z92Cq3t',
            creatorDisplayName: 'محمد',
            title: 'ddd',
            unitType: 'hizb',
            targetUnits: 120,
            reservedUnits: 1,
            completedUnits: 0,
            remainingUnits: 119,
            progressPercentage: 0,
            status: GroupKhatmStatus.active,
            createdAt: DateTime(2026, 3, 1),
          ),
        );
        final container = ProviderContainer(
          overrides: [
            khatmRepositoryProvider.overrideWithValue(fakeRepo),
            groupKhatmProgressLocalDataSourceProvider.overrideWithValue(
              _FakeGroupProgressLocalDataSource(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  body: Column(
                    children: [
                      GroupKhatmReaderBar(
                        inviteCode: '1z92Cq3t',
                        slotId: 33,
                        unitNumber: 3,
                        unitType: GroupKhatmUnitType.hizb,
                        onClose: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Collapse then immediately re-expand while AnimatedContainer is at ~3px
        container
            .read(isKhatmReaderBarCollapsedProvider.notifier)
            .setCollapsed(true);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 220));

        container
            .read(isKhatmReaderBarCollapsedProvider.notifier)
            .setCollapsed(false);
        await tester.pump();
        // Intermediate animation frame (~2.2px..15px) must NOT overflow!
        await tester.pump(const Duration(milliseconds: 30));
        await tester.pump(const Duration(milliseconds: 220));

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'GroupKhatmDetailScreen replaces invite button with توضیحات dialog explaining reading rules without overflow on 320px',
      (tester) async {
        final fakeRepo = _FakeGroupCampaignKhatmRepository(
          campaignToReturn: GroupKhatmCampaign(
            id: 95,
            inviteCode: 'GUIDE95',
            creatorDisplayName: 'مهدی',
            title: 'ختم حزبی راهنما',
            unitType: 'hizb',
            targetUnits: 120,
            remainingUnits: 118,
            progressPercentage: 1.6,
            status: GroupKhatmStatus.active,
            deadline: DateTime.now().add(const Duration(days: 5)),
            createdAt: DateTime(2026, 3, 1),
            slots: const [
              GroupKhatmSlot(
                id: 1,
                campaignId: 95,
                unitNumber: 1,
                status: GroupKhatmSlotStatus.available,
              ),
              GroupKhatmSlot(
                id: 2,
                campaignId: 95,
                unitNumber: 2,
                status: GroupKhatmSlotStatus.reserved,
                isMine: true,
                userDisplayName: 'محمد',
              ),
            ],
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              khatmRepositoryProvider.overrideWithValue(fakeRepo),
              groupKhatmProgressLocalDataSourceProvider.overrideWithValue(
                _FakeGroupProgressLocalDataSource(),
              ),
              tafakorAuthRepositoryProvider.overrideWithValue(
                _FakeTafakorAuthRepository(
                  currentUser: const TafakorUser(
                    phone: '09120000000',
                    token: 'tok',
                    firstName: 'محمد',
                    lastName: 'رضایی',
                  ),
                ),
              ),
            ],
            child: const MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(size: Size(320, 640)),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: GroupKhatmDetailScreen(inviteCode: 'GUIDE95'),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        // AppBar must show توضیحات instead of دعوت
        expect(find.text('دعوت'), findsNothing);
        expect(find.text('توضیحات'), findsOneWidget);

        // Open guide dialog
        await tester.tap(find.text('توضیحات'));
        await tester.pumpAndSettle();

        expect(find.text('راهنمای قرائت و مشارکت'), findsOneWidget);
        final headerText = tester.widget<Text>(
          find.text('راهنمای قرائت و مشارکت'),
        );
        expect(headerText.textAlign, TextAlign.center);
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(Icon),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.textContaining('زمان باقی‌مانده:'),
          ),
          findsOneWidget,
        );
        expect(find.text('اساس ختم: حزب‌بندی (۱۲۰ حزب)'), findsOneWidget);
        expect(find.textContaining('۱۲۰ حزب قرآن کریم'), findsOneWidget);
        expect(find.text('انتخاب سهم شخصی'), findsOneWidget);
        expect(find.text('تکمیل دستی یا آزادسازی کارت'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Close dialog via متوجه شدم
        await tester.tap(find.text('متوجه شدم'));
        await tester.pumpAndSettle();

        expect(find.text('راهنمای قرائت و مشارکت'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'GroupKhatmSlotGrid cards and floating unit badges render strictly colorless neutral surfaces with no green background',
      (tester) async {
        final fakeProgressDs = _FakeGroupProgressLocalDataSource();
        final campaign = GroupKhatmCampaign(
          id: 99,
          inviteCode: 'NEUTRAL99',
          creatorDisplayName: 'مهدی',
          title: 'ختم بی‌رنگ',
          unitType: 'hizb',
          targetUnits: 4,
          reservedUnits: 2,
          completedUnits: 2,
          remainingUnits: 1,
          progressPercentage: 50,
          status: GroupKhatmStatus.active,
          createdAt: DateTime(2026, 3, 1),
          slots: const [
            GroupKhatmSlot(
              id: 1,
              campaignId: 99,
              unitNumber: 1,
              status: GroupKhatmSlotStatus.reserved,
              isMine: true,
              userDisplayName: 'علی',
            ),
            GroupKhatmSlot(
              id: 2,
              campaignId: 99,
              unitNumber: 2,
              status: GroupKhatmSlotStatus.completed,
              isMine: true,
              userDisplayName: 'علی',
            ),
            GroupKhatmSlot(
              id: 3,
              campaignId: 99,
              unitNumber: 3,
              status: GroupKhatmSlotStatus.available,
            ),
            GroupKhatmSlot(
              id: 4,
              campaignId: 99,
              unitNumber: 4,
              status: GroupKhatmSlotStatus.completed,
              isMine: false,
              userDisplayName: 'سارا',
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              khatmRepositoryProvider.overrideWithValue(
                _FakeGroupCampaignKhatmRepository(campaignToReturn: campaign),
              ),
              groupKhatmProgressLocalDataSourceProvider.overrideWithValue(
                fakeProgressDs,
              ),
            ],
            child: MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  body: SingleChildScrollView(
                    child: GroupKhatmSlotGrid(
                      campaign: campaign,
                      isAuthenticated: true,
                      onSlotTap: (_) {},
                      onCompleteSlot: (_) {},
                      onReleaseSlot: (_) {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Inspect every card container & floating badge inside GridView to ensure achromatic colors (R == G == B)
        final gridFinder = find.byType(GridView);
        expect(gridFinder, findsOneWidget);

        final decoratedBoxes = tester.widgetList<AnimatedContainer>(
          find.descendant(
            of: gridFinder,
            matching: find.byType(AnimatedContainer),
          ),
        );
        expect(decoratedBoxes.length, 4);
        for (final box in decoratedBoxes) {
          final dec = box.decoration as BoxDecoration?;
          final bg = dec?.color;
          expect(bg, isNotNull);
          expect((bg!.r - bg.g).abs(), lessThan(0.01));
          expect((bg.g - bg.b).abs(), lessThan(0.01));
        }

        // Verify progress rings inside cards are colorless (not emerald green)
        final rings = tester.widgetList<GroupKhatmSlotProgressRing>(
          find.descendant(
            of: gridFinder,
            matching: find.byType(GroupKhatmSlotProgressRing),
          ),
        );
        expect(rings.length, 2);
        for (final ring in rings) {
          expect(ring.color, isNotNull);
          final c = ring.color!;
          expect((c.r - c.g).abs(), lessThan(0.02));
          expect((c.g - c.b).abs(), lessThan(0.02));
        }

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Group khatm cards in both my campaigns and active campaigns show circular progress ring on the left opposite title and subtitle in RTL',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final myCampaign = GroupKhatmCampaign(
          id: 101,
          inviteCode: 'MYRING1',
          creatorDisplayName: 'محمد',
          title: 'ختم شخصی‌سازی‌شده من',
          unitType: 'hizb',
          targetUnits: 120,
          remainingUnits: 90,
          progressPercentage: 25,
          status: GroupKhatmStatus.active,
          deadline: DateTime.now().add(const Duration(days: 3)),
          createdAt: DateTime(2026, 3, 1),
          slots: const [
            GroupKhatmSlot(
              id: 1,
              campaignId: 101,
              unitNumber: 5,
              status: GroupKhatmSlotStatus.reserved,
              isMine: true,
              userDisplayName: 'محمد',
            ),
          ],
        );

        final activeCampaign = GroupKhatmCampaign(
          id: 102,
          inviteCode: 'ACTRING2',
          creatorDisplayName: 'سارا',
          title: 'ختم فعال همگانی',
          description: 'توضیح کوتاه زیر عنوان',
          unitType: 'juz',
          targetUnits: 30,
          remainingUnits: 18,
          progressPercentage: 40,
          status: GroupKhatmStatus.active,
          createdAt: DateTime(2026, 3, 2),
        );

        final fakeRepo = _FakeGroupCampaignKhatmRepository(
          myCampaignsToReturn: [myCampaign],
          publicCampaignsToReturn: [activeCampaign],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesInstanceProvider.overrideWithValue(prefs),
              khatmLocalDataSourceProvider.overrideWithValue(
                InMemoryKhatmDataSource([]),
              ),
              khatmRepositoryProvider.overrideWithValue(fakeRepo),
              tafakorAuthRepositoryProvider.overrideWithValue(
                _FakeTafakorAuthRepository(
                  currentUser: const TafakorUser(
                    phone: '09120000000',
                    token: 'tok',
                    firstName: 'محمد',
                    lastName: 'رضایی',
                  ),
                ),
              ),
            ],
            child: const MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: KhatmListScreen(),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));

        // Switch to Group Khatm tab
        await tester.tap(find.text('گروهی'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));

        // Both cards use KhatmCircularProgressRing instead of LinearProgressIndicator
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(find.byType(KhatmCircularProgressRing), findsNWidgets(2));
        expect(find.text('۲۵٪'), findsOneWidget);
        expect(find.text('۴۰٪'), findsOneWidget);

        // Verify left-of-title positioning in RTL for my campaign card
        final myTitleFinder = find.text('ختم شخصی‌سازی‌شده من').first;
        final mySubFinder = find.textContaining('سهم شما:').first;
        final myRingFinder = find.ancestor(
          of: find.text('۲۵٪'),
          matching: find.byType(KhatmCircularProgressRing),
        );
        expect(myTitleFinder, findsOneWidget);
        expect(mySubFinder, findsOneWidget);
        expect(myRingFinder, findsOneWidget);
        expect(
          tester.getCenter(myRingFinder).dx,
          lessThan(tester.getCenter(myTitleFinder).dx),
        );
        expect(
          tester.getCenter(myRingFinder).dx,
          lessThan(tester.getCenter(mySubFinder).dx),
        );

        // Verify left-of-title positioning in RTL for active GroupKhatmCard
        final activeTitleFinder = find.text('ختم فعال همگانی');
        final activeSubFinder = find.text('توضیح کوتاه زیر عنوان');
        final activeRingFinder = find.ancestor(
          of: find.text('۴۰٪'),
          matching: find.byType(KhatmCircularProgressRing),
        );
        expect(activeTitleFinder, findsOneWidget);
        expect(activeSubFinder, findsOneWidget);
        expect(activeRingFinder, findsOneWidget);
        expect(
          tester.getCenter(activeRingFinder).dx,
          lessThan(tester.getCenter(activeTitleFinder).dx),
        );
        expect(
          tester.getCenter(activeRingFinder).dx,
          lessThan(tester.getCenter(activeSubFinder).dx),
        );

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'GuestOtpBottomSheet formats phone and OTP digits in Persian with AppTypography.fontFamily and shows inline plain error without snackbar/red box',
      (tester) async {
        final fakeAuthRepo = _FakeTafakorAuthRepository(
          verifyOtpError: const Failure(message: 'کد تأیید نادرست است.'),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tafakorAuthRepositoryProvider.overrideWithValue(fakeAuthRepo),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (ctx) => ElevatedButton(
                    onPressed: () => GuestOtpBottomSheet.show(
                      ctx,
                      title: 'ورود',
                      description: 'شماره موبایل را وارد کنید',
                    ),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        // Phone TextField uses AppTypography.fontFamily + PersianNumberFormatter
        final phoneField = tester.widget<TextField>(find.byType(TextField));
        expect(phoneField.style?.fontFamily, AppTypography.fontFamily);
        expect(
          phoneField.inputFormatters?.any((f) => f is PersianNumberFormatter),
          isTrue,
        );

        // Invalid phone shows plain inline error text inside bottom sheet
        await tester.enterText(find.byType(TextField), '09123');
        await tester.pump();
        expect(find.text('۰۹۱۲۳'), findsOneWidget);

        await tester.tap(find.text('دریافت کد تأیید'));
        await tester.pump();
        expect(
          find.text('شماره موبایل باید ۱۱ رقم و با ۰۹ شروع شود'),
          findsOneWidget,
        );
        expect(find.byType(SnackBar), findsNothing);

        // Valid phone clears inline error and advances to OTP step
        await tester.enterText(find.byType(TextField), '09123456789');
        await tester.pump();
        expect(
          find.text('شماره موبایل باید ۱۱ رقم و با ۰۹ شروع شود'),
          findsNothing,
        );
        await tester.tap(find.text('دریافت کد تأیید'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Pinput uses AppTypography.fontFamily + PersianNumberFormatter
        final pinput = tester.widget<Pinput>(find.byType(Pinput));
        expect(
          pinput.defaultPinTheme?.textStyle?.fontFamily,
          AppTypography.fontFamily,
        );
        expect(
          pinput.inputFormatters.any((f) => f is PersianNumberFormatter),
          isTrue,
        );

        // Wrong OTP shows server error as plain inline text inside bottom sheet
        await tester.enterText(find.byType(EditableText), '1234');
        await tester.pump();
        await tester.pump();
        expect(find.text('کد تأیید نادرست است.'), findsOneWidget);
        expect(find.byType(SnackBar), findsNothing);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'GroupKhatmCard omits top unit-type box and puts plain "بر اساس <unitType>" at start of remaining slots text; GroupKhatmListController paginates both my and public campaigns',
      (tester) async {
        final myList = List.generate(
          15,
          (i) => GroupKhatmCampaign(
            id: 200 + i,
            inviteCode: 'MY$i',
            creatorDisplayName: 'مریم',
            title: 'ختم من $i',
            unitType: 'hizb',
            targetUnits: 120,
            remainingUnits: 50,
            progressPercentage: 10,
            status: GroupKhatmStatus.active,
            createdAt: DateTime(2026, 3, 1),
          ),
        );
        final publicList = List.generate(
          15,
          (i) => GroupKhatmCampaign(
            id: 300 + i,
            inviteCode: 'PUB$i',
            creatorDisplayName: 'علی',
            title: 'ختم عمومی $i',
            unitType: 'hizb',
            targetUnits: 120,
            remainingUnits: 88,
            progressPercentage: 20,
            status: GroupKhatmStatus.active,
            createdAt: DateTime(2026, 3, 1),
          ),
        );

        final fakeRepo = _FakeGroupCampaignKhatmRepository(
          myCampaignsToReturn: myList,
          publicCampaignsToReturn: publicList,
        );
        final controller = GroupKhatmListController(fakeRepo);
        await controller.init();

        // Page 1 loads 10 items per list (light server payload) and tracks totalCount + hasMore
        expect(controller.state.myCampaigns.length, 10);
        expect(controller.state.myTotalCount, 15);
        expect(controller.state.myHasMore, isTrue);
        expect(controller.state.publicCampaigns.length, 10);
        expect(controller.state.publicTotalCount, 15);
        expect(controller.state.publicHasMore, isTrue);

        await controller.loadMoreMyCampaigns();
        await controller.loadMorePublicCampaigns();

        expect(controller.state.myCampaigns.length, 15);
        expect(controller.state.myHasMore, isFalse);
        expect(controller.state.publicCampaigns.length, 15);
        expect(controller.state.publicHasMore, isFalse);
        controller.dispose();

        // Card renders without standalone top unit-type box and puts "بر اساس حزب • ۸۸ موقعیت خالی" as plain subtitle
        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: GroupKhatmCard(campaign: publicList.first),
              ),
            ),
          ),
        );

        expect(find.text('حزب'), findsNothing);
        expect(find.text('بر اساس حزب • ۸۸ موقعیت خالی'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'AppConstants uses production tafakormag.ir API and GroupKhatmReaderBar avoids green background when expanded or collapsed',
      (tester) async {
        expect(AppConstants.tafakorBaseUrl, 'https://tafakormag.ir/api/');
        expect(AppConstants.patchServerBaseUrl, 'https://tafakormag.ir');

        final fakeRepo = _FakeGroupCampaignKhatmRepository(
          campaignToReturn: GroupKhatmCampaign(
            id: 205,
            inviteCode: 'BARCOLOR',
            creatorDisplayName: 'مریم',
            title: 'ختم یس',
            unitType: 'surah',
            targetUnits: 1,
            targetSurahId: 36,
            reservedUnits: 0,
            completedUnits: 1,
            remainingUnits: 0,
            progressPercentage: 100,
            status: GroupKhatmStatus.active,
            createdAt: DateTime(2026, 3, 1),
          ),
        );
        final progressDs = _FakeGroupProgressLocalDataSource();
        await progressDs.saveProgress(
          GroupKhatmSlotProgress(
            inviteCode: 'BARCOLOR',
            slotId: 44,
            unitType: GroupKhatmUnitType.surah,
            unitNumber: 36,
            targetQuantity: 1,
            completedRepetitions: 1,
            currentPassProgress: 1.0,
            isCompletedLocally: true,
            updatedAt: DateTime(2026, 3, 1),
          ),
        );

        final container = ProviderContainer(
          overrides: [
            khatmRepositoryProvider.overrideWithValue(fakeRepo),
            groupKhatmProgressLocalDataSourceProvider.overrideWithValue(
              progressDs,
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: ThemeData.light(),
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  body: GroupKhatmReaderBar(
                    inviteCode: 'BARCOLOR',
                    slotId: 44,
                    unitNumber: 36,
                    unitType: GroupKhatmUnitType.surah,
                    onClose: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Expanded background uses cardBackground (white in light theme), NOT green primary tint
        final expandedContainer = tester.widget<AnimatedContainer>(
          find.descendant(
            of: find.byType(GroupKhatmReaderBar),
            matching: find.byType(AnimatedContainer),
          ),
        );
        final expandedDecoration = expandedContainer.decoration! as BoxDecoration;
        expect(expandedDecoration.color, Colors.white);

        // Collapsed strip background must be transparent (only progress line is green)
        container
            .read(isKhatmReaderBarCollapsedProvider.notifier)
            .setCollapsed(true);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        final collapsedContainer = tester.widget<AnimatedContainer>(
          find.descendant(
            of: find.byType(GroupKhatmReaderBar),
            matching: find.byType(AnimatedContainer),
          ),
        );
        final collapsedDecoration =
            collapsedContainer.decoration! as BoxDecoration;
        expect(collapsedDecoration.color, Colors.transparent);
        expect(collapsedDecoration.border, isNull);
        expect(tester.takeException(), isNull);
      },
    );
  });
}

class _FakeGroupProgressLocalDataSource
    implements IGroupKhatmProgressLocalDataSource {
  final Map<String, GroupKhatmSlotProgress> _store = {};

  @override
  Future<void> deleteProgress(String inviteCode, int slotId) async {
    _store.remove(GroupKhatmSlotProgress.buildStorageKey(inviteCode, slotId));
  }

  @override
  Future<List<GroupKhatmSlotProgress>> getAll() async => _store.values.toList();

  @override
  Future<GroupKhatmSlotProgress?> getProgress(
    String inviteCode,
    int slotId,
  ) async => _store[GroupKhatmSlotProgress.buildStorageKey(inviteCode, slotId)];

  @override
  Future<void> saveProgress(GroupKhatmSlotProgress progress) async {
    _store[progress.storageKey] = progress;
  }
}

class _FakeGroupCampaignKhatmRepository extends _FakeSyncKhatmRepository {
  GroupKhatmCampaign? campaignToReturn;
  List<GroupKhatmCampaign> publicCampaignsToReturn;
  List<GroupKhatmCampaign> myCampaignsToReturn;
  bool shouldFailComplete = false;
  bool shouldReturnConflictOnReserve = false;
  String conflictMessage =
      'این سهم همین لحظه توسط کاربر دیگری برداشته شد؛ لطفاً سهم آزاد دیگری انتخاب کنید';
  bool returnSummaryWithoutSlotsOnReserve = false;
  Future<void>? reserveGate;
  int reserveCallCount = 0;
  final List<int> completedSlotIds = [];

  _FakeGroupCampaignKhatmRepository({
    this.campaignToReturn,
    this.publicCampaignsToReturn = const [],
    this.myCampaignsToReturn = const [],
    this.reserveGate,
  });

  @override
  Future<Result<GroupKhatmCampaign, Failure>> getCampaignDetail(
    String inviteCode,
  ) async {
    return Success(
      campaignToReturn ??
          GroupKhatmCampaign(
            id: 50,
            inviteCode: inviteCode,
            creatorDisplayName: 'مریم',
            title: 'ختم اول',
            unitType: 'juz',
            targetUnits: 30,
            reservedUnits: 1,
            completedUnits: 0,
            remainingUnits: 29,
            progressPercentage: 0,
            status: GroupKhatmStatus.active,
            createdAt: DateTime(2026, 3, 1),
          ),
    );
  }

  @override
  Future<Result<GroupKhatmCampaign, Failure>> reserveSlot(
    String inviteCode, {
    int? unitNumber,
    int quantity = 1,
  }) async {
    reserveCallCount++;
    if (reserveGate != null) {
      await reserveGate;
    }
    if (shouldReturnConflictOnReserve) {
      return Error(
        Failure(
          message: conflictMessage,
          statusCode: 409,
          code: 'slot_already_taken',
        ),
      );
    }

    final current = campaignToReturn!;
    final updatedSlots = current.slots.map((s) {
      if (unitNumber != null && s.unitNumber == unitNumber) {
        return GroupKhatmSlot(
          id: s.id,
          campaignId: s.campaignId,
          unitNumber: s.unitNumber,
          quantity: s.quantity,
          status: GroupKhatmSlotStatus.reserved,
          isMine: true,
          userDisplayName: 'رضا احمدی',
        );
      }
      return s;
    }).toList();

    final updated = GroupKhatmCampaign(
      id: current.id,
      inviteCode: current.inviteCode,
      creatorDisplayName: current.creatorDisplayName,
      title: current.title,
      unitType: current.unitType,
      targetUnits: current.targetUnits,
      reservedUnits: updatedSlots.where((s) => s.isReserved).length,
      completedUnits: updatedSlots.where((s) => s.isCompleted).length,
      remainingUnits: updatedSlots.where((s) => s.isFree).length,
      progressPercentage: current.progressPercentage,
      status: current.status,
      createdAt: current.createdAt,
      slots: updatedSlots,
    );
    campaignToReturn = updated;

    if (returnSummaryWithoutSlotsOnReserve) {
      // Return campaign metadata with empty slots to verify merge + reload!
      return Success(
        GroupKhatmCampaign(
          id: updated.id,
          inviteCode: updated.inviteCode,
          creatorDisplayName: updated.creatorDisplayName,
          title: updated.title,
          unitType: updated.unitType,
          targetUnits: updated.targetUnits,
          reservedUnits: updated.reservedUnits,
          completedUnits: updated.completedUnits,
          remainingUnits: updated.remainingUnits,
          progressPercentage: updated.progressPercentage,
          status: updated.status,
          createdAt: updated.createdAt,
          slots: const [],
        ),
      );
    }
    return Success(updated);
  }

  @override
  Future<Result<GroupKhatmCampaign, Failure>> completeSlot(
    String inviteCode, {
    int? slotId,
    int? unitNumber,
  }) async {
    if (shouldFailComplete) {
      return const Error(Failure(message: 'offline'));
    }
    if (slotId != null) {
      completedSlotIds.add(slotId);
    }
    return getCampaignDetail(inviteCode);
  }

  @override
  Future<Result<List<GroupKhatmCategory>, Failure>> getCategories() async =>
      const Success([]);

  PaginatedCampaignsPage _slicePage(
    List<GroupKhatmCampaign> source,
    int page,
    int pageSize,
  ) {
    final start = ((page - 1) * pageSize).clamp(0, source.length);
    final end = (start + pageSize).clamp(0, source.length);
    return PaginatedCampaignsPage(
      items: source.sublist(start, end),
      totalCount: source.length,
      hasNext: end < source.length,
    );
  }

  @override
  Future<Result<PaginatedCampaignsPage, Failure>> getCampaignsPage({
    int? categoryId,
    String? unitType,
    String? status,
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async => Success(_slicePage(publicCampaignsToReturn, page, pageSize));

  @override
  Future<Result<List<GroupKhatmCampaign>, Failure>> getCampaigns({
    int? categoryId,
    String? unitType,
    String? status,
    String? search,
    int page = 1,
  }) async => Success(_slicePage(publicCampaignsToReturn, page, 10).items);

  @override
  Future<Result<PaginatedCampaignsPage, Failure>> getMyCampaignsPage({
    required String tab,
    int page = 1,
    int pageSize = 10,
  }) async => Success(_slicePage(myCampaignsToReturn, page, pageSize));

  @override
  Future<Result<List<GroupKhatmCampaign>, Failure>> getMyCampaigns({
    required String tab,
  }) async => Success(_slicePage(myCampaignsToReturn, 1, 10).items);
}
