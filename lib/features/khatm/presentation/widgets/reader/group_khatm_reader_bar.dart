import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/extensions/surah_name_extension.dart';
import 'package:quran/common/widgets/app_snackbar.dart';
import 'package:quran/common/widgets/auto_scroll_text.dart';
import 'package:quran/core/theme/app_colors.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/khatm/application/controllers/group_khatm_detail_controller.dart';
import 'package:quran/features/khatm/application/controllers/group_khatm_reading_controller.dart';
import 'package:quran/features/khatm/application/controllers/khatm_detail_controller.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_campaign.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_slot.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_slot_progress.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';
import '../group_detail/group_khatm_slot_progress_ring.dart';

/// Sticky collapsible bar displayed inside [QuranReaderScreen] during a Group Khatm slot.
/// Displays live progress %, Surah repetition pass indicator, manual complete action,
/// and celebrates automatic or manual completion.
class GroupKhatmReaderBar extends ConsumerStatefulWidget {
  static const double barHeight = 48.0;
  static const double collapsedHeight = 3.0;

  final String inviteCode;
  final int? slotId;
  final int? unitNumber;
  final GroupKhatmUnitType? unitType;
  final int? targetQuantity;
  final VoidCallback? onClose;
  final void Function(int surahId, int ayahNumber)? onJumpToAyah;

  const GroupKhatmReaderBar({
    super.key,
    required this.inviteCode,
    this.slotId,
    this.unitNumber,
    this.unitType,
    this.targetQuantity,
    this.onClose,
    this.onJumpToAyah,
  });

  @override
  ConsumerState<GroupKhatmReaderBar> createState() =>
      _GroupKhatmReaderBarState();
}

class _GroupKhatmReaderBarState extends ConsumerState<GroupKhatmReaderBar> {
  bool _awaitingNextPassRestart = false;
  bool _isSubmittingComplete = false;

