import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../domain/entities/surah_entity.dart';
import 'surah_info_content.dart';
import 'surah_number_medallion.dart';
import 'surah_audio_download_button.dart';

/// Clean Surah Card composed of modular sub-widgets.
class SurahListItem extends StatelessWidget {
  final SurahEntity surah;
  final VoidCallback onTap;

  const SurahListItem({
    super.key,
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 2.0),
      child: Material(
        color: isDark ? AppColors.darkSurface : colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          splashColor: AppColors.goldAccent.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                // 1. Surah Number Star Medallion
                SurahNumberMedallion(
                  surahNumber: surah.number,
                  isDark: isDark,
                ),

                const SizedBox(width: 14.0),

                // 2. Surah Text Info & Badges Content
                Expanded(
                  child: SurahInfoContent(
                    surah: surah,
                    isDark: isDark,
                  ),
                ),

                // 3. Download Audio Button
                SurahAudioDownloadButton(
                  surah: surah,
                  onDownloadTap: () {
                    // TODO: Open Download Bottom Sheet
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
