import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../domain/entities/search_result_item.dart';
import 'search_highlight_text.dart';

class SearchResultAyahCard extends ConsumerWidget {
  final SearchResultItem item;
  final String query;
  final VoidCallback onTap;

  const SearchResultAyahCard({
    super.key,
    required this.item,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final arabicFontFamily = AppTypography.getFontFamilyByScript(fontScript);

    final arabicText = item.arabicText ?? '';
    final translationText = item.translationText ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2320) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFEBE8E3),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: Surah Name, Ayah Number, Page, Juz
                Row(
                  children: [
                    // Surah & Ayah Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.goldAccent.withValues(alpha: 0.12)
                            : const Color(0xFFF3EFE6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'سوره ${item.surahNumber.surahNameFa}',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.goldAccent
                                  : AppColors.primary,
                            ),
                          ),
                          4.hSpace,
                          Text(
                            '• آیه ${item.ayahNumber?.toPersianDigit() ?? '۱'}',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.goldAccent
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Page & Juz Info
                    if (item.pageNumber != null)
                      Text(
                        'ص ${item.pageNumber!.toPersianDigit()} • جزء ${item.juzNumber?.toPersianDigit() ?? '۱'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    8.hSpace,
                    Icon(
                      CupertinoIcons.chevron_left,
                      size: 14,
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
                  ],
                ),
                10.vSpace,

                // Matched in translation tag if applicable
                if (item.matchedInTranslation) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.amber.withValues(alpha: 0.12)
                              : const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? Colors.amber.withValues(alpha: 0.3)
                                : const Color(0xFFFFE082),
                          ),
                        ),
                        child: Text(
                          'تطابق در ترجمه',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.amber[300] : const Color(0xFFB78103),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  8.vSpace,
                ],

                // Arabic Ayah Text
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: SearchHighlightText(
                    text: arabicText,
                    query: query,
                    textAlign: TextAlign.justify,
                    baseStyle: TextStyle(
                      fontFamily: arabicFontFamily,
                      fontSize: 18,
                      height: 1.8,
                      color: isDark ? Colors.white : const Color(0xFF1E2421),
                    ),
                  ),
                ),

                // Translation Text
                if (translationText.isNotEmpty) ...[
                  10.vSpace,
                  Container(
                    padding: const EdgeInsets.only(top: 8.0),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : const Color(0xFFF0ECE6),
                        ),
                      ),
                    ),
                    child: SearchHighlightText(
                      text: translationText,
                      query: query,
                      textAlign: TextAlign.justify,
                      baseStyle: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12.5,
                        height: 1.65,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.65)
                            : const Color(0xFF55524C),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
