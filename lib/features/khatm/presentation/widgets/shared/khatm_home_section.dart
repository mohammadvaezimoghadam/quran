import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/size_extension.dart';
import 'package:quran/core/routes/route_name.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/khatm/application/controllers/khatm_list_controller.dart';
import 'package:quran/features/khatm/domain/entities/khatm_plan.dart';
import 'khatm_list_card.dart';

/// Clean Apple-style Home Section for Quran Khatm & Study Plans,
/// matching the exact minimal design system without redundant decorative icons.
class KhatmHomeSection extends ConsumerWidget {
  const KhatmHomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    final state = ref.watch(khatmListControllerProvider);
    final plans = state.plans;
    final isLoading = state.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: SizedBox(
            height: 32,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'برنامه مطالعه و ختم قرآن',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : const Color(0xFF5A554E),
                  ),
                ),
                const Spacer(),
                if (plans.isNotEmpty)
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.pushNamed(khatmListRoute).then((_) {
                        ref
                            .read(khatmListControllerProvider.notifier)
                            .loadPlans();
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 3.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'مشاهده همه',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            CupertinoIcons.chevron_left,
                            size: 12,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        8.vSpace,

        // Content: Loading Skeleton vs Empty State vs Single Card vs Horizontal List
        if (isLoading && plans.isEmpty)
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: colors.cardBackgroundSubtle,
              borderRadius: BorderRadius.circular(16),
            ),
          )
        else if (plans.isEmpty)
          _buildEmptyKhatmCard(context, ref, colors, colorScheme, isDark)
        else if (plans.length == 1)
          KhatmListCard(
            key: ValueKey(plans.first.id),
            plan: plans.first,
            margin: EdgeInsets.zero,
          )
        else
          _buildHorizontalKhatmList(context, ref, plans),
      ],
    );
  }

  /// Horizontal list for multiple plans matching old StudyPlanHomeCard layout
  Widget _buildHorizontalKhatmList(
    BuildContext context,
    WidgetRef ref,
    List<KhatmPlan> plans,
  ) {
    final cardWidth =
        (MediaQuery.of(context).size.width * 0.78).clamp(260.0, 310.0);

    return SizedBox(
      height: 126,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        itemCount: plans.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final plan = plans[index];
          return KhatmListCard(
            key: ValueKey(plan.id),
            plan: plan,
            cardWidth: cardWidth,
            margin: EdgeInsets.zero,
          );
        },
      ),
    );
  }

  /// Minimal empty state with dashed border matching old StudyPlanHomeCard
  Widget _buildEmptyKhatmCard(
    BuildContext context,
    WidgetRef ref,
    dynamic colors,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.20)
        : Colors.black.withValues(alpha: 0.16);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        context.pushNamed(createKhatmWizardRoute).then((_) {
          ref.read(khatmListControllerProvider.notifier).loadPlans();
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        painter: _DottedBorderPainter(
          color: borderColor,
          strokeWidth: 1.2,
          dash: 5.0,
          gap: 4.5,
          radius: 16.0,
        ),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.02)
                : Colors.black.withValues(alpha: 0.015),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.plus,
                size: 17,
                color: colorScheme.primary,
              ),
              6.hSpace,
              Text(
                'ایجاد برنامه ختم جدید',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for rounded rectangle dashed/dotted border
class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double radius;

  const _DottedBorderPainter({
    required this.color,
    this.strokeWidth = 1.2,
    this.dash = 5.0,
    this.gap = 4.5,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len =
            (distance + dash < metric.length) ? dash : metric.length - distance;
        final extractPath = metric.extractPath(distance, distance + len);
        canvas.drawPath(extractPath, paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dash != dash ||
      oldDelegate.gap != gap ||
      oldDelegate.radius != radius;
}
