import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/string_extension.dart';
import '../../../../common/utils/arabic_text_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import '../../application/controllers/word_by_word_provider.dart';
import '../../domain/entities/word_entity.dart';

/// Screen displaying the entire word-by-word vocabulary of a chosen Surah
class SurahDictionaryScreen extends ConsumerWidget {
  final int surahId;
  final String surahName;

  const SurahDictionaryScreen({
    super.key,
    required this.surahId,
    required this.surahName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use pre-grouped provider so grouping and sorting happens only once in background
    final groupedWordsAsync = ref.watch(surahDictionaryGroupedProvider(surahId));

    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final harakatColorHex = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.harakatColor),
    );
    final fontFamily = AppTypography.getFontFamilyByScript(fontScript);
    final harakatColor = ArabicTextHelper.parseHexColor(harakatColorHex);

    final baseArabicColor =
        isDark ? AppColors.goldAccent : const Color(0xFF1E262C);
    final baseArabicStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 19,
      height: 1.4,
      fontWeight: FontWeight.bold,
      color: baseArabicColor,
    );
    final bool useCustomColor =
        harakatColor != null && harakatColor != baseArabicColor;

    final cleanSurahName = surahName
        .replaceAll('سورة', '')
        .replaceAll('سوره', '')
        .trim();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF141C1A) : const Color(0xFFF9F7F2),
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            text: 'لغت‌نامه سوره ',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2C2A29),
            ),
            children: [
              TextSpan(
                text: cleanSurahName,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.goldAccent : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF192220) : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.arrow_right,
            color: isDark ? Colors.white70 : const Color(0xFF2C2A29),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: groupedWordsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 12),
                Text(
                  'خطا در دریافت اطلاعات لغت‌نامه:\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(surahDictionaryGroupedProvider(surahId)),
                  child: const Text('تلاش مجدد'),
                ),
              ],
            ),
          ),
        ),
        data: (ayahGroups) {
          if (ayahGroups.isEmpty) {
            return const Center(
              child: Text(
                'هیچ لغتی برای این سوره یافت نشد.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            itemCount: ayahGroups.length,
            itemBuilder: (context, index) {
              final group = ayahGroups[index];
              final ayahWords = group.words;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B2523) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFEBE7DF),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ayah Header Banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.goldAccent.withValues(alpha: 0.12)
                            : AppColors.primary.withValues(alpha: 0.07),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.goldAccent
                                  : AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'آیه ${group.ayahNumber.toString().toPersianDigit()}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${ayahWords.length.toString().toPersianDigit()} کلمه',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.goldAccent
                                  : AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Words list: Direct Column instead of nested ListView.shrinkWrap to eliminate layout thrashing
                    Column(
                      children: [
                        for (int i = 0; i < ayahWords.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : const Color(0xFFF0EDE6),
                            ),
                          _WordRow(
                            word: ayahWords[i],
                            isEven: i % 2 == 0,
                            baseArabicStyle: baseArabicStyle,
                            baseArabicColor: baseArabicColor,
                            harakatColor: harakatColor,
                            useCustomColor: useCustomColor,
                            isDark: isDark,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Lightweight, stateless widget for each vocabulary row
class _WordRow extends StatelessWidget {
  final WordEntity word;
  final bool isEven;
  final TextStyle baseArabicStyle;
  final Color baseArabicColor;
  final Color? harakatColor;
  final bool useCustomColor;
  final bool isDark;

  const _WordRow({
    required this.word,
    required this.isEven,
    required this.baseArabicStyle,
    required this.baseArabicColor,
    required this.harakatColor,
    required this.useCustomColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven
          ? Colors.transparent
          : (isDark
              ? Colors.white.withValues(alpha: 0.015)
              : const Color(0xFFFAF9F6)),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Arabic Word (Right side)
          Expanded(
            flex: 5,
            child: useCustomColor
                ? RichText(
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    text: TextSpan(
                      style: baseArabicStyle,
                      children: ArabicTextHelper.buildColoredSpans(
                        text: word.arabicText,
                        baseStyle: baseArabicStyle,
                        baseColor: baseArabicColor,
                        harakatColor: harakatColor!,
                      ),
                    ),
                  )
                : Text(
                    word.arabicText,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: baseArabicStyle,
                  ),
          ),

          const SizedBox(width: 10),

          // Subtle arrow icon
          Icon(
            CupertinoIcons.arrow_left,
            size: 13,
            color: isDark ? Colors.white24 : Colors.black26,
          ),

          const SizedBox(width: 10),

          // Persian Translation (Left side)
          Expanded(
            flex: 6,
            child: Text(
              word.translation,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13.5,
                height: 1.3,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.88)
                    : const Color(0xFF3E3B38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
