import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/extensions/string_extension.dart';
import 'package:quran/common/extensions/surah_name_extension.dart';
import 'package:quran/common/utils/jalali_date.dart';
import 'package:quran/common/widgets/app_snackbar.dart';
import 'package:quran/core/routes/route_name.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/tafakor/application/controllers/tafakor_auth_controller.dart';
import 'package:quran/features/khatm/application/controllers/group_khatm_detail_controller.dart';
import 'package:quran/features/khatm/application/controllers/group_khatm_reading_controller.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_campaign.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_slot.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';
import '../widgets/group_detail/group_khatm_bottom_cta.dart';
import '../widgets/group_detail/group_khatm_detail_header.dart';
import '../widgets/group_detail/group_khatm_detail_skeleton.dart';
import '../widgets/group_detail/group_khatm_participants_sheet.dart';
import '../widgets/group_detail/group_khatm_slot_grid.dart';
import '../widgets/group_detail/group_khatm_surah_picker.dart';
import '../widgets/group_detail/group_khatm_surah_slots_section.dart';
import '../widgets/shared/complete_name_bottom_sheet.dart';
import '../widgets/shared/guest_otp_bottom_sheet.dart';

/// Screen displaying details of a collective Group Khatm Campaign.
/// Features clean, modular widgets without decorative icons, calm Sacred Serenity
/// typography, thumb-friendly 4-column slot grid, smart bottom CTA, and seamless OTP guest flow.
class GroupKhatmDetailScreen extends ConsumerStatefulWidget {
  final String inviteCode;

  const GroupKhatmDetailScreen({super.key, required this.inviteCode});

  @override
  ConsumerState<GroupKhatmDetailScreen> createState() =>
      _GroupKhatmDetailScreenState();
}

