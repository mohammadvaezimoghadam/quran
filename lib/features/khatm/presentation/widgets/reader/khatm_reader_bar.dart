import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/widgets/app_snackbar.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/khatm/application/controllers/khatm_detail_controller.dart';
import 'package:quran/features/khatm/domain/entities/khatm_session_item.dart';

/// Clean, minimal sticky bar displayed inside [QuranReaderScreen] during a Khatm session.
/// Reading progress is automatically tracked; when completed, a subtle badge appears.
class KhatmReaderBar extends ConsumerWidget {
  final String khatmId;
  final int sessionIndex;
  final VoidCallback? onClose;
  final VoidCallback? onTap;
  final VoidCallback? onNextSession;

  static const double barHeight = 44.0;
  static const double collapsedHeight = 3.0;

  const KhatmReaderBar({
    super.key,
    required this.khatmId,
    required this.sessionIndex,
    this.onClose,
    this.onTap,
    this.onNextSession,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<KhatmDetailState>(
      khatmDetailControllerProvider(khatmId),
      (prev, next) {
        KhatmSessionItem? prevSession;
        for (final s in prev?.plan?.sessions ?? <KhatmSessionItem>[]) {
          if (s.sessionIndex == sessionIndex) {
            prevSession = s;
            break;
          }
        }
        KhatmSessionItem? nextSession;
        for (final s in next.plan?.sessions ?? <KhatmSessionItem>[]) {
          if (s.sessionIndex == sessionIndex) {
            nextSession = s;
            break;
          }
        }
        if (prevSession != null && nextSession != null) {
          if (!prevSession.isCompleted && nextSession.isCompleted) {
            HapticFeedback.mediumImpact();
            AppSnackBar.showSuccess(
              context,
              'جلسه ${(sessionIndex + 1).toPersianDigit()} تکمیل شد',
            );
          }
        }
      },
    );

    final state = ref.watch(khatmDetailControllerProvider(khatmId));
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    final plan = state.plan;
    if (plan == null) return const SizedBox.shrink();

    final session = plan.sessions.firstWhere(
      (s) => s.sessionIndex == sessionIndex,
      orElse: () => plan.sessions.first,
    );

    final isCompleted = session.isCompleted;

    final bgColor = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.94)
        : const Color(0xFFF1F5F9);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white70 : const Color(0xFF334155);

    final isCollapsed = ref.watch(isKhatmReaderBarCollapsedProvider);
    final currentHeight = isCollapsed ? collapsedHeight : barHeight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isCollapsed
            ? () {
                ref
                    .read(isKhatmReaderBarCollapsedProvider.notifier)
                    .setCollapsed(false);
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          width: double.infinity,
          height: currentHeight,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: isCollapsed ? Colors.transparent : bgColor,
            border: isCollapsed
                ? null
                : Border(
                    bottom: BorderSide(color: borderColor, width: 0.8),
                  ),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.bottomCenter,
            children: [
              // Full content with subtle fade out when collapsed
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: barHeight,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeInOut,
                  opacity: isCollapsed ? 0.0 : 1.0,
                  child: IgnorePointer(
                    ignoring: isCollapsed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Tapable Area for opening Khatm list
                          Expanded(
                            child: InkWell(
                              onTap: onTap,
                              child: Row(
                                children: [
                                  // Plan Title & Session Details (single-line, non-overflowing)
                                  Expanded(
                                    child: Text(
                                      '${plan.title}: جلسه ${(session.sessionIndex + 1).toPersianDigit()} از ${plan.sessionCount.toPersianDigit()} (${session.computeTitle(plan.unitType)})',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Progress percentage badge
                                  Text(
                                    '${session.progressPercentInt.toPersianDigit()}٪',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Manual Complete Button (when not completed, user can complete manually anytime)
                          if (!isCompleted) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () async {
                                HapticFeedback.mediumImpact();
                                await ref
                                    .read(khatmDetailControllerProvider(khatmId).notifier)
                                    .toggleSession(session.sessionIndex, true);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    color: primary.withValues(alpha: 0.25),
                                    width: 0.7,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CupertinoIcons.checkmark,
                                      size: 11,
                                      color: primary,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      'اتمام جلسه',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          // Subtle Completed Badge (only shown when completed)
                          if (isCompleted) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.checkmark_alt,
                                    size: 11,
                                    color: primary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'تکمیل شد',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Optional Next Session button when completed
                          if (isCompleted &&
                              sessionIndex + 1 < plan.sessions.length &&
                              onNextSession != null) ...[
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: onNextSession,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'جلسه بعد',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          // Optional close button
                          if (onClose != null) ...[
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: onClose,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  CupertinoIcons.xmark,
                                  size: 14,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Subtle animated progress line along the bottom border
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: isCollapsed ? collapsedHeight : 2.0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: session.effectiveProgress.clamp(0.0, 1.0),
                    child: Container(
                      height: isCollapsed ? collapsedHeight : 2.0,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: isCollapsed
                            ? BorderRadius.circular(collapsedHeight / 2)
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
