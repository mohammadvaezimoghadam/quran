import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/extensions/surah_name_extension.dart';
import 'package:quran/common/widgets/auto_scroll_text.dart';
import 'package:quran/core/theme/app_typography.dart';
import '../../../application/controllers/group_khatm_reading_controller.dart';
import '../../../domain/entities/group_khatm_campaign.dart';
import '../../../domain/entities/group_khatm_slot.dart';
import '../../../domain/entities/group_khatm_slot_progress.dart';
import 'group_khatm_slot_progress_ring.dart';

/// Displays the current user's claimed Surah slots directly as interactive cards
/// with live circular progress, repetition pass counter (e.g. دور ۱ از ۳),
/// continue-reading action, and manual "تموم شد" completion button.
class GroupKhatmSurahSlotsSection extends ConsumerWidget {
  final GroupKhatmCampaign campaign;
  final List<GroupKhatmSlot> mySlots;
  final ValueChanged<GroupKhatmSlot> onContinueReading;
  final ValueChanged<GroupKhatmSlot> onCompleteSlot;
  final ValueChanged<GroupKhatmSlot> onReleaseSlot;

  const GroupKhatmSurahSlotsSection({
    super.key,
    required this.campaign,
    required this.mySlots,
    required this.onContinueReading,
    required this.onCompleteSlot,
    required this.onReleaseSlot,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (mySlots.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final progressMap = ref.watch(groupKhatmReadingControllerProvider);
    final surahId = campaign.targetSurah ?? 1;
    final surahTitle = 'سوره ${surahId.surahNameFa}';

    final hairlineBorder = Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.04),
      width: 0.5,
    );

    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'مشارکت‌های من',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${mySlots.length.toPersianDigit()} سهم',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < mySlots.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _buildSurahSlotCard(
              context: context,
              slot: mySlots[i],
              surahTitle: surahTitle,
              progress:
                  progressMap[GroupKhatmSlotProgress.buildStorageKey(
                    campaign.inviteCode,
                    mySlots[i].id,
                  )],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSurahSlotCard({
    required BuildContext context,
    required GroupKhatmSlot slot,
    required String surahTitle,
    required GroupKhatmSlotProgress? progress,
  }) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final isCompleted =
        slot.isCompleted || (progress?.isCompletedLocally ?? false);
    final qty = slot.quantity < 1 ? 1 : slot.quantity;
    final overall = isCompleted ? 1.0 : (progress?.overallProgress ?? 0.0);
    final int percent = isCompleted
        ? 100
        : (overall * 100).floor().clamp(0, 99);
    final currentRep = progress?.currentRepetitionNumber ?? 1;

    final passSubtitle = isCompleted
        ? '${qty.toPersianDigit()} مرتبه تکمیل شد'
        : qty > 1
        ? 'دور ${currentRep.toPersianDigit()} از ${qty.toPersianDigit()}'
        : '۱ مرتبه قرائت';

    final cardBg = isDark ? const Color(0xFF242426) : const Color(0xFFFAFAFA);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.08);
    final monochromeInk = colorScheme.onSurface;
    final monochromeMuted = colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        children: [
          GroupKhatmSlotProgressRing(
            progress: overall,
            percent: percent,
            isCompleted: isCompleted,
            size: 40,
            strokeWidth: 3.2,
            fontSize: 10,
            color: monochromeInk.withValues(alpha: 0.78),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoScrollText(
                  surahTitle,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: monochromeInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  passSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11.5,
                    color: isCompleted ? monochromeInk : monochromeMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: monochromeInk.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: monochromeInk.withValues(alpha: 0.14),
                  width: 0.7,
                ),
              ),
              child: Text(
                'تکمیل شد',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: monochromeInk,
                ),
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GroupKhatmSlotIconChip(
                  icon: Icons.play_arrow_rounded,
                  color: monochromeInk,
                  tooltip: 'ادامه قرائت',
                  iconSize: 17,
                  padding: const EdgeInsets.all(6.5),
                  onTap: () => onContinueReading(slot),
                ),
                const SizedBox(width: 6),
                GroupKhatmSlotIconChip(
                  icon: Icons.undo_rounded,
                  color: monochromeMuted,
                  tooltip: 'انصراف از سهم',
                  iconSize: 16,
                  padding: const EdgeInsets.all(7),
                  onTap: () => onReleaseSlot(slot),
                ),
                const SizedBox(width: 6),
                GroupKhatmCompleteActionChip(
                  fontSize: 11,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6.5,
                  ),
                  onTap: () => onCompleteSlot(slot),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
