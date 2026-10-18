import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';

/// Segmented option selector for planning mode («نوع برنامه‌ریزی»).
/// Borderless design with soft filled background.
class KhatmPlanningModeRadio extends StatelessWidget {
  final KhatmPlanningMode selected;
  final String unitLabel;
  final ValueChanged<KhatmPlanningMode> onChanged;

  const KhatmPlanningModeRadio({
    super.key,
    required this.selected,
    required this.unitLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع برنامه‌ریزی',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // براساس جلسه
            Expanded(
              child: _buildOptionTile(
                context: context,
                title: 'براساس جلسه',
                isSelected: selected == KhatmPlanningMode.bySessionCount,
                onTap: () => onChanged(KhatmPlanningMode.bySessionCount),
                colors: colors,
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 12),
            // براساس واحد (مثلاً براساس حزب)
            Expanded(
              child: _buildOptionTile(
                context: context,
                title: 'براساس $unitLabel',
                isSelected: selected == KhatmPlanningMode.byUnitQuota,
                onTap: () => onChanged(KhatmPlanningMode.byUnitQuota),
                colors: colors,
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required dynamic colors,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colors.cardBackgroundSubtle,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? colorScheme.primary
                    : colors.cardBorder.withValues(alpha: 0.6),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
