import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/widgets/app_modal_header.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';

/// Modal bottom sheet selector for Khatm cadence / frequency («نحوه برگزاری»).
/// Borderless design with soft filled background and modal bottom sheet.
class KhatmCadenceSelector extends StatelessWidget {
  final KhatmCadence selected;
  final ValueChanged<KhatmCadence> onChanged;

  const KhatmCadenceSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  String _getCadenceSubtitle(KhatmCadence cadence) {
    switch (cadence) {
      case KhatmCadence.daily:
        return 'هر روز یک جلسه';
      case KhatmCadence.everyOtherDay:
        return 'یک روز در میان';
      case KhatmCadence.weekly:
        return 'یک روز در هر هفته';
      case KhatmCadence.customWeekdays:
        return 'روزهای انتخابی در هفته';
    }
  }

  void _showCadenceModal(BuildContext context) {
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
                      title: 'نحوه برگزاری',
                      showDragHandle: true,
                      onClose: () => Navigator.pop(ctx),
                      bottomSpacing: 4,
                    ),
                    Text(
                      'دوره زمانی و تکرار جلسات ختم را انتخاب کنید',
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
                            ...KhatmCadence.values.map((cadence) {
                              final isSelected = cadence == selected;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    onChanged(cadence);
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
                                              cadence.labelFa,
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
                                              _getCadenceSubtitle(cadence),
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
          'نحوه برگزاری',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showCadenceModal(context),
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
                  _getCadenceSubtitle(selected),
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
