import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/extensions/string_extension.dart';
import 'package:quran/common/utils/jalali_date.dart';
import 'package:quran/core/theme/app_typography.dart';
import '../../../domain/entities/group_khatm_campaign.dart';
import '../../../domain/entities/group_khatm_slot.dart';

/// Clean card displaying the active user's reserved slot with status and actions.
/// Layout and styling match the refined Sacred Serenity aesthetics:
/// - "سهم فعال شما در این ختم" header with deadline text
/// - Inner card for slot unit title and "در دست قرائت" badge
/// - Primary action button ("تأیید اتمام قرائت") and text button ("انصراف یا ویرایش")
/// - Direct tap to start reading Quran
/// - Ultra-thin, faint borders (0.5px) without heavy outlines
/// - Zero decorative icons and zero yellow
class GroupKhatmMySlotCard extends StatelessWidget {
  final GroupKhatmSlot slot;
  final GroupKhatmCampaign campaign;
  final VoidCallback onStartReading;
  final VoidCallback onComplete;
  final VoidCallback onRelease;

  const GroupKhatmMySlotCard({
    super.key,
    required this.slot,
    required this.campaign,
    required this.onStartReading,
    required this.onComplete,
    required this.onRelease,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final hours = slot.hoursRemaining;

    final unitLabel = slot.unitNumber != null
        ? '${campaign.unitTypeLabel} ${slot.unitNumber!.toPersianDigit()}'
        : 'سهم شما (${slot.quantity.toPersianDigit()} مرتبه)';

    final pillBg = isDark ? const Color(0xFF222224) : const Color(0xFFF3F1EC);

    // Subtle hairline border (ultra-thin and faint)
    final hairlineBorder = Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.04),
      width: 0.5,
    );

    final String dateFa = slot.reservedAt != null
        ? JalaliDate.fromDateTime(slot.reservedAt!).formatFa().toPersianDigit()
        : '';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: hairlineBorder,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── ۱. عنوان سهم فعال و زمان باقی‌مانده ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'سهم فعال شما در این ختم',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              if (hours != null)
                Text(
                  hours > 0
                      ? 'مهلت باقی‌مانده: ${hours.toPersianDigit()} ساعت'
                      : 'مهلت باقی‌مانده: کمتر از ۱ ساعت',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // ── ۲. کادر مشخصات سهم با قابلیت تپ برای شروع تلاوت ──
          InkWell(
            onTap: onStartReading,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.03),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unitLabel,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (dateFa.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          'ثبت شده در $dateFa (لمس جهت تلاوت قرآن)',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.04),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      'در دست قرائت',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── ۳. دکمه‌های اقدام (تأیید اتمام قرائت / انصراف یا ویرایش) ──
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 42,
                  child: FilledButton(
                    onPressed: onComplete,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'تأیید اتمام قرائت',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextButton(
                    onPressed: onRelease,
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'انصراف یا ویرایش',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
