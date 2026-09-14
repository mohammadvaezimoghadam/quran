import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../domain/entities/surah_entity.dart';
import '../../application/controllers/favorite_surahs_controller.dart';
import 'surah_info_content.dart';
import 'surah_number_medallion.dart';
import 'surah_audio_download_button.dart';

/// Clean Apple-Style Borderless Surah Row with native table cell interaction.
class SurahListItem extends StatelessWidget {
  final SurahEntity surah;
  final VoidCallback onTap;
  final VoidCallback onDownloadTap;

  const SurahListItem({
    super.key,
    required this.surah,
    required this.onTap,
    required this.onDownloadTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.03),
        highlightColor: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 11.0,
          ),
          child: Row(
            children: [
              // 1. Apple-Style Squircle Number Medallion
              SurahNumberMedallion(
                surahNumber: surah.number,
                isDark: isDark,
              ),

              14.hSpace,

              // 2. Surah Text Info Content
              Expanded(
                child: SurahInfoContent(
                  surah: surah,
                  isDark: isDark,
                ),
              ),

              // 3. Favorite Star Button (Apple SF Symbols style)
              Consumer(
                builder: (context, ref, child) {
                  final isFavorite = ref.watch(
                    favoriteSurahsProvider.select(
                      (set) => set.contains(surah.number),
                    ),
                  );
                  return IconButton(
                    visualDensity: VisualDensity.compact,
                    splashRadius: 18,
                    icon: Icon(
                      isFavorite ? CupertinoIcons.star_fill : CupertinoIcons.star,
                      color: isFavorite
                          ? colors.goldAccent
                          : (isDark ? Colors.white24 : Colors.black26),
                      size: 19,
                    ),
                    tooltip: isFavorite ? 'حذف از فهرست شخصی' : 'افزودن به فهرست شخصی',
                    onPressed: () {
                      ref.read(favoriteSurahsProvider.notifier).toggleFavorite(surah.number);
                    },
                  );
                },
              ),

              // 4. Download Audio Button
              SurahAudioDownloadButton(
                surah: surah,
                onDownloadTap: onDownloadTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
