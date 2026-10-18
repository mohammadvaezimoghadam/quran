import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/extensions/string_extension.dart';
import 'package:quran/common/utils/jalali_date.dart';
import 'package:quran/core/theme/app_typography.dart';

/// Interactive Shamsi date picker field («تاریخ شروع»).
/// Borderless design with soft filled background and outside label.
class KhatmJalaliDatePicker extends StatelessWidget {
  final JalaliDate selectedDate;
  final ValueChanged<JalaliDate> onDateChanged;

  const KhatmJalaliDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  Future<void> _pickDate(BuildContext context) async {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final now = JalaliDate.now();
    int tempYear = selectedDate.year;
    int tempMonth = selectedDate.month;
    int tempDay = selectedDate.day;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final testDate = JalaliDate(tempYear, tempMonth, 1);
            final maxDays = testDate.daysInMonth;
            if (tempDay > maxDays) tempDay = maxDays;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              height: 320,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'انصراف',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        'انتخاب تاریخ شروع',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          onDateChanged(JalaliDate(tempYear, tempMonth, tempDay));
                          Navigator.pop(context);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          'تایید',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 0.8,
                    color: colors.cardBorder.withValues(alpha: 0.5),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        // روز (Day)
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 38,
                            scrollController: FixedExtentScrollController(
                              initialItem: tempDay - 1,
                            ),
                            onSelectedItemChanged: (index) {
                              setModalState(() => tempDay = index + 1);
                            },
                            children: List.generate(maxDays, (i) {
                              return Center(
                                child: Text(
                                  (i + 1).toPersianDigit(),
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 16,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        // ماه (Month)
                        Expanded(
                          flex: 2,
                          child: CupertinoPicker(
                            itemExtent: 38,
                            scrollController: FixedExtentScrollController(
                              initialItem: tempMonth - 1,
                            ),
                            onSelectedItemChanged: (index) {
                              setModalState(() => tempMonth = index + 1);
                            },
                            children: List.generate(12, (i) {
                              final d = JalaliDate(tempYear, i + 1, 1);
                              return Center(
                                child: Text(
                                  d.monthName,
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 15.5,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        // سال (Year)
                        Expanded(
                          flex: 2,
                          child: CupertinoPicker(
                            itemExtent: 38,
                            scrollController: FixedExtentScrollController(
                              initialItem:
                                  (tempYear - (now.year - 2)).clamp(0, 9),
                            ),
                            onSelectedItemChanged: (index) {
                              setModalState(
                                  () => tempYear = (now.year - 2) + index);
                            },
                            children: List.generate(10, (i) {
                              final y = (now.year - 2) + i;
                              return Center(
                                child: Text(
                                  y.toPersianDigit(),
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 16,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final inputBg = isDark ? const Color(0xFF242426) : const Color(0xFFEEEBE4);
    final inputBorder = Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.06),
      width: 0.8,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تاریخ شروع',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickDate(context),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(14),
              border: inputBorder,
            ),
            alignment: Alignment.centerRight,
            child: Text(
              selectedDate.formatFa().toPersianDigit(),
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
