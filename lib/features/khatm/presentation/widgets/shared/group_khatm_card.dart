import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/extensions/string_extension.dart';
import 'package:quran/common/utils/jalali_date.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_campaign.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';
import 'khatm_circular_progress_ring.dart';

/// Clean card displaying a collective Group Khatm campaign in lists.
/// Strictly follows Sacred Serenity theme tokens (warm neutrals, subtle borders, no green saturation).
class GroupKhatmCard extends StatelessWidget {
  final GroupKhatmCampaign campaign;
  final VoidCallback? onTap;

  const GroupKhatmCard({super.key, required this.campaign, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final colorScheme = theme.colorScheme;

    final isDark = context.isDark;

    final isCompleted = campaign.status == GroupKhatmStatus.completed;
    final hasActiveSlot = campaign.mySlots.any(
      (s) => s.status == GroupKhatmSlotStatus.reserved,
    );

    final startDateFa = JalaliDate.fromDateTime(
      campaign.createdAt,
    ).formatFa().toPersianDigit();
    final remainingLabel = isCompleted ? null : campaign.remainingTimeLabel();

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
                if (campaign.categoryTitle != null ||
                    isCompleted ||
                    hasActiveSlot) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (campaign.categoryTitle != null)
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.cardBackgroundSubtle,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: colors.cardBorder),
                                ),
                                child: Text(
                                  campaign.categoryTitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const Spacer(),
                      if (isCompleted || hasActiveSlot) ...[
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 112),
                          child: isCompleted
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.cardBackgroundSubtle,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: colors.cardBorder,
                                    ),
                                  ),
                                  child: Text(
                                    'تکمیل شده',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'سهم فعال شما',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                // Title & plain unit/slots subtitle opposite circular progress ring on the left (RTL)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            !isCompleted
                                ? 'بر اساس ${campaign.unitTypeEnum.shortLabelFa} • ${campaign.remainingUnits.toPersianDigit()} موقعیت خالی'
                                : 'بر اساس ${campaign.unitTypeEnum.shortLabelFa} • تمام بخش‌های ختم تکمیل شد',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11.5,
                            ),
                          ),
                          if (campaign.description != null &&
                              campaign.description!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              campaign.description!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.85,
                                ),
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    KhatmCircularProgressRing(
                      progress: campaign.progressPercent / 100,
                      isCompleted: campaign.isCompleted,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Dates row: Start date & Deadline
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'شروع: $startDateFa',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                    if (remainingLabel != null) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          remainingLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                    ],
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
