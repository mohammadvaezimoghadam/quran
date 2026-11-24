import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/widgets/app_snackbar.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/khatm/application/controllers/group_khatm_detail_controller.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_campaign.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';

/// Minimal sticky bar displayed at the top of [QuranReaderScreen] during a Group Khatm session.
/// Shows campaign name, assigned slot, and a direct "Complete & Dedicate Thawab" button.
class GroupKhatmReaderBar extends ConsumerWidget {
  final String inviteCode;
  final int? slotId;
  final int? unitNumber;
  final VoidCallback? onClose;

  const GroupKhatmReaderBar({
    super.key,
    required this.inviteCode,
    this.slotId,
    this.unitNumber,
    this.onClose,
  });

  void _confirmComplete(
    BuildContext context,
    WidgetRef ref,
    GroupKhatmCampaign? campaign,
  ) {
    final colors = context.colors;
    final theme = Theme.of(context);

    final unitLabel = unitNumber != null
        ? '${campaign?.unitTypeLabel ?? "جزء"} ${unitNumber!.toPersianDigit()}'
        : 'سهم شما';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'ثبت اتمام قرائت سهم',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'آیا قرائت $unitLabel را به پایان رساندید؟ با ثبت اتمام، ثواب این قرائت به نیت ختم منظور خواهد شد.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'هنوز نه',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final notifier = ref.read(
                groupKhatmDetailControllerProvider(inviteCode).notifier,
              );
              final success = await notifier.completeSlot(
                slotId: slotId,
                unitNumber: unitNumber,
              );
              if (success && context.mounted) {
                HapticFeedback.mediumImpact();
                final updated = ref
                    .read(groupKhatmDetailControllerProvider(inviteCode))
                    .campaign;
                if (updated?.status == GroupKhatmStatus.completed) {
                  _showFullCompletionDialog(context, updated!);
                } else {
                  AppSnackBar.showSuccess(
                    context,
                    'قبول باشد، ثواب قرائت شما ثبت شد',
                  );
                  onClose?.call();
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'بله، تکمیل شد',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullCompletionDialog(
    BuildContext context,
    GroupKhatmCampaign campaign,
  ) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'تکمیل کامل ختم قرآن کریم',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        content: Text(
          'الحمدلله؛ با قرائت سهم شما، این ختم گروهی ۱۰۰٪ به پایان رسید و ثواب کامل آن به نیت مد نظر اهدا شد. طاعات و عبادات شما قبول درگاه حق.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13.5,
            color: colorScheme.onSurface,
            height: 1.55,
          ),
        ),
        actions: [
          Center(
            child: FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                onClose?.call();
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('قبول باشد'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(groupKhatmDetailControllerProvider(inviteCode));
    final campaign = state.campaign;
    final theme = Theme.of(context);
    final colors = context.colors;
    final colorScheme = theme.colorScheme;

    final unitLabel = unitNumber != null
        ? '${campaign?.unitTypeLabel ?? "جزء"} ${unitNumber!.toPersianDigit()}'
        : 'سهم شما';

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border(
          bottom: BorderSide(color: colors.cardBorder, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'ختم گروهی',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              campaign != null
                  ? '${campaign.title} ($unitLabel)'
                  : 'سهم ختم گروهی ($unitLabel)',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 32,
            child: FilledButton(
              onPressed: () => _confirmComplete(context, ref, campaign),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'ثبت اتمام',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  'بستن',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