  void _confirmComplete(
    BuildContext context,
    GroupKhatmCampaign? campaign,
    GroupKhatmSlot? slot,
    GroupKhatmUnitType unitType,
    int unitNumber,
  ) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final unitLabel = _formatUnitLabel(unitType, unitNumber);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) => PopScope(
            canPop: !isLoading,
            child: AlertDialog(
              backgroundColor: colors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'تأیید اتمام سهم ختم',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              content: Text(
                'آیا قرائت «$unitLabel» را به پایان رسانده‌اید؟ با تأیید شما، ثواب آن در این ختم گروهی ثبت و به سایر اعضای گروه اطلاع داده می‌شود.',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13.5,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(dialogCtx).pop(),
                  child: Text(
                    'ادامه می‌دهم',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setDialogState(() => isLoading = true);
                          try {
                            await _executeManualComplete(
                              campaign,
                              slot,
                              unitType,
                              unitNumber,
                            );
                          } finally {
                            if (dialogCtx.mounted) {
                              Navigator.of(dialogCtx).pop();
                            }
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(112, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
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
          ),
        );
      },
    );
  }

  Future<void> _executeManualComplete(
    GroupKhatmCampaign? campaign,
    GroupKhatmSlot? slot,
    GroupKhatmUnitType unitType,
    int unitNumber,
  ) async {
    if (_isSubmittingComplete) return;
    setState(() => _isSubmittingComplete = true);

    try {
      final notifier = ref.read(
        groupKhatmDetailControllerProvider(widget.inviteCode).notifier,
      );
      final synced = await notifier.completeSlot(
        slotId: widget.slotId,
        unitNumber: unitType == GroupKhatmUnitType.surah ? null : unitNumber,
      );

      if (widget.slotId != null && campaign != null) {
        final effectiveSlot =
            slot ??
            GroupKhatmSlot(
              id: widget.slotId!,
              campaignId: campaign.id,
              unitNumber: unitType == GroupKhatmUnitType.surah
                  ? null
                  : unitNumber,
              quantity: widget.targetQuantity ?? 1,
              status: GroupKhatmSlotStatus.completed,
              isMine: true,
            );
        await ref
            .read(groupKhatmReadingControllerProvider.notifier)
            .markCompletedLocally(
              inviteCode: widget.inviteCode,
              slot: effectiveSlot,
              campaign: campaign,
              syncedWithServer: synced,
            );
      }

      if (!mounted) return;
      HapticFeedback.mediumImpact();
      final updated = ref
          .read(groupKhatmDetailControllerProvider(widget.inviteCode))
          .campaign;
      if (updated?.status == GroupKhatmStatus.completed) {
        _showFullCompletionDialog(updated!);
      } else {
        AppSnackBar.showSuccess(
          context,
          synced
              ? 'قبول باشد، ثواب قرائت شما ثبت شد'
              : 'اتمام سهم در حافظه ذخیره شد و پس از اتصال ثبت می‌شود',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingComplete = false);
      }
    }
  }

  void _showFullCompletionDialog(GroupKhatmCampaign campaign) {
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
                widget.onClose?.call();
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

  String _formatUnitLabel(GroupKhatmUnitType unitType, int unitNumber) {
    switch (unitType) {
      case GroupKhatmUnitType.juz:
        return 'جزء ${unitNumber.toPersianDigit()}';
      case GroupKhatmUnitType.hizb:
        return 'حزب ${unitNumber.toPersianDigit()}';
      case GroupKhatmUnitType.surah:
        return 'سوره ${unitNumber.surahNameFa}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      groupKhatmDetailControllerProvider(widget.inviteCode),
    );
    final campaign = state.campaign;
    final activeSlot = ref.watch(activeGroupKhatmSlotProvider);
    final resolvedSlotId = widget.slotId ?? activeSlot?.slotId;
    final resolvedType =
        widget.unitType ??
        activeSlot?.unitType ??
        campaign?.unitTypeEnum ??
        GroupKhatmUnitType.juz;
    final resolvedUnit =
        widget.unitNumber ??
        activeSlot?.unitNumber ??
        campaign?.targetSurah ??
        1;
    final matchedSlot = resolvedSlotId == null
        ? null
        : campaign?.slots.where((s) => s.id == resolvedSlotId).firstOrNull;
    final resolvedQty =
        (widget.targetQuantity ??
                activeSlot?.targetQuantity ??
                matchedSlot?.quantity ??
                1)
            .clamp(1, 999);

    final progressMap = ref.watch(groupKhatmReadingControllerProvider);
    final storageKey = resolvedSlotId != null
        ? GroupKhatmSlotProgress.buildStorageKey(
            widget.inviteCode,
            resolvedSlotId,
          )
        : null;
    final slotProgress = storageKey != null ? progressMap[storageKey] : null;

    if (storageKey != null) {
      ref.listen<
        Map<String, GroupKhatmSlotProgress>
      >(groupKhatmReadingControllerProvider, (prev, next) {
        final before = prev?[storageKey];
        final after = next[storageKey];
        if (after == null) return;

        if ((before == null || !before.isCompletedLocally) &&
            after.isCompletedLocally) {
          HapticFeedback.mediumImpact();
          if (!mounted) return;
          setState(() => _awaitingNextPassRestart = false);
          final latestCampaign = ref
              .read(groupKhatmDetailControllerProvider(widget.inviteCode))
              .campaign;
          if (latestCampaign?.status == GroupKhatmStatus.completed) {
            _showFullCompletionDialog(latestCampaign!);
          } else {
            AppSnackBar.showSuccess(
              context,
              'سهم شما به صورت خودکار تکمیل شد و ثبت گردید',
            );
          }
        } else if (before != null &&
            after.completedRepetitions > before.completedRepetitions &&
            !after.isCompletedLocally) {
          HapticFeedback.lightImpact();
          if (!mounted) return;
          setState(() => _awaitingNextPassRestart = true);
          AppSnackBar.showSuccess(
            context,
            'دور ${after.completedRepetitions.toPersianDigit()} از ${after.targetQuantity.toPersianDigit()} تکمیل شد',
          );
        } else if (_awaitingNextPassRestart &&
            after.currentPassProgress > 0.0) {
          if (mounted) {
            setState(() => _awaitingNextPassRestart = false);
          }
        }
      });
    }

    final isCollapsed = ref.watch(isKhatmReaderBarCollapsedProvider);
    final theme = Theme.of(context);
    final colors = context.colors;
    final colorScheme = theme.colorScheme;

    final isCompleted =
        (slotProgress?.isCompletedLocally ?? false) ||
        (matchedSlot?.isCompleted ?? false);
    final isAwaitingNextPass =
        !isCompleted &&
        (_awaitingNextPassRestart || (slotProgress?.awaitingNextPass ?? false));
    final double overallProgress = isCompleted
        ? 1.0
        : (slotProgress?.overallProgress ?? 0.0);
    final int percent = isCompleted
        ? 100
        : (overallProgress * 100).floor().clamp(0, 99);
    final unitLabel = _formatUnitLabel(resolvedType, resolvedUnit);
    final currentPass = slotProgress?.currentRepetitionNumber ?? 1;
    final displayText =
        resolvedType == GroupKhatmUnitType.surah && resolvedQty > 1
        ? '$unitLabel • دور ${currentPass.toPersianDigit()} از ${resolvedQty.toPersianDigit()}'
        : campaign != null
        ? '$unitLabel • ${campaign.title}'
        : unitLabel;

    final barBg = colors.cardBackground;

    return ClipRect(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        height: isCollapsed
            ? GroupKhatmReaderBar.collapsedHeight
            : GroupKhatmReaderBar.barHeight,
        decoration: BoxDecoration(
          color: isCollapsed ? Colors.transparent : barBg,
          border: isCollapsed
              ? null
              : Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
        ),
        child: isCollapsed
            ? FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: overallProgress.clamp(0.02, 1.0),
                child: Container(color: colorScheme.primary),
              )
            : ClipRect(
                child: LayoutBuilder(
                  builder: (context, constraints) => OverflowBox(
                    minWidth: constraints.maxWidth,
                    maxWidth: constraints.maxWidth,
                    minHeight: GroupKhatmReaderBar.barHeight - 1.0,
                    maxHeight: GroupKhatmReaderBar.barHeight - 1.0,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          GroupKhatmSlotProgressRing(
                            progress: overallProgress,
                            percent: percent,
                            isCompleted: isCompleted,
                            size: 28,
                            strokeWidth: 2.6,
                            fontSize: 8.5,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AutoScrollText(
                              displayText,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                    if (isAwaitingNextPass && resolvedSlotId != null)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 6),
                        child: FilledButton(
                          onPressed: () {
                            ref
                                .read(
                                  groupKhatmReadingControllerProvider.notifier,
                                )
                                .beginNextPass(
                                  widget.inviteCode,
                                  resolvedSlotId,
                                );
                            setState(() => _awaitingNextPassRestart = false);
                            widget.onJumpToAyah?.call(resolvedUnit, 1);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 30),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'شروع دور ${currentPass.toPersianDigit()}',
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'تکمیل شد',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      FilledButton(
                        onPressed: _isSubmittingComplete
                            ? null
                            : () => _confirmComplete(
                                context,
                                campaign,
                                matchedSlot,
                                resolvedType,
                                resolvedUnit,
                              ),
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 30),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'تموم شد',
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (widget.onClose != null) ...[
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: widget.onClose,
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
