import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quran/common/exceptions/failure.dart';
import 'package:quran/core/data/local/preferences/preferences_service_provider.dart';
import 'package:quran/features/khatm/application/controllers/khatm_list_controller.dart';
import 'package:quran/features/khatm/application/controllers/personal_khatm_sync_controller.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_campaign.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_category.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_slot.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';
import 'package:quran/features/khatm/domain/entities/khatm_plan.dart';
import 'package:quran/features/khatm/domain/entities/khatm_session_item.dart';
import 'package:quran/features/khatm/domain/repositories/i_khatm_repository.dart';
import 'package:quran/features/khatm/presentation/widgets/group_detail/group_khatm_participants_sheet.dart';
import 'package:quran/features/khatm/presentation/widgets/group_detail/group_khatm_slot_grid.dart';
import 'package:quran/features/khatm/presentation/widgets/shared/complete_name_bottom_sheet.dart';
import 'package:quran/features/khatm/presentation/widgets/shared/guest_otp_bottom_sheet.dart';
import 'package:quran/features/profile/presentation/ui/profile_screen.dart';
import 'package:quran/features/subscription/application/vip_subscription_controller.dart';
import 'package:quran/features/subscription/domain/models/vip_subscription_state.dart';
import 'package:quran/features/tafakor/domain/entities/tafakor_user.dart';
import 'package:quran/features/tafakor/domain/repositories/i_tafakor_auth_repository.dart';
import 'package:quran/features/tafakor/infrastructure/dtos/tafakor_user_dto.dart';
import 'package:quran/features/tafakor/infrastructure/repositories/tafakor_auth_repository_impl.dart';

import 'khatm_sync_test.dart';

class _FakeTafakorAuthRepository implements ITafakorAuthRepository {
  TafakorUser? currentUser;
  String? updatedFirstName;
  String? updatedLastName;

  _FakeTafakorAuthRepository({this.currentUser});

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
    currentUser = (currentUser ?? const TafakorUser(phone: '09120000000', token: 'tok'))
        .copyWith(firstName: firstName, lastName: lastName);
    return Success(currentUser!);
  }

  @override
  Future<Result<TafakorUser, Failure>> verifyOtp(String phone, String otp) async =>
      Success(currentUser ?? TafakorUser(phone: phone, token: 'tok'));
}

class _FakeSyncKhatmRepository implements IKhatmRepository {
  List<Map<String, dynamic>> lastSentPlans = [];
  String? lastSentSyncedAt;
  int syncCallCount = 0;
  Map<String, dynamic> Function(
    List<Map<String, dynamic>> plans,
    String? lastSyncedAt,
  )? onSync;

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
    return const Success({
      'server_time': '2026-11-24T12:00:00Z',
      'plans': [],
    });
  }

  @override
  Future<Result<List<GroupKhatmCampaign>, Failure>> getCampaigns({
    int? categoryId,
    String? unitType,
    String? status,
    String? search,
    int page = 1,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<List<GroupKhatmCampaign>, Failure>> getMyCampaigns({
    required String tab,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<GroupKhatmCampaign, Failure>> getCampaignDetail(
    String inviteCode,
  ) =>
      throw UnimplementedError();

  @override
  Future<Result<GroupKhatmCampaign, Failure>> reserveSlot(
    String inviteCode, {
    int? unitNumber,
    int quantity = 1,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<GroupKhatmCampaign, Failure>> completeSlot(
    String inviteCode, {
    int? slotId,
    int? unitNumber,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<GroupKhatmCampaign, Failure>> releaseSlot(
    String inviteCode, {
    int? slotId,
    int? unitNumber,
  }) =>
      throw UnimplementedError();

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
  }) =>
      throw UnimplementedError();

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
  VipSubscriptionState build() => const VipSubscriptionState(
        isVip: false,
        isLoading: false,
      );
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
    test('TafakorUserDto & TafakorUser parse names and enforce hasFullName', () {
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
    });

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
          MaterialApp(
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
        );
        expect(find.text('محمدرضا حسینی'), findsNothing);
        expect(find.text('فاطمه کریمی'), findsNothing);
        expect(find.text('قرائت شده'), findsOneWidget);
        expect(find.text('در حال قرائت'), findsOneWidget);

        // Authenticated mode: shows full names single-line in 3-column grid
        await tester.pumpWidget(
          MaterialApp(
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
    test('KhatmPlan preserves real clientUpdatedAt, deletedAt, isDirty and legacy Hive compatibility', () {
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
    });

    test('Two-way sync persists server_time, uploads only dirty plans, merges LWW updates & soft deletes', () async {
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
    });

    test('PersonalKhatmSyncController.scheduleSync debounces for 4 seconds', () async {
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
    });
  });

  group('Package 1 UI Widgets: ProfileScreen & CompleteNameBottomSheet', () {
    testWidgets('ProfileScreen displays real fullName when authenticated and fallback for guest', (tester) async {
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
    });

    testWidgets('GuestOtpBottomSheet transitions to name completion after OTP when hasFullName is false and only returns true after save', (tester) async {
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
    });

    testWidgets('CompleteNameBottomSheet validates required fields and saves via updateProfile', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final authRepo = _FakeTafakorAuthRepository(
        currentUser: const TafakorUser(
          phone: '09121112233',
          token: 'tok-1',
        ),
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
    });
  });
}
