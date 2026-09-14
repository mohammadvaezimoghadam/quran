import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/surah_entity.dart';

/// Displays the Surah Title and a clean, single-line minimal metadata row.
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
    final colorScheme = context.colorScheme;
    final subtextColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.70);
    final dotColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.35);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. High-Contrast Persian Surah Title
        Text(
          'سوره ${surah.nameFa}',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            height: 1.25,
            color: colorScheme.onSurface,
          ),
        ),

        AppDimens.stackXs.vSpace,

        // 2. Monochrome Single-Line Subtitle: Kaaba Icon + Makki/Madani • Juz • Ayah Count
        Row(
          children: [
            // Subtle monochrome Kaaba Icon
            SvgPicture.asset(
              'assets/icons/ic_kaaba.svg',
              width: 12,
              height: 12,
              colorFilter: ColorFilter.mode(
                subtextColor,
                BlendMode.srcIn,
              ),
            ),
            5.hSpace,
            Text(
              surah.revelationTypeFa,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: subtextColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                '•',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11.0,
                  color: dotColor,
                ),
              ),
            ),

            // Juz Info
            Text(
              'جزء ${surah.startJuz.toPersianDigit()}',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: subtextColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                '•',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11.0,
                  color: dotColor,
                ),
              ),
            ),

            // Ayah Count Info
            Text(
              '${surah.numberOfAyahs.toPersianDigit()} ${AppConstants.ayahLabel}',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: subtextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
