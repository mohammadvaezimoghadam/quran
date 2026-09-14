import 'package:flutter/material.dart';

import '../../../../common/extensions/context_extension.dart';

/// A custom vector-painted Islamic ornamental divider line.
/// Reproduces traditional Quranic manuscript line ornaments with
/// interweaving loops, central diamond ornament, and tapered gradient lines.
class QuranOrnamentalDivider extends StatelessWidget {
  final Color? color;
  final double height;

  const QuranOrnamentalDivider({
    super.key,
    this.color,
    this.height = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.colors.goldAccent;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _QuranOrnamentPainter(color: effectiveColor),
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

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // 1. Central Diamond Ornament (rotated square)
    final dSize = size.height * 0.32;
    final diamondPath = Path()
      ..moveTo(cx, cy - dSize)
      ..lineTo(cx + dSize, cy)
      ..lineTo(cx, cy + dSize)
      ..lineTo(cx - dSize, cy)
      ..close();
    canvas.drawPath(diamondPath, fillPaint);

    // Inner diamond cutout
    final innerDSize = dSize * 0.45;
    final innerDiamondPath = Path()
      ..moveTo(cx, cy - innerDSize)
      ..lineTo(cx + innerDSize, cy)
      ..lineTo(cx, cy + innerDSize)
      ..lineTo(cx - innerDSize, cy)
      ..close();
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawPath(innerDiamondPath, clearPaint);

    // 2. Small accent dots above and below the central diamond
    final dotRadius = size.height * 0.08;
    canvas.drawCircle(Offset(cx, cy - dSize - dotRadius * 2), dotRadius, fillPaint);
    canvas.drawCircle(Offset(cx, cy + dSize + dotRadius * 2), dotRadius, fillPaint);

    // 3. Symmetric scroll loops on left and right
    final loopSpacing = dSize * 1.5;
    final loopRadius = size.height * 0.22;

    // Right loop
    _drawLoop(canvas, Offset(cx + loopSpacing, cy), loopRadius, strokePaint, isRight: true);
    // Left loop
    _drawLoop(canvas, Offset(cx - loopSpacing, cy), loopRadius, strokePaint, isRight: false);

    // 4. Secondary small diamonds
    final secDSize = dSize * 0.55;
    final secSpacing = loopSpacing + loopRadius * 2.4;
    _drawSmallDiamond(canvas, Offset(cx + secSpacing, cy), secDSize, fillPaint);
    _drawSmallDiamond(canvas, Offset(cx - secSpacing, cy), secDSize, fillPaint);

    // 5. Tapered horizontal lines extending outwards to the edges
    final lineStartOffset = secSpacing + secDSize * 1.6;
    final lineEndOffset = size.width * 0.46;

    if (lineEndOffset > lineStartOffset) {
      // Right line with gradient fade
      final rightLinePaint = Paint()
        ..shader = LinearGradient(
          colors: [color, color.withValues(alpha: 0.0)],
        ).createShader(Rect.fromPoints(
          Offset(cx + lineStartOffset, cy),
          Offset(cx + lineEndOffset, cy),
        ))
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx + lineStartOffset, cy),
        Offset(cx + lineEndOffset, cy),
        rightLinePaint,
      );

      // Left line with gradient fade
      final leftLinePaint = Paint()
        ..shader = LinearGradient(
          colors: [color, color.withValues(alpha: 0.0)],
        ).createShader(Rect.fromPoints(
          Offset(cx - lineStartOffset, cy),
          Offset(cx - lineEndOffset, cy),
        ))
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx - lineStartOffset, cy),
        Offset(cx - lineEndOffset, cy),
        leftLinePaint,
      );
    }
  }

  void _drawLoop(Canvas canvas, Offset center, double radius, Paint paint, {required bool isRight}) {
    final sign = isRight ? 1.0 : -1.0;
    final path = Path();

    // S-curve / infinity loop segment
    path.moveTo(center.dx - sign * radius * 0.8, center.dy);
    path.cubicTo(
      center.dx - sign * radius * 0.3, center.dy - radius * 1.1,
      center.dx + sign * radius * 0.3, center.dy + radius * 1.1,
      center.dx + sign * radius * 0.8, center.dy,
    );
    path.cubicTo(
      center.dx + sign * radius * 0.3, center.dy - radius * 1.1,
      center.dx - sign * radius * 0.3, center.dy + radius * 1.1,
      center.dx - sign * radius * 0.8, center.dy,
    );

    canvas.drawPath(path, paint);

    // Accent dot in center of loop
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.25, dotPaint);
  }

  void _drawSmallDiamond(Canvas canvas, Offset center, double dSize, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - dSize)
      ..lineTo(center.dx + dSize, center.dy)
      ..lineTo(center.dx, center.dy + dSize)
      ..lineTo(center.dx - dSize, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _QuranOrnamentPainter oldDelegate) => oldDelegate.color != color;
}
