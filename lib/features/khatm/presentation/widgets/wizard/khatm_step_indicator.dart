import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/core/theme/app_typography.dart';

/// Clean, borderless stepper indicator with Persian numerals and Tafakor mint theme.
class KhatmStepIndicator extends StatelessWidget {
  final int currentStep; // 0, 1, 2
  final List<String>? stepLabels;
  final ValueChanged<int>? onStepTapped;

  const KhatmStepIndicator({
    super.key,
    required this.currentStep,
    this.stepLabels,
    this.onStepTapped,
  });

  static const List<String> _stepNumbers = ['۱', '۲', '۳'];
  static const List<String> _defaultStepLabels = [
    'اطلاعات ختم',
    'برنامه‌ریزی ختم',
    'تایید نهایی',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = context.colors;
    final labels = stepLabels ?? _defaultStepLabels;

    return Container(
      color: colors.cardBackground,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Step 1: اطلاعات ختم
          _buildStep(
            context: context,
            stepIndex: 0,
            label: labels[0],
            number: _stepNumbers[0],
            colorScheme: colorScheme,
            cardSubtle: colors.cardBackgroundSubtle,
          ),
          _buildConnector(
            isPassed: currentStep >= 1,
            primaryColor: colorScheme.primary,
            subtleColor: colors.cardBackgroundSubtle,
          ),
          // Step 2: برنامه‌ریزی ختم
          _buildStep(
            context: context,
            stepIndex: 1,
            label: labels[1],
            number: _stepNumbers[1],
            colorScheme: colorScheme,
            cardSubtle: colors.cardBackgroundSubtle,
          ),
          _buildConnector(
            isPassed: currentStep >= 2,
            primaryColor: colorScheme.primary,
            subtleColor: colors.cardBackgroundSubtle,
          ),
          // Step 3: تایید نهایی
          _buildStep(
            context: context,
            stepIndex: 2,
            label: labels[2],
            number: _stepNumbers[2],
            colorScheme: colorScheme,
            cardSubtle: colors.cardBackgroundSubtle,
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required BuildContext context,
    required int stepIndex,
    required String label,
    required String number,
    required ColorScheme colorScheme,
    required Color cardSubtle,
  }) {
    final isCurrent = currentStep == stepIndex;
    final isPassed = currentStep > stepIndex;

    final Color circleBg;
    final Color contentColor;

    if (isCurrent || isPassed) {
      circleBg = colorScheme.primary;
      contentColor = Colors.white;
    } else {
      circleBg = cardSubtle;
      contentColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
    }

    return InkWell(
      onTap: (isPassed && onStepTapped != null)
          ? () => onStepTapped!(stepIndex)
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleBg,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isPassed
                    ? const Icon(
                        CupertinoIcons.checkmark,
                        size: 15,
                        color: Colors.white,
                      )
                    : Text(
                        number,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: contentColor,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11.5,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                color: isCurrent
                    ? colorScheme.primary
                    : (isPassed
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnector({
    required bool isPassed,
    required Color primaryColor,
    required Color subtleColor,
  }) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 22),
        decoration: BoxDecoration(
          color: isPassed ? primaryColor : subtleColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
