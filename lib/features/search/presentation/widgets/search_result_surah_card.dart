import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/search_result_item.dart';
import 'search_highlight_text.dart';

class SearchResultSurahCard extends ConsumerWidget {
  final SearchResultItem item;
  final String query;
  final VoidCallback onTap;

  const SearchResultSurahCard({
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              children: [
                // Surah Number Badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? colors.goldAccent.withValues(alpha: 0.12)
                        : const Color(0xFFF3EFE6),
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                    border: Border.all(
                      color: isDark
                          ? colors.goldAccent.withValues(alpha: 0.25)
                          : const Color(0xFFDFD7C7),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item.surahNumber.toPersianDigit(),
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? colors.goldAccent : colorScheme.primary,
                    ),
                  ),
                ),
                12.hSpace,

                // Surah Name and Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SearchHighlightText(
                        text: 'سوره ${item.surahNumber.surahNameFa}',
                        query: query,
                        baseStyle: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      4.vSpace,
                      Row(
                        children: [
                          SearchHighlightText(
                            text: item.englishName,
                            query: query,
                            baseStyle: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '• ${item.revelationType == 'Meccan' ? 'مکی' : 'مدنی'}',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11.5,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${item.numberOfAyahs?.toPersianDigit() ?? '۰'} آیه',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow indicator
                8.hSpace,
                Icon(
                  CupertinoIcons.chevron_left,
                  size: 16,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
