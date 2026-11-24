import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/extensions/string_extension.dart';
import 'package:quran/common/utils/jalali_date.dart';
import 'package:quran/common/widgets/app_snackbar.dart';
import 'package:quran/core/routes/route_name.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/tafakor/application/controllers/tafakor_auth_controller.dart';
import 'package:quran/features/khatm/application/controllers/group_khatm_detail_controller.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_campaign.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_slot.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';
import 'package:quran/features/khatm/domain/services/khatm_quran_resolver.dart';
import '../widgets/group_detail/group_khatm_bottom_cta.dart';
import '../widgets/group_detail/group_khatm_detail_header.dart';
import '../widgets/group_detail/group_khatm_detail_skeleton.dart';
import '../widgets/group_detail/group_khatm_my_slot_card.dart';
import '../widgets/group_detail/group_khatm_participants_sheet.dart';
import '../widgets/group_detail/group_khatm_slot_grid.dart';
import '../widgets/group_detail/group_khatm_surah_picker.dart';
import '../widgets/shared/complete_name_bottom_sheet.dart';
import '../widgets/shared/group_khatm_share_sheet.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(groupKhatmDetailControllerProvider(widget.inviteCode).notifier)
          .loadCampaign();
    });
  }

  void _onSlotTap(
    GroupKhatmSlot slot,
    GroupKhatmCampaign campaign,
    bool isAuthenticated,
  ) {
    if (!isAuthenticated) {
      if (slot.isCompleted) {
        AppSnackBar.showInfo(context, 'این سهم قبلاً قرائت شده است');
        return;
      }
      if (slot.isReserved) {
        AppSnackBar.showInfo(context, 'این سهم در حال حاضر در حال قرائت است');
        return;
      }
    }

    if (slot.isCompleted) {
      final holderName = slot.userDisplayName?.trim();
      final String message;
      if (slot.isMine) {
        message = (holderName != null && holderName.isNotEmpty)
            ? 'این سهم توسط شما ($holderName) قرائت و تکمیل شده است'
            : 'این سهم توسط شما قرائت و تکمیل شده است';
      } else {
        final name = (holderName != null && holderName.isNotEmpty)
            ? holderName
            : 'کاربر قرآن';
        message = 'این سهم توسط $name قرائت و تکمیل شده است';
      }
      AppSnackBar.showInfo(context, message);
      return;
    }

    if (slot.isReserved && !slot.isMine) {
      final holderName = slot.userDisplayName?.trim();
      final name = (holderName != null && holderName.isNotEmpty)
          ? holderName
          : 'کاربر قرآن';
      AppSnackBar.showInfo(
        context,
        'این سهم در حال حاضر توسط $name در حال قرائت است',
      );
      return;
    }

    if (slot.isMine) {
      _startReadingSlot(slot, campaign);
      return;
    }

    // Free slot: reserve it!
    _reserveSlotWithGuestCheck(unitNumber: slot.unitNumber, quantity: 1);
  }

  Future<void> _reserveSlotWithGuestCheck({
    int? unitNumber,
    int quantity = 1,
  }) async {
    final notifier = ref.read(
      groupKhatmDetailControllerProvider(widget.inviteCode).notifier,
    );
    final wasGuest = !ref.read(isTafakorAuthenticatedProvider);

    if (wasGuest) {
      final unitLabel = unitNumber != null
          ? 'جزء ${unitNumber.toPersianDigit()}'
          : 'سهم مورد نظر';
      final loggedIn = await GuestOtpBottomSheet.show(
        context,
        title: 'ثبت سهم در ختم گروهی',
        description:
            'برای ثبت $unitLabel به نام شما، لطفاً وارد حساب تفکر شوید.',
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

    var success = await notifier.reserveSlot(
      unitNumber: unitNumber,
      quantity: quantity,
    );

    if (!success && mounted) {
      final detailState = ref.read(
        groupKhatmDetailControllerProvider(widget.inviteCode),
      );
      if (detailState.errorCode == 'profile_name_required') {
        final nameSaved = await CompleteNameBottomSheet.show(context);
        if (nameSaved && mounted) {
          success = await notifier.reserveSlot(
            unitNumber: unitNumber,
            quantity: quantity,
          );
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

    final KhatmUnitType unitType;
    switch (campaign.unitTypeEnum) {
      case GroupKhatmUnitType.juz:
        unitType = KhatmUnitType.juz;
        break;
      case GroupKhatmUnitType.hizb:
        unitType = KhatmUnitType.hizb;
        break;
      case GroupKhatmUnitType.surah:
        unitType = KhatmUnitType.surah;
        break;
    }

    final unitNumber = slot.unitNumber ?? campaign.targetSurah ?? 1;
    final target = KhatmQuranResolver.resolveUnit(
      unitType: unitType,
      unitNumber: unitNumber,
    );

    context.pushNamed(
      quranReaderRoute,
      pathParameters: {'id': target.surahId.toString()},
      queryParameters: {
        'ayah': target.ayahNumber.toString(),
        'groupKhatmCode': campaign.inviteCode,
        'groupSlotUnit': unitNumber.toString(),
        'groupSlotId': slot.id.toString(),
      },
    );
  }

  void _confirmReleaseSlot(GroupKhatmSlot slot) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'انصراف از سهم',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'آیا از انصراف این سهم اطمینان دارید؟ با انصراف، این سهم مجدداً برای دیگر همراهان آزاد می‌شود.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'انصراف',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final notifier = ref.read(
                groupKhatmDetailControllerProvider(widget.inviteCode).notifier,
              );
              final ok = await notifier.releaseSlot(
                slotId: slot.id,
                unitNumber: slot.unitNumber,
              );
              if (ok && mounted) {
                AppSnackBar.showSuccess(context, 'سهم با موفقیت آزاد شد');
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'آزادسازی سهم',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCompleteSlot(GroupKhatmSlot slot, GroupKhatmCampaign campaign) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    final unitLabel = slot.unitNumber != null
        ? '${campaign.unitTypeLabel} ${slot.unitNumber!.toPersianDigit()}'
        : 'سهم شما';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'ثبت اتمام قرائت',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'آیا قرائت $unitLabel را به پایان رسانده‌اید؟ ثواب این تلاوت در پیشرفت ختم ثبت خواهد شد.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'هنوز نه',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final notifier = ref.read(
                groupKhatmDetailControllerProvider(widget.inviteCode).notifier,
              );
              final ok = await notifier.completeSlot(
                slotId: slot.id,
                unitNumber: slot.unitNumber,
              );
              if (ok && mounted) {
                HapticFeedback.mediumImpact();
                AppSnackBar.showSuccess(
                  context,
                  'قبول باشد، ثواب قرائت شما ثبت شد',
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'بله، تکمیل شد',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
                GroupKhatmShareSheet.show(context, campaign: campaign);
              },
              child: Text(
                'دعوت',
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

                            // ── ۲. کارت سهم فعال کاربر (در صورت وجود سهم) ──
                            if (state.myActiveSlot != null) ...[
                              GroupKhatmMySlotCard(
                                slot: state.myActiveSlot!,
                                campaign: campaign,
                                onStartReading: () => _startReadingSlot(
                                  state.myActiveSlot!,
                                  campaign,
                                ),
                                onComplete: () => _confirmCompleteSlot(
                                  state.myActiveSlot!,
                                  campaign,
                                ),
                                onRelease: () =>
                                    _confirmReleaseSlot(state.myActiveSlot!),
                              ),
                              const SizedBox(height: 14),
                            ],

                            // ── ۳. بخش سهم‌ها (انتخاب‌گر سوره یا گرید ۴ ستونه جزء) ──
                            if (campaign.unitTypeEnum ==
                                GroupKhatmUnitType.surah)
                              GroupKhatmSurahPicker(
                                campaign: campaign,
                                onReserve: (quantity) =>
                                    _reserveSlotWithGuestCheck(
                                      quantity: quantity,
                                    ),
                              )
                            else
                              GroupKhatmSlotGrid(
                                campaign: campaign,
                                isAuthenticated: isAuthenticated,
                                onSlotTap: (slot) => _onSlotTap(
                                  slot,
                                  campaign,
                                  isAuthenticated,
                                ),
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
