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

/// Full-width edge-to-edge "Continue Reading" bottom banner for Surah List screen.
/// Matches the reference screenshot layout: no rounded outer box, full width, no icons.
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

    // Authentic olive-green tones matching the reference screenshot
    final bgColor = isDark
        ? const Color(0xFF1D281F)
        : const Color(0xFFC7D3B0);
    final borderColor = isDark
        ? const Color(0xFF2C3C2F)
        : const Color(0xFFB0BD96);
    final titleColor = isDark
        ? const Color(0xFFE5EEE3)
        : const Color(0xFF1E2816);
    final subtitleColor = isDark
        ? const Color(0xFFA1B3A0)
        : const Color(0xFF38472E);
    final buttonBg = isDark
        ? AppColors.primary
        : const Color(0xFF2C371D);
    final buttonTextColor = Colors.white;

    return Material(
      color: bgColor,
      child: InkWell(
        onTap: () => _handleTap(context, ref, surahId, rawSurahName, ayahNumber),
        splashColor: Colors.black.withValues(alpha: 0.08),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: borderColor, width: 1.0),
            ),
          ),
          child: Row(
            children: [
              // Right Side: Surah Info + Ayah Number (Pure text, NO icons)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'سوره $surahFaName - آیه شماره ${ayahNumber.toPersianDigit()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      surahId == 1 && ayahNumber == 1
                          ? 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'
                          : 'آخرین موقعیت قرائت شما در قرآن کریم',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Left Side: "ادامه مطالعه" Action Button (Text only, NO icon)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: buttonBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ادامه مطالعه',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: buttonTextColor,
                  ),
                ),
              ),
            ],
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
