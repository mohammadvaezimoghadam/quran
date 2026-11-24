import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/core/theme/app_typography.dart';
import '../../../domain/entities/group_khatm_campaign.dart';

/// Clean, typography-first card for reserving slots in a Surah-based group Khatm.
/// Layout and styling match the refined Sacred Serenity aesthetics:
/// - "مشارکت در این ختم" header with "سهم دلخواه" badge
/// - Centered Stepper with rounded buttons and big bold count
/// - 4 quick preset pills (۱ بار، ۳ بار، ۵ بار، ۱۰ بار)
/// - Primary full-width CTA button ("برداشتن سهم و شروع تلاوت")
/// - Ultra-thin, faint borders (0.5px) without heavy outlines
/// - Zero decorative icons and zero yellow
class GroupKhatmSurahPicker extends StatefulWidget {
  final GroupKhatmCampaign campaign;
  final ValueChanged<int> onReserve;
  final bool isLoading;

  const GroupKhatmSurahPicker({
    super.key,
    required this.campaign,
    required this.onReserve,
    this.isLoading = false,
  });

  @override
  State<GroupKhatmSurahPicker> createState() => _GroupKhatmSurahPickerState();
}

class _GroupKhatmSurahPickerState extends State<GroupKhatmSurahPicker> {
  int _quantity = 3;

  @override
  void initState() {
    super.initState();
    final maxAllowed = widget.campaign.remainingUnits.clamp(1, 100000);
    if (_quantity > maxAllowed) {
      _quantity = maxAllowed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final campaign = widget.campaign;
    final maxAllowed = campaign.remainingUnits.clamp(1, 100000);

    final pillBg = isDark ? const Color(0xFF222224) : const Color(0xFFF3F1EC);

    // Subtle hairline border (ultra-thin and faint)
    final hairlineBorder = Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.04),
      width: 0.5,
    );

    final surahLabel = campaign.targetSurahName != null &&
            campaign.targetSurahName!.trim().isNotEmpty
        ? 'سوره ${campaign.targetSurahName}'
        : 'سوره مبارکه';

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
          // ── ۱. عنوان بخش و برچسب سهم دلخواه ──
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
                  'سهم دلخواه',
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
            'تعداد قرائتی که بر عهده می‌گیرید را مشخص فرمایید:',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.5,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 18),

          // ── ۲. استپر عددی مدرن و روان ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(16),
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
                // دکمه کاهش (-)
                _buildStepperCircle(
                  label: '−',
                  onTap: _quantity > 1
                      ? () {
                          HapticFeedback.lightImpact();
                          setState(() => _quantity--);
                        }
                      : null,
                  isPrimary: false,
                  colors: colors,
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),

                // شمارنده و عنوان در مرکز
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _quantity.toPersianDigit(),
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'مرتبه تلاوت $surahLabel',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),

                // دکمه افزایش (+)
                _buildStepperCircle(
                  label: '+',
                  onTap: _quantity < maxAllowed
                      ? () {
                          HapticFeedback.lightImpact();
                          setState(() => _quantity++);
                        }
                      : null,
                  isPrimary: true,
                  colors: colors,
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── ۳. ردیف ۴ تایی گزینه‌های آماده سریع (۱، ۳، ۵، ۱۰ بار) ──
          Row(
            children: [1, 3, 5, 10].where((n) => n <= maxAllowed).map((n) {
              final isSelected = _quantity == n;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _quantity = n);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.primary : pillBg,
                        borderRadius: BorderRadius.circular(12),
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
                        isSelected
                            ? '✓ ${n.toPersianDigit()} بار'
                            : '${n.toPersianDigit()} بار',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // ── ۴. دکمه اصلی برداشتن سهم ──
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: (campaign.remainingUnits > 0 && !widget.isLoading)
                  ? () => widget.onReserve(_quantity)
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                disabledBackgroundColor:
                    colorScheme.primary.withValues(alpha: 0.35),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: widget.isLoading
                  ? const CupertinoActivityIndicator(
                      color: Colors.white,
                      radius: 10,
                    )
                  : Text(
                      'برداشتن ${_quantity.toPersianDigit()} مرتبه سهم و شروع تلاوت',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperCircle({
    required String label,
    required VoidCallback? onTap,
    required bool isPrimary,
    required dynamic colors,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final enabled = onTap != null;
    final bg = isPrimary
        ? (enabled
            ? colorScheme.primary
            : colorScheme.primary.withValues(alpha: 0.35))
        : (enabled
            ? colors.cardBackground
            : colors.cardBackground.withValues(alpha: 0.5));
    final fg = isPrimary
        ? Colors.white
        : (enabled
            ? colorScheme.onSurface
            : colorScheme.onSurface.withValues(alpha: 0.3));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [
            if (enabled)
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: fg,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
