import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:quran/core/data/local/hive/hive_service_provider.dart';
import 'package:quran/core/data/local/hive/i_hive_service.dart';
import 'package:quran/features/khatm/domain/entities/khatm_plan.dart';

abstract class IKhatmLocalDataSource {
  Future<void> savePlan(KhatmPlan plan);
  Future<void> deletePlan(String id);
  Future<KhatmPlan?> getPlan(String id);
  Future<List<KhatmPlan>> getAllPlans();
  Future<List<KhatmPlan>> getActivePlans();
  Future<void> updateSessionStatus({
    required String planId,
    required int sessionIndex,
    required bool isCompleted,
  });
  Future<void> updateSessionProgress({
    required String planId,
    required int sessionIndex,
    required double progress,
    int? lastReadUnit,
    bool? isCompleted,
  });
  Future<void> clearAll();
  void addListener(VoidCallback listener);
  void removeListener(VoidCallback listener);
}

class KhatmLocalDataSource implements IKhatmLocalDataSource {
  static const String boxName = 'khatm_plans_box';

  final IHiveService _hiveService;
  final List<VoidCallback> _listeners = [];

  KhatmLocalDataSource(this._hiveService);

  @override
  void addListener(VoidCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final l in List<VoidCallback>.from(_listeners)) {
      try {
        l();
      } catch (e) {
        debugPrint('⚠️ [KhatmLocalDataSource] Error in listener: $e');
      }
    }
  }

  Future<void> _ensureBoxOpen() async {
    if (!Hive.isBoxOpen(boxName)) {
      await _hiveService.openBox(boxName);
    }
  }

  @override
  Future<void> savePlan(KhatmPlan plan) async {
    try {
      await _ensureBoxOpen();
      await _hiveService.put(plan.id, plan.toMap(), boxName: boxName);
      _notifyListeners();
    } catch (e) {
      debugPrint('⚠️ [KhatmLocalDataSource] Error saving plan: $e');
    }
  }

  @override
  Future<void> deletePlan(String id) async {
    try {
      await _ensureBoxOpen();
      await _hiveService.delete(id, boxName: boxName);
      _notifyListeners();
    } catch (e) {
      debugPrint('⚠️ [KhatmLocalDataSource] Error deleting plan: $e');
    }
  }

  @override
  Future<KhatmPlan?> getPlan(String id) async {
    try {
      await _ensureBoxOpen();
      final val = _hiveService.get<dynamic>(id, boxName: boxName);
      if (val is Map) {
        return KhatmPlan.fromMap(val);
      }
    } catch (e) {
      debugPrint('⚠️ [KhatmLocalDataSource] Error getting plan $id: $e');
    }
    return null;
  }

  @override
  Future<List<KhatmPlan>> getAllPlans() async {
    try {
      await _ensureBoxOpen();
      final values = _hiveService.getValues(boxName: boxName);
      final plans = <KhatmPlan>[];

      for (final val in values) {
        if (val is Map) {
          try {
            final map = Map<dynamic, dynamic>.from(val);
            if (map['id'] != null) {
              plans.add(KhatmPlan.fromMap(map));
            }
          } catch (e) {
            debugPrint('⚠️ [KhatmLocalDataSource] Error parsing plan item: $e');
          }
        }
      }

      // Sort newest first
      plans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return plans;
    } catch (e) {
      debugPrint('⚠️ [KhatmLocalDataSource] Error loading all plans: $e');
      return [];
    }
  }

  @override
  Future<List<KhatmPlan>> getActivePlans() async {
    final all = await getAllPlans();
    return all.where((p) => !p.isArchived).toList();
  }

  @override
  Future<void> updateSessionStatus({
    required String planId,
    required int sessionIndex,
    required bool isCompleted,
  }) async {
    final plan = await getPlan(planId);
    if (plan == null) return;

    final updatedSessions = plan.sessions.map((session) {
      if (session.sessionIndex == sessionIndex) {
        return session.copyWith(
          isCompleted: isCompleted,
          completedAt: isCompleted ? DateTime.now() : null,
          progress: isCompleted ? 1.0 : 0.0,
          lastReadUnit: isCompleted ? session.toUnit : null,
        );
      }
      return session;
    }).toList();

    final updatedPlan = plan.copyWith(sessions: updatedSessions);
    await savePlan(updatedPlan);
  }

  @override
  Future<void> updateSessionProgress({
    required String planId,
    required int sessionIndex,
    required double progress,
    int? lastReadUnit,
    bool? isCompleted,
  }) async {
    final plan = await getPlan(planId);
    if (plan == null) return;

    final updatedSessions = plan.sessions.map((session) {
      if (session.sessionIndex == sessionIndex) {
        final completed = isCompleted ?? (progress >= 1.0 ? true : session.isCompleted);
        return session.copyWith(
          progress: progress.clamp(0.0, 1.0),
          lastReadUnit: lastReadUnit ?? session.lastReadUnit,
          isCompleted: completed,
          completedAt: completed ? (session.completedAt ?? DateTime.now()) : null,
        );
      }
      return session;
    }).toList();

    final updatedPlan = plan.copyWith(sessions: updatedSessions);
    await savePlan(updatedPlan);
  }

  @override
  Future<void> clearAll() async {
    try {
      await _ensureBoxOpen();
      await _hiveService.clear(boxName: boxName);
      _notifyListeners();
    } catch (e) {
      debugPrint('⚠️ [KhatmLocalDataSource] Error clearing box: $e');
    }
  }
}

final khatmLocalDataSourceProvider = Provider<IKhatmLocalDataSource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return KhatmLocalDataSource(hiveService);
});
