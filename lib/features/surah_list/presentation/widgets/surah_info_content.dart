import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/surah_entity.dart';

/// Displays the Surah Title, Kaaba Icon (Makki/Madani), Juz & Hizb, and Ayah Count.
class SurahInfoContent extends StatelessWidget {
  final SurahEntity surah;
  final bool isDark;

  const SurahInfoContent({
    super.key,
    required this.surah,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Persian Surah Title
        Text(
          'سوره ${surah.nameFa}',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
            height: 1.3,
            color: isDark ? Colors.white : const Color(0xFF1A1D1E),
          ),
        ),

        const SizedBox(height: 6),

        // Subtitle: Kaaba Icon + Makki/Madani • Juz • Ayah Count
        Row(
          children: [
            // Kaaba Icon for Revelation Type
            SvgPicture.asset(
              'assets/icons/ic_kaaba.svg',
              width: 14,
              height: 14,
              colorFilter: const ColorFilter.mode(
                AppColors.goldAccent,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              surah.revelationTypeFa,
              style: AppTypography.surahMetadata.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                '•',
                style: AppTypography.surahMetadata.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
            ),

            // Juz Info
            Text(
              'جزء ${surah.startJuz.toPersianDigit()}',
              style: AppTypography.surahMetadata.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                '•',
                style: AppTypography.surahMetadata.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
            ),

            // Ayah Count Info
            Text(
              '${surah.numberOfAyahs.toPersianDigit()} ${AppConstants.ayahLabel}',
              style: AppTypography.surahMetadata.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

