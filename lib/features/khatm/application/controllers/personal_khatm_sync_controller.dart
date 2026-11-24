import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quran/core/data/local/preferences/preferences_service_provider.dart';
import 'package:quran/features/khatm/domain/entities/khatm_plan.dart';
import 'package:quran/features/tafakor/application/controllers/tafakor_auth_controller.dart';
import '../../domain/repositories/i_khatm_repository.dart';
import '../../infrastructure/datasources/khatm_local_datasource.dart';
import '../../infrastructure/repositories/khatm_repository_impl.dart';

class PersonalKhatmSyncState {
  final bool isSyncing;
  final DateTime? lastSyncedAt;
  final String? syncError;

  const PersonalKhatmSyncState({
    this.isSyncing = false,
    this.lastSyncedAt,
    this.syncError,
  });

  PersonalKhatmSyncState copyWith({
    bool? isSyncing,
    DateTime? lastSyncedAt,
    bool clearLastSyncedAt = false,
    String? syncError,
    bool clearError = false,
  }) {
    return PersonalKhatmSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedAt:
          clearLastSyncedAt ? null : (lastSyncedAt ?? this.lastSyncedAt),
      syncError: clearError ? null : (syncError ?? this.syncError),
    );
  }
}

final personalKhatmSyncControllerProvider =
    StateNotifierProvider<PersonalKhatmSyncController, PersonalKhatmSyncState>((
      ref,
    ) {
      final repository = ref.watch(khatmRepositoryProvider);
      final localDataSource = ref.watch(khatmLocalDataSourceProvider);
      SharedPreferences? prefs;
      try {
        prefs = ref.watch(sharedPreferencesInstanceProvider);
      } catch (_) {
        prefs = null;
      }

      final controller = PersonalKhatmSyncController(
        repository,
        localDataSource,
        prefs,
      );

      // Auto-sync on authentication and clear persisted sync state on logout
      try {
        ref.listen<bool>(isTafakorAuthenticatedProvider, (
          previous,
          isAuthenticated,
        ) {
          if (isAuthenticated) {
            debugPrint(
              '🔄 [PersonalKhatmSync] User authenticated! Running background auto-sync...',
            );
            controller.syncWithBackend();
          } else if (previous == true && !isAuthenticated) {
            debugPrint(
              '🧹 [PersonalKhatmSync] User logged out! Clearing sync metadata...',
            );
            controller.clearSyncState();
          }
        }, fireImmediately: true);
      } catch (e) {
        debugPrint(
          '⚠️ [PersonalKhatmSync] Auth listener skipped (likely test scope): $e',
        );
      }

      return controller;
    });

