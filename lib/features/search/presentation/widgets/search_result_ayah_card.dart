import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../core/theme/app_dimens.dart';
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
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final arabicFontFamily = AppTypography.getFontFamilyByScript(fontScript);

    final arabicText = item.arabicText ?? '';
    final translationText = item.translationText ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: colors.cardBorder,
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
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: Surah Name, Ayah Number, Page, Juz
                Row(
                  children: [
                    // Surah & Ayah Info
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'سوره ${item.surahNumber.surahNameFa}',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? colors.goldAccent
                                : colorScheme.primary,
                          ),
                        ),
                        4.hSpace,
                        Text(
                          '• آیه ${item.ayahNumber?.toPersianDigit() ?? '۱'}',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? colors.goldAccent.withValues(alpha: 0.8)
                                : colorScheme.primary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
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

                // Matched in translation indicator if applicable
                if (item.matchedInTranslation) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.translate_rounded,
                        size: 13,
                        color: isDark ? Colors.amber[300] : const Color(0xFFB78103),
                      ),
                      4.hSpace,
                      Text(
                        'تطابق در ترجمه',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          color: isDark ? Colors.amber[300] : const Color(0xFFB78103),
                          fontWeight: FontWeight.w500,
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
