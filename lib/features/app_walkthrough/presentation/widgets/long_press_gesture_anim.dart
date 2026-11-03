import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Pure, boxless animated hand gesture demonstrating Long-Press directly on an Ayah.
/// Completely transparent with zero container card or borders.
class LongPressGestureAnim extends StatefulWidget {
  const LongPressGestureAnim({super.key});

  @override
  State<LongPressGestureAnim> createState() => _LongPressGestureAnimState();
}

class _LongPressGestureAnimState extends State<LongPressGestureAnim>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;

        // Cycle breakdown:
        // 0.00 -> 0.20 : Hand ascends & presses up into surface (scale 1.15 -> 0.90)
        // 0.20 -> 0.72 : Holding down! Circular charge arc sweeps 0° -> 360°
        // 0.72 -> 0.85 : Success pulse burst! Hand begins withdrawing downward
        // 0.85 -> 1.00 : Retract down & smooth reset
        double scale = 1.15;
        double handOffsetY = -7.0;
        double ringProgress = 0.0;
        double rippleRadius = 0.0;
        double rippleOpacity = 0.0;
        double burstRadius = 0.0;
        double burstOpacity = 0.0;
        double opacity = 0.85;

        if (t < 0.20) {
          final p = t / 0.20;
          final curve = Curves.easeInQuad.transform(p);
          scale = 1.15 - (0.25 * curve); // 1.15 -> 0.90
          handOffsetY = -7.0 + (7.0 * curve); // -7 -> 0
          opacity = 0.85 + (0.15 * curve);
        } else if (t < 0.72) {
          final p = (t - 0.20) / 0.52;
          scale = 0.90;
          handOffsetY = 0.0;
          opacity = 1.0;
          ringProgress = p;

          // Continuous subtle pulse ripple while holding
          final rippleP = (p * 2.2) % 1.0;
          rippleRadius = 14.0 + (16.0 * rippleP);
          rippleOpacity = (1.0 - rippleP) * 0.45;
        } else if (t < 0.85) {
          final p = (t - 0.72) / 0.13;
          ringProgress = 1.0;
          scale = 0.90 + (0.25 * Curves.easeOutQuad.transform(p));
          handOffsetY = -7.0 * Curves.easeOutQuad.transform(p);
          opacity = 1.0;

          // Expanding success ring burst
          burstRadius = 15.0 + (22.0 * Curves.easeOutQuad.transform(p));
          burstOpacity = (1.0 - p) * 0.85;
        } else {
          final p = (t - 0.85) / 0.15;
          scale = 1.15;
          handOffsetY = -7.0;
          opacity = 1.0 - (0.15 * p);
          ringProgress = 0.0;
        }

        return SizedBox(
          width: 90,
          height: 90,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Touch point and Hold gauge ring (positioned at fingertip top)
              Positioned(
                top: 8,
                child: CustomPaint(
                  size: const Size(60, 60),
                  painter: _HoldGesturePainter(
                    ringProgress: ringProgress,
                    rippleRadius: rippleRadius,
                    rippleOpacity: rippleOpacity,
                    burstRadius: burstRadius,
                    burstOpacity: burstOpacity,
                  ),
                ),
              ),

              // Animated Hand Icon pointing UPWARDS directly onto the contact point
              Positioned(
                top: 36 - handOffsetY,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topCenter,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x66000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Transform.rotate(
                        angle: math.pi / 2,
                        child: const Icon(
                          CupertinoIcons.hand_point_left_fill,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HoldGesturePainter extends CustomPainter {
  final double ringProgress;
  final double rippleRadius;
  final double rippleOpacity;
  final double burstRadius;
  final double burstOpacity;

  _HoldGesturePainter({
    required this.ringProgress,
    required this.rippleRadius,
    required this.rippleOpacity,
    required this.burstRadius,
    required this.burstOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const baseRadius = 15.0;

    // 1. Success trigger burst ring
    if (burstOpacity > 0.01 && burstRadius > 0) {
      final burstPaint = Paint()
        ..color = Colors.white.withValues(alpha: burstOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(center, burstRadius, burstPaint);
    }

    // 2. Continuous pulse ripple while holding
    if (rippleOpacity > 0.01 && rippleRadius > 0) {
      final ripplePaint = Paint()
        ..color = Colors.white.withValues(alpha: rippleOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(center, rippleRadius, ripplePaint);
    }

    // 3. Faint background circle track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: ringProgress > 0.01 ? 0.25 : 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, baseRadius, trackPaint);

    // 4. Center touch contact dot
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: ringProgress > 0.01 ? 0.90 : 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.5, dotPaint);

    // 5. Active circular progress arc (Hold timer filling 360°)
    if (ringProgress > 0.01) {
      final progressPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round;

      final sweepAngle = ringProgress * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: baseRadius),
        -math.pi / 2, // Start at 12 o'clock
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HoldGesturePainter oldDelegate) {
    return oldDelegate.ringProgress != ringProgress ||
        oldDelegate.rippleRadius != rippleRadius ||
        oldDelegate.rippleOpacity != rippleOpacity ||
        oldDelegate.burstRadius != burstRadius ||
        oldDelegate.burstOpacity != burstOpacity;
  }
}
