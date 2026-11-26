import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/widgets/auto_scroll_text.dart';
import 'package:quran/core/theme/app_colors.dart';
import 'package:quran/core/theme/app_typography.dart';
import '../../../application/controllers/group_khatm_reading_controller.dart';
import '../../../domain/entities/group_khatm_campaign.dart';
import '../../../domain/entities/group_khatm_slot.dart';
import '../../../domain/entities/group_khatm_slot_progress.dart';
import '../../../domain/entities/khatm_enums.dart';
import 'group_khatm_slot_progress_ring.dart';

/// 3-column thumb-friendly slot grid for Juz (30) and Hizb (120) units.
/// Features:
/// - Floating emerald-green rounded unit pill (e.g. "حزب ۱") half-outside the top card border.
/// - Free slots can be tapped to reserve.
/// - Claimed slots owned by the current user display live circular %, reader name centered
///   below the circle, matching styled Continue & Release icon chips, and a checkbox "تموم شد" button.
/// - Claimed/completed slots owned by other participants are strictly read-only (non-clickable).
class GroupKhatmSlotGrid extends ConsumerStatefulWidget {
  final GroupKhatmCampaign campaign;
  final ValueChanged<GroupKhatmSlot> onSlotTap;
  final ValueChanged<GroupKhatmSlot>? onCompleteSlot;
  final ValueChanged<GroupKhatmSlot>? onReleaseSlot;
  final bool isAuthenticated;

  const GroupKhatmSlotGrid({
    super.key,
    required this.campaign,
    required this.onSlotTap,
    this.onCompleteSlot,
    this.onReleaseSlot,
    this.isAuthenticated = false,
  });

  @override
  ConsumerState<GroupKhatmSlotGrid> createState() => _GroupKhatmSlotGridState();
}

class _GroupKhatmSlotGridState extends ConsumerState<GroupKhatmSlotGrid> {
  String _selectedFilter = 'all'; // 'all', 'available', 'mine'

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final campaign = widget.campaign;

    final mySlotsCount = campaign.slots.where((s) => s.isMine).length;

    final filteredSlots = campaign.slots.where((s) {
      if (_selectedFilter == 'available') return s.isFree;
      if (_selectedFilter == 'mine') return s.isMine;
      return true;
    }).toList()..sort(GroupKhatmSlot.compareByUnitOrder);

