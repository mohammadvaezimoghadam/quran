import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';
import 'package:quran/features/khatm/domain/entities/khatm_plan.dart';
import 'package:quran/features/khatm/domain/entities/khatm_session_item.dart';
import 'package:quran/features/khatm/infrastructure/datasources/khatm_local_datasource.dart';
import 'package:quran/features/khatm/infrastructure/datasources/khatm_quran_data.dart';
import 'package:quran/features/study_plan/domain/entities/study_plan.dart'
    show getGlobalAyahIndex;
import 'package:quran/features/surah_list/infrastructure/datasources/static_surahs_data.dart';
import 'khatm_list_controller.dart';

/// Active Khatm session currently being read in the Quran Reader.
class ActiveKhatmSession {
  final String khatmId;
  final int sessionIndex;

  const ActiveKhatmSession({
    required this.khatmId,
    required this.sessionIndex,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveKhatmSession &&
          other.khatmId == khatmId &&
          other.sessionIndex == sessionIndex;

  @override
  int get hashCode => khatmId.hashCode ^ sessionIndex.hashCode;
}

/// Manages the currently active Khatm session in the Quran reader.
class ActiveKhatmSessionNotifier extends StateNotifier<ActiveKhatmSession?> {
  ActiveKhatmSessionNotifier() : super(null);

  void setActive({required String khatmId, required int sessionIndex}) {
    state = ActiveKhatmSession(khatmId: khatmId, sessionIndex: sessionIndex);
  }

  void updateSessionIndex(int sessionIndex) {
    if (state != null) {
      state = ActiveKhatmSession(
        khatmId: state!.khatmId,
        sessionIndex: sessionIndex,
      );
    }
  }

  void clear() {
    state = null;
  }
}

final activeKhatmSessionProvider =
    StateNotifierProvider<ActiveKhatmSessionNotifier, ActiveKhatmSession?>(
  (ref) => ActiveKhatmSessionNotifier(),
);

/// Manages whether the KhatmReaderBar is collapsed to a micro-progress line during reading scroll.
class KhatmReaderBarCollapsedNotifier extends StateNotifier<bool> {
  KhatmReaderBarCollapsedNotifier() : super(false);

  void setCollapsed(bool value) {
    if (state != value) {
      state = value;
    }
  }

  void toggle() {
    state = !state;
  }
}

final isKhatmReaderBarCollapsedProvider =
    StateNotifierProvider<KhatmReaderBarCollapsedNotifier, bool>(
  (ref) => KhatmReaderBarCollapsedNotifier(),
);

/// State for the Khatm detail and progress report screen.
class KhatmDetailState {
  final KhatmPlan? plan;
  final bool isLoading;
  final String? errorMessage;

  const KhatmDetailState({
    this.plan,
    this.isLoading = true,
    this.errorMessage,
  });

  KhatmDetailState copyWith({
    KhatmPlan? plan,
    bool? isLoading,
    String? errorMessage,
  }) {
    return KhatmDetailState(
      plan: plan ?? this.plan,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Controller managing a single Khatm plan's details, session completion, and actions.
class KhatmDetailController extends StateNotifier<KhatmDetailState> {
  final IKhatmLocalDataSource _localDataSource;
  final String planId;
  final Ref? _ref;
  bool _isAutoCompleting = false;

  KhatmDetailController(this._localDataSource, this.planId, [this._ref])
      : super(const KhatmDetailState()) {
    loadPlan();
  }

  Future<void> loadPlan() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final plan = await _localDataSource.getPlan(planId);
      if (!mounted) return;
      if (plan != null) {
        state = state.copyWith(plan: plan, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'ختم مورد نظر یافت نشد',
        );
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'خطا در بارگذاری ختم: $e',
      );
    }
  }

  /// Toggles manual completion status for a specific session.
  Future<void> toggleSession(int sessionIndex, bool isCompleted) async {
    if (!mounted) return;
    final currentPlan = state.plan;
    if (currentPlan == null) return;

    // Optimistic UI update in detail state
    final updatedSessions = currentPlan.sessions.map((s) {
      if (s.sessionIndex == sessionIndex) {
        return s.copyWith(
          isCompleted: isCompleted,
          completedAt: isCompleted ? DateTime.now() : null,
          progress: isCompleted ? 1.0 : 0.0,
          lastReadUnit: isCompleted ? s.toUnit : null,
        );
      }
      return s;
    }).toList();

    final updatedPlan = currentPlan.copyWith(sessions: updatedSessions);
    if (!mounted) return;
    state = state.copyWith(plan: updatedPlan);

    // Optimistic UI update in global list controller for Home Screen & List Screen
    _ref?.read(khatmListControllerProvider.notifier).optimisticUpdateSession(
          planId: planId,
          sessionIndex: sessionIndex,
          isCompleted: isCompleted,
        );

    // Persist to Hive (this triggers listeners as well)
    await _localDataSource.updateSessionStatus(
      planId: planId,
      sessionIndex: sessionIndex,
      isCompleted: isCompleted,
    );
  }

  /// Records user reading position and automatically completes the session if the end is reached.
  /// Returns true if the session was completed by this invocation.
  Future<bool> recordReadingProgress({
    required int sessionIndex,
    required int surahId,
    required int ayahNumber,
    int? page,
    int? juz,
    int? hizb,
    bool isEndOfPage = false,
    double pageFraction = 0.0,
  }) async {
    if (!mounted || _isAutoCompleting) return false;

    // If state.plan is still loading asynchronously, await plan loading first
    if (state.plan == null && state.isLoading) {
      await loadPlan();
    }

    final currentPlan = state.plan;
    if (currentPlan == null) return false;

    KhatmSessionItem? session;
    for (final s in currentPlan.sessions) {
      if (s.sessionIndex == sessionIndex) {
        session = s;
        break;
      }
    }

    // If current session is completed or not found, do not track or touch other sessions!
    if (session == null || session.isCompleted) {
      return false;
    }

    final computedProgress = _calculateSessionProgress(
      plan: currentPlan,
      session: session,
      surahId: surahId,
      ayahNumber: ayahNumber,
      page: page,
      juz: juz,
      hizb: hizb,
      isEndOfPage: isEndOfPage,
      pageFraction: pageFraction,
    );

    final shouldComplete = _checkIfSessionEndReached(
      plan: currentPlan,
      session: session,
      surahId: surahId,
      ayahNumber: ayahNumber,
      page: page,
      juz: juz,
      hizb: hizb,
      isEndOfPage: isEndOfPage,
      pageFraction: pageFraction,
      computedProgress: computedProgress,
    );

    if (shouldComplete) {
      _isAutoCompleting = true;
      try {
        await toggleSession(sessionIndex, true);
        return true;
      } finally {
        _isAutoCompleting = false;
      }
    } else if (computedProgress > session.progress) {
      final int unitValue;
      switch (currentPlan.unitType) {
        case KhatmUnitType.page:
          unitValue = page ?? KhatmQuranData.getPageForAyah(surahId, ayahNumber);
          break;
        case KhatmUnitType.surah:
          unitValue = surahId;
          break;
        case KhatmUnitType.juz:
          final p = page ?? KhatmQuranData.getPageForAyah(surahId, ayahNumber);
          unitValue = juz ?? KhatmQuranData.getJuzForPage(p);
          break;
        case KhatmUnitType.hizb:
          final p = page ?? KhatmQuranData.getPageForAyah(surahId, ayahNumber);
          unitValue = hizb ?? KhatmQuranData.getHizbForPage(p);
          break;
        case KhatmUnitType.ayah:
          unitValue = getGlobalAyahIndex(surahId, ayahNumber);
          break;
      }

      final updatedSessions = currentPlan.sessions.map((s) {
        if (s.sessionIndex == sessionIndex) {
          return s.copyWith(
            progress: computedProgress,
            lastReadUnit: unitValue,
          );
        }
        return s;
      }).toList();

      final updatedPlan = currentPlan.copyWith(sessions: updatedSessions);
      state = state.copyWith(plan: updatedPlan);

      await _localDataSource.updateSessionProgress(
        planId: planId,
        sessionIndex: sessionIndex,
        progress: computedProgress,
        lastReadUnit: unitValue,
      );
    }

    return false;
  }

  /// Checks if a given Quran position is within a Khatm session's boundaries.
  static bool isPositionInSession({
    required KhatmPlan plan,
    required KhatmSessionItem session,
    required int surahId,
    required int ayahNumber,
    int? page,
    int? juz,
    int? hizb,
  }) {
    final resolvedPage =
        page ?? KhatmQuranData.getPageForAyah(surahId, ayahNumber);

    switch (plan.unitType) {
      case KhatmUnitType.page:
        return resolvedPage >= session.fromUnit && resolvedPage <= session.toUnit;
      case KhatmUnitType.surah:
        return surahId >= session.fromUnit && surahId <= session.toUnit;
      case KhatmUnitType.juz:
        final startPage = KhatmQuranData.juzToStartPage[session.fromUnit]!;
        final endPage = session.toUnit < 30
            ? (KhatmQuranData.juzToStartPage[session.toUnit + 1]! - 1)
            : 604;
        return resolvedPage >= startPage && resolvedPage <= endPage;
      case KhatmUnitType.hizb:
        final startPage = KhatmQuranData.hizb120ToStartPage[session.fromUnit]!;
        final endPage = session.toUnit < 120
            ? (KhatmQuranData.hizb120ToStartPage[session.toUnit + 1]! - 1)
            : 604;
        return resolvedPage >= startPage && resolvedPage <= endPage;
      case KhatmUnitType.ayah:
        final globalAyah = getGlobalAyahIndex(surahId, ayahNumber);
        return globalAyah >= session.fromUnit && globalAyah <= session.toUnit;
    }
  }

  /// Calculates the fraction (0.0 to 1.0) of session progress based on current reading position.
  double _calculateSessionProgress({
    required KhatmPlan plan,
    required KhatmSessionItem session,
    required int surahId,
    required int ayahNumber,
    int? page,
    int? juz,
    int? hizb,
    bool isEndOfPage = false,
    double pageFraction = 0.0,
  }) {
    if (session.isCompleted) return 1.0;

    final resolvedPage =
        page ?? KhatmQuranData.getPageForAyah(surahId, ayahNumber);
    final currentGlobalAyah = getGlobalAyahIndex(surahId, ayahNumber);

    switch (plan.unitType) {
      case KhatmUnitType.page:
        if (resolvedPage < session.fromUnit) return session.progress;
        if (resolvedPage > session.toUnit) {
          return (resolvedPage == session.toUnit + 1) ? 1.0 : session.progress;
        }
        final fractionOnPage =
            isEndOfPage ? 1.0 : (pageFraction > 0 ? pageFraction : 0.0);
        final pagesRead =
            (resolvedPage - session.fromUnit) + fractionOnPage;
        final rawProgress = (pagesRead / session.unitCount).clamp(0.0, 1.0);
        // If reached the target page and substantially progressed (or end of page reached), mark 100%
        if (resolvedPage == session.toUnit) {
          if (isEndOfPage) return 1.0;
          if (session.unitCount > 1 && (pageFraction >= 0.75 || rawProgress >= 0.96)) {
            return 1.0;
          }
        }
        return rawProgress;

      case KhatmUnitType.surah:
        if (surahId < session.fromUnit) return session.progress;
        if (surahId > session.toUnit) {
          return (surahId == session.toUnit + 1) ? 1.0 : session.progress;
        }
        int totalAyahsInSession = 0;
        int ayahsReadBeforeCurrent = 0;
        for (int s = session.fromUnit; s <= session.toUnit; s++) {
          final count = kStaticQuranSurahs[s - 1].numberOfAyahs;
          totalAyahsInSession += count;
          if (s < surahId) {
            ayahsReadBeforeCurrent += count;
          }
        }
        final ayahsRead = ayahsReadBeforeCurrent + ayahNumber;
        final rawProgress = totalAyahsInSession > 0
            ? (ayahsRead / totalAyahsInSession).clamp(0.0, 1.0)
            : 0.0;
        if (surahId == session.toUnit &&
            ayahNumber >= kStaticQuranSurahs[surahId - 1].numberOfAyahs) {
          if (isEndOfPage) return 1.0;
          if (session.unitCount > 1) return 1.0;
        }
        return rawProgress;

      case KhatmUnitType.juz:
        final int targetStartPage =
            KhatmQuranData.juzToStartPage[session.fromUnit]!;
        final int targetEndPage = session.toUnit < 30
            ? (KhatmQuranData.juzToStartPage[session.toUnit + 1]! - 1)
            : 604;
        if (resolvedPage < targetStartPage) return session.progress;
        if (resolvedPage > targetEndPage) {
          return (resolvedPage == targetEndPage + 1) ? 1.0 : session.progress;
        }
        final totalPages = targetEndPage - targetStartPage + 1;
        final fractionOnPage =
            isEndOfPage ? 1.0 : (pageFraction > 0 ? pageFraction : 0.0);
        final pagesRead = (resolvedPage - targetStartPage) + fractionOnPage;
        final rawProgress = (pagesRead / totalPages).clamp(0.0, 1.0);
        if (resolvedPage == targetEndPage) {
          if (isEndOfPage) return 1.0;
          if (session.unitCount > 1 && (pageFraction >= 0.75 || rawProgress >= 0.96)) {
            return 1.0;
          }
        }
        return rawProgress;

      case KhatmUnitType.hizb:
        final int targetStartPage =
            KhatmQuranData.hizb120ToStartPage[session.fromUnit]!;
        final int targetEndPage = session.toUnit < 120
            ? (KhatmQuranData.hizb120ToStartPage[session.toUnit + 1]! - 1)
            : 604;
        if (resolvedPage < targetStartPage) return session.progress;
        if (resolvedPage > targetEndPage) {
          return (resolvedPage == targetEndPage + 1) ? 1.0 : session.progress;
        }
        final totalPages = targetEndPage - targetStartPage + 1;
        final fractionOnPage =
            isEndOfPage ? 1.0 : (pageFraction > 0 ? pageFraction : 0.0);
        final pagesRead = (resolvedPage - targetStartPage) + fractionOnPage;
        final rawProgress = (pagesRead / totalPages).clamp(0.0, 1.0);
        if (resolvedPage == targetEndPage) {
          if (isEndOfPage) return 1.0;
          if (session.unitCount > 1 && (pageFraction >= 0.75 || rawProgress >= 0.96)) {
            return 1.0;
          }
        }
        return rawProgress;

      case KhatmUnitType.ayah:
        if (currentGlobalAyah < session.fromUnit) return session.progress;
        if (currentGlobalAyah > session.toUnit) {
          return (currentGlobalAyah == session.toUnit + 1) ? 1.0 : session.progress;
        }
        final ayahsRead = (currentGlobalAyah - session.fromUnit);
        final fraction = (ayahsRead / session.unitCount).clamp(0.0, 1.0);
        if (currentGlobalAyah == session.toUnit && isEndOfPage) {
          return 1.0;
        }
        return fraction;
    }
  }

  bool _checkIfSessionEndReached({
    required KhatmPlan plan,
    required KhatmSessionItem session,
    required int surahId,
    required int ayahNumber,
    int? page,
    int? juz,
    int? hizb,
    bool isEndOfPage = false,
    double pageFraction = 0.0,
    double? computedProgress,
  }) {
    if (session.isCompleted) return false;

    final resolvedPage =
        page ?? KhatmQuranData.getPageForAyah(surahId, ayahNumber);
    final currentGlobalAyah = getGlobalAyahIndex(surahId, ayahNumber);

    if (computedProgress != null && computedProgress >= 0.985) {
      if (session.unitCount > 1 &&
          isPositionInSession(
            plan: plan,
            session: session,
            surahId: surahId,
            ayahNumber: ayahNumber,
            page: page,
            juz: juz,
            hizb: hizb,
          )) {
        return true;
      }
      if (plan.unitType == KhatmUnitType.page && resolvedPage == session.toUnit + 1) {
        return true;
      }
    }

    switch (plan.unitType) {
      case KhatmUnitType.page:
        // Position is outside session's vicinity (before start or more than 1 page past the end):
        if (resolvedPage < session.fromUnit || resolvedPage > session.toUnit + 1) {
          return false;
        }
        // Flipped to the immediate next page after session:
        if (resolvedPage == session.toUnit + 1) return true;
        // Reached end of the target page:
        if (resolvedPage == session.toUnit) {
          if (isEndOfPage) return true;
          if (session.unitCount > 1 &&
              (pageFraction >= 0.75 || (computedProgress != null && computedProgress >= 0.95))) {
            return true;
          }
        }
        return false;

      case KhatmUnitType.surah:
        if (surahId < session.fromUnit || surahId > session.toUnit + 1) {
          return false;
        }
        if (surahId == session.toUnit + 1) return true;
        if (surahId == session.toUnit) {
          final totalAyahs = kStaticQuranSurahs[surahId - 1].numberOfAyahs;
          if (ayahNumber >= totalAyahs) {
            if (isEndOfPage) return true;
            if (session.unitCount > 1) return true;
          }
        }
        return false;

      case KhatmUnitType.juz:
        final int targetStartPage =
            KhatmQuranData.juzToStartPage[session.fromUnit]!;
        final int targetEndPage = session.toUnit < 30
            ? (KhatmQuranData.juzToStartPage[session.toUnit + 1]! - 1)
            : 604;
        if (resolvedPage < targetStartPage || resolvedPage > targetEndPage + 1) {
          return false;
        }
        if (resolvedPage == targetEndPage + 1) return true;
        if (resolvedPage == targetEndPage) {
          if (isEndOfPage) return true;
          if (session.unitCount > 1 &&
              (pageFraction >= 0.75 || (computedProgress != null && computedProgress >= 0.95))) {
            return true;
          }
        }
        return false;

      case KhatmUnitType.hizb:
        final int targetStartPage =
            KhatmQuranData.hizb120ToStartPage[session.fromUnit]!;
        final int targetEndPage = session.toUnit < 120
            ? (KhatmQuranData.hizb120ToStartPage[session.toUnit + 1]! - 1)
            : 604;
        if (resolvedPage < targetStartPage || resolvedPage > targetEndPage + 1) {
          return false;
        }
        if (resolvedPage == targetEndPage + 1) return true;
        if (resolvedPage == targetEndPage) {
          if (isEndOfPage) return true;
          if (session.unitCount > 1 &&
              (pageFraction >= 0.75 || (computedProgress != null && computedProgress >= 0.95))) {
            return true;
          }
        }
        return false;

      case KhatmUnitType.ayah:
        if (currentGlobalAyah < session.fromUnit || currentGlobalAyah > session.toUnit + 1) {
          return false;
        }
        // Completed when scrolled to the ayah after target:
        if (currentGlobalAyah == session.toUnit + 1) return true;
        // Or reached target ayah and end of page/item:
        if (currentGlobalAyah == session.toUnit && isEndOfPage) return true;
        return false;
    }
  }

  /// Deletes the current plan from local storage.
  Future<bool> deletePlan() async {
    try {
      await _localDataSource.deletePlan(planId);
      _ref?.read(khatmListControllerProvider.notifier).loadPlans();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'خطا در حذف ختم: $e');
      return false;
    }
  }
}

final khatmDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<KhatmDetailController, KhatmDetailState, String>((ref, planId) {
  final localDataSource = ref.read(khatmLocalDataSourceProvider);
  return KhatmDetailController(localDataSource, planId, ref);
});
