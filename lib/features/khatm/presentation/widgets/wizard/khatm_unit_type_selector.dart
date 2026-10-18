import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/widgets/app_modal_header.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';

/// Unit type selector for choosing Quran unit type («نوع ختم»).
/// Borderless design with soft filled background and modal bottom sheet.
class KhatmUnitTypeSelector extends StatelessWidget {
  final KhatmUnitType selected;
  final ValueChanged<KhatmUnitType> onChanged;

  const KhatmUnitTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  String _getUnitTypeSubtitle(KhatmUnitType type) {
    switch (type) {
      case KhatmUnitType.page:
        return '${type.maxUnits.toPersianDigit()} صفحه قرآن کریم';
      case KhatmUnitType.hizb:
        return '${type.maxUnits.toPersianDigit()} حزب قرآن کریم';
      case KhatmUnitType.juz:
        return '${type.maxUnits.toPersianDigit()} جزء قرآن کریم';
      case KhatmUnitType.surah:
        return '${type.maxUnits.toPersianDigit()} سوره مبارکه';
      case KhatmUnitType.ayah:
        return '${type.maxUnits.toPersianDigit()} آیه شریفه';
    }
  }

  void _showUnitTypeModal(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  MediaQuery.viewInsetsOf(ctx).bottom + 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppModalHeader(
                      title: 'انتخاب نوع ختم',
                      showDragHandle: true,
                      onClose: () => Navigator.pop(ctx),
                      bottomSpacing: 4,
                    ),
                    Text(
                      'واحد محاسبه و تقسیم‌بندی جلسات ختم را انتخاب کنید',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12.5,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                    Container(
                      height: 0.8,
                      color: colors.cardBorder.withValues(alpha: 0.5),
                      margin: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...KhatmUnitType.values.map((type) {
                              final isSelected = type == selected;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    onChanged(type);
                                    Navigator.pop(ctx);
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 13,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? colorScheme.primary.withValues(alpha: 0.12)
                                          : colors.cardBackgroundSubtle,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              type.labelFa,
                                              style: TextStyle(
                                                fontFamily: AppTypography.fontFamily,
                                                fontSize: 14,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                                color: isSelected
                                                    ? colorScheme.primary
                                                    : colorScheme.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _getUnitTypeSubtitle(type),
                                              style: TextStyle(
                                                fontFamily: AppTypography.fontFamily,
                                                fontSize: 11.5,
                                                color: colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected
                                                ? colorScheme.primary
                                                : colors.cardBorder.withValues(alpha: 0.6),
                                          ),
                                          child: isSelected
                                              ? Center(
                                                  child: Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final inputBg = isDark ? const Color(0xFF242426) : const Color(0xFFEEEBE4);
    final inputBorder = Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.06),
      width: 0.8,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع ختم',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showUnitTypeModal(context),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(14),
              border: inputBorder,
            ),
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selected.labelFa,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  _getUnitTypeSubtitle(selected),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
