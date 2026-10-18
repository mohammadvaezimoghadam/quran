import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/core/theme/app_typography.dart';

/// Multi-select day selector for choosing specific weekdays.
/// Borderless design with soft filled chips.
class KhatmWeekdaySelector extends StatelessWidget {
  final List<int> selectedWeekdays; // 1 = Monday ... 7 = Sunday
  final ValueChanged<int> onToggle;

  const KhatmWeekdaySelector({
    super.key,
    required this.selectedWeekdays,
    required this.onToggle,
  });

  static const List<({int weekday, String label})> _days = [
    (weekday: 6, label: 'شنبه'),
    (weekday: 7, label: 'یکشنبه'),
    (weekday: 1, label: 'دوشنبه'),
    (weekday: 2, label: 'سه‌شنبه'),
    (weekday: 3, label: 'چهارشنبه'),
    (weekday: 4, label: 'پنج‌شنبه'),
    (weekday: 5, label: 'جمعه'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'روزهای تلاوت در هفته:',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _days.map((day) {
            final isSelected = selectedWeekdays.contains(day.weekday);
            return InkWell(
              onTap: () => onToggle(day.weekday),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colors.cardBackgroundSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  day.label,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
