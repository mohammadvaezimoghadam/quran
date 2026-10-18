import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/core/theme/app_typography.dart';

/// Clean docked bottom button for continuing the next session of the Khatm,
/// without decorative icons.
class KhatmContinueButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed;
  final String label;

  const KhatmContinueButton({
    super.key,
    required this.isEnabled,
    required this.onPressed,
    this.label = 'ادامه ختم',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final primary = colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border(
          top: BorderSide(
            color: colors.cardBorder,
            width: 0.8,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          onPressed: isEnabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            disabledBackgroundColor:
                isDark ? Colors.white12 : const Color(0xFFE2E8F0),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isEnabled
                  ? Colors.white
                  : (isDark ? Colors.white38 : Colors.black38),
            ),
          ),
        ),
      ),
    );
  }
}
