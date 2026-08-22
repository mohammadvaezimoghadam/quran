import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';

/// Reusable Metadata Badge component for Ayah count.
class SurahAyahBadge extends StatelessWidget {
  final String label;
  final bool isDark;

  const SurahAyahBadge({
    super.key,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          fontFamily: AppTypography.fontFamily,
          color: isDark ? AppColors.inversePrimary : AppColors.primary,
        ),
      ),
    );
  }
}
