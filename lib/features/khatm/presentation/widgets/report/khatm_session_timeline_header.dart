import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/core/theme/app_typography.dart';

/// Clean table column header for the sessions timeline («ردیف» | «عنوان» | «تاریخ»).
class KhatmSessionTimelineHeader extends StatelessWidget {
  const KhatmSessionTimelineHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final headerColor = isDark ? Colors.white54 : const Color(0xFF7A756D);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // ردیف (Right in RTL)
          SizedBox(
            width: 44,
            child: Text(
              'ردیف',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: headerColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // عنوان (Middle)
          Expanded(
            child: Text(
              'عنوان جلسه',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: headerColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // تاریخ (Left in RTL)
          SizedBox(
            width: 85,
            child: Text(
              'تاریخ',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: headerColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
