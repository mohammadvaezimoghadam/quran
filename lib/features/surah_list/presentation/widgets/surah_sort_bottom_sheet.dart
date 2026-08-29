import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/surah_list_controller.dart';
import '../../domain/enums/surah_sort_options.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusMd),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.paddingOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          const Text(
            'مرتب‌سازی سوره‌ها',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // 1. Sort Order Selector (Ascending / Descending)
          const Text(
            'جهت مرتب‌سازی',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _OrderChip(
                  label: 'صعودی',
                  isSelected: _tempSortOrder == SortOrder.ascending,
                  onTap: () {
                    setState(() {
                      _tempSortOrder = SortOrder.ascending;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OrderChip(
                  label: 'نزولی',
                  isSelected: _tempSortOrder == SortOrder.descending,
                  onTap: () {
                    setState(() {
                      _tempSortOrder = SortOrder.descending;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. Sort Criteria List
          const Text(
            'بر اساس',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          ...SurahSortBy.values.map(
            (option) => _SortOptionTile(
              option: option,
              isSelected: _tempSortBy == option,
              onTap: () {
                setState(() {
                  _tempSortBy = option;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // 3. Theme-matching Green Confirm Button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.darkPrimaryContainer
                    : colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                ),
                elevation: 2,
              ),
              onPressed: () {
                final notifier =
                    ref.read(surahListControllerProvider.notifier);
                notifier.setSortBy(_tempSortBy);
                notifier.setSortOrder(_tempSortOrder);
                Navigator.pop(context);
              },
              child: const Text(
                'تایید',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _OrderChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrderChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.darkPrimaryContainer
        : Theme.of(context).colorScheme.primary;
    final activeTextColor = isDark
        ? AppColors.softGoldText
        : Theme.of(context).colorScheme.primary;

    return Material(
      color: isSelected
          ? primaryColor.withValues(alpha: isDark ? 0.3 : 0.12)
          : (isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.withValues(alpha: 0.08)),
      borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeTextColor : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  final SurahSortBy option;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.darkPrimaryContainer
        : Theme.of(context).colorScheme.primary;
    final activeTextColor = isDark
        ? AppColors.softGoldText
        : Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Material(
        color: isSelected
            ? primaryColor.withValues(alpha: isDark ? 0.25 : 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                option.label,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? activeTextColor : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
