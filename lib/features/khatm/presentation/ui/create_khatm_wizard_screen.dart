import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/widgets/app_snackbar.dart';
import 'package:quran/core/routes/route_name.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/khatm/application/controllers/khatm_wizard_controller.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';
import '../widgets/wizard/khatm_cadence_selector.dart';
import '../widgets/wizard/khatm_confirmation_card.dart';
import '../widgets/wizard/khatm_jalali_date_picker.dart';
import '../widgets/wizard/khatm_live_preview_card.dart';
import '../widgets/wizard/khatm_planning_mode_radio.dart';
import '../widgets/wizard/khatm_range_input.dart';
import '../widgets/wizard/khatm_session_count_input.dart';
import '../widgets/wizard/khatm_step_indicator.dart';
import '../widgets/wizard/khatm_title_input.dart';
import '../widgets/wizard/khatm_unit_type_selector.dart';
import '../widgets/wizard/khatm_weekday_selector.dart';
import '../widgets/wizard/khatm_wizard_navigation_buttons.dart';

/// Screen orchestrator for the 3-Step Khatm Creation Wizard («ایجاد ختم شخصی»).
/// Refactored to match the app's minimal Apple design system.
class CreateKhatmWizardScreen extends ConsumerWidget {
  const CreateKhatmWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final state = ref.watch(khatmWizardControllerProvider);
    final controller = ref.read(khatmWizardControllerProvider.notifier);

