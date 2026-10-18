import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/extensions/string_extension.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';

/// Summary confirmation card presented in Step 3 before saving the Khatm.
/// Borderless design with soft filled background.
class KhatmConfirmationCard extends StatelessWidget {
  final String title;
  final KhatmUnitType unitType;
  final int rangeFrom;
  final int rangeTo;
  final int sessionCount;
  final int quotaPerSession;
  final KhatmCadence cadence;
  final String startDateFa;
  final String endDateFa;

  const KhatmConfirmationCard({
    super.key,
    required this.title,
    required this.unitType,
    required this.rangeFrom,
    required this.rangeTo,
    required this.sessionCount,
    required this.quotaPerSession,
    required this.cadence,
    required this.startDateFa,
    required this.endDateFa,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackgroundSubtle,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'خلاصه مشخصات ختم',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'اطلاعات زیر را بررسی و تایید کنید',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.5,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          Container(
            height: 0.8,
            color: colors.cardBorder.withValues(alpha: 0.4),
            margin: const EdgeInsets.symmetric(vertical: 16),
          ),
          _buildRow(
            context: context,
            label: 'عنوان ختم:',
            value: title,
            valueStyle: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          _buildRow(
            context: context,
            label: 'محدوده تلاوت:',
            value:
                'از ${unitType.labelFa} ${rangeFrom.toPersianDigit()} تا ${rangeTo.toPersianDigit()} (${(rangeTo - rangeFrom + 1).toPersianDigit()} ${unitType.labelFa})',
          ),
          _buildRow(
            context: context,
            label: 'تعداد کل جلسات:',
            value: '${sessionCount.toPersianDigit()} جلسه',
          ),
          _buildRow(
            context: context,
            label: 'سهمیه هر جلسه:',
            value: 'حدود ${quotaPerSession.toPersianDigit()} ${unitType.labelFa}',
          ),
          _buildRow(
            context: context,
            label: 'نحوه برگزاری:',
            value: cadence.labelFa,
          ),
          _buildRow(
            context: context,
            label: 'تاریخ شروع:',
            value: startDateFa.toPersianDigit(),
          ),
          _buildRow(
            context: context,
            label: 'تاریخ پایان:',
            value: endDateFa.toPersianDigit(),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required BuildContext context,
    required String label,
    required String value,
    TextStyle? valueStyle,
    bool isLast = false,
  }) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: valueStyle ??
                  TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
