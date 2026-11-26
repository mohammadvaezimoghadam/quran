import 'package:flutter/material.dart';

import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/core/theme/app_colors.dart';
import 'package:quran/core/theme/app_typography.dart';

/// Shared compact circular progress indicator used inside Group Khatm
/// slot tiles, Surah participation cards, and the reader progress bar.
class GroupKhatmSlotProgressRing extends StatelessWidget {
  final double progress;
  final int percent;
  final bool isCompleted;
  final double size;
  final double strokeWidth;
  final double fontSize;
  final Color? color;

  const GroupKhatmSlotProgressRing({
    super.key,
    required this.progress,
    required this.percent,
    this.isCompleted = false,
    this.size = 28.0,
    this.strokeWidth = 2.6,
    this.fontSize = 8.5,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    final normalized = isCompleted ? 1.0 : progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CircularProgressIndicator(
              value: normalized,
              strokeWidth: strokeWidth,
              backgroundColor: activeColor.withValues(alpha: 0.14),
              valueColor: AlwaysStoppedAnimation<Color>(activeColor),
            ),
          ),
          if (isCompleted)
            Icon(Icons.check_rounded, size: size * 0.48, color: activeColor)
          else
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Text(
                  '${percent.toPersianDigit()}٪',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: activeColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shared rounded icon button chip used consistently for Continue Reading
/// and Release Slot actions on Group Khatm cards.
class GroupKhatmSlotIconChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  const GroupKhatmSlotIconChip({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.tooltip,
    this.iconSize = 14,
    this.padding = const EdgeInsets.all(4.5),
  });

  @override
  Widget build(BuildContext context) {
    final chip = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: color.withValues(alpha: 0.18),
            width: 0.7,
          ),
        ),
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
    if (tooltip == null) return chip;
    return Tooltip(message: tooltip!, child: chip);
  }
}

/// Shared minimal colorless pill button for marking a claimed Group Khatm slot
/// completed ("تموم شد") in the same visual style as [GroupKhatmSlotIconChip].
class GroupKhatmCompleteActionChip extends StatelessWidget {
  final VoidCallback onTap;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const GroupKhatmCompleteActionChip({
    super.key,
    required this.onTap,
    this.fontSize = 9.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: isDark ? 0.10 : 0.06),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: foreground.withValues(alpha: isDark ? 0.20 : 0.16),
            width: 0.7,
          ),
        ),
        child: Text(
          'تموم شد',
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: foreground,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
