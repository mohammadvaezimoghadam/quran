import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/extensions/size_extension.dart';
import 'package:quran/common/widgets/app_snackbar.dart';
import 'package:quran/core/routes/route_name.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/khatm/application/controllers/khatm_list_controller.dart';
import 'package:quran/features/khatm/domain/entities/khatm_plan.dart';
import 'package:quran/features/khatm/domain/services/khatm_quran_resolver.dart';

/// Clean Apple-style unified card for Khatm plans, matching the exact styling
/// of the Quran app's study cards with circular progress indicator and quick-action menu.
class KhatmListCard extends ConsumerWidget {
  final KhatmPlan plan;
  final double? cardWidth;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const KhatmListCard({
    super.key,
    required this.plan,
    this.cardWidth,
    this.margin,
    this.onTap,
  });

  void _confirmDeletePlan(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final colors = context.colors;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
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
            color: Theme.of(dialogCtx).colorScheme.onSurface,
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
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'انصراف',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13.5,
                color: Theme.of(dialogCtx).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await ref
                  .read(khatmListControllerProvider.notifier)
                  .deletePlan(plan.id);
              if (context.mounted) {
                AppSnackBar.showSuccess(context, 'برنامه ختم حذف شد.');
              }
            },
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
  }

  void _navigateToSession(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    final nextSession = plan.nextPendingSession;
    if (nextSession == null) {
      // If completed, open report
      context.pushNamed(
        khatmDetailRoute,
        pathParameters: {'id': plan.id},
      ).then((_) {
        ref.read(khatmListControllerProvider.notifier).loadPlans();
      });
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
      ref.read(khatmListControllerProvider.notifier).loadPlans();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final nextSession = plan.nextPendingSession;

    return Container(
      width: cardWidth,
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ??
              () {
                HapticFeedback.lightImpact();
                context.pushNamed(
                  khatmDetailRoute,
                  pathParameters: {'id': plan.id},
                ).then((_) {
                  ref.read(khatmListControllerProvider.notifier).loadPlans();
                });
              },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: cardWidth != null
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.start,
              children: [
                // ── ۱. ردیف بالا: نشانگر پیشرفت دایره‌ای + عنوان و وضعیت متنی + منوی سه نقطه ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circular Progress Indicator (دقیقاً مشابه استایل قدیم)
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: plan.progressPercentage),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedProgress, child) {
                        final int animatedPercent =
                            (animatedProgress * 100).toInt();
                        return SizedBox(
                          width: 38,
                          height: 38,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 38,
                                height: 38,
                                child: CircularProgressIndicator(
                                  value: animatedProgress.clamp(0.0, 1.0),
                                  strokeWidth: 3.2,
                                  backgroundColor: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : colors.cardBorder,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.primary,
                                  ),
                                ),
                              ),
                              Text(
                                '${animatedPercent.toPersianDigit()}٪',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    12.hSpace,

                    // متن عنوان و جزئیات جلسه بعدی
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            plan.title,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          3.vSpace,
                          Text(
                            nextSession != null
                                ? 'جلسه ${(nextSession.sessionIndex + 1).toPersianDigit()} از ${plan.sessionCount.toPersianDigit()} • ${nextSession.computeTitle(plan.unitType)}'
                                : 'تمام جلسات ختم تکمیل شد',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // منوی سه نقطه برای عملیات سریع (بدون آیکون، متن ساده و تمیز)
                    PopupMenuButton<String>(
                      icon: Icon(
                        CupertinoIcons.ellipsis_vertical,
                        size: 17,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onSelected: (val) async {
                        HapticFeedback.lightImpact();
                        if (val == 'quick_complete' && nextSession != null) {
                          await ref
                              .read(khatmListControllerProvider.notifier)
                              .toggleSession(
                                planId: plan.id,
                                sessionIndex: nextSession.sessionIndex,
                                isCompleted: true,
                              );
                          if (context.mounted) {
                            AppSnackBar.showSuccess(
                              context,
                              'جلسه ${(nextSession.sessionIndex + 1).toPersianDigit()} تکمیل شد.',
                            );
                          }
                        } else if (val == 'report') {
                          context.pushNamed(
                            khatmDetailRoute,
                            pathParameters: {'id': plan.id},
                          ).then((_) {
                            ref
                                .read(khatmListControllerProvider.notifier)
                                .loadPlans();
                          });
                        } else if (val == 'delete') {
                          _confirmDeletePlan(context, ref);
                        }
                      },
                      itemBuilder: (ctx) => [
                        if (nextSession != null)
                          PopupMenuItem(
                            value: 'quick_complete',
                            child: Text(
                              'تکمیل سریع جلسه ${(nextSession.sessionIndex + 1).toPersianDigit()}',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 13,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        PopupMenuItem(
                          value: 'report',
                          child: Text(
                            'گزارش و جدول ختم',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'حذف ختم',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (cardWidth == null) 10.vSpace,

                // ── ۲. دکمه پایین: ادامه مطالعه یا وضعیت تکمیل ──
                InkWell(
                  onTap: () => _navigateToSession(context, ref),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 7.5,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.07)
                          : const Color(0xFFF3F1EC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      plan.isCompleted ? 'تکمیل شده' : 'ادامه مطالعه',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: plan.isCompleted
                            ? (isDark ? Colors.white38 : Colors.black38)
                            : colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
