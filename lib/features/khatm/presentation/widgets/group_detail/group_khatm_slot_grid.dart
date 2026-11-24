import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/core/theme/app_typography.dart';
import '../../../domain/entities/group_khatm_campaign.dart';
import '../../../domain/entities/group_khatm_slot.dart';
import '../../../domain/entities/khatm_enums.dart';

/// 3-column thumb-friendly slot grid for Juz (30) and Hizb (120) units.
/// Layout and styling match the refined Sacred Serenity aesthetics:
/// - "مشارکت در این ختم" card header with unit badge
/// - Quick filter chips (همه، آزاد، سهم من)
/// - 3-column thumb-friendly slot tiles with ultra-thin faint borders (0.5px)
///   and privacy-aware labels (status-only for guests; user display name for authenticated viewers)
/// - Completely free of decorative icons and zero yellow
class GroupKhatmSlotGrid extends StatefulWidget {
  final GroupKhatmCampaign campaign;
  final ValueChanged<GroupKhatmSlot> onSlotTap;
  final bool isAuthenticated;

  const GroupKhatmSlotGrid({
    super.key,
    required this.campaign,
    required this.onSlotTap,
    this.isAuthenticated = false,
  });

  @override
  State<GroupKhatmSlotGrid> createState() => _GroupKhatmSlotGridState();
}

class _GroupKhatmSlotGridState extends State<GroupKhatmSlotGrid> {
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
    }).toList();

    // Subtle hairline border (ultra-thin and faint)
    final hairlineBorder = Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.04),
      width: 0.5,
    );

    return Container(
      padding: const EdgeInsets.all(20),
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
              Text(
                'مشارکت در این ختم',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  campaign.unitTypeLabel,
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
          const SizedBox(height: 6),
          Text(
            'یک یا چند جزء را برای قرائت انتخاب کنید:',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.5,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),

          // ── ۲. ردیف فیلترهای سریع (همه، آزاد، سهم من) ──
          Row(
            children: [
              _buildFilterChip(
                key: 'all',
                label: 'همه (${campaign.slots.length.toPersianDigit()})',
                isDark: isDark,
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                key: 'available',
                label: 'آزاد (${campaign.remainingUnits.toPersianDigit()})',
                isDark: isDark,
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                key: 'mine',
                label: mySlotsCount > 0
                    ? 'سهم من (${mySlotsCount.toPersianDigit()})'
                    : 'سهم من',
                isDark: isDark,
                colorScheme: colorScheme,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── ۳. گرید ۳ ستونه استاندارد با بوردرهای فوق‌باریک ──
          if (filteredSlots.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
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
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.18,
              ),
              itemCount: filteredSlots.length,
              itemBuilder: (ctx, index) {
                final slot = filteredSlots[index];
                return _buildSlotTile(
                  context: ctx,
                  slot: slot,
                  campaign: campaign,
                  colors: colors,
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

  Widget _buildSlotTile({
    required BuildContext context,
    required GroupKhatmSlot slot,
    required GroupKhatmCampaign campaign,
    required dynamic colors,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final unitPrefix =
        campaign.unitTypeEnum == GroupKhatmUnitType.juz ? 'جزء' : 'حزب';
    final numberText = slot.unitNumber != null
        ? slot.unitNumber!.toPersianDigit()
        : '-';

    final pillBg = isDark ? const Color(0xFF242426) : const Color(0xFFF6F4F0);

    Color bgColor = pillBg;
    Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);
    Color textColor = colorScheme.onSurface;
    String topLabel = unitPrefix;
    String bottomLabel = 'آزاد';
    Color bottomColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.6);

    final rawName = slot.userDisplayName?.trim() ?? '';
    final hasName = rawName.isNotEmpty;

    if (slot.isCompleted) {
      bgColor = isDark
          ? const Color(0xFF1E2624)
          : const Color(0xFFEEF5F3);
      borderColor = colorScheme.primary.withValues(alpha: 0.2);
      textColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.75);
      topLabel = slot.isMine ? '✓ $unitPrefix (شما)' : '✓ قرائت شده';
      bottomLabel = widget.isAuthenticated
          ? (hasName ? rawName : (slot.isMine ? 'شما' : 'قرائت شده'))
          : 'قرائت شده';
      bottomColor = colorScheme.primary.withValues(alpha: 0.9);
      if (!widget.isAuthenticated) {
        topLabel = unitPrefix;
      }
    } else if (slot.isMine) {
      bgColor = colorScheme.primary.withValues(alpha: 0.1);
      borderColor = colorScheme.primary.withValues(alpha: 0.45);
      textColor = colorScheme.primary;
      topLabel = '$unitPrefix • سهم من';
      bottomLabel = (widget.isAuthenticated && hasName) ? rawName : 'سهم من';
      bottomColor = colorScheme.primary;
    } else if (slot.isReserved) {
      bgColor = pillBg.withValues(alpha: 0.65);
      borderColor = isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.black.withValues(alpha: 0.03);
      textColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.65);
      topLabel = widget.isAuthenticated ? '$unitPrefix • در حال قرائت' : unitPrefix;
      bottomLabel = widget.isAuthenticated
          ? (hasName ? rawName : 'در حال قرائت')
          : 'در حال قرائت';
      bottomColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.75);
    }

    return InkWell(
      onTap: () => widget.onSlotTap(slot),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: slot.isMine ? 0.9 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              topLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9.5,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              numberText,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              bottomLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10,
                fontWeight: (slot.isMine || (!slot.isFree && widget.isAuthenticated && hasName))
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: bottomColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
