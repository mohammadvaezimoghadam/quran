import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';

/// Soft, subtle action chips (Tafsir & Dictionary/Lughat) displayed at the bottom
/// of an Ayah card when focused via long-press.
class AyahBottomActionChips extends StatelessWidget {
  final bool isVisible;
  final VoidCallback? onTafsirTap;
  final VoidCallback? onDictionaryTap;

  const AyahBottomActionChips({
    super.key,
    required this.isVisible,
    this.onTafsirTap,
    this.onDictionaryTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: isVisible
          ? Padding(
              padding: const EdgeInsets.only(top: AppDimens.stackSmMd),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: isVisible ? 1.0 : 0.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tafsir Action Chip
                    _buildSubtleChip(
                      context: context,
                      label: 'تفسیر آیه',
                      onTap: onTafsirTap,
                      colorScheme: colorScheme,
                    ),

                    const SizedBox(width: AppDimens.stackSmMd),

                    // Vocabulary / Dictionary Action Chip
                    _buildSubtleChip(
                      context: context,
                      label: 'واژه‌نامه و لغات',
                      onTap: onDictionaryTap,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildSubtleChip({
    required BuildContext context,
    required String label,
    required VoidCallback? onTap,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: 0.8,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
