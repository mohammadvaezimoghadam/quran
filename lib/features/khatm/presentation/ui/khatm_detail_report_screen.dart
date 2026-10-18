import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/widgets/app_snackbar.dart';
import 'package:quran/core/routes/route_name.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/khatm/application/controllers/khatm_detail_controller.dart';
import 'package:quran/features/khatm/application/controllers/khatm_list_controller.dart';
import 'package:quran/features/khatm/domain/services/khatm_quran_resolver.dart';
import '../widgets/report/khatm_continue_button.dart';
import '../widgets/report/khatm_date_range_card.dart';
import '../widgets/report/khatm_progress_donut_chart.dart';
import '../widgets/report/khatm_session_timeline.dart';
import '../widgets/report/khatm_session_timeline_header.dart';

/// Screen presenting the detailed Khatm Report & Sessions Timeline
/// styled cleanly to match the app's minimal Apple design system without decorative icons.
class KhatmDetailReportScreen extends ConsumerWidget {
  final String planId;

  const KhatmDetailReportScreen({
    super.key,
    required this.planId,
  });

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    final colors = context.colors;
    final isDark = context.isDark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          'حذف ختم',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: Theme.of(ctx).colorScheme.onSurface,
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            'آیا از حذف این برنامه ختم اطمینان دارید؟',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'انصراف',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13.5,
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? Colors.white12 : Colors.black87,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'حذف',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(khatmDetailControllerProvider(planId).notifier)
          .deletePlan();
      if (success && context.mounted) {
        AppSnackBar.showSuccess(context, 'برنامه ختم حذف شد.');
        context.pop();
      }
    }
  }

  void _onContinueKhatm(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    final state = ref.read(khatmDetailControllerProvider(planId));
    final plan = state.plan;
    if (plan == null) return;

    final nextSession = plan.nextPendingSession;
    if (nextSession == null) {
      AppSnackBar.showInfo(context, 'تمام جلسات این ختم به پایان رسیده است.');
      return;
    }

    final unitToNavigate = (nextSession.lastReadUnit != null &&
            nextSession.lastReadUnit! >= nextSession.fromUnit &&
            nextSession.lastReadUnit! <= nextSession.toUnit)
        ? nextSession.lastReadUnit!
        : nextSession.fromUnit;

    final target = KhatmQuranResolver.resolveUnit(
      unitType: plan.unitType,
      unitNumber: unitToNavigate,
    );

    context.pushNamed(
      quranReaderRoute,
      pathParameters: {'id': target.surahId.toString()},
      queryParameters: {
        'ayah': target.ayahNumber.toString(),
        'khatmId': plan.id,
        'khatmSession': nextSession.sessionIndex.toString(),
      },
    ).then((_) {
      ref.read(khatmDetailControllerProvider(planId).notifier).loadPlan();
      ref.read(khatmListControllerProvider.notifier).loadPlans();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    final state = ref.watch(khatmDetailControllerProvider(planId));
    final controller =
        ref.read(khatmDetailControllerProvider(planId).notifier);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final plan = state.plan;
    if (plan == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'گزارش ختم',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.bold,
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
              if (Navigator.of(context).canPop()) {
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
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage ?? 'ختم یافت نشد',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'بازگشت',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'گزارش ختم',
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
            if (Navigator.of(context).canPop()) {
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
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextButton(
              onPressed: () => _confirmDelete(context, ref),
              child: Text(
                'حذف',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: themeErrorColor(context),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Card 1: Donut Progress Chart ───────────────────────
                    KhatmProgressDonutChart(
                      title: plan.title,
                      totalUnits: plan.totalUnits,
                      completedUnits: plan.completedUnits,
                      unitLabel: plan.unitLabel,
                    ),
                    const SizedBox(height: 12),

                    // ── Card 2: Date Range (Zero icons) ────────────────────
                    KhatmDateRangeCard(
                      startDateFa: plan.startDateFa,
                      endDateFa: plan.endDateFa,
                    ),
                    const SizedBox(height: 22),

                    // ── Section Title: گزارش تلاوت براساس تاریخ ────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'گزارش تلاوت براساس تاریخ',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF5A554E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Table Column Headers & Divider ─────────────────────
                    const KhatmSessionTimelineHeader(),
                    Container(
                      height: 0.8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: colors.cardBorder,
                    ),

                    // ── Timeline Sessions List ─────────────────────────────
                    KhatmSessionTimeline(
                      sessions: plan.sessions,
                      unitType: plan.unitType,
                      onSessionToggle: (sessionIndex, isCompleted) {
                        controller.toggleSession(sessionIndex, isCompleted);
                      },
                      onSessionTap: (sessionIndex) {
                        final session = plan.sessions[sessionIndex];
                        final unitToNavigate = (!session.isCompleted &&
                                session.lastReadUnit != null &&
                                session.lastReadUnit! >= session.fromUnit &&
                                session.lastReadUnit! <= session.toUnit)
                            ? session.lastReadUnit!
                            : session.fromUnit;
                        final target = KhatmQuranResolver.resolveUnit(
                          unitType: plan.unitType,
                          unitNumber: unitToNavigate,
                        );
                        context.pushNamed(
                          quranReaderRoute,
                          pathParameters: {'id': target.surahId.toString()},
                          queryParameters: {
                            'ayah': target.ayahNumber.toString(),
                            if (!session.isCompleted) ...{
                              'khatmId': plan.id,
                              'khatmSession': session.sessionIndex.toString(),
                            },
                          },
                        ).then((_) {
                          ref
                              .read(khatmDetailControllerProvider(planId).notifier)
                              .loadPlan();
                          ref
                              .read(khatmListControllerProvider.notifier)
                              .loadPlans();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Docked Bottom Continue Khatm Button ────────────────────────
            KhatmContinueButton(
              isEnabled: !plan.isCompleted,
              label: plan.isCompleted ? 'ختم تکمیل شده است' : 'ادامه ختم',
              onPressed: () => _onContinueKhatm(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Color themeErrorColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }
}
