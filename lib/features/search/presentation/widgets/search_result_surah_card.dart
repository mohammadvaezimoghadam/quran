import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/surah_name_extension.dart';
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.cardBorder,
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              children: [
                // Surah Number Badge in Tafakor Mint Green
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(
                      alpha: isDark ? 0.16 : 0.10,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withValues(
                        alpha: isDark ? 0.35 : 0.22,
                      ),
                      width: 0.8,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item.surahNumber.toPersianDigit(),
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
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
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      3.vSpace,
                      Row(
                        children: [
                          SearchHighlightText(
                            text: item.englishName,
                            query: query,
                            baseStyle: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '• ${item.revelationType == 'Meccan' ? 'مکی' : 'مدنی'}',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11.5,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${item.numberOfAyahs?.toPersianDigit() ?? '۰'} آیه',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11.5,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron indicator
                8.hSpace,
                Icon(
                  CupertinoIcons.chevron_left,
                  size: 13,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
