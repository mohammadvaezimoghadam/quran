import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../quran_reader/application/controllers/quran_display_settings_controller.dart';

import '../../../../../common/extensions/int_extension.dart';
import '../../../../../common/extensions/size_extension.dart';
import '../../../../../core/routes/route_name.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

/// Sacred Minimalist "Continue Reading" Widget (ویجت ادامه خواندن)
/// Pixel-perfect implementation matching the reference UI design.
class ContinueReadingCard extends ConsumerWidget {
  const ContinueReadingCard({super.key});

  // Placeholder data for UI demonstration
  static const String _surahName = 'سورة البقرة';
  static const int _surahId = 2;
  static const int _ayahNumber = 142;
  static const int _totalAyahs = 286;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final double progress = 0.50; // 50% matching reference image
    final String progressPercentText = '${50.toPersianDigit()}%';
    final String ayahInfoText =
        'آیه ${_ayahNumber.toPersianDigit()} از ${_totalAyahs.toPersianDigit()}';

    // Theme-Aware Colors (High Contrast & Perfect Readability)
    final cardBgColor = isDark ? const Color(0xFF192220) : Colors.white;
    final cardBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFEAE7E3);
        
    final headerColor = isDark ? const Color(0xFF52C498) : AppColors.primary;
    final titleColor = isDark ? const Color(0xFFF4E0A5) : const Color(0xFF947124);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252);
    
    final buttonBgColor = AppColors.primary;
    final buttonTextColor = const Color(0xFFF4E0A5);
    final gaugeColor = isDark ? const Color(0xFF52C498) : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: cardBorderColor,
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18.0,
                  spreadRadius: 0.0,
                  offset: const Offset(0, 6.0),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24.0),
        child: InkWell(
          onTap: () {
            ref.read(quranDisplaySettingsControllerProvider.notifier).toggleArabicText(true);
            Future.microtask(() {
              if (context.mounted) {
                context.pushNamed(
                  quranReaderRoute,
                  pathParameters: {'id': _surahId.toString()},
                  queryParameters: {'name': _surahName},
                );
              }
            });
          },
          borderRadius: BorderRadius.circular(24.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 22.0,
              vertical: 20.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Positioned on RIGHT in RTL: Title, Surah Name, Ayah Info, and "ادامه >" Button
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // "ادامه خواندن" Header
                      Text(
                        'ادامه خواندن',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: headerColor,
                          height: 1.2,
                        ),
                      ),
                      4.vSpace,

                      // "سورة البقرة" Title
                      Text(
                        _surahName,
                        style: TextStyle(
                          fontFamily: AppTypography.neyriziFont,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                          height: 1.3,
                        ),
                      ),
                      4.vSpace,

                      // "آیه ۱۴۲ از ۲۸۶" Subtitle
                      Text(
                        ayahInfoText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: subtitleColor,
                          height: 1.3,
                        ),
                      ),
                      14.vSpace,

                      // Solid Pill Button with "ادامه >"
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: buttonBgColor,
                          borderRadius: BorderRadius.circular(30.0),
                          boxShadow: [
                            BoxShadow(
                              color: buttonBgColor.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ادامه',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: buttonTextColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              CupertinoIcons.chevron_back,
                              size: 18,
                              color: buttonTextColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                16.hSpace,

                // 2. Positioned on LEFT in RTL: Circular Progress Gauge with 50% & Checkmark
                SizedBox(
                  width: 110,
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 104,
                        height: 104,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 9.0,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.10)
                              : const Color(0xFFEFEFEF),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            gaugeColor,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            progressPercentText,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: gaugeColor,
                              height: 1.1,
                            ),
                          ),
                          4.vSpace,
                          Icon(
                            CupertinoIcons.checkmark,
                            size: 22,
                            color: gaugeColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
