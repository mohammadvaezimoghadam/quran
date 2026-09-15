import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_segmented_tab_bar.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/surah_list_controller.dart';
import '../../domain/enums/surah_sort_options.dart';

/// Clean Apple-Style Bottom Sheet for Sorting Surahs (by Number, Name, Ayah Count, Revelation Order)
class SurahSortBottomSheet extends ConsumerStatefulWidget {
  const SurahSortBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SurahSortBottomSheet(),
    );
  }

  @override
  ConsumerState<SurahSortBottomSheet> createState() =>
      _SurahSortBottomSheetState();
}

class _SurahSortBottomSheetState extends ConsumerState<SurahSortBottomSheet> {
  late SurahSortBy _tempSortBy;
  late SortOrder _tempSortOrder;

  @override
  void initState() {
    super.initState();
    final currentState = ref.read(surahListControllerProvider);
    _tempSortBy = currentState.sortBy;
    _tempSortOrder = currentState.sortOrder;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.dialogSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: context.screenPadding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4.5,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header - Centered with balanced spacer
          Row(
            children: [
              48.hSpace,
              const Expanded(
                child: Text(
                  'مرتب‌سازی سوره‌ها',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'بستن',
                icon: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  size: 24,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          16.vSpace,

          // 1. Hayat/Tafakor Style Segmented Control for Sort Order
          AppSegmentedTabBar(
            items: const [
              AppSegmentedTabItem(title: 'صعودی (الف تا ی / ۱ تا ۱۱۴)'),
              AppSegmentedTabItem(title: 'نزولی (ی تا الف / ۱۱۴ تا ۱)'),
            ],
            selectedIndex: _tempSortOrder == SortOrder.ascending ? 0 : 1,
            onTabSelected: (index) {
              setState(() {
                _tempSortOrder = index == 0 ? SortOrder.ascending : SortOrder.descending;
              });
            },
          ),

          18.vSpace,

          // 2. Apple Inset Grouped Card for Sort Criteria
          Container(
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.cardBorder,
                width: 0.8,
              ),
            ),
            child: Column(
              children: SurahSortBy.values.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isSelected = _tempSortBy == option;
                final isLast = index == SurahSortBy.values.length - 1;

                return Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() => _tempSortBy = option);
                        },
                        borderRadius: BorderRadius.vertical(
                          top: index == 0 ? const Radius.circular(16) : Radius.zero,
                          bottom: isLast ? const Radius.circular(16) : Radius.zero,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          child: Row(
                            children: [
                              Text(
                                option.label,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 14.5,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                Icon(
                                  CupertinoIcons.checkmark_alt,
                                  size: 19,
                                  color: colorScheme.primary,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        thickness: 0.8,
                        indent: 16,
                        endIndent: 16,
                        color: colors.cardBorder,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),

          22.vSpace,

          // 3. Confirm Button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                ),
                elevation: 0,
              ),
              onPressed: () {
                final notifier =
                    ref.read(surahListControllerProvider.notifier);
                notifier.setSortBy(_tempSortBy);
                notifier.setSortOrder(_tempSortOrder);
                Navigator.pop(context);
              },
              child: const Text(
                'اعمال مرتب‌سازی',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          4.vSpace,
        ],
      ),
    );
  }

}
