import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quran/common/exceptions/failure.dart';
import 'package:quran/core/data/local/preferences/preferences_service_impl.dart';
import 'package:quran/core/data/local/preferences/preferences_service_provider.dart';
import 'package:quran/core/services/analytics/analytics_providers.dart';
import 'package:quran/core/services/analytics/i_analytics_service.dart';
import 'package:quran/core/services/audio/audio_player_providers.dart';
import 'package:quran/core/services/audio/audio_player_state.dart';
import 'package:quran/core/services/audio/i_audio_player_service.dart';
import 'package:quran/core/services/audio/quran_audio_handler.dart';
import 'package:quran/core/services/audio_storage/audio_storage_providers.dart';
import 'package:quran/core/services/audio_storage/i_audio_storage_service.dart';
import 'package:quran/core/services/quran_navigation/domain/entities/ayah_target.dart';
import 'package:quran/features/ayah_teaser/application/controllers/ayah_teaser_controller.dart';
import 'package:quran/features/bookmarks/application/controllers/bookmarks_controller.dart';
import 'package:quran/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:quran/features/khatm/application/controllers/group_khatm_reading_controller.dart';
import 'package:quran/features/khatm/application/controllers/khatm_detail_controller.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_campaign.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_category.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_slot_progress.dart';
import 'package:quran/features/khatm/domain/entities/khatm_ayah_span.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';
import 'package:quran/features/khatm/domain/entities/khatm_plan.dart';
import 'package:quran/features/khatm/domain/entities/khatm_session_item.dart';
import 'package:quran/features/khatm/domain/repositories/i_khatm_repository.dart';
import 'package:quran/features/khatm/domain/services/khatm_progress_calculator.dart';
import 'package:quran/features/khatm/domain/services/khatm_quran_resolver.dart';
import 'package:quran/features/khatm/infrastructure/datasources/group_khatm_progress_local_datasource.dart';
import 'package:quran/features/khatm/infrastructure/datasources/khatm_local_datasource.dart';
import 'package:quran/features/khatm/infrastructure/datasources/khatm_quran_data.dart';
import 'package:quran/features/khatm/infrastructure/repositories/khatm_repository_impl.dart';
import 'package:quran/features/khatm/presentation/widgets/report/khatm_progress_donut_chart.dart';
import 'package:quran/features/khatm/presentation/widgets/shared/khatm_circular_progress_ring.dart';
import 'package:quran/features/quran_reader/application/ayah_service.dart';
import 'package:quran/features/quran_reader/application/controllers/quran_audio_controller.dart';
import 'package:quran/features/quran_reader/application/controllers/quran_display_settings_controller.dart';
import 'package:quran/features/quran_reader/application/controllers/quran_reader_controller.dart';
import 'package:quran/features/quran_reader/application/states/quran_display_settings_state.dart';
import 'package:quran/features/quran_reader/domain/entities/ayah_entity.dart';
import 'package:quran/features/quran_reader/domain/entities/reciter_entity.dart';
import 'package:quran/features/quran_reader/infrastructure/repositories/reciter_repository.dart';
import 'package:quran/features/quran_reader/presentation/ui/quran_reader_screen.dart';
import 'package:quran/features/quran_reader/presentation/widgets/quran_info_bar.dart';
import 'package:quran/features/quran_reader/presentation/widgets/surah_ayah_page_view.dart';
import 'package:quran/features/study_plan/domain/entities/study_plan.dart';
import 'package:quran/features/study_plan/infrastructure/datasources/study_plan_local_datasource.dart';
import 'package:quran/features/subscription/application/vip_subscription_controller.dart';
import 'package:quran/features/subscription/domain/models/vip_subscription_state.dart';
import 'package:quran/features/surah_list/application/surah_service.dart';
import 'package:quran/features/surah_list/domain/entities/surah_entity.dart';
import 'package:quran/features/surah_list/infrastructure/datasources/static_surahs_data.dart';
import 'package:quran/features/surah_list/infrastructure/dtos/surah_dto.dart';

class _TrackingKhatmLocalDataSource implements IKhatmLocalDataSource {
  final Map<String, KhatmPlan> plans = {};
  int savePlanCalls = 0;

  _TrackingKhatmLocalDataSource(List<KhatmPlan> initial) {
    for (final p in initial) {
      plans[p.id] = p;
    }
  }

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

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
  Future<void> hardDeletePlan(String id) async => plans.remove(id);

  @override
  Future<void> savePlan(KhatmPlan plan) async {
    savePlanCalls++;
    plans[plan.id] = plan;
  }

  @override
  Future<void> updateSessionProgress({
    required String planId,
    required int sessionIndex,
    required double progress,
    int? lastReadUnit,
    bool? isCompleted,
  }) async {}

  @override
  Future<void> updateSessionStatus({
    required String planId,
    required int sessionIndex,
    required bool isCompleted,
  }) async {}
}

class _FakeGroupProgressDs implements IGroupKhatmProgressLocalDataSource {
  final Map<String, GroupKhatmSlotProgress> items = {};
  final Duration delay;

  _FakeGroupProgressDs({this.delay = Duration.zero});

  @override
  Future<void> deleteProgress(String inviteCode, int slotId) async {
    items.remove(GroupKhatmSlotProgress.buildStorageKey(inviteCode, slotId));
  }

  @override
  Future<List<GroupKhatmSlotProgress>> getAll() async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    return items.values.toList();
  }

  @override
  Future<GroupKhatmSlotProgress?> getProgress(
    String inviteCode,
    int slotId,
  ) async => items[GroupKhatmSlotProgress.buildStorageKey(inviteCode, slotId)];

  @override
  Future<void> saveProgress(GroupKhatmSlotProgress progress) async {
    items[progress.storageKey] = progress;
  }
}

class _FakeGroupRepo extends Fake implements IKhatmRepository {
  final List<int> completedSlots = [];

  @override
  Future<Result<List<GroupKhatmCategory>, Failure>> getCategories() async =>
      const Success([]);

