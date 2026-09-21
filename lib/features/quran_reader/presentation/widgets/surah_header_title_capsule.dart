import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../core/theme/app_typography.dart';

/// Unified interactive Surah title capsule for navigation headers.
/// Displays surah number badge, surah name, and downward chevron indicator.
/// Used consistently across Quran Reader, Ayah Dictionary, and Surah Dictionary headers.
class SurahHeaderTitleCapsule extends StatelessWidget {
  final int surahNumber;
  final String surahName;
  final VoidCallback? onTap;

  const SurahHeaderTitleCapsule({
    super.key,
    required this.surahNumber,
    required this.surahName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.28),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  surahNumber.toPersianDigit(),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  surahName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1D1D1F),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                CupertinoIcons.chevron_down,
                size: 11,
                color: colorScheme.primary.withValues(alpha: 0.75),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
