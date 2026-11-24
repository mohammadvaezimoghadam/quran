import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/core/theme/app_typography.dart';
import '../../../domain/entities/group_khatm_campaign.dart';
import '../../../domain/entities/group_khatm_slot.dart';

/// Clean bottom sheet displaying all participants and their claimed slots.
/// Fully adheres to the Sacred Serenity design system:
/// - Minimalist Apple-like typography and layout
/// - Ultra-thin faint borders (0.5px)
/// - Zero decorative icons and zero yellow
class GroupKhatmParticipantsSheet extends StatefulWidget {
  final GroupKhatmCampaign campaign;
  final bool isAuthenticated;

  const GroupKhatmParticipantsSheet({
    super.key,
    required this.campaign,
    this.isAuthenticated = false,
  });

  static Future<void> show(
    BuildContext context, {
    required GroupKhatmCampaign campaign,
    bool isAuthenticated = false,
  }) {
    final colors = context.colors;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => GroupKhatmParticipantsSheet(
        campaign: campaign,
        isAuthenticated: isAuthenticated,
      ),
    );
  }

  @override
  State<GroupKhatmParticipantsSheet> createState() =>
      _GroupKhatmParticipantsSheetState();
}

class _GroupKhatmParticipantsSheetState
    extends State<GroupKhatmParticipantsSheet> {
  String _filter = 'all'; // 'all', 'completed', 'reserved'

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final campaign = widget.campaign;

    // Slots that are taken (either in progress or completed)
    final takenSlots = campaign.slots.where((s) => !s.isFree).toList();

    final filteredSlots = takenSlots.where((s) {
      if (_filter == 'completed') return s.isCompleted;
      if (_filter == 'reserved') return s.isReserved;
      return true;
    }).toList();

    final pillBg = isDark ? const Color(0xFF222224) : const Color(0xFFF3F1EC);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'همراهان و سهم‌های این ختم',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${takenSlots.length.toPersianDigit()} سهم توسط همراهان برداشته شده است',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                splashRadius: 20,
                icon: Text(
                  'بستن',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Quick Filter Chips
          Row(
            children: [
              _buildFilterChip('all', 'همه (${takenSlots.length.toPersianDigit()})',
                  pillBg, colorScheme, isDark),
              const SizedBox(width: 8),
              _buildFilterChip(
                  'completed',
                  'قرائت شده (${campaign.completedUnits.toPersianDigit()})',
                  pillBg,
                  colorScheme,
                  isDark),
              const SizedBox(width: 8),
              _buildFilterChip(
                  'reserved',
                  'در حال قرائت (${campaign.reservedUnits.toPersianDigit()})',
                  pillBg,
                  colorScheme,
                  isDark),
            ],
          ),
          const SizedBox(height: 14),

          // Slots List
          if (filteredSlots.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'هنوز سهمی در این وضعیت ثبت نشده است',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: filteredSlots.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final slot = filteredSlots[index];
                  return _buildParticipantItem(
                    slot: slot,
                    campaign: campaign,
                    pillBg: pillBg,
                    colorScheme: colorScheme,
                    isDark: isDark,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, Color pillBg,
      ColorScheme colorScheme, bool isDark) {
    final isSelected = _filter == key;
    return InkWell(
      onTap: () => setState(() => _filter = key),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : pillBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
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

  Widget _buildParticipantItem({
    required GroupKhatmSlot slot,
    required GroupKhatmCampaign campaign,
    required Color pillBg,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final String unitLabel;
    if (slot.unitNumber != null) {
      unitLabel = '${campaign.unitTypeLabel} ${slot.unitNumber!.toPersianDigit()}';
    } else {
      unitLabel = '${slot.quantity.toPersianDigit()} مرتبه سوره ${campaign.targetSurahName ?? ''}';
    }

    final rawName = slot.userDisplayName?.trim() ?? '';
    final String? displayName = widget.isAuthenticated
        ? (slot.isMine
            ? (rawName.isNotEmpty ? '$rawName (شما)' : 'شما')
            : (rawName.isNotEmpty ? rawName : 'کاربر قرآن'))
        : null;

    final String initialChar = (displayName != null && displayName.runes.isNotEmpty)
        ? String.fromCharCode(displayName.runes.first)
        : '';

    final bool isDone = slot.isCompleted;

    final statusBg = isDone
        ? colorScheme.primary.withValues(alpha: 0.08)
        : (isDark ? const Color(0xFF2B2B2D) : const Color(0xFFE8E5DF));

    final statusTextColor = isDone
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.75);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
          Expanded(
            child: Row(
              children: [
                if (displayName != null) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: slot.isMine
                          ? colorScheme.primary
                          : colorScheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initialChar,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: slot.isMine ? Colors.white : colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName ?? unitLabel,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight:
                              slot.isMine ? FontWeight.bold : FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (displayName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          unitLabel,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11.5,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isDone ? 'قرائت شده' : 'در حال قرائت',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
