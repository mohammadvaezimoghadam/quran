import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/extensions/string_extension.dart';
import 'package:quran/common/utils/jalali_date.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_campaign.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';

/// Clean card displaying a collective Group Khatm campaign in lists.
/// Strictly follows Sacred Serenity theme tokens (warm neutrals, subtle borders, no green saturation).
class GroupKhatmCard extends StatelessWidget {
  final GroupKhatmCampaign campaign;
  final VoidCallback? onTap;

  const GroupKhatmCard({
    super.key,
    required this.campaign,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final colorScheme = theme.colorScheme;

    final isDark = context.isDark;

    final isCompleted = campaign.status == GroupKhatmStatus.completed;
    final hasActiveSlot = campaign.mySlots.any((s) => s.status == GroupKhatmSlotStatus.reserved);

    final startDateFa =
        JalaliDate.fromDateTime(campaign.createdAt).formatFa().toPersianDigit();
    final deadlineFa = campaign.deadline != null
        ? JalaliDate.fromDateTime(campaign.deadline!).formatFa().toPersianDigit()
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasActiveSlot
              ? colorScheme.primary.withValues(alpha: 0.35)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.04)),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Category tag & Unit badge
                Row(
                  children: [
                    if (campaign.categoryTitle != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.cardBackgroundSubtle,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: colors.cardBorder),
                        ),
                        child: Text(
                          campaign.categoryTitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.cardBackgroundSubtle,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: Text(
                        campaign.unitTypeLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.cardBackgroundSubtle,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: colors.cardBorder),
                        ),
                        child: Text(
                          'تکمیل شده',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (hasActiveSlot)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'سهم فعال شما',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  campaign.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                if (campaign.description != null && campaign.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    campaign.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 14),

                // Progress Bar & Percentage
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: campaign.progressPercent / 100,
                    minHeight: 6,
                    backgroundColor: colors.cardBackgroundSubtle,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 10),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${campaign.progressPercent.toInt().toPersianDigit()}٪ خوانده شده',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                    if (!isCompleted)
                      Text(
                        '${campaign.remainingUnits.toPersianDigit()} ${campaign.unitTypeLabel} موقعیت خالی',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11.5,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Dates row: Start date & Deadline
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'شروع: $startDateFa',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 10.5,
                      ),
                    ),
                    if (deadlineFa != null)
                      Text(
                        'مهلت پایان: $deadlineFa',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          fontSize: 10.5,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
