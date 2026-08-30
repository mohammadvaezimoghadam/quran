import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A custom vector-painted Islamic ornamental divider line.
/// Reproduces traditional Quranic manuscript line ornaments with
/// interweaving loops, central diamond ornament, and tapered gradient lines.
class QuranOrnamentalDivider extends StatelessWidget {
  final Color color;
  final double height;

  const QuranOrnamentalDivider({
    super.key,
    this.color = AppColors.goldAccent,
    this.height = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _QuranOrnamentPainter(color: color),
      ),
    );
  }
}

class _QuranOrnamentPainter extends CustomPainter {
  final Color color;

  _QuranOrnamentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cy = size.height / 2;
    final cx = size.width / 2;

    const ornamentHalfWidth = 38.0;
    const diamondSize = 9.0;
    const innerDiamondSize = 4.5;
    const maxLineHalfThickness = 0.85;

    // 1. Tapered Left Horizontal Line with Smooth Transparent Gradient
    final leftRect = Rect.fromLTRB(0, cy - 2, cx - ornamentHalfWidth, cy + 2);
    final leftPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.0), color],
        stops: const [0.0, 0.6],
      ).createShader(leftRect);

    final leftTaperedPath = Path()
      ..moveTo(0, cy) // Sharp needle point at outer left edge
      ..lineTo(cx - ornamentHalfWidth, cy - maxLineHalfThickness)
      ..lineTo(cx - ornamentHalfWidth, cy + maxLineHalfThickness)
      ..close();
    canvas.drawPath(leftTaperedPath, leftPaint);

    // 2. Tapered Right Horizontal Line with Smooth Transparent Gradient
    final rightRect = Rect.fromLTRB(cx + ornamentHalfWidth, cy - 2, size.width, cy + 2);
    final rightPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [color, color.withValues(alpha: 0.0)],
        stops: const [0.4, 1.0],
      ).createShader(rightRect);

    final rightTaperedPath = Path()
      ..moveTo(cx + ornamentHalfWidth, cy - maxLineHalfThickness)
      ..lineTo(size.width, cy) // Sharp needle point at outer right edge
      ..lineTo(cx + ornamentHalfWidth, cy + maxLineHalfThickness)
      ..close();
    canvas.drawPath(rightTaperedPath, rightPaint);

    // 3. Central outer diamond
    final diamondPath = Path()
      ..moveTo(cx, cy - diamondSize)
      ..lineTo(cx + diamondSize, cy)
      ..lineTo(cx, cy + diamondSize)
      ..lineTo(cx - diamondSize, cy)
      ..close();
    canvas.drawPath(diamondPath, strokePaint);

    // 4. Central inner diamond
    final innerDiamondPath = Path()
      ..moveTo(cx, cy - innerDiamondSize)
      ..lineTo(cx + innerDiamondSize, cy)
      ..lineTo(cx, cy + innerDiamondSize)
      ..lineTo(cx - innerDiamondSize, cy)
      ..close();
    canvas.drawPath(innerDiamondPath, strokePaint);

    // 5. Left interweaving loops
    final x0 = cx - ornamentHalfWidth;
    final x3 = cx - diamondSize;
    final dx = (x3 - x0) / 3;

    final leftWave1 = Path()
      ..moveTo(x0, cy)
      ..cubicTo(
        x0 + dx, cy - 8,
        x0 + 2 * dx, cy + 8,
        x3, cy,
      );
    canvas.drawPath(leftWave1, strokePaint);

    final leftWave2 = Path()
      ..moveTo(x0, cy)
      ..cubicTo(
        x0 + dx, cy + 8,
        x0 + 2 * dx, cy - 8,
        x3, cy,
      );
    canvas.drawPath(leftWave2, strokePaint);

    // 6. Right interweaving loops (symmetric)
    final rx0 = cx + ornamentHalfWidth;
    final rx3 = cx + diamondSize;
    final rdx = (rx0 - rx3) / 3;

    final rightWave1 = Path()
      ..moveTo(rx3, cy)
      ..cubicTo(
        rx3 + rdx, cy - 8,
        rx3 + 2 * rdx, cy + 8,
        rx0, cy,
      );
    canvas.drawPath(rightWave1, strokePaint);

    final rightWave2 = Path()
      ..moveTo(rx3, cy)
      ..cubicTo(
        rx3 + rdx, cy + 8,
        rx3 + 2 * rdx, cy - 8,
        rx0, cy,
      );
    canvas.drawPath(rightWave2, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _QuranOrnamentPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
