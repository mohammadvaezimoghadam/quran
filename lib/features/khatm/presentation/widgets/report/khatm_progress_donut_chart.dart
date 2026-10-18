import 'dart:math';

import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/core/theme/app_typography.dart';

/// Donut chart card displaying reading progress, styled cleanly to match
/// the app's minimal Apple-style design system with Tafakor Mint theme.
class KhatmProgressDonutChart extends StatelessWidget {
  final String title;
  final int totalUnits;
  final int completedUnits;
  final String unitLabel;

  const KhatmProgressDonutChart({
    super.key,
    required this.title,
    required this.totalUnits,
    required this.completedUnits,
    required this.unitLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    final remainingUnits = (totalUnits - completedUnits).clamp(0, totalUnits);
    final double completedFraction =
        totalUnits > 0 ? (completedUnits / totalUnits).clamp(0.0, 1.0) : 0.0;

    final completedColor = colorScheme.primary;
    final remainingColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFE5E2DA);

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.cardBorder,
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        children: [
          // Card Title: گزارش "نام ختم"
          Text(
            'گزارش "$title"',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Legends on left
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Completed legend (Mint Primary)
                    _buildLegendItem(
                      color: completedColor,
                      label:
                          '${completedUnits.toPersianDigit()} $unitLabel تلاوت شده',
                      textColor: colorScheme.onSurface,
                    ),
                    const SizedBox(height: 12),
                    // Remaining legend (Muted neutral)
                    _buildLegendItem(
                      color: remainingColor,
                      label:
                          '${remainingUnits.toPersianDigit()} $unitLabel باقی مانده',
                      textColor:
                          isDark ? Colors.white60 : const Color(0xFF7A756D),
                    ),
                  ],
                ),
              ),
              // Donut Chart on right with percentage in center (smooth animated ring & count)
              SizedBox(
                width: 84,
                height: 84,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: completedFraction),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOutCubic,
                  builder: (context, animFraction, _) {
                    final animPercent =
                        (animFraction * 100).toInt().clamp(0, 100);
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(84, 84),
                          painter: _DonutRingPainter(
                            completedFraction: animFraction,
                            completedColor: completedColor,
                            remainingColor: remainingColor,
                            strokeWidth: 8.5,
                          ),
                        ),
                        Text(
                          '${animPercent.toPersianDigit()}٪',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required Color textColor,
  }) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for modern Donut Ring with smooth rounded caps
class _DonutRingPainter extends CustomPainter {
  final double completedFraction;
  final Color completedColor;
  final Color remainingColor;
  final double strokeWidth;

  _DonutRingPainter({
    required this.completedFraction,
    required this.completedColor,
    required this.remainingColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    // Remaining background ring
    final bgPaint = Paint()
      ..color = remainingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Completed progress arc
    if (completedFraction > 0.0) {
      final fgPaint = Paint()
        ..color = completedColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = completedFraction >= 0.999 ? StrokeCap.butt : StrokeCap.round;

      if (completedFraction >= 0.999) {
        canvas.drawCircle(center, radius, fgPaint);
      } else {
        const startAngle = -pi / 2;
        final sweepAngle = 2 * pi * completedFraction;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          fgPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DonutRingPainter oldDelegate) {
    return oldDelegate.completedFraction != completedFraction ||
        oldDelegate.completedColor != completedColor ||
        oldDelegate.remainingColor != remainingColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