class PersonalKhatmSyncController
    extends StateNotifier<PersonalKhatmSyncState> {
  static const String lastSyncedAtPrefKey = 'personal_khatm_last_synced_at';
  static const Duration syncDebounceDuration = Duration(seconds: 4);

  final IKhatmRepository _repository;
  final IKhatmLocalDataSource _localDataSource;
  final SharedPreferences? _prefs;

  Timer? _debounceTimer;
  bool _pendingSync = false;

  PersonalKhatmSyncController(
    this._repository,
    this._localDataSource, [
    this._prefs,
  ]) : super(_initialState(_prefs));

  static PersonalKhatmSyncState _initialState(SharedPreferences? prefs) {
    final raw = prefs?.getString(lastSyncedAtPrefKey);
    final parsed = raw != null ? DateTime.tryParse(raw)?.toUtc() : null;
    return PersonalKhatmSyncState(lastSyncedAt: parsed);
  }

  /// Schedules a debounced background sync (4 seconds) for frequent edits
  /// such as continuous reading progress tracking.
  void scheduleSync() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(syncDebounceDuration, () {
      if (mounted) {
        syncWithBackend();
      }
    });
  }

  /// Clears persisted `lastSyncedAt` and resets sync state (e.g. on logout).
  Future<void> clearSyncState() async {
    _debounceTimer?.cancel();
    _pendingSync = false;
    await _prefs?.remove(lastSyncedAtPrefKey);
    if (mounted) {
      state = state.copyWith(
        isSyncing: false,
        clearLastSyncedAt: true,
        clearError: true,
      );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Two-way sync between offline Hive plans and Django backend.
  Future<bool> syncWithBackend() async {
    _debounceTimer?.cancel();
    if (state.isSyncing) {
      _pendingSync = true;
      return false;
    }

    state = state.copyWith(isSyncing: true, clearError: true);

    try {
      final allPlans = await _localDataSource.getAllPlans();
      final isInitialSync = state.lastSyncedAt == null;
      final plansToSend = isInitialSync
          ? allPlans
          : allPlans.where((p) => p.isDirty).toList();
      final plansPayload = plansToSend.map((p) => p.toServerMap()).toList();

      final result = await _repository.syncPersonalPlans(
        plans: plansPayload,
        lastSyncedAt: state.lastSyncedAt?.toUtc().toIso8601String(),
      );

      final success = await result.when(
        (data) async {
          debugPrint('✅ [PersonalKhatmSync] Synced successfully');

          // 1. Mark uploaded dirty plans as clean if not modified again mid-flight
          for (final sentPlan in plansToSend) {
            try {
              final currentLocal = await _localDataSource.getPlan(sentPlan.id);
              if (currentLocal != null &&
                  !currentLocal.clientUpdatedAt.isAfter(
                    sentPlan.clientUpdatedAt,
                  )) {
                if (currentLocal.deletedAt != null) {
                  await _localDataSource.hardDeletePlan(sentPlan.id);
                } else if (currentLocal.isDirty) {
                  await _localDataSource.savePlan(
                    currentLocal.copyWith(isDirty: false),
                  );
                }
              }
            } catch (e) {
              debugPrint(
                '⚠️ [PersonalKhatmSync] Error finalizing sent plan ${sentPlan.id}: $e',
              );
            }
          }

          // 2. Apply server delta with timestamp-based two-way LWW merge
          if (data['plans'] is List) {
            final serverPlans = data['plans'] as List;
            for (final raw in serverPlans) {
              if (raw is! Map) continue;
              try {
                final serverPlan = KhatmPlan.fromServerMap(
                  Map<String, dynamic>.from(raw),
                );
                if (serverPlan.id.isEmpty) continue;

                final local = await _localDataSource.getPlan(serverPlan.id);

                if (serverPlan.deletedAt != null) {
                  if (local != null &&
                      !local.clientUpdatedAt.isAfter(
                        serverPlan.clientUpdatedAt,
                      )) {
                    await _localDataSource.hardDeletePlan(serverPlan.id);
                    debugPrint(
                      '🗑️ [PersonalKhatmSync] Removed soft-deleted cloud plan: ${serverPlan.title}',
                    );
                  }
                } else if (local == null) {
                  await _localDataSource.savePlan(
                    serverPlan.copyWith(isDirty: false),
                  );
                  debugPrint(
                    '📥 [PersonalKhatmSync] Imported cloud plan: ${serverPlan.title}',
                  );
                } else if (!serverPlan.clientUpdatedAt.isBefore(
                  local.clientUpdatedAt,
                )) {
                  await _localDataSource.savePlan(
                    serverPlan.copyWith(isDirty: false),
                  );
                  debugPrint(
                    '🔁 [PersonalKhatmSync] Updated local plan from cloud: ${serverPlan.title}',
                  );
                }
              } catch (e) {
                debugPrint(
                  '⚠️ [PersonalKhatmSync] Error merging server plan: $e',
                );
              }
            }
          }

          // 3. Persist server_time monotonically as lastSyncedAt
          final rawServerTime = data['server_time']?.toString();
          final parsedServerTime = rawServerTime != null
              ? DateTime.tryParse(rawServerTime)?.toUtc()
              : null;
          final syncedAt = parsedServerTime ?? state.lastSyncedAt;

          if (syncedAt != null) {
            await _prefs?.setString(
              lastSyncedAtPrefKey,
              syncedAt.toUtc().toIso8601String(),
            );
          }

          if (mounted) {
            state = state.copyWith(
              isSyncing: false,
              lastSyncedAt: syncedAt,
            );
          }
          return true;
        },
        (failure) async {
          debugPrint('⚠️ [PersonalKhatmSync] Sync error: ${failure.message}');
          if (mounted) {
            state = state.copyWith(
              isSyncing: false,
              syncError: failure.message,
            );
          }
          return false;
        },
      );
      return success;
    } catch (e) {
      debugPrint('⚠️ [PersonalKhatmSync] Exception during sync: $e');
      if (mounted) {
        state = state.copyWith(isSyncing: false, syncError: e.toString());
      }
      return false;
    } finally {
      final shouldFollowUp = _pendingSync;
      _pendingSync = false;
      if (shouldFollowUp && mounted) {
        Future.microtask(() {
          if (mounted) {
            syncWithBackend();
          }
        });
      }
    }
  }
}
