import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/core/theme/app_typography.dart';

/// Animated circular progress indicator shared across Personal and Group Khatm
/// summary cards, matching the Personal Khatm card visual language.
class KhatmCircularProgressRing extends StatelessWidget {
  final double progress;
  final bool? isCompleted;
  final double size;
  final double strokeWidth;
  final double fontSize;

  const KhatmCircularProgressRing({
    super.key,
    required this.progress,
    this.isCompleted,
    this.size = 38,
    this.strokeWidth = 3.2,
    this.fontSize = 9.5,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final normalizedTarget = progress.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: normalizedTarget),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, child) {
        final int animatedPercent = (isCompleted == false)
            ? (animatedProgress * 100).floor().clamp(0, 99)
            : (normalizedTarget >= 1.0 && animatedProgress >= 0.999)
                ? 100
                : (animatedProgress * 100).floor().clamp(0, 99);
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: animatedProgress.clamp(0.0, 1.0),
                  strokeWidth: strokeWidth,
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
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
