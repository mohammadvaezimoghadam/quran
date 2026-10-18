import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/string_extension.dart';
import 'package:quran/core/theme/app_typography.dart';

/// Clean Apple-style card showing Khatm start and end dates without decorative icons.
class KhatmDateRangeCard extends StatelessWidget {
  final String startDateFa;
  final String endDateFa;

  const KhatmDateRangeCard({
    super.key,
    required this.startDateFa,
    required this.endDateFa,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    final labelColor = isDark ? Colors.white54 : const Color(0xFF8C867A);
    final valueColor = colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.cardBorder,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Right: تاریخ شروع
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تاریخ شروع',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                startDateFa.toPersianDigit(),
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),

          // Center: Subtle vertical divider
          Container(
            width: 0.8,
            height: 28,
            color: colors.cardBorder,
          ),

          // Left: تاریخ پایان
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'تاریخ پایان',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                endDateFa.toPersianDigit(),
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
