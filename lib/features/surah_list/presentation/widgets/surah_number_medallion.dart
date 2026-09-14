import 'package:flutter/material.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../core/theme/app_typography.dart';

/// Minimalist Apple-grade Squircle Medallion for Surah Number.
/// Combines high-contrast Persian typography with a soft, border-free/hairline elevated squircle.
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
    final colorScheme = context.colorScheme;

    final badgeBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFF3EFE8);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE5DFD3);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 0.8,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        surahNumber.toPersianDigit(),
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 13.5,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
