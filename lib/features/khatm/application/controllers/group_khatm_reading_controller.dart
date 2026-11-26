import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../study_plan/domain/entities/study_plan.dart'
    show getGlobalAyahIndex;
import '../../../surah_list/infrastructure/datasources/static_surahs_data.dart';
import '../../domain/entities/group_khatm_campaign.dart';
import '../../domain/entities/group_khatm_slot.dart';
import '../../domain/entities/group_khatm_slot_progress.dart';
import '../../domain/entities/khatm_ayah_span.dart';
import '../../domain/entities/khatm_enums.dart';
import '../../domain/services/khatm_progress_calculator.dart';
import '../../domain/services/khatm_quran_resolver.dart';
import '../../infrastructure/datasources/group_khatm_progress_local_datasource.dart';
import '../../infrastructure/datasources/khatm_quran_data.dart';
import 'group_khatm_detail_controller.dart';

/// Active Group Khatm slot currently being read in [QuranReaderScreen].
class ActiveGroupKhatmSlot {
  final String inviteCode;
  final int slotId;
  final GroupKhatmUnitType unitType;
  final int unitNumber;
  final int targetQuantity;
  final bool isDetachedFromReader;

  const ActiveGroupKhatmSlot({
    required this.inviteCode,
    required this.slotId,
    required this.unitType,
    required this.unitNumber,
    this.targetQuantity = 1,
    this.isDetachedFromReader = false,
  });

  ActiveGroupKhatmSlot copyWith({
    String? inviteCode,
    int? slotId,
    GroupKhatmUnitType? unitType,
    int? unitNumber,
    int? targetQuantity,
    bool? isDetachedFromReader,
  }) {
    return ActiveGroupKhatmSlot(
      inviteCode: inviteCode ?? this.inviteCode,
      slotId: slotId ?? this.slotId,
      unitType: unitType ?? this.unitType,
      unitNumber: unitNumber ?? this.unitNumber,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      isDetachedFromReader: isDetachedFromReader ?? this.isDetachedFromReader,
    );
  }

  String get storageKey =>
      GroupKhatmSlotProgress.buildStorageKey(inviteCode, slotId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveGroupKhatmSlot &&
          other.inviteCode == inviteCode &&
          other.slotId == slotId &&
          other.unitType == unitType &&
          other.unitNumber == unitNumber &&
          other.targetQuantity == targetQuantity &&
          other.isDetachedFromReader == isDetachedFromReader;

  @override
  int get hashCode => Object.hash(
        inviteCode,
        slotId,
        unitType,
        unitNumber,
        targetQuantity,
        isDetachedFromReader,
      );
}

class ActiveGroupKhatmSlotNotifier extends StateNotifier<ActiveGroupKhatmSlot?> {
  ActiveGroupKhatmSlotNotifier() : super(null);

