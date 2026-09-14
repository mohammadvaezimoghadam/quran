import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran_home/application/controllers/continue_reading_controller.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';

/// Sticky "Continue Reading" bottom banner for Surah List screen.
/// Designed to dock above the mini audio player with seamless Islamic aesthetics.
class SurahListContinueReadingBar extends ConsumerWidget {
  final VoidCallback? onBeforeNavigation;

  const SurahListContinueReadingBar({
    super.key,
    this.onBeforeNavigation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final continueState = ref.watch(continueReadingControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Resolve active reading location or default to Al-Fatihah 1
    final surahId = continueState?.surahId ?? 1;
    final rawSurahName = continueState?.surahName ?? 'الفاتحة';
    final surahFaName = surahId.surahNameFa;
    final ayahNumber = continueState?.ayahNumber ?? 1;

    // Theme-tailored sage green & deep forest colors
    final bgColor = isDark
        ? const Color(0xFF19251D)
        : const Color(0xFFEDF3EB);
    final borderColor = isDark
        ? const Color(0xFF2C4434)
        : const Color(0xFFCADBC6);
    final titleColor = isDark
        ? const Color(0xFFE2EFE0)
        : const Color(0xFF1B3821);
    final subtitleColor = isDark
        ? const Color(0xFF9CB79F)
        : const Color(0xFF4C6B51);
    final buttonBg = isDark
        ? AppColors.primary
        : const Color(0xFF24482B);
    final buttonTextColor = isDark
        ? const Color(0xFFF7E2A9)
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _handleTap(context, ref, surahId, rawSurahName, ayahNumber),
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withValues(alpha: 0.12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.1),
            ),
            child: Row(
              children: [
                // Right Side: Surah Info + Ayah Number + Ayah Preview
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.book_fill,
                            size: 15,
                            color: isDark ? AppColors.goldAccent : AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'سوره $surahFaName - آیه شماره ${ayahNumber.toPersianDigit()}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        surahId == 1 && ayahNumber == 1
                            ? 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'
                            : 'آخرین موقعیت قرائت شما در قرآن کریم',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10.5,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Left Side: "ادامه مطالعه" Action Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7.5),
                  decoration: BoxDecoration(
                    color: buttonBg,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: buttonBg.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'ادامه مطالعه',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: buttonTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(
    BuildContext context,
    WidgetRef ref,
    int surahId,
    String surahName,
    int ayahNumber,
  ) {
    onBeforeNavigation?.call();
    ref.read(quranDisplaySettingsControllerProvider.notifier).toggleArabicText(true);
    context.pushNamed(
      quranReaderRoute,
      pathParameters: {'id': surahId.toString()},
      queryParameters: {
        'name': surahName,
        'ayah': ayahNumber.toString(),
      },
    );
  }
}
