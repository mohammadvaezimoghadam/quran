import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../core/theme/app_colors.dart';

class SearchRecentHistoryView extends StatelessWidget {
  final List<String> recentSearches;
  final ValueChanged<String> onSearchSelected;
  final ValueChanged<String> onRemoveSearch;
  final VoidCallback onClearAll;

  const SearchRecentHistoryView({
    super.key,
    required this.recentSearches,
    required this.onSearchSelected,
    required this.onRemoveSearch,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (recentSearches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.search,
                size: 52,
                color: isDark ? Colors.white24 : Colors.black12,
              ),
              16.vSpace,
              Text(
                'جستجو در قرآن کریم',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              8.vSpace,
              Text(
                'می‌توانید نام سوره، شماره سوره، کلمات آیه به عربی یا ترجمه فارسی را جستجو کنید.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.6,
                  color: isDark ? Colors.white38 : Colors.black45,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.clock,
                size: 16,
                color: isDark ? AppColors.goldAccent : AppColors.primary,
              ),
              8.hSpace,
              Text(
                'جستجوهای اخیر',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onClearAll,
                child: Text(
                  'پاک کردن همه',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.white38 : Colors.black45,
                  ),
                ),
              ),
            ],
          ),
          12.vSpace,
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: recentSearches.map((term) {
              return Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFF1EFEA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFE5E2DB),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSearchSelected(term),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 6.0,
                        right: 12.0,
                        top: 5.0,
                        bottom: 5.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            term,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          6.hSpace,
                          GestureDetector(
                            onTap: () => onRemoveSearch(term),
                            child: Icon(
                              CupertinoIcons.xmark,
                              size: 13,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