    // Listen for error messages to show AppSnackBar
    ref.listen<KhatmWizardState>(khatmWizardControllerProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        AppSnackBar.showError(context, next.errorMessage!);
      }
    });

    return PopScope(
      canPop: state.currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && state.currentStep > 0) {
          controller.previousStep();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(
          'ایجاد ختم شخصی',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colors.cardBackground,
        leading: IconButton(
          tooltip: 'بازگشت',
          icon: Icon(
            CupertinoIcons.chevron_forward,
            size: 24,
            color: colorScheme.onSurface,
          ),
          splashRadius: 22,
          onPressed: () {
            HapticFeedback.lightImpact();
            if (state.currentStep > 0) {
              controller.previousStep();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.pop();
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.8),
          child: Container(
            color: colors.cardBorder,
            height: 0.8,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. Stepper Indicator (Zero Icons) ──────────────────────────
            KhatmStepIndicator(currentStep: state.currentStep),

            // ── 2. Step Body Content ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildCurrentStep(context, state, controller),
                ),
              ),
            ),

            // ── 3. Bottom Navigation Buttons ───────────────────────────────
            KhatmWizardNavigationButtons(
              isLoading: state.isSubmitting,
              isNextEnabled: state.currentStep == 0
                  ? state.canProceedStep1
                  : (state.currentStep == 1
                      ? state.canProceedStep2
                      : true),
              isBackVisible: state.currentStep > 0,
              nextLabel: state.currentStep == 2 ? 'تایید و ایجاد ختم' : 'ادامه',
              onNext: () async {
                if (state.currentStep < 2) {
                  controller.nextStep();
                } else {
                  final createdPlan = await controller.createKhatm();
                  if (createdPlan != null && context.mounted) {
                    AppSnackBar.showSuccess(context, 'برنامه ختم ایجاد شد');
                    context.pushReplacementNamed(
                      khatmDetailRoute,
                      pathParameters: {'id': createdPlan.id},
                    );
                  }
                }
              },
              onBack: () => controller.previousStep(),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildCurrentStep(
    BuildContext context,
    KhatmWizardState state,
    KhatmWizardController controller,
  ) {
    switch (state.currentStep) {
      case 0:
        return _buildStep1(context, state, controller);
      case 1:
        return _buildStep2(context, state, controller);
      case 2:
        return _buildStep3(context, state, controller);
      default:
        return const SizedBox.shrink();
    }
  }

  /// گام ۱: اطلاعات ختم
  Widget _buildStep1(
    BuildContext context,
    KhatmWizardState state,
    KhatmWizardController controller,
  ) {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KhatmTitleInput(
          value: state.title,
          onChanged: controller.setTitle,
        ),
        const SizedBox(height: 18),
        KhatmUnitTypeSelector(
          selected: state.unitType,
          onChanged: controller.setUnitType,
        ),
        const SizedBox(height: 18),
        KhatmRangeInput(
          fromValue: state.rangeFrom,
          toValue: state.rangeTo,
          maxValue: state.unitType.maxUnits,
          unitLabel: state.unitType.labelFa,
          onRangeChanged: (from, to) => controller.setRange(from, to),
        ),
      ],
    );
  }

  /// گام ۲: برنامه‌ریزی ختم
  Widget _buildStep2(
    BuildContext context,
    KhatmWizardState state,
    KhatmWizardController controller,
  ) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KhatmPlanningModeRadio(
          selected: state.planningMode,
          unitLabel: state.unitType.labelFa,
          onChanged: controller.setPlanningMode,
        ),
        const SizedBox(height: 16),
        KhatmSessionCountInput(
          value: state.planningMode == KhatmPlanningMode.bySessionCount
              ? state.sessionCountInput
              : state.quotaInput,
          label: state.planningMode == KhatmPlanningMode.bySessionCount
              ? 'تعداد جلسات'
              : 'تعداد ${state.unitType.labelFa} در هر جلسه',
          max: state.totalUnits,
          onChanged: (val) {
            if (state.planningMode == KhatmPlanningMode.bySessionCount) {
              controller.setSessionCountInput(val);
            } else {
              controller.setQuotaInput(val);
            }
          },
        ),
        const SizedBox(height: 16),
        KhatmCadenceSelector(
          selected: state.cadence,
          onChanged: controller.setCadence,
        ),
        if (state.cadence == KhatmCadence.customWeekdays) ...[
          const SizedBox(height: 16),
          KhatmWeekdaySelector(
            selectedWeekdays: state.selectedWeekdays,
            onToggle: controller.toggleWeekday,
          ),
        ],
        const SizedBox(height: 16),
        KhatmJalaliDatePicker(
          selectedDate: state.startDate,
          onDateChanged: controller.setStartDate,
        ),
        // ── یادآور روزانه (فعلاً کامنت شده) ──
        // Container(
        //   decoration: BoxDecoration(
        //     color: colors.cardBackgroundSubtle,
        //     borderRadius: BorderRadius.circular(14),
        //   ),
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Text(
        //         'یادآور روزانه',
        //         style: TextStyle(
        //           fontFamily: AppTypography.fontFamily,
        //           fontSize: 13.5,
        //           fontWeight: FontWeight.w500,
        //           color: colorScheme.onSurface,
        //         ),
        //       ),
        //       Switch.adaptive(
        //         value: state.isReminderEnabled,
        //         activeTrackColor: colorScheme.primary,
        //         onChanged: controller.toggleReminder,
        //       ),
        //     ],
        //   ),
        // ),
        // const SizedBox(height: 16),
        const SizedBox(height: 16),
        KhatmLivePreviewCard(
          previewText: state.livePreviewText,
        ),
      ],
    );
  }

  /// گام ۳: تایید نهایی
  Widget _buildStep3(
    BuildContext context,
    KhatmWizardState state,
    KhatmWizardController controller,
  ) {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KhatmConfirmationCard(
          title: state.title.trim(),
          unitType: state.unitType,
          rangeFrom: state.rangeFrom,
          rangeTo: state.rangeTo,
          sessionCount: state.calculatedSessionCount,
          quotaPerSession: state.estimatedQuotaPerSession,
          cadence: state.cadence,
          startDateFa: state.startDate.formatFa(),
          endDateFa: state.calculatedEndDate.formatFa(),
        ),
      ],
    );
  }
}
