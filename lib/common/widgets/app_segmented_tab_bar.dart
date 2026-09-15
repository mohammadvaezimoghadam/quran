import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_typography.dart';
import '../extensions/context_extension.dart';

/// Single item descriptor for [AppSegmentedTabBar]
class AppSegmentedTabItem {
  final String title;
  final IconData? icon;
  final String? badge;

  const AppSegmentedTabItem({
    required this.title,
    this.icon,
    this.badge,
  });
}

/// Unified, Hayat/Tafakor-inspired Segmented Tab Bar for Bottom Sheets & Dialogs.
/// Adapts seamlessly to the app's dark (mint green #52C498) and light (emerald #005C55) palettes.
class AppSegmentedTabBar extends StatelessWidget {
  final List<AppSegmentedTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final double height;

  const AppSegmentedTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTabSelected,
    this.height = 42,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primaryColor = context.colorScheme.primary;

    // Track Styling (Hayat Modular Token System)
    final trackBg = isDark
        ? const Color(0xFF181717)
        : const Color(0xFFF2EFEB);

    final trackBorder = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE2DDD5);

    // Active Pill Styling
    final activePillBg = isDark
        ? const Color(0xFF23352B)
        : const Color(0xFFE2EDE7);

    final activePillBorder = isDark
        ? primaryColor.withValues(alpha: 0.35)
        : primaryColor.withValues(alpha: 0.22);

    // Inactive Text Styling
    final inactiveTextColor = isDark
        ? const Color(0xFF9E9E9E)
        : const Color(0xFF6E6D68);

    return Container(
      height: height,
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: trackBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: trackBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = selectedIndex == index;

          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (!isSelected) {
                    HapticFeedback.selectionClick();
                    onTabSelected(index);
                  }
                },
                borderRadius: BorderRadius.circular(10.5),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? activePillBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.5),
                    border: isSelected
                        ? Border.all(color: activePillBorder, width: 0.8)
                        : null,
                    boxShadow: isSelected && !isDark
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.icon != null) ...[
                        Icon(
                          item.icon,
                          size: 16,
                          color: isSelected ? primaryColor : inactiveTextColor,
                        ),
                        const SizedBox(width: 5),
                      ],
                      Flexible(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? primaryColor : inactiveTextColor,
                          ),
                        ),
                      ),
                      if (item.badge != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          item.badge!,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? primaryColor.withValues(alpha: 0.9)
                                : inactiveTextColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
