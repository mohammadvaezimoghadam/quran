import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/misc.dart';

import 'package:quran/features/khatm/domain/entities/khatm_ayah_span.dart';
import 'package:quran/features/khatm/domain/entities/khatm_plan.dart';
import 'package:quran/features/khatm/domain/entities/khatm_session_item.dart';
import 'package:quran/features/khatm/domain/services/khatm_progress_calculator.dart';
import 'package:quran/features/khatm/infrastructure/datasources/khatm_local_datasource.dart';
import 'package:quran/features/khatm/infrastructure/datasources/khatm_mock_data.dart';
import 'package:quran/features/study_plan/domain/entities/study_plan.dart'
    show getGlobalAyahIndex;
import 'package:quran/features/tafakor/application/controllers/tafakor_auth_controller.dart';
import 'khatm_list_controller.dart';
import 'personal_khatm_sync_controller.dart';

/// Active Khatm session currently being read in the Quran Reader.
class ActiveKhatmSession {
  final String khatmId;
  final int sessionIndex;
  final bool isDetachedFromReader;

  const ActiveKhatmSession({
    required this.khatmId,
    required this.sessionIndex,
    this.isDetachedFromReader = false,
  });

  ActiveKhatmSession copyWith({
    String? khatmId,
    int? sessionIndex,
    bool? isDetachedFromReader,
  }) {
    return ActiveKhatmSession(
      khatmId: khatmId ?? this.khatmId,
      sessionIndex: sessionIndex ?? this.sessionIndex,
      isDetachedFromReader: isDetachedFromReader ?? this.isDetachedFromReader,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveKhatmSession &&
          other.khatmId == khatmId &&
          other.sessionIndex == sessionIndex &&
          other.isDetachedFromReader == isDetachedFromReader;

  @override
  int get hashCode => Object.hash(khatmId, sessionIndex, isDetachedFromReader);
}

/// Manages the currently active Khatm session in the Quran reader.
class ActiveKhatmSessionNotifier extends StateNotifier<ActiveKhatmSession?> {
  ActiveKhatmSessionNotifier() : super(null);

  void setActive({required String khatmId, required int sessionIndex}) {
    state = ActiveKhatmSession(
      khatmId: khatmId,
      sessionIndex: sessionIndex,
      isDetachedFromReader: false,
    );
  }

  void updateSessionIndex(int sessionIndex) {
    if (state != null) {
      state = state!.copyWith(sessionIndex: sessionIndex);
    }
  }

  void detachFromReader() {
    final current = state;
    if (current != null && !current.isDetachedFromReader) {
      state = current.copyWith(isDetachedFromReader: true);
    }
  }

  void clearIfDetached() {
    if (state?.isDetachedFromReader == true) {
      state = null;
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

  const KhatmDetailState({this.plan, this.isLoading = true, this.errorMessage});

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

  Timer? _saveDebounceTimer;
  KhatmPlan? _pendingPlanToSave;
  Future<void>? _inFlightSave;
  Future<void>? _pendingOperation;
  KeepAliveLink? _keepAliveLink;
  bool _isDisposing = false;

  KhatmDetailController(
    this._localDataSource,
    this.planId, [
    this._ref,
    KhatmPlan? initialPlan,
  ]) : super(
         KhatmDetailState(plan: initialPlan, isLoading: initialPlan == null),
       ) {
    if (initialPlan == null) {
      loadPlan();
    }
  }

  void _syncKeepAlive() {
    if (_isDisposing || !mounted) {
      _keepAliveLink?.close();
      _keepAliveLink = null;
      return;
    }
    final ref = _ref;
    if (ref == null) return;
    final shouldKeepAlive =
        _pendingOperation != null ||
        _pendingPlanToSave != null ||
        _inFlightSave != null;
    if (shouldKeepAlive) {
      try {
        _keepAliveLink ??= ref.keepAlive();
      } catch (_) {}
    } else {
      _keepAliveLink?.close();
      _keepAliveLink = null;
    }
  }

  Future<T> _serialized<T>(Future<T> Function() action) {
    final prev = _pendingOperation ?? Future<void>.value();
    final completer = Completer<T>();
    final next = prev.catchError((_) {}).then((_) async {
      try {
        final result = await action();
        if (!completer.isCompleted) completer.complete(result);
      } catch (e, st) {
        if (!completer.isCompleted) completer.completeError(e, st);
      }
    });
    _pendingOperation = next;
    _syncKeepAlive();
    next.whenComplete(() {
      if (identical(_pendingOperation, next)) {
        _pendingOperation = null;
      }
      _syncKeepAlive();
    });
    return completer.future;
  }

  Future<void> _savePlanTracked(KhatmPlan plan) {
    final prev = _inFlightSave ?? Future<void>.value();
    late final Future<void> current;
    current = prev
        .catchError((_) {})
        .then((_) async {
          await _localDataSource.savePlan(plan);
        })
        .whenComplete(() {
          if (identical(_inFlightSave, current)) {
            _inFlightSave = null;
          }
          _syncKeepAlive();
        });
    _inFlightSave = current;
    _syncKeepAlive();
    return current;
  }

  void _scheduleSavePlan(KhatmPlan plan) {
    _pendingPlanToSave = plan;
    _syncKeepAlive();
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(milliseconds: 600), () {
      final toSave = _pendingPlanToSave;
      _pendingPlanToSave = null;
      if (toSave != null) {
        unawaited(_savePlanTracked(toSave));
      }
      _syncKeepAlive();
    });
  }

  /// Flushes any pending debounced Hive write (and awaits any in-flight write)
  /// immediately to disk.
  Future<void> flushPendingSave() async {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = null;
    final toSave = _pendingPlanToSave;
    _pendingPlanToSave = null;
    if (toSave != null) {
      await _savePlanTracked(toSave);
    } else {
      _syncKeepAlive();
      if (_inFlightSave != null) {
        await _inFlightSave;
      }
    }
  }

  @override
  void dispose() {
    _isDisposing = true;
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = null;
    final toSave = _pendingPlanToSave;
    _pendingPlanToSave = null;
    if (toSave != null) {
      unawaited(_savePlanTracked(toSave));
    }
    _keepAliveLink?.close();
    _keepAliveLink = null;
    super.dispose();
  }

  Future<void> loadPlan() {
    return _serialized(_loadPlanInternal);
  }

  Future<void> _loadPlanInternal() async {
    await flushPendingSave();
    if (!mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    if (planId == 'test-personal-khatm' || planId.startsWith('test')) {
      state = state.copyWith(
        plan: KhatmTestData.samplePersonalPlan,
        isLoading: false,
      );
      return;
    }
    try {
      final plan = await _localDataSource.getPlan(planId);
      if (!mounted) return;
      if (plan != null && plan.deletedAt == null) {
        state = state.copyWith(plan: plan, isLoading: false);
      } else {
        state = state.copyWith(
          plan: KhatmTestData.samplePersonalPlan,
          isLoading: false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        plan: KhatmTestData.samplePersonalPlan,
        isLoading: false,
      );
    }
  }

  /// Toggles manual completion status for a specific session.
  Future<void> toggleSession(int sessionIndex, bool isCompleted) {
    return _serialized(() => _toggleSessionInternal(sessionIndex, isCompleted));
  }

  Future<void> _toggleSessionInternal(
    int sessionIndex,
    bool isCompleted, {
    List<KhatmAyahSpan>? coveredSpans,
    int? lastSurahId,
    int? lastAyahNumber,
    int? lastReadUnit,
  }) async {
    if (!mounted) return;
    final currentPlan = state.plan;
    if (currentPlan == null) return;

    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = null;
    _pendingPlanToSave = null;

    final updatedSessions = currentPlan.sessions.map((s) {
      if (s.sessionIndex == sessionIndex) {
        if (isCompleted) {
          final range = KhatmProgressCalculator.resolveGlobalAyahRange(
            unitType: currentPlan.unitType,
            fromUnit: s.fromUnit,
            toUnit: s.toUnit,
          );
          return s.copyWith(
            isCompleted: true,
            completedAt: DateTime.now(),
            progress: 1.0,
            lastReadUnit: lastReadUnit ?? s.toUnit,
            lastSurahId: lastSurahId ?? s.lastSurahId,
            lastAyahNumber: lastAyahNumber ?? s.lastAyahNumber,
            coveredSpans:
                coveredSpans ??
                [KhatmAyahSpan(start: range.startGlobal, end: range.endGlobal)],
          );
        } else {
          return s.copyWith(
            isCompleted: false,
            completedAt: null,
            progress: 0.0,
            coveredSpans: const [],
            clearResumeCoordinates: true,
          );
        }
      }
      return s;
    }).toList();

    final updatedPlan = currentPlan.copyWith(
      sessions: updatedSessions,
      clientUpdatedAt: DateTime.now().toUtc(),
      isDirty: true,
    );
    if (!mounted) return;
    state = state.copyWith(plan: updatedPlan);

    // Optimistic UI update in global list controller for Home Screen & List Screen
    _ref
        ?.read(khatmListControllerProvider.notifier)
        .optimisticUpdateSession(
          planId: planId,
          sessionIndex: sessionIndex,
          isCompleted: isCompleted,
        );

    // Persist immediately on explicit completion/uncompletion
    await _savePlanTracked(updatedPlan);

    // Auto-sync in background if authenticated
    if (_ref != null) {
      try {
        final isAuth = _ref.read(isTafakorAuthenticatedProvider);
        if (isAuth) {
          _ref
              .read(personalKhatmSyncControllerProvider.notifier)
              .syncWithBackend();
        }
      } catch (e) {
        debugPrint('⚠️ [KhatmDetail] Background sync skipped: $e');
      }
    }
  }

  /// Records user reading position and automatically completes the session if 100%
  /// of its `[startGlobal..endGlobal]` ayahs are covered.
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
    int? coverStartGlobal,
    int? coverEndGlobal,
    bool isAudio = false,
    bool recordCoverage = true,
  }) {
    return _serialized(() async {
      if (!mounted) return false;

      if (state.plan == null && state.isLoading) {
        await _loadPlanInternal();
      }
      if (!mounted) return false;

      final currentPlan = state.plan;
      if (currentPlan == null) return false;

      var activeSessionIndex = sessionIndex;
      KhatmSessionItem? session;
      for (final s in currentPlan.sessions) {
        if (s.sessionIndex == activeSessionIndex) {
          session = s;
          break;
        }
      }

      if (session == null) {
        return false;
      }

      if (session.isCompleted) {
        // Manual scrolling past a completed session must NOT auto-advance into
        // later sessions (preserving session boundaries during free browsing).
        if (!isAudio) {
          return false;
        }

        final stillInsideCompleted = isPositionInSession(
          plan: currentPlan,
          session: session,
          surahId: surahId,
          ayahNumber: ayahNumber,
          page: page,
          juz: juz,
          hizb: hizb,
        );
        if (stillInsideCompleted) {
          return false;
        }

        // Continuous audio playback moved past a completed session into a later
        // incomplete session in the same Khatm: auto-advance active tracking.
        KhatmSessionItem? nextSession;
        for (final s in currentPlan.sessions) {
          if (!s.isCompleted &&
              isPositionInSession(
                plan: currentPlan,
                session: s,
                surahId: surahId,
                ayahNumber: ayahNumber,
                page: page,
                juz: juz,
                hizb: hizb,
              )) {
            nextSession = s;
            break;
          }
        }
        if (nextSession == null) {
          return false;
        }
        session = nextSession;
        activeSessionIndex = nextSession.sessionIndex;
        try {
          _ref
              ?.read(activeKhatmSessionProvider.notifier)
              .updateSessionIndex(activeSessionIndex);
        } catch (_) {}
      }

      final eval = recordCoverage
          ? KhatmProgressCalculator.evaluateProgress(
              unitType: currentPlan.unitType,
              fromUnit: session.fromUnit,
              toUnit: session.toUnit,
              existingSpans: session.coveredSpans,
              existingProgress: session.progress,
              surahId: surahId,
              ayahNumber: ayahNumber,
              coverStartGlobal: coverStartGlobal,
              coverEndGlobal: coverEndGlobal,
              isAlreadyCompleted: session.isCompleted,
            )
          : KhatmProgressEvaluation(
              coveredSpans: session.coveredSpans,
              progress: session.progress,
              isCompleted: false,
              hasNewCoverage: false,
              isPositionInRange: KhatmProgressCalculator.isPositionInRange(
                unitType: currentPlan.unitType,
                fromUnit: session.fromUnit,
                toUnit: session.toUnit,
                surahId: surahId,
                ayahNumber: ayahNumber,
                page: page,
              ),
              coveredAyahsCount: KhatmAyahSpan.countUniqueAyahs(
                session.coveredSpans,
              ),
              totalAyahsCount: 1,
            );

      final unitValue = eval.isPositionInRange
          ? KhatmProgressCalculator.resolveUnitValue(
              unitType: currentPlan.unitType,
              surahId: surahId,
              ayahNumber: ayahNumber,
              page: page,
              juz: juz,
              hizb: hizb,
            )
          : session.lastReadUnit;

      if (eval.isCompleted) {
        await _toggleSessionInternal(
          activeSessionIndex,
          true,
          coveredSpans: eval.coveredSpans,
          lastSurahId: eval.isPositionInRange ? surahId : session.lastSurahId,
          lastAyahNumber: eval.isPositionInRange
              ? ayahNumber
              : session.lastAyahNumber,
          lastReadUnit: unitValue ?? session.toUnit,
        );
        return true;
      }

      final currentGlobal = getGlobalAyahIndex(surahId, ayahNumber);
      final savedGlobal =
          (session.lastSurahId != null && session.lastAyahNumber != null)
          ? getGlobalAyahIndex(session.lastSurahId!, session.lastAyahNumber!)
          : null;
      final isAtOrBeyondResumePoint =
          eval.isPositionInRange &&
          (savedGlobal == null || currentGlobal >= savedGlobal);
      final positionMovedForwardInRange =
          isAtOrBeyondResumePoint &&
          (session.lastSurahId != surahId ||
              session.lastAyahNumber != ayahNumber ||
              session.lastReadUnit != unitValue);

      if (eval.hasNewCoverage || positionMovedForwardInRange) {
        final updatedSessions = currentPlan.sessions.map((s) {
          if (s.sessionIndex == activeSessionIndex) {
            return s.copyWith(
              progress: eval.progress,
              coveredSpans: eval.coveredSpans,
              lastReadUnit: isAtOrBeyondResumePoint
                  ? unitValue
                  : s.lastReadUnit,
              lastSurahId: isAtOrBeyondResumePoint ? surahId : s.lastSurahId,
              lastAyahNumber: isAtOrBeyondResumePoint
                  ? ayahNumber
                  : s.lastAyahNumber,
            );
          }
          return s;
        }).toList();

        final updatedPlan = currentPlan.copyWith(
          sessions: updatedSessions,
          clientUpdatedAt: DateTime.now().toUtc(),
          isDirty: true,
        );
        if (!mounted) return false;
        state = state.copyWith(plan: updatedPlan);

        try {
          _ref
              ?.read(khatmListControllerProvider.notifier)
              .optimisticUpdatePlan(updatedPlan);
        } catch (_) {}

        // Debounce Hive writes during active reading scroll; flushed on dispose/pause/completion.
        _scheduleSavePlan(updatedPlan);

        if (_ref != null) {
          try {
            final isAuth = _ref.read(isTafakorAuthenticatedProvider);
            if (isAuth) {
              _ref
                  .read(personalKhatmSyncControllerProvider.notifier)
                  .scheduleSync();
            }
          } catch (e) {
            debugPrint('⚠️ [KhatmDetail] Debounced sync skipped: $e');
          }
        }
      }

      return false;
    });
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
    return KhatmProgressCalculator.isPositionInRange(
      unitType: plan.unitType,
      fromUnit: session.fromUnit,
      toUnit: session.toUnit,
      surahId: surahId,
      ayahNumber: ayahNumber,
      page: page,
    );
  }

  /// Deletes the current plan (soft delete) and triggers background sync.
  Future<bool> deletePlan() async {
    try {
      _saveDebounceTimer?.cancel();
      _saveDebounceTimer = null;
      _pendingPlanToSave = null;
      _syncKeepAlive();
      await _localDataSource.deletePlan(planId);
      _ref?.read(khatmListControllerProvider.notifier).loadPlans();
      if (_ref != null) {
        try {
          final isAuth = _ref.read(isTafakorAuthenticatedProvider);
          if (isAuth) {
            _ref
                .read(personalKhatmSyncControllerProvider.notifier)
                .syncWithBackend();
          }
        } catch (e) {
          debugPrint('⚠️ [KhatmDetail] Delete sync skipped: $e');
        }
      }
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(errorMessage: 'خطا در حذف ختم: $e');
      }
      return false;
    }
  }
}

final khatmDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<KhatmDetailController, KhatmDetailState, String>((ref, planId) {
      final localDataSource = ref.read(khatmLocalDataSourceProvider);
      final listState = ref.read(khatmListControllerProvider);
      KhatmPlan? initialPlan;
      for (final p in listState.plans) {
        if (p.id == planId) {
          initialPlan = p;
          break;
        }
      }
      if (initialPlan == null &&
          (planId == 'test-personal-khatm' || planId.startsWith('test'))) {
        initialPlan = KhatmTestData.samplePersonalPlan;
      }
      return KhatmDetailController(localDataSource, planId, ref, initialPlan);
    });
