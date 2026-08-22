import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Medallion Widget displaying the Surah Number inside a Rich Dual-Layered Gold Star & Emerald Circle.
class SurahNumberMedallion extends StatelessWidget {
  final int surahNumber;
  final bool isDark;

  const SurahNumberMedallion({
    super.key,
    required this.surahNumber,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final emeraldGreen = isDark ? AppColors.darkPrimaryContainer : AppColors.primary;

    return SizedBox(
      width: 46,
      height: 46,
      child: CustomPaint(
        painter: RichStarCirclePainter(
          circleColor: emeraldGreen,
          starFillColor: AppColors.goldMetallic,
          starBorderColor: AppColors.goldDarkBorder,
        ),
        child: Center(
          child: Text(
            '$surahNumber',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: AppTypography.fontFamily,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom Painter for Rich Layered 8-Point Islamic Star Medallion
class RichStarCirclePainter extends CustomPainter {
  final Color circleColor;
  final Color starFillColor;
  final Color starBorderColor;

  RichStarCirclePainter({
    required this.circleColor,
    required this.starFillColor,
    required this.starBorderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    Path buildStarPath(double outerR, double innerR, int points) {
      final path = Path();
      final double angleStep = math.pi / points;
      for (int i = 0; i < points * 2; i++) {
        final r = i.isEven ? outerR : innerR;
        final a = i * angleStep - (math.pi / 2);
        final x = center.dx + r * math.cos(a);
        final y = center.dy + r * math.sin(a);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      return path;
    }

    final outerStarPath = buildStarPath(radius * 0.98, radius * 0.74, 8);

    final starFillPaint = Paint()
      ..color = starFillColor
      ..style = PaintingStyle.fill;

    final starBorderPaint = Paint()
      ..color = starBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawPath(outerStarPath, starFillPaint);
    canvas.drawPath(outerStarPath, starBorderPaint);

    final innerStarPath = buildStarPath(radius * 0.82, radius * 0.68, 8);
    final innerStarPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawPath(innerStarPath, innerStarPaint);

    final circlePaint = Paint()
      ..color = circleColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.60, circlePaint);

    final circleBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    canvas.drawCircle(center, radius * 0.60, circleBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
