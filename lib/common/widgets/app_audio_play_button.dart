import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

/// Reusable Audio Play / Pause Button Component with subtle shadow and loading state support.
/// Renders a theme-adaptive filled circle where the play triangle is cleanly REPLACED by the loading spinner during loading.
class AppAudioPlayButton extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onTap;
  final double iconSize;
  final Color color;

  const AppAudioPlayButton({
    super.key,
    required this.isPlaying,
    this.isLoading = false,
    required this.onTap,
    this.iconSize = AppDimens.iconLg,
    this.color = AppColors.secondaryContainer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Auto-calculate inner contrast symbol color (Dark emerald for yellow gold button, white for dark button)
    final bool isDarkBackground = color.computeLuminance() < 0.5;
    final Color innerSymbolColor =
        isDarkBackground ? theme.colorScheme.surface : AppColors.primary;

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 8.0,
            spreadRadius: -1.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: const BorderRadius.all(Radius.circular(AppDimens.radiusFull)),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: iconSize * 0.44,
                    height: iconSize * 0.44,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: innerSymbolColor,
                    ),
                  )
                : Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: innerSymbolColor,
                    size: iconSize * 0.62,
                  ),
          ),
        ),
      ),
    );
  }
}
