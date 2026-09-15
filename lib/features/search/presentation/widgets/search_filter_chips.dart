import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/search_filter_type.dart';

class SearchFilterChips extends StatelessWidget {
  final SearchFilterType selectedFilter;
  final ValueChanged<SearchFilterType> onFilterSelected;
  final int totalResults;
  final int surahCount;
  final int ayahCount;
  final int translationCount;

  const SearchFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    this.totalResults = 0,
    this.surahCount = 0,
    this.ayahCount = 0,
    this.translationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: SearchFilterType.values.map((filter) {
          final isSelected = selectedFilter == filter;

          String countSuffix = '';
          if (totalResults > 0) {
            switch (filter) {
              case SearchFilterType.all:
                countSuffix = ' (${totalResults.toPersianDigit()})';
                break;
              case SearchFilterType.surahs:
                countSuffix = surahCount > 0
                    ? ' (${surahCount.toPersianDigit()})'
                    : ' (۰)';
                break;
              case SearchFilterType.ayahs:
                countSuffix = ayahCount > 0
                    ? ' (${ayahCount.toPersianDigit()})'
                    : ' (۰)';
                break;
              case SearchFilterType.translations:
                countSuffix = translationCount > 0
                    ? ' (${translationCount.toPersianDigit()})'
                    : ' (۰)';
                break;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onFilterSelected(filter);
                },
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 7.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withValues(
                            alpha: isDark ? 0.20 : 0.12,
                          )
                        : colors.cardBackground,
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary.withValues(
                              alpha: isDark ? 0.50 : 0.35,
                            )
                          : colors.cardBorder,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '${filter.label}$countSuffix',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.primary
                          : (isDark
                              ? Colors.white60
                              : const Color(0xFF6B6760)),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
