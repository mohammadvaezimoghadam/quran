import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/search_filter_type.dart';

class SearchFilterChips extends StatelessWidget {
  final SearchFilterType selectedFilter;
  final ValueChanged<SearchFilterType> onFilterSelected;
  final int totalResults;
  final int surahCount;
  final int ayahCount;

  const SearchFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    this.totalResults = 0,
    this.surahCount = 0,
    this.ayahCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: SearchFilterType.values.map((filter) {
          final isSelected = selectedFilter == filter;

          String countSuffix = '';
          if (totalResults > 0) {
            if (filter == SearchFilterType.all) {
              countSuffix = ' ($totalResults)';
            } else if (filter == SearchFilterType.surahs && surahCount > 0) {
              countSuffix = ' ($surahCount)';
            } else if (filter == SearchFilterType.ayahs && ayahCount > 0) {
              countSuffix = ' ($ayahCount)';
            }
          }

          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onFilterSelected(filter),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 7.0,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? AppColors.goldAccent.withValues(alpha: 0.18)
                              : AppColors.primary)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : const Color(0xFFF3F0EB)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? (isDark
                                ? AppColors.goldAccent
                                : AppColors.primary)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${filter.label}$countSuffix',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? (isDark ? AppColors.goldAccent : Colors.white)
                            : (isDark
                                ? Colors.white70
                                : const Color(0xFF5A5852)),
                      ),
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
