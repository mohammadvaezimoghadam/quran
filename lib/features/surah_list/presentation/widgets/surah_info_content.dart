import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/surah_entity.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';

/// Displays the Surah Title, English Name, Kaaba Icon (Makki/Madani), Juz & Hizb, and Ayah Count.
class SurahInfoContent extends ConsumerWidget {
  final SurahEntity surah;
  final bool isDark;

  const SurahInfoContent({
    super.key,
    required this.surah,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final fontFamily = AppTypography.getFontFamilyByScript(fontScript);

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Arabic Surah Title
        Text(
          surah.name,
          style: AppTypography.surahTitle.copyWith(
            fontFamily: fontFamily,
            height: 1.4,
            color: isDark ? AppColors.softGoldText : AppColors.primary,
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

