import 'dart:math';

import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/core/theme/app_typography.dart';
import '../../../domain/entities/group_khatm_campaign.dart';

/// Clean, typography-first hero header card for Group Khatm Details.
/// Inspired by modern Apple-like and Sacred Serenity aesthetics:
/// - Prominent centered circular progress donut chart
/// - Category / Intention pill (no yellow)
/// - Bold campaign title & subtitle
/// - 3-column stats pill card (قرائت شده، در حال قرائت، باقی‌مانده)
/// - Ultra-thin, faint borders (0.5px) without heavy outlines
/// - Zero decorative icons
class GroupKhatmDetailHeader extends StatelessWidget {
  final GroupKhatmCampaign campaign;

  const GroupKhatmDetailHeader({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    final targetUnits = campaign.targetUnits > 0 ? campaign.targetUnits : 30;
    final completedFraction =
        (campaign.completedUnits / targetUnits).clamp(0.0, 1.0);
    final reservedFraction =
        (campaign.reservedUnits / targetUnits).clamp(0.0, 1.0 - completedFraction);

    // Muted teal/slate tone for in-progress arc (strict constraint: zero yellow/amber)
    final inProgressColor = isDark
        ? const Color(0xFF3B6B65)
        : const Color(0xFF4C8A81);

    final trackBgColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFEBE8E1);

    // Subtle hairline border (ultra-thin and faint as requested)
    final hairlineBorder = Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.04),
      width: 0.5,
    );

    final pillBg = isDark ? const Color(0xFF222224) : const Color(0xFFF3F1EC);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: hairlineBorder,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── ۱. نشان دسته‌بندی و نیت ختم (بدون رنگ زرد) ──
          if (campaign.categoryTitle != null &&
              campaign.categoryTitle!.trim().isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                campaign.categoryTitle!,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── ۲. نمودار دایره‌ای بزرگ پیشرفت (Donut Chart) ──
          SizedBox(
            width: 154,
            height: 154,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(154, 154),
                  painter: _GroupDonutRingPainter(
                    completedFraction: completedFraction,
                    reservedFraction: reservedFraction,
                    completedColor: colorScheme.primary,
                    inProgressColor: inProgressColor,
                    backgroundColor: trackBgColor,
                    strokeWidth: 9.5,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${campaign.progressPercent.toInt().toPersianDigit()}٪',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${campaign.completedUnits.toPersianDigit()} از ${targetUnits.toPersianDigit()}',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── ۳. عنوان ختم و توضیحات نیت ──
          Text(
            campaign.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 17.5,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              height: 1.35,
            ),
          ),
          if (campaign.description != null &&
              campaign.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                campaign.description!,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12.5,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),

          // ── ۴. کادر آمار ۳ ستونه سهم‌ها ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.03),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCol(
                    dotColor: colorScheme.primary,
                    label: 'قرائت شده',
                    value: campaign.completedUnits.toPersianDigit(),
                    colorScheme: colorScheme,
                  ),
                ),
                Container(
                  width: 0.6,
                  height: 26,
                  color: colorScheme.onSurface.withValues(alpha: 0.08),
                ),
                Expanded(
                  child: _buildStatCol(
                    dotColor: inProgressColor,
                    label: 'در حال قرائت',
                    value: campaign.reservedUnits.toPersianDigit(),
                    colorScheme: colorScheme,
                  ),
                ),
                Container(
                  width: 0.6,
                  height: 26,
                  color: colorScheme.onSurface.withValues(alpha: 0.08),
                ),
                Expanded(
                  child: _buildStatCol(
                    dotColor: colorScheme.onSurface.withValues(alpha: 0.28),
                    label: 'باقی‌مانده',
                    value: campaign.remainingUnits.toPersianDigit(),
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol({
    required Color dotColor,
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6.5,
              height: 6.5,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the 3-state Donut Ring with smooth circular geometry
class _GroupDonutRingPainter extends CustomPainter {
  final double completedFraction;
  final double reservedFraction;
  final Color completedColor;
  final Color inProgressColor;
  final Color backgroundColor;
  final double strokeWidth;

  const _GroupDonutRingPainter({
    required this.completedFraction,
    required this.reservedFraction,
    required this.completedColor,
    required this.inProgressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    // 1. Background full circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -pi / 2;

    // 2. In-Progress arc (draws after completed arc)
    if (reservedFraction > 0.0) {
      final inProgressPaint = Paint()
        ..color = inProgressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final inProgressStartAngle = startAngle + (completedFraction * 2 * pi);
      final inProgressSweepAngle = reservedFraction * 2 * pi;

      canvas.drawArc(
        rect,
        inProgressStartAngle,
        inProgressSweepAngle,
        false,
        inProgressPaint,
      );
    }

    // 3. Completed progress arc (draws from top startAngle)
    if (completedFraction > 0.0) {
      final completedPaint = Paint()
        ..color = completedColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final completedSweepAngle = completedFraction * 2 * pi;

      canvas.drawArc(
        rect,
        startAngle,
        completedSweepAngle,
        false,
        completedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GroupDonutRingPainter oldDelegate) {
    return oldDelegate.completedFraction != completedFraction ||
        oldDelegate.reservedFraction != reservedFraction ||
        oldDelegate.completedColor != completedColor ||
        oldDelegate.inProgressColor != inProgressColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