  @override
  Future<Result<PaginatedCampaignsPage, Failure>> getCampaignsPage({
    int? categoryId,
    String? unitType,
    String? status,
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async => const Success(
    PaginatedCampaignsPage(items: [], totalCount: 0, hasNext: false),
  );

  @override
  Future<Result<PaginatedCampaignsPage, Failure>> getMyCampaignsPage({
    required String tab,
    int page = 1,
    int pageSize = 10,
  }) async => const Success(
    PaginatedCampaignsPage(items: [], totalCount: 0, hasNext: false),
  );

  @override
  Future<Result<GroupKhatmCampaign, Failure>> completeSlot(
    String inviteCode, {
    int? slotId,
    int? unitNumber,
  }) async {
    if (slotId != null) completedSlots.add(slotId);
    return Success(
      GroupKhatmCampaign(
        id: 1,
        inviteCode: inviteCode,
        creatorDisplayName: 'علی',
        title: 'ختم تستی',
        unitType: 'surah',
        targetUnits: 1,
        remainingUnits: 0,
        progressPercentage: 100.0,
        status: GroupKhatmStatus.completed,
        createdAt: DateTime(2026, 3, 1),
      ),
    );
  }
}

class _DelayedCompleteGroupRepo extends _FakeGroupRepo {
  final Completer<void> completeGate = Completer<void>();
  int completeCallCount = 0;

  @override
  Future<Result<GroupKhatmCampaign, Failure>> getCampaignDetail(
    String inviteCode,
  ) async {
    return Success(
      GroupKhatmCampaign(
        id: 1,
        inviteCode: inviteCode,
        creatorDisplayName: 'علی',
        title: 'ختم تاخیری',
        unitType: 'surah',
        targetUnits: 1,
        targetSurahId: 112,
        remainingUnits: completeCallCount > 0 ? 0 : 1,
        progressPercentage: completeCallCount > 0 ? 100.0 : 0.0,
        status: completeCallCount > 0
            ? GroupKhatmStatus.completed
            : GroupKhatmStatus.active,
        createdAt: DateTime(2026, 3, 1),
      ),
    );
  }

  @override
  Future<Result<GroupKhatmCampaign, Failure>> completeSlot(
    String inviteCode, {
    int? slotId,
    int? unitNumber,
  }) async {
    completeCallCount++;
    await completeGate.future;
    return super.completeSlot(
      inviteCode,
      slotId: slotId,
      unitNumber: unitNumber,
    );
  }
}

class _MockReciterRepo extends Fake implements ReciterRepository {
  static const parhizgar = ReciterEntity(
    id: 1,
    name: 'استاد شهریار پرهیزگار',
    arabicName: 'شهريار برهيزكار',
    englishName: 'Parhizgar',
    subfolder: 'Parhizgar_48kbps',
    bitrate: '48kbps',
    identifier: 'parhizgar_48kbps',
    styleId: 1,
    styleName: 'ترتیل',
  );

  @override
  Future<Result<List<ReciterEntity>, Failure>> getAllReciters() async =>
      const Success([parhizgar]);
}

class _FakeVipController extends VipSubscriptionController {
  @override
  VipSubscriptionState build() =>
      const VipSubscriptionState(isVip: true, isLoading: false);
}

class _MockAudioHandler extends Fake implements QuranAudioHandler {
  @override
  Future<void> Function()? onSkipNext;
  @override
  Future<void> Function()? onSkipPrevious;
  @override
  Future<void> Function()? onPlay;
  @override
  Future<void> Function()? onPause;

  @override
  void updateAyahMediaItem({
    required String id,
    required String surahName,
    required int ayahNumber,
    required String reciterName,
    Duration? duration,
  }) {}

  @override
  Future<void> stop() async {}
}

class _FakeAudioStorage extends Fake implements IAudioStorageService {
  @override
  Future<String?> getLocalAyahAudioPath({
    required int reciterId,
    required int surahId,
    required int ayahNumber,
  }) async => '/fake/audio/$surahId/$ayahNumber.mp3';
}

class _FakeAudioPlayerService extends Fake implements IAudioPlayerService {
  final _controller = StreamController<AudioPlayerState>.broadcast();
  final List<String> playedUrls = [];
  int stopCalls = 0;

  @override
  Stream<AudioPlayerState> get stateStream => _controller.stream;

  @override
  Future<void> play(String url) async {
    playedUrls.add(url);
    _controller.add(
      AudioPlayerState(
        status: AudioStatus.playing,
        currentUrl: url,
        position: Duration.zero,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void completeCurrentTrack() {
    _controller.add(
      const AudioPlayerState(
        status: AudioStatus.completed,
        position: Duration(seconds: 3),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Future<void> pause() async {
    _controller.add(
      const AudioPlayerState(
        status: AudioStatus.paused,
        position: Duration(seconds: 1),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Future<void> resume() async {
    _controller.add(
      const AudioPlayerState(
        status: AudioStatus.playing,
        position: Duration(seconds: 1),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Future<void> setSpeed(double speed) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> stop() async {
    stopCalls++;
    _controller.add(
      const AudioPlayerState(
        status: AudioStatus.stopped,
        position: Duration.zero,
        duration: Duration.zero,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
  }
}

class _FakeAnalyticsService extends Fake implements IAnalyticsService {
  @override
  Future<void> logAudioPlay({
    required int surahNumber,
    int? ayahNumber,
    String? reciterName,
  }) async {}

  @override
  Future<void> logAudioPause({
    required int surahNumber,
    int? ayahNumber,
  }) async {}

  @override
  Future<void> logSurahOpen({
    required int surahNumber,
    required String surahName,
    int? ayahNumber,
  }) async {}
}

class _FakeAyahService extends Fake implements AyahService {
  final Map<int, List<AyahEntity>> surahAyahs;

  _FakeAyahService(this.surahAyahs);

  @override
  Future<Result<List<AyahEntity>, Failure>> getAyahsBySurah(int surahId) async {
    return Success(surahAyahs[surahId] ?? _buildSyntheticSurahAyahs(surahId));
  }
}

class _FakeSurahService extends Fake implements SurahService {
  @override
  Future<Result<List<SurahEntity>, Failure>> getSurahs() async {
    return Success(kStaticQuranSurahs.map((dto) => dto.toDomain()).toList());
  }
}

class _FakeStudyPlanDs implements IStudyPlanLocalDataSource {
  @override
  Future<void> clearAll() async {}
  @override
  Future<void> deletePlan(String id) async {}
  @override
  String? getActivePlanId() => null;
  @override
  Future<List<StudyPlan>> getAllPlans() async => const [];
  @override
  Future<StudyPlan?> getPlan(String id) async => null;
  @override
  Future<void> savePlan(StudyPlan plan) async {}
  @override
  Future<void> setActivePlanId(String? id) async {}
}

class _FakeBookmarksController extends BookmarksController {
  @override
  List<BookmarkItem> build() => const [];
}

class _FakeAyahTeaserController extends AyahTeaserController {
  @override
  AyahTeaserState build() => const AyahTeaserState();

  @override
  Future<void> prefetchSurah(int surahId, {bool forceRefresh = true}) async {}

  @override
  void reset() {}
}

class _FakeDisplaySettingsController extends QuranDisplaySettingsController {
  @override
  QuranDisplaySettingsState build() => const QuranDisplaySettingsState(
    arabicFontSize: 20,
    arabicLineHeight: 1.6,
    showTranslation: false,
    showArabicText: true,
    showAyahNumbers: true,
  );
}

List<AyahEntity> _buildSyntheticSurahAyahs(int surahId) {
  final info = kStaticQuranSurahs[surahId - 1];
  final startGlobal = getGlobalAyahIndex(surahId, 1);
  return [
    for (int i = 1; i <= info.numberOfAyahs; i++)
      AyahEntity(
        id: startGlobal + i - 1,
        surahId: surahId,
        ayahNumber: i,
        arabicText:
            'آیة $i من سورة $surahId بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        page: KhatmQuranData.getPageForAyah(surahId, i),
        juz: KhatmQuranData.getJuzForGlobalAyah(startGlobal + i - 1),
        hizbQuarter:
            KhatmQuranData.getHizbForGlobalAyah(startGlobal + i - 1) * 2 - 1,
      ),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. Exact global-ayah unit boundaries & resolver', () {
    test(
      'All 30 Juz, 120 Ahzab, 114 Surahs, 604 Pages partition 1..6236 cleanly',
      () {
        int cursor = 1;
        for (int j = 1; j <= 30; j++) {
          final r = KhatmQuranData.getGlobalAyahRangeForJuz(j);
          expect(r.startGlobal, cursor, reason: 'Juz $j start');
          expect(r.endGlobal, greaterThanOrEqualTo(r.startGlobal));
          cursor = r.endGlobal + 1;
        }
        expect(cursor - 1, 6236);

        cursor = 1;
        for (int h = 1; h <= 120; h++) {
          final r = KhatmQuranData.getGlobalAyahRangeForHizb(h);
          expect(r.startGlobal, cursor, reason: 'Hizb $h start');
          expect(r.endGlobal, greaterThanOrEqualTo(r.startGlobal));
          cursor = r.endGlobal + 1;
        }
        expect(cursor - 1, 6236);

        cursor = 1;
        for (int s = 1; s <= 114; s++) {
          final r = KhatmQuranData.getGlobalAyahRangeForSurah(s);
          expect(r.startGlobal, cursor, reason: 'Surah $s start');
          expect(r.endGlobal, greaterThanOrEqualTo(r.startGlobal));
          cursor = r.endGlobal + 1;
        }
        expect(cursor - 1, 6236);

        cursor = 1;
        for (int p = 1; p <= 604; p++) {
          final r = KhatmQuranData.getGlobalAyahRangeForPage(p);
          expect(r.startGlobal, cursor, reason: 'Page $p start');
          expect(r.endGlobal, greaterThanOrEqualTo(r.startGlobal));
          cursor = r.endGlobal + 1;
        }
        expect(cursor - 1, 6236);
      },
    );

    test(
      'Mid-page Juz & Hizb boundaries reject earlier ayahs on the same page',
      () {
        // Juz 4 starts at 3:93 (page 62), while page 62 starts at 3:92
        expect(
          KhatmProgressCalculator.isPositionInRange(
            unitType: KhatmUnitType.juz,
            fromUnit: 4,
            toUnit: 4,
            surahId: 3,
            ayahNumber: 92,
            page: 62,
          ),
          isFalse,
        );
        expect(
          KhatmProgressCalculator.isPositionInRange(
            unitType: KhatmUnitType.juz,
            fromUnit: 4,
            toUnit: 4,
            surahId: 3,
            ayahNumber: 93,
            page: 62,
          ),
          isTrue,
        );

        // Hizb 2 starts at 2:44 (page 7), while page 7 starts at 2:38
        expect(
          KhatmProgressCalculator.isPositionInRange(
            unitType: KhatmUnitType.hizb,
            fromUnit: 2,
            toUnit: 2,
            surahId: 2,
            ayahNumber: 38,
            page: 7,
          ),
          isFalse,
        );
        expect(
          KhatmProgressCalculator.isPositionInRange(
            unitType: KhatmUnitType.hizb,
            fromUnit: 2,
            toUnit: 2,
            surahId: 2,
            ayahNumber: 44,
            page: 7,
          ),
          isTrue,
        );
      },
    );

    test(
      'KhatmQuranResolver.resolveSessionResumeTarget prefers exact lastSurahId/lastAyahNumber',
      () {
        final session = KhatmSessionItem(
          sessionIndex: 0,
          fromUnit: 2,
          toUnit: 2,
          scheduledDate: DateTime(2026, 3, 1),
          lastReadUnit: 2,
          lastSurahId: 2,
          lastAyahNumber: 177,
        );
        final target = KhatmQuranResolver.resolveSessionResumeTarget(
          unitType: KhatmUnitType.juz,
          session: session,
        );
        expect(target.surahId, 2);
        expect(target.ayahNumber, 177);
        expect(target.pageNumber, KhatmQuranData.getPageForAyah(2, 177));
      },
    );
  });

  group(
    '2. Coverage tracking (coveredSpans), thresholds, and percentage display',
    () {
      test(
        'Multi-surah 1..114 session does NOT complete at Surah 99 or 99%',
        () {
          final s1To99End = getGlobalAyahIndex(99, 8);
          final eval = KhatmProgressCalculator.evaluateProgress(
            unitType: KhatmUnitType.surah,
            fromUnit: 1,
            toUnit: 114,
            existingSpans: const [],
            existingProgress: 0.0,
            surahId: 99,
            ayahNumber: 8,
            coverStartGlobal: 1,
            coverEndGlobal: s1To99End,
          );
          expect(eval.isCompleted, isFalse);
          expect(eval.progress, lessThan(1.0));

          final session = KhatmSessionItem(
            sessionIndex: 0,
            fromUnit: 1,
            toUnit: 114,
            scheduledDate: DateTime(2026, 3, 1),
            progress: eval.progress,
            coveredSpans: eval.coveredSpans,
          );
          expect(session.progressPercentInt, lessThan(100));

          // Even at 6235/6236 ayahs, progressPercentInt must never be 100!
          final almostDone = KhatmProgressCalculator.evaluateProgress(
            unitType: KhatmUnitType.surah,
            fromUnit: 1,
            toUnit: 114,
            existingSpans: [const KhatmAyahSpan(start: 1, end: 6235)],
            existingProgress: 0.999,
            surahId: 114,
            ayahNumber: 5,
          );
          expect(almostDone.isCompleted, isFalse);
          final sessionAlmost = KhatmSessionItem(
            sessionIndex: 0,
            fromUnit: 1,
            toUnit: 114,
            scheduledDate: DateTime(2026, 3, 1),
            progress: almostDone.progress,
            coveredSpans: almostDone.coveredSpans,
          );
          expect(sessionAlmost.progressPercentInt, 99);
        },
      );

      test(
        'KhatmUnitType.ayah has zero off-by-one or out-of-range completion',
        () {
          // Target: global ayahs 100..110 (11 ayahs)
          final pos99 = getSurahAndAyahFromGlobalIndex(99);
          final outBefore = KhatmProgressCalculator.evaluateProgress(
            unitType: KhatmUnitType.ayah,
            fromUnit: 100,
            toUnit: 110,
            existingSpans: const [],
            existingProgress: 0.0,
            surahId: pos99.surahId,
            ayahNumber: pos99.ayahNumber,
          );
          expect(outBefore.isPositionInRange, isFalse);
          expect(outBefore.progress, 0.0);
          expect(outBefore.isCompleted, isFalse);

          // Covering 100..109 leaves 1 ayah uncovered -> 10/11, NOT completed
          final pos109 = getSurahAndAyahFromGlobalIndex(109);
          final almost = KhatmProgressCalculator.evaluateProgress(
            unitType: KhatmUnitType.ayah,
            fromUnit: 100,
            toUnit: 110,
            existingSpans: const [],
            existingProgress: 0.0,
            surahId: pos109.surahId,
            ayahNumber: pos109.ayahNumber,
            coverStartGlobal: 100,
            coverEndGlobal: 109,
          );
          expect(almost.coveredAyahsCount, 10);
          expect(almost.totalAyahsCount, 11);
          expect(almost.isCompleted, isFalse);

          // Jumping to 111 (toUnit + 1) does NOT complete 110
          final pos111 = getSurahAndAyahFromGlobalIndex(111);
          final outAfter = KhatmProgressCalculator.evaluateProgress(
            unitType: KhatmUnitType.ayah,
            fromUnit: 100,
            toUnit: 110,
            existingSpans: almost.coveredSpans,
            existingProgress: almost.progress,
            surahId: pos111.surahId,
            ayahNumber: pos111.ayahNumber,
          );
          expect(outAfter.isPositionInRange, isFalse);
          expect(outAfter.isCompleted, isFalse);

          // Covering 110 completes cleanly
          final pos110 = getSurahAndAyahFromGlobalIndex(110);
          final done = KhatmProgressCalculator.evaluateProgress(
            unitType: KhatmUnitType.ayah,
            fromUnit: 100,
            toUnit: 110,
            existingSpans: almost.coveredSpans,
            existingProgress: almost.progress,
            surahId: pos110.surahId,
            ayahNumber: pos110.ayahNumber,
          );
          expect(done.isCompleted, isTrue);
          expect(done.progress, 1.0);
        },
      );

      testWidgets(
        'KhatmCircularProgressRing never renders 100% when isCompleted == false',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: KhatmCircularProgressRing(
                  progress: 0.9999,
                  isCompleted: false,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('۹۹٪'), findsOneWidget);
          expect(find.text('۱۰۰٪'), findsNothing);
        },
      );

      test(
        'KhatmDetailController debounces Hive writes, flushes on loadPlan/flushPendingSave, and serializes concurrent updates',
        () async {
          final now = DateTime(2026, 3, 1);
          final plan = KhatmPlan(
            id: 'debounce-plan',
            title: 'ختم تستی',
            unitType: KhatmUnitType.ayah,
            rangeFrom: 1,
            rangeTo: 10,
            planningMode: KhatmPlanningMode.bySessionCount,
            sessionCount: 1,
            quotaPerSession: 10,
            cadence: KhatmCadence.daily,
            startDateTime: now,
            endDateTime: now,
            sessions: [
              KhatmSessionItem(
                sessionIndex: 0,
                fromUnit: 1,
                toUnit: 10,
                scheduledDate: now,
              ),
            ],
            createdAt: now,
          );
          final ds = _TrackingKhatmLocalDataSource([plan]);
          final container = ProviderContainer(
            overrides: [khatmLocalDataSourceProvider.overrideWithValue(ds)],
          );
          addTearDown(container.dispose);

          final sub = container.listen(
            khatmDetailControllerProvider('debounce-plan'),
            (_, _) {},
          );
          addTearDown(sub.close);
          await container.pump();
          final ctrl = container.read(
            khatmDetailControllerProvider('debounce-plan').notifier,
          );

          // Fire 3 concurrent progress updates covering ayahs 1, 2, 3
          await Future.wait([
            ctrl.recordReadingProgress(
              sessionIndex: 0,
              surahId: 1,
              ayahNumber: 1,
            ),
            ctrl.recordReadingProgress(
              sessionIndex: 0,
              surahId: 1,
              ayahNumber: 2,
            ),
            ctrl.recordReadingProgress(
              sessionIndex: 0,
              surahId: 1,
              ayahNumber: 3,
            ),
          ]);

          // In-memory state immediately reflects all 3 spans, while Hive save is debounced
          final memSession = container
              .read(khatmDetailControllerProvider('debounce-plan'))
              .plan!
              .sessions[0];
          expect(memSession.coveredSpans, [
            const KhatmAyahSpan(start: 1, end: 3),
          ]);
          expect(ds.savePlanCalls, 0);

          // loadPlan flushes pending debounced save before reading from storage
          await ctrl.loadPlan();
          expect(ds.savePlanCalls, 1);
          expect(ds.plans['debounce-plan']!.sessions[0].coveredSpans, [
            const KhatmAyahSpan(start: 1, end: 3),
          ]);
        },
      );
    },
  );

  group(
    '3. Audio tracking (non-t=0:00, independent of scrolled surah, shared pages, stop reset)',
    () {
      test(
        'Does not mark completion at t=0:00; completes only on _advanceNextAyah independent of reader surah and resets currentSurahId on stop()',
        () async {
          SharedPreferences.setMockInitialValues({});
          final prefs = await SharedPreferences.getInstance();
          final prefsService = PreferencesServiceImpl(prefs);
          final mockPlayer = _FakeAudioPlayerService();
          addTearDown(mockPlayer.dispose);

          final now = DateTime(2026, 3, 1);
          // Session = Surah 112 (Al-Ikhlas: 4 ayahs, shared on page 604 with 113 & 114)
          final plan = KhatmPlan(
            id: 'audio-shared-plan',
            title: 'ختم سوره اخلاص',
            unitType: KhatmUnitType.surah,
            rangeFrom: 112,
            rangeTo: 112,
            planningMode: KhatmPlanningMode.byUnitQuota,
            sessionCount: 1,
            quotaPerSession: 1,
            cadence: KhatmCadence.daily,
            startDateTime: now,
            endDateTime: now,
            sessions: [
              KhatmSessionItem(
                sessionIndex: 0,
                fromUnit: 112,
                toUnit: 112,
                scheduledDate: now,
              ),
            ],
            createdAt: now,
          );
          final ds = _TrackingKhatmLocalDataSource([plan]);

          final container = ProviderContainer(
            overrides: [
              sharedPreferencesInstanceProvider.overrideWithValue(prefs),
              preferencesServiceProvider.overrideWithValue(prefsService),
              reciterRepositoryProvider.overrideWithValue(_MockReciterRepo()),
              quranAudioHandlerProvider.overrideWithValue(_MockAudioHandler()),
              audioStorageServiceProvider.overrideWithValue(
                _FakeAudioStorage(),
              ),
              audioPlayerServiceProvider.overrideWithValue(mockPlayer),
              vipSubscriptionControllerProvider.overrideWith(
                _FakeVipController.new,
              ),
              analyticsServiceProvider.overrideWithValue(
                _FakeAnalyticsService(),
              ),
              khatmLocalDataSourceProvider.overrideWithValue(ds),
              ayahServiceProvider.overrideWithValue(_FakeAyahService({})),
            ],
          );
          addTearDown(container.dispose);

          // Keep active session & reader pointing to a DIFFERENT surah (Surah 2)
          final subPlan = container.listen(
            khatmDetailControllerProvider('audio-shared-plan'),
            (_, _) {},
          );
          addTearDown(subPlan.close);
          await container.pump();
          container
              .read(activeKhatmSessionProvider.notifier)
              .setActive(khatmId: 'audio-shared-plan', sessionIndex: 0);
          await container
              .read(quranReaderControllerProvider.notifier)
              .fetchAyahs(2);

          final audioCtrl = container.read(
            quranAudioControllerProvider.notifier,
          );

          // Start playing Surah 112 Ayah 1 -> at t=0:00 session must still have 0% progress
          await audioCtrl.playAyah(
            surahId: 112,
            ayahNumber: 1,
            totalAyahsInSurah: 4,
          );
          expect(container.read(activeAyahProvider), 1);
          expect(
            container
                .read(khatmDetailControllerProvider('audio-shared-plan'))
                .plan!
                .sessions[0]
                .progress,
            0.0,
          );

          // Finish Ayahs 1, 2, 3 -> still incomplete (75%)
          for (int a = 1; a <= 3; a++) {
            mockPlayer.completeCurrentTrack();
            await Future.delayed(const Duration(milliseconds: 30));
          }
          final midSession = container
              .read(khatmDetailControllerProvider('audio-shared-plan'))
              .plan!
              .sessions[0];
          expect(midSession.isCompleted, isFalse);
          expect(midSession.coveredSpans.first.length, 3);
          expect(
            container.read(quranAudioControllerProvider).currentAyahNumber,
            4,
          );

          // Finish Ayah 4 (last ayah of Surah 112, shared page 604) -> completes session & stops audio!
          mockPlayer.completeCurrentTrack();
          await Future.delayed(const Duration(milliseconds: 40));

          final doneSession = container
              .read(khatmDetailControllerProvider('audio-shared-plan'))
              .plan!
              .sessions[0];
          expect(doneSession.isCompleted, isTrue);
          final finalAudio = container.read(quranAudioControllerProvider);
          expect(finalAudio.status, AudioStatus.stopped);
          expect(finalAudio.currentSurahId, isNull);
          expect(finalAudio.currentAyahNumber, isNull);
        },
      );

      test(
        'Group Khatm 3-pass short Surah (Al-Kawthar, 3 ayahs) works cleanly via audio Pass 1 -> Pass 2 without cascade',
        () async {
          SharedPreferences.setMockInitialValues({});
          final prefs = await SharedPreferences.getInstance();
          final prefsService = PreferencesServiceImpl(prefs);
          final mockPlayer = _FakeAudioPlayerService();
          addTearDown(mockPlayer.dispose);
          final fakeProgressDs = _FakeGroupProgressDs();
          final fakeRepo = _FakeGroupRepo();

          final container = ProviderContainer(
            overrides: [
              sharedPreferencesInstanceProvider.overrideWithValue(prefs),
              preferencesServiceProvider.overrideWithValue(prefsService),
              reciterRepositoryProvider.overrideWithValue(_MockReciterRepo()),
              quranAudioHandlerProvider.overrideWithValue(_MockAudioHandler()),
              audioStorageServiceProvider.overrideWithValue(
                _FakeAudioStorage(),
              ),
              audioPlayerServiceProvider.overrideWithValue(mockPlayer),
              vipSubscriptionControllerProvider.overrideWith(
                _FakeVipController.new,
              ),
              analyticsServiceProvider.overrideWithValue(
                _FakeAnalyticsService(),
              ),
              groupKhatmProgressLocalDataSourceProvider.overrideWithValue(
                fakeProgressDs,
              ),
              khatmRepositoryProvider.overrideWithValue(fakeRepo),
              ayahServiceProvider.overrideWithValue(_FakeAyahService({})),
            ],
          );
          addTearDown(container.dispose);

          container
              .read(activeGroupKhatmSlotProvider.notifier)
              .setActive(
                const ActiveGroupKhatmSlot(
                  inviteCode: 'AUDIO3PASS',
                  slotId: 77,
                  unitType: GroupKhatmUnitType.surah,
                  unitNumber: 108, // Al-Kawthar (3 ayahs)
                  targetQuantity: 3,
                ),
              );

          final audioCtrl = container.read(
            quranAudioControllerProvider.notifier,
          );

          // Play Pass 1 (Ayahs 1 -> 2 -> 3)
          await audioCtrl.playAyah(
            surahId: 108,
            ayahNumber: 1,
            totalAyahsInSurah: 3,
          );
          for (int a = 1; a <= 3; a++) {
            mockPlayer.completeCurrentTrack();
            await Future.delayed(const Duration(milliseconds: 30));
          }

          final readCtrl = container.read(
            groupKhatmReadingControllerProvider.notifier,
          );
          expect(
            readCtrl.progressFor('AUDIO3PASS', 77)!.completedRepetitions,
            1,
          );
          expect(
            container.read(quranAudioControllerProvider).status,
            AudioStatus.stopped,
          );

          // Now user plays Ayah 1 again for Pass 2 -> must NOT be blocked by _awaitingPassResetKeys!
          await audioCtrl.playAyah(
            surahId: 108,
            ayahNumber: 1,
            totalAyahsInSurah: 3,
          );
          mockPlayer.completeCurrentTrack();
          await Future.delayed(const Duration(milliseconds: 30));
          final p2 = readCtrl.progressFor('AUDIO3PASS', 77)!;
          expect(p2.completedRepetitions, 1);
          expect(p2.currentPassProgress, closeTo(1 / 3, 0.01));
        },
      );
    },
  );

  group('4. Group Khatm concurrency & 3-ayah cascade prevention', () {
    test(
      'Serializes concurrent recordReadingProgress during slow initial loadAll()',
      () async {
        final ds = _FakeGroupProgressDs(
          delay: const Duration(milliseconds: 30),
        );
        final repo = _FakeGroupRepo();
        final container = ProviderContainer(
          overrides: [
            groupKhatmProgressLocalDataSourceProvider.overrideWithValue(ds),
            khatmRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(container.dispose);

        final ctrl = container.read(
          groupKhatmReadingControllerProvider.notifier,
        );
        const slot = ActiveGroupKhatmSlot(
          inviteCode: 'CONC1',
          slotId: 10,
          unitType: GroupKhatmUnitType.surah,
          unitNumber: 108,
          targetQuantity: 3,
        );
        final sStart = getGlobalAyahIndex(108, 1);

        await Future.wait([
          ctrl.recordReadingProgress(
            activeSlot: slot,
            surahId: 108,
            ayahNumber: 1,
            coverStartGlobal: sStart,
            coverEndGlobal: sStart,
          ),
          ctrl.recordReadingProgress(
            activeSlot: slot,
            surahId: 108,
            ayahNumber: 2,
            coverStartGlobal: sStart + 1,
            coverEndGlobal: sStart + 1,
          ),
        ]);

        final saved = ctrl.progressFor('CONC1', 10)!;
        expect(saved.coveredSpans, [
          KhatmAyahSpan(start: sStart, end: sStart + 1),
        ]);
        expect(saved.lastAyahNumber, 2);
      },
    );
  });

  group(
    '5. Reader widgets: paused audio scroll, dwell timer, no init/swipe/QuickJump false completion, no endCardPos jump',
    () {
      testWidgets(
        'SurahAyahPageView: single-page surah completes via 2s dwell timer without scroll, not at t=0',
        (tester) async {
          SharedPreferences.setMockInitialValues({});
          final prefs = await SharedPreferences.getInstance();
          final prefsService = PreferencesServiceImpl(prefs);
          final mockPlayer = _FakeAudioPlayerService();
          addTearDown(mockPlayer.dispose);

          final now = DateTime(2026, 3, 1);
          final plan = KhatmPlan(
            id: 'dwell-surah-108',
            title: 'ختم کوثر',
            unitType: KhatmUnitType.surah,
            rangeFrom: 108,
            rangeTo: 108,
            planningMode: KhatmPlanningMode.byUnitQuota,
            sessionCount: 1,
            quotaPerSession: 1,
            cadence: KhatmCadence.daily,
            startDateTime: now,
            endDateTime: now,
            sessions: [
              KhatmSessionItem(
                sessionIndex: 0,
                fromUnit: 108,
                toUnit: 108,
                scheduledDate: now,
              ),
            ],
            createdAt: now,
          );
          final ds = _TrackingKhatmLocalDataSource([plan]);

          final container = ProviderContainer(
            overrides: [
              sharedPreferencesInstanceProvider.overrideWithValue(prefs),
              preferencesServiceProvider.overrideWithValue(prefsService),
              reciterRepositoryProvider.overrideWithValue(_MockReciterRepo()),
              quranAudioHandlerProvider.overrideWithValue(_MockAudioHandler()),
              audioStorageServiceProvider.overrideWithValue(
                _FakeAudioStorage(),
              ),
              audioPlayerServiceProvider.overrideWithValue(mockPlayer),
              vipSubscriptionControllerProvider.overrideWith(
                _FakeVipController.new,
              ),
              analyticsServiceProvider.overrideWithValue(
                _FakeAnalyticsService(),
              ),
              khatmLocalDataSourceProvider.overrideWithValue(ds),
              ayahServiceProvider.overrideWithValue(_FakeAyahService({})),
              surahServiceProvider.overrideWithValue(_FakeSurahService()),
              studyPlanLocalDataSourceProvider.overrideWithValue(
                _FakeStudyPlanDs(),
              ),
              bookmarksControllerProvider.overrideWith(
                _FakeBookmarksController.new,
              ),
              quranDisplaySettingsControllerProvider.overrideWith(
                _FakeDisplaySettingsController.new,
              ),
            ],
          );
          addTearDown(container.dispose);

          final dwellSub = container.listen(
            khatmDetailControllerProvider('dwell-surah-108'),
            (_, _) {},
          );
          addTearDown(dwellSub.close);

          container
              .read(activeKhatmSessionProvider.notifier)
              .setActive(khatmId: 'dwell-surah-108', sessionIndex: 0);
          await container
              .read(khatmDetailControllerProvider('dwell-surah-108').notifier)
              .loadPlan();
          await container
              .read(quranReaderControllerProvider.notifier)
              .fetchAyahs(108);

          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: const MaterialApp(
                home: Scaffold(
                  body: SizedBox(
                    width: 600,
                    height: 1800,
                    child: SurahAyahPageView(
                      surahId: 108,
                      surahName: 'سوره کوثر',
                      isCurrentPage: true,
                      topPadding: 140,
                    ),
                  ),
                ),
              ),
            ),
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          // Before 2s dwell completes -> must NOT complete!
          expect(
            container
                .read(khatmDetailControllerProvider('dwell-surah-108'))
                .plan!
                .sessions[0]
                .isCompleted,
            isFalse,
          );

          // After 2s dwell completes -> must complete all 3 ayahs!
          await tester.pump(const Duration(seconds: 2));
          await tester.pump(const Duration(milliseconds: 100));

          expect(
            container
                .read(khatmDetailControllerProvider('dwell-surah-108'))
                .plan!
                .sessions[0]
                .isCompleted,
            isTrue,
          );
        },
      );

      testWidgets(
        'SurahAyahPageView: paused audio does NOT block scroll progress',
        (tester) async {
          SharedPreferences.setMockInitialValues({});
          final prefs = await SharedPreferences.getInstance();
          final prefsService = PreferencesServiceImpl(prefs);
          final mockPlayer = _FakeAudioPlayerService();
          addTearDown(mockPlayer.dispose);

          final now = DateTime(2026, 3, 1);
          final plan = KhatmPlan(
            id: 'paused-scroll-plan',
            title: 'ختم بقره',
            unitType: KhatmUnitType.surah,
            rangeFrom: 2,
            rangeTo: 2,
            planningMode: KhatmPlanningMode.byUnitQuota,
            sessionCount: 1,
            quotaPerSession: 1,
            cadence: KhatmCadence.daily,
            startDateTime: now,
            endDateTime: now,
            sessions: [
              KhatmSessionItem(
                sessionIndex: 0,
                fromUnit: 2,
                toUnit: 2,
                scheduledDate: now,
              ),
            ],
            createdAt: now,
          );
          final ds = _TrackingKhatmLocalDataSource([plan]);

          final container = ProviderContainer(
            overrides: [
              sharedPreferencesInstanceProvider.overrideWithValue(prefs),
              preferencesServiceProvider.overrideWithValue(prefsService),
              reciterRepositoryProvider.overrideWithValue(_MockReciterRepo()),
              quranAudioHandlerProvider.overrideWithValue(_MockAudioHandler()),
              audioStorageServiceProvider.overrideWithValue(
                _FakeAudioStorage(),
              ),
              audioPlayerServiceProvider.overrideWithValue(mockPlayer),
              vipSubscriptionControllerProvider.overrideWith(
                _FakeVipController.new,
              ),
              analyticsServiceProvider.overrideWithValue(
                _FakeAnalyticsService(),
              ),
              khatmLocalDataSourceProvider.overrideWithValue(ds),
              ayahServiceProvider.overrideWithValue(_FakeAyahService({})),
              surahServiceProvider.overrideWithValue(_FakeSurahService()),
              studyPlanLocalDataSourceProvider.overrideWithValue(
                _FakeStudyPlanDs(),
              ),
              bookmarksControllerProvider.overrideWith(
                _FakeBookmarksController.new,
              ),
              quranDisplaySettingsControllerProvider.overrideWith(
                _FakeDisplaySettingsController.new,
              ),
            ],
          );
          addTearDown(container.dispose);

          final pausedSub = container.listen(
            khatmDetailControllerProvider('paused-scroll-plan'),
            (_, _) {},
          );
          addTearDown(pausedSub.close);

          container
              .read(activeKhatmSessionProvider.notifier)
              .setActive(khatmId: 'paused-scroll-plan', sessionIndex: 0);
          await container
              .read(
                khatmDetailControllerProvider('paused-scroll-plan').notifier,
              )
              .loadPlan();
          await container
              .read(quranReaderControllerProvider.notifier)
              .fetchAyahs(2);

          // Start audio on Surah 2 Ayah 1, then PAUSE it
          final audioCtrl = container.read(
            quranAudioControllerProvider.notifier,
          );
          await audioCtrl.playAyah(
            surahId: 2,
            ayahNumber: 1,
            totalAyahsInSurah: 286,
          );
          await audioCtrl.pause();
          await tester.pump(const Duration(milliseconds: 20));
          expect(
            container.read(quranAudioControllerProvider).status,
            AudioStatus.paused,
          );

          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: const MaterialApp(
                home: Scaffold(
                  body: SizedBox(
                    width: 400,
                    height: 700,
                    child: SurahAyahPageView(
                      surahId: 2,
                      surahName: 'سوره بقره',
                      isCurrentPage: true,
                      topPadding: 140,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));

          // User manually drags down while audio is paused -> scroll progress MUST be recorded!
          await tester.drag(
            find.byType(ScrollablePositionedList),
            const Offset(0, -400),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          await tester.pumpAndSettle();
          await tester.pump(const Duration(milliseconds: 700));

          final session = container
              .read(khatmDetailControllerProvider('paused-scroll-plan'))
              .plan!
              .sessions[0];
          expect(session.progress, greaterThan(0.0));
          expect(session.coveredSpans, isNotEmpty);
        },
      );

      testWidgets(
        'QuranInfoBar does not jump to last ayah when endCardPos is visible or bounce on bar collapse',
        (tester) async {
          SharedPreferences.setMockInitialValues({});
          final prefs = await SharedPreferences.getInstance();
          final prefsService = PreferencesServiceImpl(prefs);
          final mockPlayer = _FakeAudioPlayerService();
          addTearDown(mockPlayer.dispose);

          final listener = ItemPositionsListener.create();
          final notifier =
              listener.itemPositions as ValueNotifier<Iterable<ItemPosition>>;
          // Simulate 5-ayah surah where Ayah 2 (index 1) is at readingBaseline (~0.27),
          // and endCardPos (index 5) is visible at the bottom (0.80..0.98 <= 1.0)
          notifier.value = const [
            ItemPosition(
              index: 0,
              itemLeadingEdge: 0.05,
              itemTrailingEdge: 0.22,
            ),
            ItemPosition(
              index: 1,
              itemLeadingEdge: 0.22,
              itemTrailingEdge: 0.40,
            ),
            ItemPosition(
              index: 2,
              itemLeadingEdge: 0.40,
              itemTrailingEdge: 0.56,
            ),
            ItemPosition(
              index: 3,
              itemLeadingEdge: 0.56,
              itemTrailingEdge: 0.70,
            ),
            ItemPosition(
              index: 4,
              itemLeadingEdge: 0.70,
              itemTrailingEdge: 0.80,
            ),
            ItemPosition(
              index: 5,
              itemLeadingEdge: 0.80,
              itemTrailingEdge: 0.98,
            ),
          ];

          final container = ProviderContainer(
            overrides: [
              sharedPreferencesInstanceProvider.overrideWithValue(prefs),
              preferencesServiceProvider.overrideWithValue(prefsService),
              reciterRepositoryProvider.overrideWithValue(_MockReciterRepo()),
              quranAudioHandlerProvider.overrideWithValue(_MockAudioHandler()),
              audioStorageServiceProvider.overrideWithValue(
                _FakeAudioStorage(),
              ),
              audioPlayerServiceProvider.overrideWithValue(mockPlayer),
              vipSubscriptionControllerProvider.overrideWith(
                _FakeVipController.new,
              ),
              analyticsServiceProvider.overrideWithValue(
                _FakeAnalyticsService(),
              ),
              ayahServiceProvider.overrideWithValue(_FakeAyahService({})),
              surahServiceProvider.overrideWithValue(_FakeSurahService()),
              studyPlanLocalDataSourceProvider.overrideWithValue(
                _FakeStudyPlanDs(),
              ),
            ],
          );
          addTearDown(container.dispose);

          await container
              .read(quranReaderControllerProvider.notifier)
              .fetchAyahs(105);
          container
              .read(activeItemPositionsListenerProvider.notifier)
              .setListener(listener);
          container
              .read(activeKhatmSessionProvider.notifier)
              .setActive(khatmId: 'test-khatm', sessionIndex: 0);

          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: const MaterialApp(
                home: Scaffold(
                  body: SizedBox(
                    width: 580,
                    height: 800,
                    child: QuranInfoBar(),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          // Ayah 2 (index 1) crosses readingBaseline (~0.21), NOT jumping to Ayah 5!
          expect(find.text('آیه ۲'), findsOneWidget);
          expect(find.text('آیه ۵'), findsNothing);

          // Simulate Ayah 2 (index 1) right at expanded baseline (0.21) while collapsing bar:
          // Must NOT jump back up to Ayah 1 (index 0) just because bar collapsed!
          notifier.value = const [
            ItemPosition(
              index: 0,
              itemLeadingEdge: 0.02,
              itemTrailingEdge: 0.19,
            ),
            ItemPosition(
              index: 1,
              itemLeadingEdge: 0.19,
              itemTrailingEdge: 0.38,
            ),
            ItemPosition(
              index: 5,
              itemLeadingEdge: 0.80,
              itemTrailingEdge: 0.98,
            ),
          ];
          container
              .read(isKhatmReaderBarCollapsedProvider.notifier)
              .setCollapsed(true);
          await tester.pump();

          expect(find.text('آیه ۲'), findsOneWidget);
        },
      );

      testWidgets(
        'QuranReaderScreen does not dispatch false progress on initState or horizontal swipe',
        (tester) async {
          SharedPreferences.setMockInitialValues({
            'walkthrough_seen_reader_v1': true,
          });
          final prefs = await SharedPreferences.getInstance();
          final prefsService = PreferencesServiceImpl(prefs);
          final mockPlayer = _FakeAudioPlayerService();
          addTearDown(mockPlayer.dispose);

          final now = DateTime(2026, 3, 1);
          // 1-ayah session at Surah 1 Ayah 1: previously completed immediately in initState!
          final plan = KhatmPlan(
            id: 'no-init-complete',
            title: 'ختم تک آیه',
            unitType: KhatmUnitType.ayah,
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
              ),
            ],
            createdAt: now,
          );
          final ds = _TrackingKhatmLocalDataSource([plan]);

          final container = ProviderContainer(
            overrides: [
              sharedPreferencesInstanceProvider.overrideWithValue(prefs),
              preferencesServiceProvider.overrideWithValue(prefsService),
              reciterRepositoryProvider.overrideWithValue(_MockReciterRepo()),
              quranAudioHandlerProvider.overrideWithValue(_MockAudioHandler()),
              audioStorageServiceProvider.overrideWithValue(
                _FakeAudioStorage(),
              ),
              audioPlayerServiceProvider.overrideWithValue(mockPlayer),
              vipSubscriptionControllerProvider.overrideWith(
                _FakeVipController.new,
              ),
              analyticsServiceProvider.overrideWithValue(
                _FakeAnalyticsService(),
              ),
              khatmLocalDataSourceProvider.overrideWithValue(ds),
              groupKhatmProgressLocalDataSourceProvider.overrideWithValue(
                _FakeGroupProgressDs(),
              ),
              ayahServiceProvider.overrideWithValue(_FakeAyahService({})),
              surahServiceProvider.overrideWithValue(_FakeSurahService()),
              studyPlanLocalDataSourceProvider.overrideWithValue(
                _FakeStudyPlanDs(),
              ),
              bookmarksControllerProvider.overrideWith(
                _FakeBookmarksController.new,
              ),
              ayahTeaserControllerProvider.overrideWith(
                _FakeAyahTeaserController.new,
              ),
              quranDisplaySettingsControllerProvider.overrideWith(
                _FakeDisplaySettingsController.new,
              ),
            ],
          );
          addTearDown(container.dispose);

          final noInitSub = container.listen(
            khatmDetailControllerProvider('no-init-complete'),
            (_, _) {},
          );
          addTearDown(noInitSub.close);

          await container
              .read(khatmDetailControllerProvider('no-init-complete').notifier)
              .loadPlan();

          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: const MaterialApp(
                home: QuranReaderScreen(
                  surahId: 1,
                  surahName: 'سوره فاتحة',
                  initialAyahNumber: 1,
                  khatmId: 'no-init-complete',
                  khatmSession: 0,
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));

          // Must NOT complete on initState!
          expect(
            container
                .read(khatmDetailControllerProvider('no-init-complete'))
                .plan!
                .sessions[0]
                .isCompleted,
            isFalse,
          );

          // QuickJump to Surah 2 Ayah 1 via navigationTargetProvider must also NOT record Surah 2 Ayah 1
          container
              .read(navigationTargetProvider.notifier)
              .forceTarget(const AyahTarget(surahId: 2, ayahNumber: 1));
          await tester.pump(const Duration(milliseconds: 200));

          expect(
            container
                .read(khatmDetailControllerProvider('no-init-complete'))
                .plan!
                .sessions[0]
                .isCompleted,
            isFalse,
          );

          // Cleanly unmount before walkthrough 950ms timer or wait it out
          await tester.pump(const Duration(seconds: 1));
        },
      );
    },
  );

  group('Audio-only detached, multi-session & stale-track regressions', () {
    test(
      'Track switch resets position/duration and ignores delayed stale currentUrl completion',
      () async {
        SharedPreferences.setMockInitialValues({
          'audio_reciter_id': 1,
          'audio_playback_mode': 0,
        });
        final prefs = await SharedPreferences.getInstance();
        final prefsService = PreferencesServiceImpl(prefs);
        final mockPlayer = _FakeAudioPlayerService();
        addTearDown(mockPlayer.dispose);

        final now = DateTime(2026, 3, 1);
        final plan = KhatmPlan(
          id: 'stale-url-plan',
          title: 'سوره اخلاص',
          unitType: KhatmUnitType.surah,
          rangeFrom: 112,
          rangeTo: 112,
          planningMode: KhatmPlanningMode.bySessionCount,
          sessionCount: 1,
          quotaPerSession: 1,
          cadence: KhatmCadence.daily,
          startDateTime: now,
          endDateTime: now,
          sessions: [
            KhatmSessionItem(
              sessionIndex: 0,
              fromUnit: 112,
              toUnit: 112,
              scheduledDate: now,
            ),
          ],
          createdAt: now,
        );
        final ds = _TrackingKhatmLocalDataSource([plan]);

        final container = ProviderContainer(
          overrides: [
            sharedPreferencesInstanceProvider.overrideWithValue(prefs),
            preferencesServiceProvider.overrideWithValue(prefsService),
            reciterRepositoryProvider.overrideWithValue(_MockReciterRepo()),
            quranAudioHandlerProvider.overrideWithValue(_MockAudioHandler()),
            audioStorageServiceProvider.overrideWithValue(_FakeAudioStorage()),
            audioPlayerServiceProvider.overrideWithValue(mockPlayer),
            vipSubscriptionControllerProvider.overrideWith(
              _FakeVipController.new,
            ),
            analyticsServiceProvider.overrideWithValue(_FakeAnalyticsService()),
            khatmLocalDataSourceProvider.overrideWithValue(ds),
            groupKhatmProgressLocalDataSourceProvider.overrideWithValue(
              _FakeGroupProgressDs(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final planSub = container.listen(
          khatmDetailControllerProvider('stale-url-plan'),
          (_, _) {},
        );
        addTearDown(planSub.close);
        await container
            .read(khatmDetailControllerProvider('stale-url-plan').notifier)
            .loadPlan();
        container
            .read(activeKhatmSessionProvider.notifier)
            .setActive(khatmId: 'stale-url-plan', sessionIndex: 0);

        final audioCtrl = container.read(quranAudioControllerProvider.notifier);
        await audioCtrl.playAyah(
          surahId: 112,
          ayahNumber: 1,
          totalAyahsInSurah: 4,
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));

        // Emit completion specifically tagged with Track 1 URL.
        mockPlayer._controller.add(
          const AudioPlayerState(
            status: AudioStatus.completed,
            currentUrl: '/fake/audio/112/1.mp3',
            position: Duration(seconds: 3),
            duration: Duration(seconds: 3),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(
          container.read(quranAudioControllerProvider).currentAyahNumber,
          2,
        );
        expect(
          container
              .read(khatmDetailControllerProvider('stale-url-plan'))
              .plan!
              .sessions[0]
              .progress,
          closeTo(0.25, 0.01),
        );

        // Now inject a delayed stale event from Track 1 after Track 2 is active.
        mockPlayer._controller.add(
          const AudioPlayerState(
            status: AudioStatus.completed,
            currentUrl: '/fake/audio/112/1.mp3',
            position: Duration(seconds: 3),
            duration: Duration(seconds: 3),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Must NOT skip Ayah 2 or record premature completion for Ayah 2!
        expect(
          container.read(quranAudioControllerProvider).currentAyahNumber,
          2,
        );
        expect(
          container
              .read(khatmDetailControllerProvider('stale-url-plan'))
              .plan!
              .sessions[0]
              .progress,
          closeTo(0.25, 0.01),
        );

        // Real completion of Track 2 advances to Ayah 3 and records 50%.
        mockPlayer._controller.add(
          const AudioPlayerState(
            status: AudioStatus.completed,
            currentUrl: '/fake/audio/112/2.mp3',
            position: Duration(seconds: 3),
            duration: Duration(seconds: 3),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(
          container.read(quranAudioControllerProvider).currentAyahNumber,
          3,
        );
        expect(
          container
              .read(khatmDetailControllerProvider('stale-url-plan'))
              .plan!
              .sessions[0]
              .progress,
          closeTo(0.50, 0.01),
        );
      },
    );

    test(
      'Multi-session Personal Khatm auto-advances from Session 0 into Session 1 and completes full Khatm via audio',
      () async {
        SharedPreferences.setMockInitialValues({
          'audio_reciter_id': 1,
          'audio_playback_mode': 0,
        });
        final prefs = await SharedPreferences.getInstance();
        final prefsService = PreferencesServiceImpl(prefs);
        final mockPlayer = _FakeAudioPlayerService();
        addTearDown(mockPlayer.dispose);

        final now = DateTime(2026, 3, 1);
        final plan = KhatmPlan(
          id: 'multi-session-audio',
          title: 'معوذتین',
          unitType: KhatmUnitType.surah,
          rangeFrom: 113,
          rangeTo: 114,
          planningMode: KhatmPlanningMode.bySessionCount,
          sessionCount: 2,
          quotaPerSession: 1,
          cadence: KhatmCadence.daily,
          startDateTime: now,
          endDateTime: now.add(const Duration(days: 1)),
          sessions: [
            KhatmSessionItem(
              sessionIndex: 0,
              fromUnit: 113,
              toUnit: 113,
              scheduledDate: now,
            ),
            KhatmSessionItem(
              sessionIndex: 1,
              fromUnit: 114,
              toUnit: 114,
              scheduledDate: now.add(const Duration(days: 1)),
            ),
          ],
          createdAt: now,
        );
        final ds = _TrackingKhatmLocalDataSource([plan]);

        final container = ProviderContainer(
          overrides: [
            sharedPreferencesInstanceProvider.overrideWithValue(prefs),
            preferencesServiceProvider.overrideWithValue(prefsService),
            reciterRepositoryProvider.overrideWithValue(_MockReciterRepo()),
            quranAudioHandlerProvider.overrideWithValue(_MockAudioHandler()),
            audioStorageServiceProvider.overrideWithValue(_FakeAudioStorage()),
            audioPlayerServiceProvider.overrideWithValue(mockPlayer),
            vipSubscriptionControllerProvider.overrideWith(
              _FakeVipController.new,
            ),
            analyticsServiceProvider.overrideWithValue(_FakeAnalyticsService()),
            khatmLocalDataSourceProvider.overrideWithValue(ds),
            groupKhatmProgressLocalDataSourceProvider.overrideWithValue(
              _FakeGroupProgressDs(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final sub = container.listen(
          khatmDetailControllerProvider('multi-session-audio'),
          (_, _) {},
        );
        addTearDown(sub.close);
        await container
            .read(khatmDetailControllerProvider('multi-session-audio').notifier)
            .loadPlan();
        container
            .read(activeKhatmSessionProvider.notifier)
            .setActive(khatmId: 'multi-session-audio', sessionIndex: 0);

        final audioCtrl = container.read(quranAudioControllerProvider.notifier);
        await audioCtrl.playAyah(
          surahId: 113,
          ayahNumber: 1,
          totalAyahsInSurah: 5,
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));

        // Finish all 5 ayahs of Surah 113 (Session 0).
        for (int i = 0; i < 5; i++) {
          mockPlayer.completeCurrentTrack();
          await Future<void>.delayed(const Duration(milliseconds: 40));
        }

        final afterSession0 = container
            .read(khatmDetailControllerProvider('multi-session-audio'))
            .plan!;
        expect(afterSession0.sessions[0].isCompleted, isTrue);
        expect(afterSession0.isCompleted, isFalse);
        expect(
          container.read(quranAudioControllerProvider).currentSurahId,
          114,
        );
        expect(
          container.read(quranAudioControllerProvider).currentAyahNumber,
          1,
        );
        expect(mockPlayer.stopCalls, 0);

        // Complete first ayah of Surah 114 (Session 1): must auto-advance sessionIndex to 1.
        mockPlayer.completeCurrentTrack();
        await Future<void>.delayed(const Duration(milliseconds: 40));
        expect(container.read(activeKhatmSessionProvider)?.sessionIndex, 1);

        // Finish remaining 5 ayahs of Surah 114 -> completes Session 1 and whole Khatm.
        for (int i = 0; i < 5; i++) {
          mockPlayer.completeCurrentTrack();
          await Future<void>.delayed(const Duration(milliseconds: 40));
        }

        final completedPlan = ds.plans['multi-session-audio']!;
        expect(completedPlan.sessions[1].isCompleted, isTrue);
        expect(completedPlan.isCompleted, isTrue);
        expect(completedPlan.progressPercentage, 1.0);
        expect(mockPlayer.stopCalls, 1);
      },
    );

    testWidgets(
      'Personal Khatm continues tracking and saves completion when QuranReaderScreen closes while audio plays',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'audio_reciter_id': 1,
          'audio_playback_mode': 0,
        });
        final prefs = await SharedPreferences.getInstance();
        final prefsService = PreferencesServiceImpl(prefs);
        final mockPlayer = _FakeAudioPlayerService();
        addTearDown(mockPlayer.dispose);

        final now = DateTime(2026, 3, 1);
        final plan = KhatmPlan(
          id: 'detached-personal',
          title: 'سوره اخلاص',
          unitType: KhatmUnitType.surah,
          rangeFrom: 112,
          rangeTo: 112,
          planningMode: KhatmPlanningMode.bySessionCount,
          sessionCount: 1,
          quotaPerSession: 1,
          cadence: KhatmCadence.daily,
          startDateTime: now,
          endDateTime: now,
          sessions: [
            KhatmSessionItem(
              sessionIndex: 0,
              fromUnit: 112,
              toUnit: 112,
              scheduledDate: now,
            ),
          ],
          createdAt: now,
        );
        final ds = _TrackingKhatmLocalDataSource([plan]);

        final container = ProviderContainer(
          overrides: [
            sharedPreferencesInstanceProvider.overrideWithValue(prefs),
            preferencesServiceProvider.overrideWithValue(prefsService),
            reciterRepositoryProvider.overrideWithValue(_MockReciterRepo()),
            quranAudioHandlerProvider.overrideWithValue(_MockAudioHandler()),
            audioStorageServiceProvider.overrideWithValue(_FakeAudioStorage()),
            audioPlayerServiceProvider.overrideWithValue(mockPlayer),
            vipSubscriptionControllerProvider.overrideWith(
              _FakeVipController.new,
            ),
            analyticsServiceProvider.overrideWithValue(_FakeAnalyticsService()),
            khatmLocalDataSourceProvider.overrideWithValue(ds),
            groupKhatmProgressLocalDataSourceProvider.overrideWithValue(
              _FakeGroupProgressDs(),
            ),
            ayahServiceProvider.overrideWithValue(_FakeAyahService({})),
            surahServiceProvider.overrideWithValue(_FakeSurahService()),
            studyPlanLocalDataSourceProvider.overrideWithValue(
              _FakeStudyPlanDs(),
            ),
            bookmarksControllerProvider.overrideWith(
              _FakeBookmarksController.new,
            ),
            ayahTeaserControllerProvider.overrideWith(
              _FakeAyahTeaserController.new,
            ),
            quranDisplaySettingsControllerProvider.overrideWith(
              _FakeDisplaySettingsController.new,
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: QuranReaderScreen(
                surahId: 112,
                surahName: 'سوره توحید',
                initialAyahNumber: 1,
                khatmId: 'detached-personal',
                khatmSession: 0,
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Start playback from Ayah 1 and advance Ayah 1.
        await container
            .read(quranAudioControllerProvider.notifier)
            .playAyah(surahId: 112, ayahNumber: 1, totalAyahsInSurah: 4);
        await tester.pump(const Duration(milliseconds: 50));

        // Close QuranReaderScreen while audio keeps playing in MiniAudioPlayerBar.
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: Scaffold()),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final detached = container.read(activeKhatmSessionProvider);
        expect(detached, isNotNull);
        expect(detached!.khatmId, 'detached-personal');
        expect(detached.isDetachedFromReader, isTrue);

        // Finish all 4 ayahs purely in background after reader disposal.
        for (int i = 0; i < 4; i++) {
          mockPlayer.completeCurrentTrack();
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.pump(const Duration(milliseconds: 50));

        expect(ds.plans['detached-personal']!.sessions[0].isCompleted, isTrue);
        expect(ds.plans['detached-personal']!.isCompleted, isTrue);
        expect(mockPlayer.stopCalls, 1);
        expect(container.read(activeKhatmSessionProvider), isNull);
      },
    );

    testWidgets(
      'Group Khatm completes slot safely in background even with delayed server sync after reader disposal',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'audio_reciter_id': 1,
          'audio_playback_mode': 0,
        });
        final prefs = await SharedPreferences.getInstance();
        final prefsService = PreferencesServiceImpl(prefs);
        final mockPlayer = _FakeAudioPlayerService();
        addTearDown(mockPlayer.dispose);
        final groupDs = _FakeGroupProgressDs();
        final delayedRepo = _DelayedCompleteGroupRepo();

        final container = ProviderContainer(
          overrides: [
            sharedPreferencesInstanceProvider.overrideWithValue(prefs),
            preferencesServiceProvider.overrideWithValue(prefsService),
            reciterRepositoryProvider.overrideWithValue(_MockReciterRepo()),
            quranAudioHandlerProvider.overrideWithValue(_MockAudioHandler()),
            audioStorageServiceProvider.overrideWithValue(_FakeAudioStorage()),
            audioPlayerServiceProvider.overrideWithValue(mockPlayer),
            vipSubscriptionControllerProvider.overrideWith(
              _FakeVipController.new,
            ),
            analyticsServiceProvider.overrideWithValue(_FakeAnalyticsService()),
            khatmLocalDataSourceProvider.overrideWithValue(
              _TrackingKhatmLocalDataSource(const []),
            ),
            groupKhatmProgressLocalDataSourceProvider.overrideWithValue(
              groupDs,
            ),
            khatmRepositoryProvider.overrideWithValue(delayedRepo),
            ayahServiceProvider.overrideWithValue(_FakeAyahService({})),
            surahServiceProvider.overrideWithValue(_FakeSurahService()),
            studyPlanLocalDataSourceProvider.overrideWithValue(
              _FakeStudyPlanDs(),
            ),
            bookmarksControllerProvider.overrideWith(
              _FakeBookmarksController.new,
            ),
            ayahTeaserControllerProvider.overrideWith(
              _FakeAyahTeaserController.new,
            ),
            quranDisplaySettingsControllerProvider.overrideWith(
              _FakeDisplaySettingsController.new,
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: QuranReaderScreen(
                surahId: 112,
                surahName: 'سوره توحید',
                initialAyahNumber: 1,
                groupKhatmCode: 'G-DET',
                groupSlotId: 77,
                groupUnitType: GroupKhatmUnitType.surah,
                groupSlotUnit: 112,
                groupSlotQuantity: 1,
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        await container
            .read(quranAudioControllerProvider.notifier)
            .playAyah(surahId: 112, ayahNumber: 1, totalAyahsInSurah: 4);
        await tester.pump(const Duration(milliseconds: 50));

        // Leave QuranReaderScreen while Group Khatm audio is playing.
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: Scaffold()),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final detachedGroup = container.read(activeGroupKhatmSlotProvider);
        expect(detachedGroup, isNotNull);
        expect(detachedGroup!.isDetachedFromReader, isTrue);

        // Complete all 4 ayahs in background.
        for (int i = 0; i < 4; i++) {
          mockPlayer.completeCurrentTrack();
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(delayedRepo.completeCallCount, 1);

        // Complete async server sync now (must NOT throw StateError on autoDispose controller).
        delayedRepo.completeGate.complete();
        await tester.pump(const Duration(milliseconds: 50));

        final saved =
            groupDs.items[GroupKhatmSlotProgress.buildStorageKey('G-DET', 77)];
        expect(saved, isNotNull);
        expect(saved!.completedRepetitions, 1);
        expect(saved.isCompletedLocally, isTrue);
        expect(mockPlayer.stopCalls, 1);
        expect(container.read(activeGroupKhatmSlotProvider), isNull);
      },
    );

    testWidgets(
      'KhatmProgressDonutChart displays fractional completedFractionOverride percentage',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: KhatmProgressDonutChart(
                  title: 'ختم جزئی',
                  totalUnits: 30,
                  completedUnits: 0,
                  unitLabel: 'جزء',
                  completedFractionOverride: 0.45,
                  isCompletedOverride: false,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('۴۵٪'), findsOneWidget);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: KhatmProgressDonutChart(
                  title: 'ختم جزئی',
                  totalUnits: 30,
                  completedUnits: 30,
                  unitLabel: 'جزء',
                  completedFractionOverride: 1.0,
                  isCompletedOverride: true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('۱۰۰٪'), findsOneWidget);
      },
    );
  });
}
