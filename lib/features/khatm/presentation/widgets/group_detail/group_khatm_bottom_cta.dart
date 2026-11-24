import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/core/theme/app_typography.dart';
import '../../../domain/entities/group_khatm_campaign.dart';
import '../../../domain/entities/group_khatm_slot.dart';

/// Contextual sticky bottom CTA button bar for Group Khatm Detail Screen.
/// Intelligently switches between "شروع تلاوت سهم من" and "انتخاب خودکار اولین سهم آزاد".
class GroupKhatmBottomCta extends StatelessWidget {
  final GroupKhatmCampaign campaign;
  final GroupKhatmSlot? myActiveSlot;
  final GroupKhatmSlot? firstFreeSlot;
  final VoidCallback onStartReading;
  final VoidCallback onAutoSelectFree;
  final bool isLoading;

  const GroupKhatmBottomCta({
    super.key,
    required this.campaign,
    required this.myActiveSlot,
    required this.firstFreeSlot,
    required this.onStartReading,
    required this.onAutoSelectFree,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    final String buttonLabel;
    final VoidCallback? onPressed;

    if (myActiveSlot != null) {
      final unitNum = myActiveSlot!.unitNumber;
      buttonLabel = unitNum != null
          ? 'شروع تلاوت سهم من (${campaign.unitTypeLabel} ${unitNum.toPersianDigit()})'
          : 'شروع تلاوت سهم من';
      onPressed = onStartReading;
    } else if (firstFreeSlot != null) {
      final unitNum = firstFreeSlot!.unitNumber;
      buttonLabel = unitNum != null
          ? 'انتخاب خودکار اولین سهم آزاد (${campaign.unitTypeLabel} ${unitNum.toPersianDigit()})'
          : 'انتخاب خودکار اولین سهم آزاد';
      onPressed = onAutoSelectFree;
    } else if (campaign.remainingUnits > 0) {
      buttonLabel = 'برداشتن سهم جدید در این ختم';
      onPressed = onAutoSelectFree;
    } else {
      buttonLabel = 'تمام سهم‌های این ختم تکمیل شده است';
      onPressed = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border(
          top: BorderSide(color: colors.cardBorder, width: 0.8),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: isLoading ? null : onPressed,
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
                ? const CupertinoActivityIndicator(
                    color: Colors.white,
                    radius: 10,
                  )
                : Text(
                    buttonLabel,
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
    );
  }
}
