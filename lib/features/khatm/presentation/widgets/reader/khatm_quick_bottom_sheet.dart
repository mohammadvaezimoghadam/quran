import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/widgets/app_modal_header.dart';
import 'package:quran/core/routes/route_name.dart';
import 'package:quran/core/services/quran_navigation/domain/entities/ayah_target.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/khatm/application/controllers/khatm_detail_controller.dart';
import 'package:quran/features/khatm/application/controllers/khatm_list_controller.dart';
import 'package:quran/features/khatm/domain/entities/khatm_plan.dart';
import 'package:quran/features/khatm/domain/services/khatm_quran_resolver.dart';

/// Result returned when a user taps a Khatm plan inside the bottom sheet.
class KhatmJumpResult {
  final AyahTarget? target;
  final String khatmId;
  final int sessionIndex;
  final bool shouldJump;

  const KhatmJumpResult({
    this.target,
    required this.khatmId,
    required this.sessionIndex,
    this.shouldJump = true,
  });
}

/// Quick Bottom Sheet to inspect and switch active Khatm plan from inside Quran Reader.
class KhatmQuickBottomSheet extends ConsumerWidget {
  final String? activeKhatmId;
  final int? currentSurahId;
  final int? currentAyahNumber;
  final int? currentPage;

  const KhatmQuickBottomSheet({
    super.key,
    this.activeKhatmId,
    this.currentSurahId,
    this.currentAyahNumber,
    this.currentPage,
  });

  static Future<KhatmJumpResult?> show(
    BuildContext context, {
    String? activeKhatmId,
    int? currentSurahId,
    int? currentAyahNumber,
    int? currentPage,
  }) {
    return showModalBottomSheet<KhatmJumpResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KhatmQuickBottomSheet(
        activeKhatmId: activeKhatmId,
        currentSurahId: currentSurahId,
        currentAyahNumber: currentAyahNumber,
        currentPage: currentPage,
      ),
    );
  }

  void _onSelectPlan(BuildContext context, KhatmPlan plan) {
    HapticFeedback.lightImpact();

    // Find the next incomplete session or default to the first session
    final nextSession = plan.sessions.firstWhere(
      (s) => !s.isCompleted,
      orElse: () => plan.sessions.first,
    );

    // Check if user's current reading position is already inside this session
    bool isCurrentInSession = false;
    if (currentSurahId != null && currentAyahNumber != null) {
      isCurrentInSession = KhatmDetailController.isPositionInSession(
        plan: plan,
        session: nextSession,
        surahId: currentSurahId!,
        ayahNumber: currentAyahNumber!,
        page: currentPage,
      );
    }

    if (isCurrentInSession) {
      // User is already reading inside this session: do not jump backwards!
      final jumpResult = KhatmJumpResult(
        target: null,
        khatmId: plan.id,
        sessionIndex: nextSession.sessionIndex,
        shouldJump: false,
      );
      Navigator.of(context).pop(jumpResult);
      return;
    }

    // Otherwise, resume from lastReadUnit if available and within session range, or fromUnit
    final int resumeUnit = (nextSession.lastReadUnit != null &&
            nextSession.lastReadUnit! >= nextSession.fromUnit &&
            nextSession.lastReadUnit! <= nextSession.toUnit)
        ? nextSession.lastReadUnit!
        : nextSession.fromUnit;

    // Resolve target surah and ayah for the session unit
    final resolvedTarget = KhatmQuranResolver.resolveUnit(
      unitType: plan.unitType,
      unitNumber: resumeUnit,
    );

    final jumpResult = KhatmJumpResult(
      target: AyahTarget(
        surahId: resolvedTarget.surahId,
        ayahNumber: resolvedTarget.ayahNumber,
      ),
      khatmId: plan.id,
      sessionIndex: nextSession.sessionIndex,
      shouldJump: true,
    );

    Navigator.of(context).pop(jumpResult);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final state = ref.watch(khatmListControllerProvider);
    final plans = state.plans;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          18,
          12,
          18,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppModalHeader(
              title: 'برنامه ختم قرآن',
              showDragHandle: true,
              leadingAction: IconButton(
                tooltip: 'ایجاد ختم جدید',
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  CupertinoIcons.plus,
                  size: 22,
                  color: colorScheme.primary,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                  context.pushNamed(createKhatmWizardRoute).then((_) {
                    ref.read(khatmListControllerProvider.notifier).loadPlans();
                  });
                },
              ),
              onClose: () => Navigator.of(context).pop(),
              bottomSpacing: 10.0,
            ),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (plans.isEmpty)
              _buildEmptyState(context, colorScheme)
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: plans.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    final isActive = plan.id == activeKhatmId;
                    return _buildPlanCard(
                      context: context,
                      plan: plan,
                      isActive: isActive,
                      colors: colors,
                      colorScheme: colorScheme,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'هنوز برنامه ختمی ایجاد نکرده‌اید',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'می‌توانید برای جزء، حزب، سوره یا صفحه ختم شخصی تعریف کنید.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.5,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pushNamed(createKhatmWizardRoute);
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
            child: Text(
              'ایجاد ختم جدید',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required KhatmPlan plan,
    required bool isActive,
    required dynamic colors,
    required ColorScheme colorScheme,
  }) {
    final nextSession = plan.nextPendingSession ??
        (plan.sessions.isNotEmpty ? plan.sessions.first : null);
    final isAllCompleted = plan.isCompleted;

    return InkWell(
      onTap: () => _onSelectPlan(context, plan),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primary.withValues(alpha: 0.08)
              : colors.cardBackgroundSubtle,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isAllCompleted
                        ? colorScheme.primary
                        : colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isAllCompleted
                        ? 'تکمیل شد'
                        : '${plan.progressPercentInt.toPersianDigit()}٪',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isAllCompleted
                          ? Colors.white
                          : colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isAllCompleted || nextSession == null
                  ? 'تمام ${plan.sessionCount.toPersianDigit()} جلسه این ختم تلاوت شد.'
                  : 'جلسه ${(nextSession.sessionIndex + 1).toPersianDigit()} از ${plan.sessionCount.toPersianDigit()} (${nextSession.computeTitle(plan.unitType)})',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: plan.progressPercentage,
                minHeight: 4,
                backgroundColor: colors.cardBorder.withValues(alpha: 0.4),
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
