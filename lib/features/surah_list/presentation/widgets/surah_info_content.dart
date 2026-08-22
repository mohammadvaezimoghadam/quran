import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/surah_entity.dart';
import 'surah_ayah_badge.dart';

/// Displays the Surah Title, English Name, Kaaba Icon (Makki/Madani), Juz & Hizb, and Ayah Count Badge.
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
        // Top Row: Arabic Name & English Name
        Row(
          children: [
            Text(
              surah.name,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                fontFamily: 'Amiri',
                color: isDark ? AppColors.softGoldText : AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '(${surah.englishName})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: AppTypography.fontFamily,
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Subtitle: Kaaba Icon + Makki/Madani • Juz & Hizb • Ayah Count Badge
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
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: AppTypography.fontFamily,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                '•',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
            ),

            // Juz Info
            Text(
              'جزء ${surah.startJuz}',
              style: TextStyle(
                fontSize: 11,
                fontFamily: AppTypography.fontFamily,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),


            const Spacer(),

            // Ayah Count Badge
            SurahAyahBadge(
              label: '${surah.numberOfAyahs} ${AppConstants.ayahLabel}',
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }
}