    final hairlineBorder = Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.04),
      width: 0.5,
    );

    final progressMap = ref.watch(groupKhatmReadingControllerProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
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
          // ── ۱. عنوان بخش و برچسب نوع سهم‌ها ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'مشارکت در این ختم',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${campaign.targetUnits.toPersianDigit()} ${campaign.unitTypeLabel}',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── ۲. فیلتر سریع سهم‌ها ──
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildFilterChip(
                key: 'all',
                label: 'همه (${campaign.slots.length.toPersianDigit()})',
                isDark: isDark,
                colorScheme: colorScheme,
              ),
              _buildFilterChip(
                key: 'available',
                label: 'آزاد (${campaign.remainingUnits.toPersianDigit()})',
                isDark: isDark,
                colorScheme: colorScheme,
              ),
              if (mySlotsCount > 0)
                _buildFilterChip(
                  key: 'mine',
                  label: 'سهم من (${mySlotsCount.toPersianDigit()})',
                  isDark: isDark,
                  colorScheme: colorScheme,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // ── ۳. شبکه ۳ ستونه سهم‌ها با تگ سبز بالای کارت ──
          if (filteredSlots.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28),
              alignment: Alignment.center,
              child: Text(
                'هیچ سهمی در این فیلتر وجود ندارد',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.89,
              ),
              itemCount: filteredSlots.length,
              itemBuilder: (ctx, index) {
                final slot = filteredSlots[index];
                final slotProgress =
                    progressMap[GroupKhatmSlotProgress.buildStorageKey(
                      campaign.inviteCode,
                      slot.id,
                    )];
                return _buildSlotTile(
                  context: ctx,
                  slot: slot,
                  campaign: campaign,
                  slotProgress: slotProgress,
                  colorScheme: colorScheme,
                  isDark: isDark,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String key,
    required String label,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _selectedFilter == key;
    final pillBg = isDark ? const Color(0xFF222224) : const Color(0xFFF3F1EC);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedFilter = key);
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : pillBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.03)),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildSlotTile({
    required BuildContext context,
    required GroupKhatmSlot slot,
    required GroupKhatmCampaign campaign,
    required GroupKhatmSlotProgress? slotProgress,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final unitPrefix = campaign.unitTypeEnum == GroupKhatmUnitType.juz
        ? 'جزء'
        : 'حزب';
    final numberText = slot.unitNumber != null
        ? slot.unitNumber!.toPersianDigit()
        : '-';
    final unitBadgeLabel = '$unitPrefix $numberText';
    final isCompletedEffective =
        slot.isCompleted || (slotProgress?.isCompletedLocally ?? false);

    final rawName = slot.userDisplayName?.trim() ?? '';
    final hasName = rawName.isNotEmpty;
    final neutralCardBg = isDark ? const Color(0xFF242426) : const Color(0xFFFAFAFA);
    final activeMineCardBg = isDark ? const Color(0xFF28282B) : Colors.white;
    final neutralBorder = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.08);
    final subtleBorder = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.06);
    final monochromeInk = colorScheme.onSurface;
    final monochromeMuted = colorScheme.onSurfaceVariant;

    // Colorless neutral floating unit pill badge (no green)
    final topBadgeBg = isDark ? const Color(0xFF2E2E32) : Colors.white;
    final topBadgeBorder = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.black.withValues(alpha: 0.14);

    Widget wrapWithFloatingBadge({
      required Color cardBg,
      required Color borderColor,
      required double borderWidth,
      required Widget child,
      VoidCallback? onTap,
    }) {
      final cardWithPill = Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.fromLTRB(5, 12, 5, 5),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: borderColor, width: borderWidth),
              ),
              child: child,
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
              decoration: BoxDecoration(
                color: topBadgeBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: topBadgeBorder, width: 0.7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                unitBadgeLabel,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: monochromeInk,
                  height: 1.15,
                ),
              ),
            ),
          ),
        ],
      );

      if (onTap != null) {
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: cardWithPill,
        );
      }
      return cardWithPill;
    }

    // 1. User's active reserved slot: centered monochrome ring + reader name below it,
    //    and a single compact bottom row with [Continue] [Undo] on the right of [تموم شد].
    if (slot.isMine && !isCompletedEffective) {
      final overall = slotProgress?.overallProgress ?? 0.0;
      final percent = (overall * 100).floor().clamp(0, 99);
      final holderLabel = (widget.isAuthenticated && hasName)
          ? rawName
          : 'سهم من';

      return wrapWithFloatingBadge(
        cardBg: activeMineCardBg,
        borderColor: isDark
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.black.withValues(alpha: 0.16),
        borderWidth: 0.9,
        onTap: () => widget.onSlotTap(slot),
        child: Column(
          children: [
            const SizedBox(height: 3),
            // Vertically centered % ring + reader name right below it (aligned with completed cards)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GroupKhatmSlotProgressRing(
                    progress: overall,
                    percent: percent,
                    isCompleted: false,
                    size: 26,
                    strokeWidth: 2.4,
                    fontSize: 8,
                    color: monochromeInk.withValues(alpha: 0.78),
                  ),
                  const SizedBox(height: 2),
                  AutoScrollText(
                    holderLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: monochromeInk,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),

            // Bottom action row in RTL: [Play] [Undo] [تموم شد]
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GroupKhatmSlotIconChip(
                    icon: Icons.play_arrow_rounded,
                    color: monochromeInk,
                    tooltip: 'ادامه قرائت',
                    iconSize: 13,
                    padding: const EdgeInsets.all(3),
                    onTap: () => widget.onSlotTap(slot),
                  ),
                  if (widget.onReleaseSlot != null) ...[
                    const SizedBox(width: 3),
                    GroupKhatmSlotIconChip(
                      icon: Icons.undo_rounded,
                      color: monochromeMuted,
                      tooltip: 'انصراف از سهم',
                      iconSize: 12,
                      padding: const EdgeInsets.all(3.5),
                      onTap: () => widget.onReleaseSlot!(slot),
                    ),
                  ],
                  const SizedBox(width: 3),
                  GroupKhatmCompleteActionChip(
                    fontSize: 9,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3.5,
                    ),
                    onTap: widget.onCompleteSlot != null
                        ? () => widget.onCompleteSlot!(slot)
                        : () => widget.onSlotTap(slot),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 2. Mine Completed slot (read-only, colorless neutral style)
    if (slot.isMine && isCompletedEffective) {
      final holderLabel = (widget.isAuthenticated && hasName)
          ? rawName
          : 'تکمیل شد';
      return wrapWithFloatingBadge(
        cardBg: neutralCardBg,
        borderColor: neutralBorder,
        borderWidth: 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GroupKhatmSlotProgressRing(
              progress: 1.0,
              percent: 100,
              isCompleted: true,
              size: 26,
              strokeWidth: 2.4,
              color: monochromeInk.withValues(alpha: 0.78),
            ),
            const SizedBox(height: 3),
            Text(
              'تکمیل شد',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: monochromeInk,
              ),
            ),
            const SizedBox(height: 1),
            AutoScrollText(
              holderLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: monochromeMuted,
              ),
            ),
          ],
        ),
      );
    }

    // 3. Free slot (clickable to claim, colorless neutral style)
    if (slot.isFree) {
      return wrapWithFloatingBadge(
        cardBg: neutralCardBg,
        borderColor: neutralBorder,
        borderWidth: 0.7,
        onTap: () => widget.onSlotTap(slot),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: monochromeInk.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                size: 15,
                color: monochromeMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'آزاد',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: monochromeMuted,
              ),
            ),
          ],
        ),
      );
    }

    // 4. Other participants' reserved or completed slots (strictly non-clickable, colorless neutral)
    final isDoneByOther = slot.isCompleted;
    final statusBadgeText = isDoneByOther ? 'قرائت شده' : 'در حال قرائت';
    final showParticipantName = widget.isAuthenticated && hasName;

    return wrapWithFloatingBadge(
      cardBg: neutralCardBg,
      borderColor: subtleBorder,
      borderWidth: 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showParticipantName) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: monochromeInk.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusBadgeText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  color: monochromeMuted.withValues(alpha: 0.85),
                ),
              ),
            ),
            const SizedBox(height: 4),
            AutoScrollText(
              rawName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: monochromeInk.withValues(alpha: 0.85),
              ),
            ),
          ] else ...[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: monochromeInk.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDoneByOther ? Icons.check_rounded : Icons.menu_book_outlined,
                size: 13,
                color: monochromeMuted.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              statusBadgeText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: monochromeMuted.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
