import 'package:flutter_riverpod/legacy.dart';

import 'package:quran/features/khatm/domain/entities/khatm_plan.dart';
import 'package:quran/features/khatm/infrastructure/datasources/khatm_local_datasource.dart';

class KhatmListState {
  final List<KhatmPlan> plans;
  final bool isLoading;
  final String? errorMessage;

  const KhatmListState({
    this.plans = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  KhatmListState copyWith({
    List<KhatmPlan>? plans,
    bool? isLoading,
    String? errorMessage,
  }) {
    return KhatmListState(
      plans: plans ?? this.plans,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class KhatmListController extends StateNotifier<KhatmListState> {
  final IKhatmLocalDataSource _localDataSource;

  KhatmListController(this._localDataSource) : super(const KhatmListState()) {
    _localDataSource.addListener(_onDataSourceChanged);
    loadPlans();
  }

  void _onDataSourceChanged() {
    loadPlans(silent: true);
  }

  @override
  void dispose() {
    _localDataSource.removeListener(_onDataSourceChanged);
    super.dispose();
  }

  /// Synchronous in-memory optimistic update to instantly update UI elements (Home card, list)
  void optimisticUpdateSession({
    required String planId,
    required int sessionIndex,
    required bool isCompleted,
  }) {
    final updatedPlans = state.plans.map((p) {
      if (p.id == planId) {
        final updatedSessions = p.sessions.map((s) {
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
        return p.copyWith(sessions: updatedSessions);
      }
      return p;
    }).toList();
    state = state.copyWith(plans: updatedPlans);
  }

  Future<void> loadPlans({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    try {
      final plans = await _localDataSource.getAllPlans();
      state = state.copyWith(plans: plans, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'خطا در بارگذاری برنامه‌های ختم: $e',
      );
    }
  }

  Future<void> deletePlan(String id) async {
    try {
      await _localDataSource.deletePlan(id);
      await loadPlans();
    } catch (e) {
      state = state.copyWith(errorMessage: 'خطا در حذف ختم: $e');
    }
  }

  Future<void> toggleSession({
    required String planId,
    required int sessionIndex,
    required bool isCompleted,
  }) async {
    optimisticUpdateSession(
      planId: planId,
      sessionIndex: sessionIndex,
      isCompleted: isCompleted,
    );
    try {
      await _localDataSource.updateSessionStatus(
        planId: planId,
        sessionIndex: sessionIndex,
        isCompleted: isCompleted,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'خطا در به‌روزرسانی جلسه: $e');
    }
  }
}

final khatmListControllerProvider =
    StateNotifierProvider<KhatmListController, KhatmListState>(
  (ref) {
    final localDataSource = ref.read(khatmLocalDataSourceProvider);
    return KhatmListController(localDataSource);
  },
);
