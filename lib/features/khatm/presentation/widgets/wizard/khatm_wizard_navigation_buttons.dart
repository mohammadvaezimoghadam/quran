import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/core/theme/app_typography.dart';

/// Navigation buttons row at bottom of wizard («مرحله قبل» and «ادامه»).
/// Borderless design with soft filled tonal back button and primary next button.
class KhatmWizardNavigationButtons extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final bool isNextEnabled;
  final bool isBackVisible;
  final bool isLoading;
  final String nextLabel;

  const KhatmWizardNavigationButtons({
    super.key,
    required this.onNext,
    this.onBack,
    this.isNextEnabled = true,
    this.isBackVisible = true,
    this.isLoading = false,
    this.nextLabel = 'ادامه',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    return Container(
      color: colors.cardBackground,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // ── Back Button (مرحله قبل) ──────────────────────────────────
          if (isBackVisible) ...[
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: isLoading ? null : onBack,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.cardBackgroundSubtle,
                    foregroundColor: colorScheme.onSurface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'مرحله قبل',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // ── Next / Submit Button (ادامه / تایید و ایجاد ختم) ─────────
          Expanded(
            child: SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: (isNextEnabled && !isLoading) ? onNext : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  disabledBackgroundColor:
                      colorScheme.primary.withValues(alpha: 0.35),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        nextLabel,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
