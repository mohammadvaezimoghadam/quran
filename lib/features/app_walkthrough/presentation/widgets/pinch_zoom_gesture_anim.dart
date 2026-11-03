import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quran/core/theme/app_typography.dart';

/// Spacious animated illustration demonstrating 2-finger zoom gesture with two hands.
/// Pure white typography and hands directly on transparent backdrop (no line, no box).
class PinchZoomGestureAnim extends StatefulWidget {
  const PinchZoomGestureAnim({super.key});

  @override
  State<PinchZoomGestureAnim> createState() => _PinchZoomGestureAnimState();
}

class _PinchZoomGestureAnimState extends State<PinchZoomGestureAnim>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _progressAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
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
        final p = _progressAnim.value; // 0.0 (pinched) -> 1.0 (expanded)

        // Hands separation: from 28px each side (56px total) to 85px each side (170px total)
        final distance = 28.0 + (57.0 * p);

        // Text dynamically zooms with hands motion (0.85x -> 1.35x)
        final textScale = 0.85 + (0.50 * p);

        // Continuous subtle touch ripple at fingertips
        final rippleP = (p * 2.0) % 1.0;
        final rippleRadius = 14.0 + (14.0 * rippleP);
        final rippleOpacity = (1.0 - rippleP) * 0.60;

        final isExpanding = _controller.status == AnimationStatus.forward;

        return SizedBox(
          width: 320,
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Center Quran Text dynamically scaling with hand movements
              Positioned(
                top: 92,
                child: Transform.scale(
                  scale: textScale,
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            color: Color(0x99000000),
                            blurRadius: 12,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Left Hand (Pointing UP, moving outward to left & inward to right)
              Positioned(
                top: 18,
                left: (160 - distance) - 25,
                child: _buildHandWithTouchPoint(
                  isLeft: true,
                  rippleRadius: rippleRadius,
                  rippleOpacity: rippleOpacity,
                ),
              ),

              // 3. Right Hand (Pointing UP, moving outward to right & inward to left)
              Positioned(
                top: 18,
                right: (160 - distance) - 25,
                child: _buildHandWithTouchPoint(
                  isLeft: false,
                  rippleRadius: rippleRadius,
                  rippleOpacity: rippleOpacity,
                ),
              ),

              // 4. Subtitle hint below
              Positioned(
                bottom: 8,
                child: Text(
                  isExpanding
                      ? 'باز کردن انگشتان برای بزرگ‌نمایی'
                      : 'بستن انگشتان برای کوچک‌نمایی',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                    shadows: const [
                      Shadow(
                        color: Color(0x99000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandWithTouchPoint({
    required bool isLeft,
    required double rippleRadius,
    required double rippleOpacity,
  }) {
    return SizedBox(
      width: 50,
      height: 68,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Touch point at the fingertip
          Positioned(
            top: 2,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulse ripple
                  if (rippleOpacity > 0.02)
                    Container(
                      width: rippleRadius * 2,
                      height: rippleRadius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: rippleOpacity),
                          width: 1.4,
                        ),
                      ),
                    ),

                  // Touch contact dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x77FFFFFF),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // The Hand Icon (pointing UPWARDS, identical to Long Press hand)
          Positioned(
            top: 14,
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
              child: Transform.scale(
                scaleX: isLeft ? 1 : -1, // Mirrors right hand naturally
                child: Transform.rotate(
                  angle: math.pi / 2, // Index finger points UP
                  child: const Icon(
                    CupertinoIcons.hand_point_left_fill,
                    size: 38,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
