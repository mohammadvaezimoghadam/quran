import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/core/theme/app_typography.dart';

/// Pure, minimalist white typography walkthrough overlay.
/// Boxless, iconless, with pure white text and thin white outlined action button.
class WalkthroughCardBubble extends StatelessWidget {
  final TutorialCoachMarkController controller;
  final String title;
  final String description;
  final Widget? customIllustration;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onFinish;
  final VoidCallback? onSkip;

  const WalkthroughCardBubble({
    super.key,
    required this.controller,
    required this.title,
    required this.description,
    this.customIllustration,
    required this.currentStep,
    required this.totalSteps,
    this.onFinish,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isFirstStep = currentStep == 1;
    final isLastStep = currentStep == totalSteps;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row 1: Step Indicator (No box, no "گام", Persian digits, pure white) + Skip button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Plain white text: e.g. "۱ از ۴"
                Text(
                  '${currentStep.toPersianDigit()} از ${totalSteps.toPersianDigit()}',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),

                // Skip Button (رد شدن)
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onSkip?.call();
                    controller.skip();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      'رد شدن',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.60),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Row 2: Title (No icon, clean pure bold white typography)
            Text(
              title,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Row 3: Description Text (Pure white on dimmed background)
            Text(
              description,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13.5,
                height: 1.65,
                color: Colors.white.withValues(alpha: 0.90),
                shadows: const [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 6,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),

            // Custom gesture illustration (if present)
            if (customIllustration != null) ...[
              const SizedBox(height: 10),
              customIllustration!,
            ],

            const SizedBox(height: 18),

            // Row 4: Action Buttons (No background color, only thin white border!)
            Row(
              children: [
                // "قبلی" Button (Hidden on first step)
                if (!isFirstStep) ...[
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.transparent,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.40),
                          width: 0.8,
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        controller.previous();
                      },
                      child: const Text(
                        'قبلی',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // "بعدی" or "متوجه شدم" (Primary Button: transparent with thin white border)
                Expanded(
                  flex: isFirstStep ? 1 : 2,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(
                        color: Colors.white,
                        width: 0.8,
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (isLastStep) {
                        onFinish?.call();
                        controller.skip();
                      } else {
                        controller.next();
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastStep ? 'متوجه شدم' : 'بعدی',
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (!isLastStep) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            CupertinoIcons.chevron_left,
                            size: 13,
                            color: Colors.white,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
