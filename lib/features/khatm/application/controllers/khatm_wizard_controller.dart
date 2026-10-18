import 'dart:math';

import 'package:flutter_riverpod/legacy.dart';

import 'package:quran/common/utils/jalali_date.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';
import 'package:quran/features/khatm/domain/entities/khatm_plan.dart';
import 'package:quran/features/khatm/domain/entities/khatm_session_item.dart';
import 'package:quran/features/khatm/domain/services/khatm_date_engine.dart';
import 'package:quran/features/khatm/domain/services/khatm_slicing_engine.dart';
import 'package:quran/features/khatm/infrastructure/datasources/khatm_local_datasource.dart';

/// Immutable state holding the creation wizard form inputs and calculations.
class KhatmWizardState {
  final int currentStep; // 0, 1, 2
  final String title;
  final KhatmUnitType unitType;
  final int rangeFrom;
  final int rangeTo;
  final KhatmPlanningMode planningMode;
  final int sessionCountInput;
  final int quotaInput;
  final KhatmCadence cadence;
  final List<int> selectedWeekdays;
  final JalaliDate startDate;
  final bool isReminderEnabled;
  final bool isSubmitting;
  final String? errorMessage;

  const KhatmWizardState({
    this.currentStep = 0,
    this.title = '',
    this.unitType = KhatmUnitType.page,
    this.rangeFrom = 1,
    this.rangeTo = 604,
    this.planningMode = KhatmPlanningMode.bySessionCount,
    this.sessionCountInput = 5,
    this.quotaInput = 10,
    this.cadence = KhatmCadence.daily,
    this.selectedWeekdays = const [6, 1, 3], // Saturday, Monday, Wednesday
    required this.startDate,
    this.isReminderEnabled = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  factory KhatmWizardState.initial() {
    return KhatmWizardState(
      startDate: JalaliDate.now(),
    );
  }

  // ── Derived Properties ───────────────────────────────────────────────────

  int get totalUnits => max(1, rangeTo - rangeFrom + 1);

  /// Resolved count of total sessions based on selected mode.
  int get calculatedSessionCount {
    if (planningMode == KhatmPlanningMode.bySessionCount) {
      return sessionCountInput.clamp(1, totalUnits);
    } else {
      final quota = quotaInput.clamp(1, totalUnits);
      return (totalUnits / quota).ceil();
    }
  }

  /// Estimated or exact quota per session.
  int get estimatedQuotaPerSession {
    if (planningMode == KhatmPlanningMode.byUnitQuota) {
      return quotaInput.clamp(1, totalUnits);
    } else {
      final sessions = sessionCountInput.clamp(1, totalUnits);
      return (totalUnits / sessions).ceil();
    }
  }

  /// Live preview string for step 2 banner: «تعداد صفحه در هر جلسه = X»
  String get livePreviewText {
    final quota = estimatedQuotaPerSession;
    return 'تعداد ${unitType.labelFa} در هر جلسه ≈ $quota';
  }

  /// Calculated ending date in Jalali.
  JalaliDate get calculatedEndDate {
    final startGregorian = startDate.toDateTime();
    final endGregorian = KhatmDateEngine.calculateEndDate(
      startDate: startGregorian,
      sessionCount: calculatedSessionCount,
      cadence: cadence,
      selectedWeekdays: selectedWeekdays,
    );
    return JalaliDate.fromDateTime(endGregorian);
  }

  bool get canProceedStep1 {
    return title.trim().isNotEmpty &&
        rangeFrom >= 1 &&
        rangeTo >= rangeFrom &&
        rangeTo <= unitType.maxUnits;
  }

  bool get canProceedStep2 {
    if (calculatedSessionCount <= 0) return false;
    if (cadence == KhatmCadence.customWeekdays && selectedWeekdays.isEmpty) {
      return false;
    }
    return true;
  }

  KhatmWizardState copyWith({
    int? currentStep,
    String? title,
    KhatmUnitType? unitType,
    int? rangeFrom,
    int? rangeTo,
    KhatmPlanningMode? planningMode,
    int? sessionCountInput,
    int? quotaInput,
    KhatmCadence? cadence,
    List<int>? selectedWeekdays,
    JalaliDate? startDate,
    bool? isReminderEnabled,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return KhatmWizardState(
      currentStep: currentStep ?? this.currentStep,
      title: title ?? this.title,
      unitType: unitType ?? this.unitType,
      rangeFrom: rangeFrom ?? this.rangeFrom,
      rangeTo: rangeTo ?? this.rangeTo,
      planningMode: planningMode ?? this.planningMode,
      sessionCountInput: sessionCountInput ?? this.sessionCountInput,
      quotaInput: quotaInput ?? this.quotaInput,
      cadence: cadence ?? this.cadence,
      selectedWeekdays: selectedWeekdays ?? this.selectedWeekdays,
      startDate: startDate ?? this.startDate,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

/// Controller managing state and logic for the 3-step Khatm wizard.
class KhatmWizardController extends StateNotifier<KhatmWizardState> {
  final IKhatmLocalDataSource _localDataSource;

  KhatmWizardController(this._localDataSource)
      : super(KhatmWizardState.initial());

  void setTitle(String value) {
    state = state.copyWith(title: value, errorMessage: null);
  }

  void setUnitType(KhatmUnitType type) {
    state = state.copyWith(
      unitType: type,
      rangeFrom: 1,
      rangeTo: type.maxUnits,
      errorMessage: null,
    );
  }

  void setRange(int from, int to) {
    state = state.copyWith(
      rangeFrom: from,
      rangeTo: to,
      errorMessage: null,
    );
  }

  void setPlanningMode(KhatmPlanningMode mode) {
    state = state.copyWith(planningMode: mode, errorMessage: null);
  }

  void setSessionCountInput(int count) {
    state = state.copyWith(sessionCountInput: count, errorMessage: null);
  }

  void setQuotaInput(int quota) {
    state = state.copyWith(quotaInput: quota, errorMessage: null);
  }

  void setCadence(KhatmCadence cadence) {
    state = state.copyWith(cadence: cadence, errorMessage: null);
  }

  void toggleWeekday(int weekday) {
    final list = List<int>.from(state.selectedWeekdays);
    if (list.contains(weekday)) {
      list.remove(weekday);
    } else {
      list.add(weekday);
      list.sort();
    }
    state = state.copyWith(selectedWeekdays: list, errorMessage: null);
  }

  void setStartDate(JalaliDate date) {
    state = state.copyWith(startDate: date, errorMessage: null);
  }

  void toggleReminder(bool value) {
    state = state.copyWith(isReminderEnabled: value);
  }

  bool nextStep() {
    if (state.currentStep == 0) {
      if (!state.canProceedStep1) {
        state = state.copyWith(
          errorMessage: 'لطفاً نام ختم و بازه معتبر را وارد کنید',
        );
        return false;
      }
      state = state.copyWith(currentStep: 1, errorMessage: null);
      return true;
    } else if (state.currentStep == 1) {
      if (!state.canProceedStep2) {
        state = state.copyWith(
          errorMessage: 'لطفاً برنامه‌ریزی جلسات را به طور صحیح تکمیل کنید',
        );
        return false;
      }
      state = state.copyWith(currentStep: 2, errorMessage: null);
      return true;
    }
    return false;
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        errorMessage: null,
      );
    }
  }

  /// Generates the [KhatmPlan], slices sessions, computes calendar dates,
  /// saves to Hive, and returns the created plan.
  Future<KhatmPlan?> createKhatm() async {
    if (state.isSubmitting) return null;
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final totalSessions = state.calculatedSessionCount;
      final startGregorian = state.startDate.toDateTime();

      // 1. Slicing
      final List<KhatmSliceRange> slices;
      if (state.planningMode == KhatmPlanningMode.bySessionCount) {
        slices = KhatmSlicingEngine.sliceBySessionCount(
          rangeFrom: state.rangeFrom,
          rangeTo: state.rangeTo,
          sessionCount: totalSessions,
        );
      } else {
        slices = KhatmSlicingEngine.sliceByUnitQuota(
          rangeFrom: state.rangeFrom,
          rangeTo: state.rangeTo,
          quotaPerSession: state.quotaInput,
        );
      }

      // 2. Dates
      final dates = KhatmDateEngine.generateSessionDates(
        startDate: startGregorian,
        sessionCount: slices.length,
        cadence: state.cadence,
        selectedWeekdays: state.selectedWeekdays,
      );

      // 3. Assemble session items
      final sessionItems = <KhatmSessionItem>[];
      for (int i = 0; i < slices.length; i++) {
        final sessionDate = i < dates.length ? dates[i] : startGregorian;
        sessionItems.add(
          KhatmSessionItem(
            sessionIndex: i,
            fromUnit: slices[i].fromUnit,
            toUnit: slices[i].toUnit,
            scheduledDate: sessionDate,
            isCompleted: false,
          ),
        );
      }

      final actualStartGregorian =
          dates.isNotEmpty ? dates.first : startGregorian;
      final endGregorian = dates.isNotEmpty ? dates.last : startGregorian;
      final planId =
          'khatm_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';

      final plan = KhatmPlan(
        id: planId,
        title: state.title.trim(),
        unitType: state.unitType,
        rangeFrom: state.rangeFrom,
        rangeTo: state.rangeTo,
        planningMode: state.planningMode,
        sessionCount: sessionItems.length,
        quotaPerSession: state.estimatedQuotaPerSession,
        cadence: state.cadence,
        selectedWeekdays: state.selectedWeekdays,
        startDateTime: actualStartGregorian,
        endDateTime: endGregorian,
        sessions: sessionItems,
        createdAt: DateTime.now(),
      );

      await _localDataSource.savePlan(plan);
      state = state.copyWith(isSubmitting: false);
      return plan;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'خطا در ثبت ختم: $e',
      );
      return null;
    }
  }
}

final khatmWizardControllerProvider =
    StateNotifierProvider.autoDispose<KhatmWizardController, KhatmWizardState>(
  (ref) {
    final localDataSource = ref.read(khatmLocalDataSourceProvider);
    return KhatmWizardController(localDataSource);
  },
);