  void setActive(ActiveGroupKhatmSlot slot) {
    final attached = slot.isDetachedFromReader
        ? slot.copyWith(isDetachedFromReader: false)
        : slot;
    if (state != attached) {
      state = attached;
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

final activeGroupKhatmSlotProvider =
    StateNotifierProvider<ActiveGroupKhatmSlotNotifier, ActiveGroupKhatmSlot?>(
      (ref) => ActiveGroupKhatmSlotNotifier(),
    );

/// Outcome of a reading progress update for a Group Khatm slot.
enum GroupKhatmProgressEvent {
  none,
  progressed,
  passCompleted,
  slotCompleted,
}

/// Manages offline reading progress, resume coordinates, and auto-completion
/// across all claimed Group Khatm slots using [KhatmProgressCalculator].
class GroupKhatmReadingController
    extends StateNotifier<Map<String, GroupKhatmSlotProgress>> {
  final IGroupKhatmProgressLocalDataSource _localDataSource;
  final Ref _ref;

  final Map<String, Future<void>> _pendingByKey = <String, Future<void>>{};
  final Set<String> _awaitingPassResetKeys = <String>{};
  late final Future<void> _initialLoadFuture;

  GroupKhatmReadingController(this._localDataSource, this._ref)
      : super(const {}) {
    _initialLoadFuture = loadAll();
  }

  Future<T> _serialized<T>(String key, Future<T> Function() action) {
    final prev = _pendingByKey[key] ?? Future<void>.value();
    final completer = Completer<T>();
    final next = prev.catchError((_) {}).then((_) async {
      try {
        await _initialLoadFuture;
        final result = await action();
        if (!completer.isCompleted) completer.complete(result);
      } catch (e, st) {
        if (!completer.isCompleted) completer.completeError(e, st);
      }
    });
    _pendingByKey[key] = next;
    next.whenComplete(() {
      if (identical(_pendingByKey[key], next)) {
        _pendingByKey.remove(key);
      }
    });
    return completer.future;
  }

  Future<void> loadAll() async {
    final items = await _localDataSource.getAll();
    if (!mounted) return;
    final map = <String, GroupKhatmSlotProgress>{};
    for (final item in items) {
      map[item.storageKey] = item;
    }
    state = map;
  }

  GroupKhatmSlotProgress? progressFor(String inviteCode, int slotId) {
    return state[GroupKhatmSlotProgress.buildStorageKey(inviteCode, slotId)];
  }

  /// Resolves the navigation target to open [QuranReaderScreen] for [slot],
  /// resuming from exact `(lastSurahId, lastAyahNumber)` when available.
  KhatmNavigationTarget resolveResumeTarget({
    required GroupKhatmCampaign campaign,
    required GroupKhatmSlot slot,
  }) {
    final unitType = campaign.unitTypeEnum;
    final unitNumber = slot.unitNumber ?? campaign.targetSurah ?? 1;
    final khatmUnitType = _toKhatmUnitType(unitType);
    final saved = progressFor(campaign.inviteCode, slot.id);

    if (saved != null &&
        !saved.isCompletedLocally &&
        saved.lastSurahId != null &&
        saved.lastAyahNumber != null) {
      final inRange = KhatmProgressCalculator.isPositionInRange(
        unitType: khatmUnitType,
        fromUnit: unitNumber,
        toUnit: unitNumber,
        surahId: saved.lastSurahId!,
        ayahNumber: saved.lastAyahNumber!,
        page: saved.lastPage,
      );
      if (inRange) {
        return KhatmNavigationTarget(
          surahId: saved.lastSurahId!,
          ayahNumber: saved.lastAyahNumber!,
          pageNumber: saved.lastPage ??
              KhatmQuranData.getPageForAyah(
                saved.lastSurahId!,
                saved.lastAyahNumber!,
              ),
        );
      }
    }

    return KhatmQuranResolver.resolveUnit(
      unitType: khatmUnitType,
      unitNumber: unitNumber,
    );
  }

  /// Clears the pass-reset guard when the user explicitly starts the next pass.
  Future<void> beginNextPass(String inviteCode, int slotId) {
    final key = GroupKhatmSlotProgress.buildStorageKey(inviteCode, slotId);
    _awaitingPassResetKeys.remove(key);
    return _serialized(key, () async {
      if (!mounted) return;
      final existing = state[key] ??
          await _localDataSource.getProgress(inviteCode, slotId);
      if (existing != null && existing.awaitingNextPass) {
        await _persist(
          existing.copyWith(
            awaitingNextPass: false,
            updatedAt: DateTime.now(),
          ),
        );
      }
    });
  }

  /// Records reading position for an active Group Khatm slot.
  Future<GroupKhatmProgressEvent> recordReadingProgress({
    required ActiveGroupKhatmSlot activeSlot,
    required int surahId,
    required int ayahNumber,
    int? page,
    bool isEndOfPage = false,
    double pageFraction = 0.0,
    int? coverStartGlobal,
    int? coverEndGlobal,
    bool isAudio = false,
    bool recordCoverage = true,
  }) {
    final key = activeSlot.storageKey;
    return _serialized(key, () async {
      if (!mounted) return GroupKhatmProgressEvent.none;

      final khatmUnitType = _toKhatmUnitType(activeSlot.unitType);
      final resolvedPage =
          page ?? KhatmQuranData.getPageForAyah(surahId, ayahNumber);
      final now = DateTime.now();

      var existing = state[key] ??
          await _localDataSource.getProgress(
            activeSlot.inviteCode,
            activeSlot.slotId,
          ) ??
          GroupKhatmSlotProgress(
            inviteCode: activeSlot.inviteCode,
            slotId: activeSlot.slotId,
            unitType: activeSlot.unitType,
            unitNumber: activeSlot.unitNumber,
            targetQuantity: activeSlot.targetQuantity,
            updatedAt: now,
          );

      if (!mounted || existing.isCompletedLocally) {
        return GroupKhatmProgressEvent.none;
      }

      final range = KhatmProgressCalculator.resolveGlobalAyahRange(
        unitType: khatmUnitType,
        fromUnit: activeSlot.unitNumber,
        toUnit: activeSlot.unitNumber,
      );

      // Prevent immediate cascading completions of passes 2..N on multi-pass Surah slots:
      // - Never auto-clear on short surahs (<= 5 ayahs, e.g. 3-ayah Al-Asr/Al-Kawthar/An-Nasr),
      //   single-page views covering the end ayah, or ScrollEndNotification at bottom.
      // - On long multi-page surahs (> 5 ayahs), auto-clear only if genuinely back at Ayah 1
      //   before the end of the surah; otherwise require explicit `beginNextPass()`.
      bool clearedAwaitingPass = false;
      if (_awaitingPassResetKeys.contains(key) || existing.awaitingNextPass) {
        final totalAyahs = (surahId >= 1 && surahId <= 114)
            ? kStaticQuranSurahs[surahId - 1].numberOfAyahs
            : 7;
        final maxCovered =
            coverEndGlobal ?? getGlobalAyahIndex(surahId, ayahNumber);
        final isSurahUnit =
            activeSlot.unitType == GroupKhatmUnitType.surah &&
            surahId == activeSlot.unitNumber;
        final isLongSurahRestartAtTop =
            isSurahUnit &&
            totalAyahs > 5 &&
            ayahNumber == 1 &&
            !isEndOfPage &&
            maxCovered < range.endGlobal;
        final isAudioRestartAtTop =
            isAudio &&
            isSurahUnit &&
            ayahNumber == 1 &&
            !isEndOfPage &&
            maxCovered < range.endGlobal;
        if (isLongSurahRestartAtTop || isAudioRestartAtTop) {
          _awaitingPassResetKeys.remove(key);
          if (existing.awaitingNextPass) {
            existing = existing.copyWith(awaitingNextPass: false);
            clearedAwaitingPass = true;
          }
        } else {
          return GroupKhatmProgressEvent.none;
        }
      }

      final eval = recordCoverage
          ? KhatmProgressCalculator.evaluateProgress(
              unitType: khatmUnitType,
              fromUnit: activeSlot.unitNumber,
              toUnit: activeSlot.unitNumber,
              existingSpans: existing.coveredSpans,
              existingProgress: existing.currentPassProgress,
              surahId: surahId,
              ayahNumber: ayahNumber,
              coverStartGlobal: coverStartGlobal,
              coverEndGlobal: coverEndGlobal,
              isAlreadyCompleted: existing.isCompletedLocally,
            )
          : KhatmProgressEvaluation(
              coveredSpans: existing.coveredSpans,
              progress: existing.currentPassProgress,
              isCompleted: false,
              hasNewCoverage: false,
              isPositionInRange: KhatmProgressCalculator.isPositionInRange(
                unitType: khatmUnitType,
                fromUnit: activeSlot.unitNumber,
                toUnit: activeSlot.unitNumber,
                surahId: surahId,
                ayahNumber: ayahNumber,
                page: resolvedPage,
              ),
              coveredAyahsCount: KhatmAyahSpan.countUniqueAyahs(
                existing.coveredSpans,
              ),
              totalAyahsCount: 1,
            );

      if (eval.isCompleted) {
        final qty =
            activeSlot.targetQuantity < 1 ? 1 : activeSlot.targetQuantity;
        final nextReps = existing.completedRepetitions + 1;

        if (activeSlot.unitType == GroupKhatmUnitType.surah && nextReps < qty) {
          // Completed 1 repetition of a multi-pass Surah slot: advance counter & reset pass progress
          _awaitingPassResetKeys.add(key);
          final startTarget = KhatmQuranResolver.resolveUnit(
            unitType: KhatmUnitType.surah,
            unitNumber: activeSlot.unitNumber,
          );
          final updated = existing.copyWith(
            unitType: activeSlot.unitType,
            unitNumber: activeSlot.unitNumber,
            targetQuantity: qty,
            completedRepetitions: nextReps,
            currentPassProgress: 0.0,
            coveredSpans: const [],
            lastSurahId: startTarget.surahId,
            lastAyahNumber: startTarget.ayahNumber,
            lastPage: startTarget.pageNumber,
            awaitingNextPass: true,
            updatedAt: now,
          );
          await _persist(updated);
          return GroupKhatmProgressEvent.passCompleted;
        }

        // Final pass (or discrete Juz/Hizb slot) finished -> auto-complete slot!
        final completedLocal = existing.copyWith(
          unitType: activeSlot.unitType,
          unitNumber: activeSlot.unitNumber,
          targetQuantity: qty,
          completedRepetitions: qty,
          currentPassProgress: 1.0,
          coveredSpans: eval.coveredSpans,
          lastSurahId:
              eval.isPositionInRange ? surahId : existing.lastSurahId,
          lastAyahNumber:
              eval.isPositionInRange ? ayahNumber : existing.lastAyahNumber,
          lastPage:
              eval.isPositionInRange ? resolvedPage : existing.lastPage,
          awaitingNextPass: false,
          isCompletedLocally: true,
          pendingServerSync: true,
          updatedAt: now,
        );
        await _persist(completedLocal);

        final synced = await _completeOnServer(activeSlot);
        if (synced && mounted) {
          await _persist(completedLocal.copyWith(
            pendingServerSync: false,
            updatedAt: DateTime.now(),
          ));
        }
        return GroupKhatmProgressEvent.slotCompleted;
      }

      // Track forward coverage & high-water-mark resume coordinates inside the slot
      final currentGlobal = getGlobalAyahIndex(surahId, ayahNumber);
      final savedGlobal =
          (existing.lastSurahId != null && existing.lastAyahNumber != null)
              ? getGlobalAyahIndex(
                  existing.lastSurahId!,
                  existing.lastAyahNumber!,
                )
              : null;
      final isAtOrBeyondResumePoint =
          eval.isPositionInRange &&
          (savedGlobal == null || currentGlobal >= savedGlobal);
      final positionMovedForwardInRange =
          isAtOrBeyondResumePoint &&
          (existing.lastSurahId != surahId ||
              existing.lastAyahNumber != ayahNumber);

      if (eval.hasNewCoverage ||
          positionMovedForwardInRange ||
          clearedAwaitingPass) {
        final updated = existing.copyWith(
          unitType: activeSlot.unitType,
          unitNumber: activeSlot.unitNumber,
          targetQuantity: activeSlot.targetQuantity,
          currentPassProgress: eval.progress,
          coveredSpans: eval.coveredSpans,
          lastSurahId:
              isAtOrBeyondResumePoint ? surahId : existing.lastSurahId,
          lastAyahNumber:
              isAtOrBeyondResumePoint ? ayahNumber : existing.lastAyahNumber,
          lastPage:
              isAtOrBeyondResumePoint ? resolvedPage : existing.lastPage,
          awaitingNextPass: false,
          updatedAt: now,
        );
        await _persist(updated);
        return eval.hasNewCoverage
            ? GroupKhatmProgressEvent.progressed
            : GroupKhatmProgressEvent.none;
      }

      return GroupKhatmProgressEvent.none;
    });
  }

  /// Syncs locally completed (offline) slots for [inviteCode] when back online.
  Future<void> syncPendingCompletions(String inviteCode) async {
    final pending = state.values
        .where((p) => p.inviteCode == inviteCode && p.pendingServerSync)
        .toList();
    for (final item in pending) {
      await _serialized(item.storageKey, () async {
        final latest = state[item.storageKey] ?? item;
        if (!latest.pendingServerSync) return;
        final slot = ActiveGroupKhatmSlot(
          inviteCode: latest.inviteCode,
          slotId: latest.slotId,
          unitType: latest.unitType,
          unitNumber: latest.unitNumber,
          targetQuantity: latest.targetQuantity,
        );
        final ok = await _completeOnServer(slot);
        if (ok && mounted) {
          await _persist(latest.copyWith(
            pendingServerSync: false,
            updatedAt: DateTime.now(),
          ));
        }
      });
    }
  }

  /// Updates local Hive progress immediately when user manually marks a slot completed.
  Future<void> markCompletedLocally({
    required String inviteCode,
    required GroupKhatmSlot slot,
    required GroupKhatmCampaign campaign,
    required bool syncedWithServer,
  }) {
    final key = GroupKhatmSlotProgress.buildStorageKey(inviteCode, slot.id);
    return _serialized(key, () async {
      if (!mounted) return;
      final qty = slot.quantity < 1 ? 1 : slot.quantity;
      final unitNumber = slot.unitNumber ?? campaign.targetSurah ?? 1;
      final range = KhatmProgressCalculator.resolveGlobalAyahRange(
        unitType: _toKhatmUnitType(campaign.unitTypeEnum),
        fromUnit: unitNumber,
        toUnit: unitNumber,
      );
      final existing = progressFor(inviteCode, slot.id);
      final updated = (existing ??
              GroupKhatmSlotProgress(
                inviteCode: inviteCode,
                slotId: slot.id,
                unitType: campaign.unitTypeEnum,
                unitNumber: unitNumber,
                targetQuantity: qty,
                updatedAt: DateTime.now(),
              ))
          .copyWith(
        completedRepetitions: qty,
        currentPassProgress: 1.0,
        coveredSpans: [
          KhatmAyahSpan(start: range.startGlobal, end: range.endGlobal),
        ],
        awaitingNextPass: false,
        isCompletedLocally: true,
        pendingServerSync: !syncedWithServer,
        updatedAt: DateTime.now(),
      );
      await _persist(updated);
    });
  }

  /// Clears stored local progress when a slot is voluntarily released.
  Future<void> clearSlotProgress(String inviteCode, int slotId) {
    final key = GroupKhatmSlotProgress.buildStorageKey(inviteCode, slotId);
    return _serialized(key, () async {
      _awaitingPassResetKeys.remove(key);
      if (mounted) {
        final next = Map<String, GroupKhatmSlotProgress>.from(state)
          ..remove(key);
        state = next;
      }
      await _localDataSource.deleteProgress(inviteCode, slotId);
    });
  }

  Future<void> _persist(GroupKhatmSlotProgress progress) async {
    if (!mounted) return;
    final next = Map<String, GroupKhatmSlotProgress>.from(state);
    next[progress.storageKey] = progress;
    state = next;
    await _localDataSource.saveProgress(progress);
  }

  Future<bool> _completeOnServer(ActiveGroupKhatmSlot activeSlot) async {
    final sub = _ref.listen(
      groupKhatmDetailControllerProvider(activeSlot.inviteCode),
      (_, _) {},
    );
    try {
      final notifier = _ref.read(
        groupKhatmDetailControllerProvider(activeSlot.inviteCode).notifier,
      );
      return await notifier.completeSlot(
        slotId: activeSlot.slotId,
        unitNumber: activeSlot.unitType == GroupKhatmUnitType.surah
            ? null
            : activeSlot.unitNumber,
      );
    } catch (e) {
      debugPrint('⚠️ [GroupKhatmReading] Server sync deferred (offline): $e');
      return false;
    } finally {
      sub.close();
    }
  }

  static KhatmUnitType _toKhatmUnitType(GroupKhatmUnitType type) {
    switch (type) {
      case GroupKhatmUnitType.juz:
        return KhatmUnitType.juz;
      case GroupKhatmUnitType.hizb:
        return KhatmUnitType.hizb;
      case GroupKhatmUnitType.surah:
        return KhatmUnitType.surah;
    }
  }
}

final groupKhatmReadingControllerProvider = StateNotifierProvider<
    GroupKhatmReadingController, Map<String, GroupKhatmSlotProgress>>((ref) {
  final localDataSource = ref.read(groupKhatmProgressLocalDataSourceProvider);
  return GroupKhatmReadingController(localDataSource, ref);
});