class _GroupKhatmDetailScreenState
    extends ConsumerState<GroupKhatmDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(groupKhatmDetailControllerProvider(widget.inviteCode).notifier)
          .loadCampaign();
      await ref
          .read(groupKhatmReadingControllerProvider.notifier)
          .syncPendingCompletions(widget.inviteCode);
    });
  }

  void _onSlotTap(
    GroupKhatmSlot slot,
    GroupKhatmCampaign campaign,
    bool isAuthenticated,
  ) {
    // Strictly ignore other participants' slots or already-completed slots
    if (!slot.isFree && !slot.isMine) {
      return;
    }

    if (slot.isCompleted) {
      return;
    }

    if (slot.isMine) {
      _startReadingSlot(slot, campaign);
      return;
    }

    // Free slot: reserve it!
    _reserveSlotWithGuestCheck(unitNumber: slot.unitNumber, quantity: 1);
  }

  String _formatReserveTargetLabel({
    required GroupKhatmCampaign? campaign,
    int? unitNumber,
    int quantity = 1,
  }) {
    if (campaign?.unitTypeEnum == GroupKhatmUnitType.surah) {
      final surahId = campaign?.targetSurah ?? 1;
      final surahTitle = 'سوره ${surahId.surahNameFa}';
      return quantity > 1
          ? '${quantity.toPersianDigit()} مرتبه $surahTitle'
          : surahTitle;
    }
    if (unitNumber != null) {
      final unitPrefix = campaign?.unitTypeLabel ?? 'جزء';
      return '$unitPrefix ${unitNumber.toPersianDigit()}';
    }
    return 'سهم مورد نظر';
  }

  /// Shared confirmation dialog that locks dismissal and shows an inline
  /// loading spinner inside the confirm button while [onConfirm] completes.
  /// Returns `null` if the user cancelled, or the boolean result of [onConfirm].
  Future<bool?> _showActionConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'انصراف',
    Color? confirmColor,
    required Future<bool> Function() onConfirm,
  }) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final effectiveConfirmColor = confirmColor ?? colorScheme.primary;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return PopScope(
              canPop: !isLoading,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  backgroundColor: colors.cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  content: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.55,
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceEvenly,
                  actions: [
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(dialogCtx).pop(null),
                      child: Text(
                        cancelLabel,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              setDialogState(() => isLoading = true);
                              bool ok = false;
                              try {
                                ok = await onConfirm();
                              } finally {
                                if (dialogCtx.mounted) {
                                  Navigator.of(dialogCtx).pop(ok);
                                }
                              }
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: effectiveConfirmColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size(108, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CupertinoActivityIndicator(
                                color: Colors.white,
                                radius: 9,
                              ),
                            )
                          : Text(
                              confirmLabel,
                              style: const TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _reserveSlotWithGuestCheck({
    int? unitNumber,
    int quantity = 1,
  }) async {
    final notifier = ref.read(
      groupKhatmDetailControllerProvider(widget.inviteCode).notifier,
    );
    final wasGuest = !ref.read(isTafakorAuthenticatedProvider);
    final currentCampaign = ref
        .read(groupKhatmDetailControllerProvider(widget.inviteCode))
        .campaign;
    final unitLabel = _formatReserveTargetLabel(
      campaign: currentCampaign,
      unitNumber: unitNumber,
      quantity: quantity,
    );

    if (wasGuest) {
      final loggedIn = await GuestOtpBottomSheet.show(
        context,
        title: 'ثبت سهم در ختم گروهی',
        description:
            'برای ثبت «$unitLabel» به نام شما، لطفاً وارد حساب تفکر شوید.',
      );
      if (!loggedIn || !mounted) {
        if (mounted && ref.read(isTafakorAuthenticatedProvider)) {
          notifier.loadCampaign(silent: true);
        }
        return;
      }
    }

    final currentUser = ref.read(tafakorUserProvider);
    if (currentUser == null || !currentUser.hasFullName) {
      final nameSaved = await CompleteNameBottomSheet.show(context);
      if (!nameSaved || !mounted) {
        if (wasGuest && mounted) {
          notifier.loadCampaign(silent: true);
        }
        return;
      }
    }

    var dialogResult = await _showActionConfirmDialog(
      title: 'تأیید برداشتن سهم',
      message:
          'آیا مایل به برداشتن «$unitLabel» در این ختم گروهی هستید؟ با تأیید شما این سهم به نام شما ثبت می‌شود.',
      confirmLabel: 'بله، برمی‌دارم',
      onConfirm: () => notifier.reserveSlot(
        unitNumber: unitNumber,
        quantity: quantity,
      ),
    );

    if (dialogResult == null || !mounted) {
      if (wasGuest && mounted) {
        notifier.loadCampaign(silent: true);
      }
      return;
    }

    var success = dialogResult;
    if (!success && mounted) {
      final detailState = ref.read(
        groupKhatmDetailControllerProvider(widget.inviteCode),
      );
      if (detailState.errorCode == 'profile_name_required') {
        final nameSaved = await CompleteNameBottomSheet.show(context);
        if (nameSaved && mounted) {
          dialogResult = await _showActionConfirmDialog(
            title: 'تأیید برداشتن سهم',
            message: 'آیا مایل به ثبت نهایی «$unitLabel» هستید؟',
            confirmLabel: 'ثبت سهم',
            onConfirm: () => notifier.reserveSlot(
              unitNumber: unitNumber,
              quantity: quantity,
            ),
          );
          success = dialogResult == true;
        }
      }
    }

    if (success && mounted) {
      HapticFeedback.mediumImpact();
      AppSnackBar.showSuccess(context, 'سهم شما با موفقیت ثبت شد');
    } else if (wasGuest && mounted) {
      notifier.loadCampaign(silent: true);
    }
  }

  void _startReadingSlot(GroupKhatmSlot slot, GroupKhatmCampaign campaign) {
    HapticFeedback.lightImpact();

    final unitNumber = slot.unitNumber ?? campaign.targetSurah ?? 1;
    final readingController =
        ref.read(groupKhatmReadingControllerProvider.notifier);
    final target = readingController.resolveResumeTarget(
      campaign: campaign,
      slot: slot,
    );

    context.pushNamed(
      quranReaderRoute,
      pathParameters: {'id': target.surahId.toString()},
      queryParameters: {
        'ayah': target.ayahNumber.toString(),
        'groupKhatmCode': campaign.inviteCode,
        'groupSlotUnit': unitNumber.toString(),
        'groupSlotId': slot.id.toString(),
        'groupUnitType': campaign.unitTypeEnum.name,
        'groupSlotQuantity': slot.quantity.toString(),
      },
    );
  }

  Future<void> _confirmReleaseSlot(GroupKhatmSlot slot) async {
    final colorScheme = context.colorScheme;
    final notifier = ref.read(
      groupKhatmDetailControllerProvider(widget.inviteCode).notifier,
    );

    final ok = await _showActionConfirmDialog(
      title: 'انصراف از سهم',
      message:
          'آیا از انصراف این سهم اطمینان دارید؟ با انصراف، این سهم مجدداً برای دیگر همراهان آزاد می‌شود.',
      confirmLabel: 'آزادسازی سهم',
      confirmColor: colorScheme.error,
      onConfirm: () async {
        final released = await notifier.releaseSlot(
          slotId: slot.id,
          unitNumber: slot.unitNumber,
        );
        if (released) {
          await ref
              .read(groupKhatmReadingControllerProvider.notifier)
              .clearSlotProgress(widget.inviteCode, slot.id);
        }
        return released;
      },
    );

    if (ok == true && mounted) {
      AppSnackBar.showSuccess(context, 'سهم با موفقیت آزاد شد');
    }
  }

  Future<void> _confirmCompleteSlot(
    GroupKhatmSlot slot,
    GroupKhatmCampaign campaign,
  ) async {
    final unitLabel = _formatReserveTargetLabel(
      campaign: campaign,
      unitNumber: slot.unitNumber,
      quantity: slot.quantity,
    );
    final notifier = ref.read(
      groupKhatmDetailControllerProvider(widget.inviteCode).notifier,
    );

    final ok = await _showActionConfirmDialog(
      title: 'ثبت اتمام قرائت',
      message:
          'آیا قرائت «$unitLabel» را به پایان رسانده‌اید؟ ثواب این تلاوت در پیشرفت ختم ثبت خواهد شد.',
      confirmLabel: 'بله، تکمیل شد',
      cancelLabel: 'هنوز نه',
      onConfirm: () async {
        final synced = await notifier.completeSlot(
          slotId: slot.id,
          unitNumber: slot.unitNumber,
        );
        await ref
            .read(groupKhatmReadingControllerProvider.notifier)
            .markCompletedLocally(
              inviteCode: widget.inviteCode,
              slot: slot,
              campaign: campaign,
              syncedWithServer: synced,
            );
        return synced;
      },
    );

    if (ok != null && mounted) {
      HapticFeedback.mediumImpact();
      AppSnackBar.showSuccess(
        context,
        ok
            ? 'قبول باشد، ثواب قرائت شما ثبت شد'
            : 'اتمام سهم در حافظه ذخیره شد و پس از اتصال ثبت می‌شود',
      );
    }
  }

  String _buildCampaignStructureSummary(GroupKhatmCampaign campaign) {
    return switch (campaign.unitTypeEnum) {
      GroupKhatmUnitType.juz =>
        'این ختم گروهی بر پایه ۳۰ جزء کامل قرآن کریم طراحی شده است؛ هر کارت یک جزء است و با تکمیل همه بخش‌ها، ثواب یک ختم کامل جمعی ثبت می‌شود.',
      GroupKhatmUnitType.hizb =>
        'این ختم گروهی بر پایه ۱۲۰ حزب قرآن کریم (هر جزء شامل ۴ حزب) تقسیم شده تا حجم هر سهم کوتاه‌تر باشد و همگان به آسانی مشارکت کنند.',
      GroupKhatmUnitType.surah => () {
        final surahName =
            campaign.targetSurahName ??
            campaign.targetSurah?.surahNameFa ??
            'منتخب';
        return 'این ختم گروهی بر محور قرائت سوره مبارکه «$surahName» در قالب ${campaign.targetUnits.toPersianDigit()} سهم طراحی شده است و می‌توانید یک یا چند دور قرائت را انتخاب کنید.';
      }(),
    };
  }

  Future<void> _showReadingGuideDialog(GroupKhatmCampaign campaign) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final remainingLabel = campaign.remainingTimeLabel();
    final structureLabel = switch (campaign.unitTypeEnum) {
      GroupKhatmUnitType.juz => 'اساس ختم: جزءبندی (۳۰ جزء)',
      GroupKhatmUnitType.hizb => 'اساس ختم: حزب‌بندی (۱۲۰ حزب)',
      GroupKhatmUnitType.surah =>
        'اساس ختم: سوره ${campaign.targetSurahName ?? campaign.targetSurah?.surahNameFa ?? 'منتخب'}',
    };

    return showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: colors.cardBackground,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            contentPadding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
            actionsPadding: const EdgeInsets.fromLTRB(18, 6, 18, 16),
            title: Text(
              'راهنمای قرائت و مشارکت',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildGuideStepItem(
                    title: structureLabel,
                    description: _buildCampaignStructureSummary(campaign),
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 10),
                  _buildGuideStepItem(
                    title: 'انتخاب سهم شخصی',
                    description:
                        'با لمس هر کارت آزاد و تایید در پنجره، آن بخش به نام شما ثبت می‌شود. کارت سایر همراهان تنها برای مشاهده وضعیت است.',
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 10),
                  _buildGuideStepItem(
                    title: 'تلاوت در برنامه و ثبت خودکار',
                    description:
                        'با لمس کارت خود یا آیکون پخش وارد قرآن‌خوان همان بخش می‌شوید. درصد مطالعه و آخرین آیه حتی به‌صورت آفلاین ذخیره می‌شود تا ادامه دهید و در پایان بخش خودکار تکمیل گردد.',
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 10),
                  _buildGuideStepItem(
                    title: 'تکمیل دستی یا آزادسازی کارت',
                    description:
                        'در صورت قرائت از روی مصحف کاغذی، با دکمه «تموم شد» اتمام را ثبت کنید؛ پیش از اتمام نیز با آیکون بازگشت می‌توانید سهم را آزاد کنید.',
                    colorScheme: colorScheme,
                  ),
                  if (remainingLabel != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      remainingLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Text(
                    'متوجه شدم',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuideStepItem({
    required String title,
    required String description,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            description,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11.5,
              height: 1.55,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      groupKhatmDetailControllerProvider(widget.inviteCode),
    );
    final isAuthenticated = ref.watch(isTafakorAuthenticatedProvider);
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    // Listen for conflict error (409) or other errors
    ref.listen<GroupKhatmDetailState>(
      groupKhatmDetailControllerProvider(widget.inviteCode),
      (prev, next) {
        if (next.conflictError != null &&
            next.conflictError != prev?.conflictError) {
          AppSnackBar.showWarning(context, next.conflictError!);
        } else if (next.errorMessage != null &&
            next.errorMessage != prev?.errorMessage &&
            next.errorCode != 'profile_name_required') {
          AppSnackBar.showError(context, next.errorMessage!);
        }
      },
    );

    final campaign = state.campaign;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'جزئیات ختم گروهی',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colors.cardBackground,
        leading: IconButton(
          tooltip: 'بازگشت',
          icon: Icon(
            CupertinoIcons.chevron_forward,
            size: 24,
            color: colorScheme.onSurface,
          ),
          splashRadius: 22,
          onPressed: () {
            HapticFeedback.lightImpact();
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.pop();
            }
          },
        ),
        actions: [
          if (campaign != null)
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showReadingGuideDialog(campaign);
              },
              child: Text(
                'توضیحات',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
            height: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: state.isLoading && campaign == null
            ? const GroupKhatmDetailSkeleton()
            : campaign == null
            ? _buildNotFoundView(colorScheme)
            : RefreshIndicator(
                onRefresh: () => ref
                    .read(
                      groupKhatmDetailControllerProvider(
                        widget.inviteCode,
                      ).notifier,
                    )
                    .loadCampaign(silent: true),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── ۱. کارت هدر مشخصات و پیشرفت ختم (با نمودار دایره‌ای) ──
                            GroupKhatmDetailHeader(campaign: campaign),
                            const SizedBox(height: 14),

                            // ── ۲. بخش سهم‌ها (سوره + کارت‌های مشارکت من، یا گرید ۳ ستونه با درصد و دکمه‌ها روی خود کارت) ──
                            if (campaign.unitTypeEnum ==
                                GroupKhatmUnitType.surah) ...[
                              if (state.mySlots.isNotEmpty) ...[
                                GroupKhatmSurahSlotsSection(
                                  campaign: campaign,
                                  mySlots: state.mySlots,
                                  onContinueReading: (slot) =>
                                      _startReadingSlot(slot, campaign),
                                  onCompleteSlot: (slot) =>
                                      _confirmCompleteSlot(slot, campaign),
                                  onReleaseSlot: _confirmReleaseSlot,
                                ),
                                const SizedBox(height: 14),
                              ],
                              GroupKhatmSurahPicker(
                                campaign: campaign,
                                onReserve: (quantity) =>
                                    _reserveSlotWithGuestCheck(
                                      quantity: quantity,
                                    ),
                              ),
                            ] else
                              GroupKhatmSlotGrid(
                                campaign: campaign,
                                isAuthenticated: isAuthenticated,
                                onSlotTap: (slot) => _onSlotTap(
                                  slot,
                                  campaign,
                                  isAuthenticated,
                                ),
                                onCompleteSlot: (slot) =>
                                    _confirmCompleteSlot(slot, campaign),
                                onReleaseSlot: _confirmReleaseSlot,
                              ),
                            const SizedBox(height: 14),

                            // ── ۴. کارت فعالیت همراهان و تاریخ پایان ختم ──
                            _buildSocialProofCard(
                              campaign,
                              isAuthenticated,
                              isDark,
                              colorScheme,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // ── ۵. دکمه هوشمند چسبان پایین (صرفاً برای حالت جزء/حزب زمانی که سهمی برداشته نشده) ──
                    if (campaign.unitTypeEnum != GroupKhatmUnitType.surah &&
                        state.myActiveSlot == null)
                      GroupKhatmBottomCta(
                        campaign: campaign,
                        myActiveSlot: state.myActiveSlot,
                        firstFreeSlot: state.firstFreeSlot,
                        onStartReading: () {
                          if (state.myActiveSlot != null) {
                            _startReadingSlot(state.myActiveSlot!, campaign);
                          }
                        },
                        onAutoSelectFree: () {
                          if (state.firstFreeSlot != null) {
                            _reserveSlotWithGuestCheck(
                              unitNumber: state.firstFreeSlot!.unitNumber,
                              quantity: 1,
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSocialProofCard(
    GroupKhatmCampaign campaign,
    bool isAuthenticated,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final pillBg = isDark ? const Color(0xFF222224) : const Color(0xFFF3F1EC);
    final String deadlineText = campaign.deadline != null
        ? 'تا ${JalaliDate.fromDateTime(campaign.deadline!).formatFa().toPersianDigit()}'
        : '';

    if (!isAuthenticated) {
      return InkWell(
        onTap: () async {
          HapticFeedback.lightImpact();
          final loggedIn = await GuestOtpBottomSheet.show(
            context,
            title: 'ورود به حساب تفکر',
            description:
                'برای مشاهده نام همراهان و مشارکت در ختم گروهی، وارد حساب خود شوید.',
          );
          if (loggedIn && mounted) {
            ref
                .read(
                  groupKhatmDetailControllerProvider(widget.inviteCode).notifier,
                )
                .loadCampaign(silent: true);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
              Expanded(
                child: Text(
                  'برای مشاهده نام همراهان و مشارکت، وارد شوید',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ورود',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final takenSlots =
        campaign.slots.where((s) => s.isReserved || s.isCompleted).toList();
    final seenParticipantKeys = <String>{};
    final realNames = <String>[];
    for (final s in takenSlots) {
      final name = s.userDisplayName?.trim() ?? '';
      final key = s.userId?.toString() ?? (name.isNotEmpty ? name : 'slot_${s.id}');
      if (seenParticipantKeys.add(key) && name.isNotEmpty) {
        realNames.add(name);
      }
    }

    final participantCount = seenParticipantKeys.length;
    final avatarNames = realNames.take(3).toList();
    final stackWidth = avatarNames.isEmpty
        ? 0.0
        : (22.0 + (avatarNames.length - 1) * 14.0);
    final avatarColors = [
      colorScheme.primary,
      const Color(0xFF3F6964),
      const Color(0xFF5E7E7A),
    ];

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        GroupKhatmParticipantsSheet.show(
          context,
          campaign: campaign,
          isAuthenticated: isAuthenticated,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            Expanded(
              child: Row(
                children: [
                  if (avatarNames.isNotEmpty) ...[
                    SizedBox(
                      width: stackWidth,
                      height: 22,
                      child: Stack(
                        children: [
                          for (int i = 0; i < avatarNames.length; i++)
                            Positioned(
                              right: i * 14.0,
                              child: _buildAvatarCircle(
                                String.fromCharCode(avatarNames[i].runes.first),
                                avatarColors[i % avatarColors.length],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      participantCount == 0
                          ? 'هنوز همراهی در این ختم شرکت نکرده است.'
                          : 'تاکنون ${participantCount.toPersianDigit()} نفر در این ختم شرکت کرده‌اند.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        color:
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (deadlineText.isNotEmpty) ...[
                  Text(
                    deadlineText,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  'مشاهده',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCircle(String char, Color bgColor) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.2),
      ),
      child: Center(
        child: Text(
          char,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundView(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ختم مورد نظر یافت نشد یا حذف شده است',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.pop(),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('بازگشت به لیست ختم‌ها'),
          ),
        ],
      ),
    );
  }
}
