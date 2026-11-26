import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/group_khatm_campaign.dart';
import '../../domain/entities/group_khatm_slot.dart';
import '../../domain/entities/khatm_enums.dart';
import '../../domain/repositories/i_khatm_repository.dart';
import '../../infrastructure/repositories/khatm_repository_impl.dart';
import 'group_khatm_list_controller.dart';

class GroupKhatmDetailState {
  final GroupKhatmCampaign? campaign;
  final bool isLoading;
  final bool isActionLoading;
  final String? errorMessage;
  final String? errorCode;
  final String? conflictError;
  final bool campaignJustCompleted;

  const GroupKhatmDetailState({
    this.campaign,
    this.isLoading = true,
    this.isActionLoading = false,
    this.errorMessage,
    this.errorCode,
    this.conflictError,
    this.campaignJustCompleted = false,
  });

  GroupKhatmDetailState copyWith({
    GroupKhatmCampaign? campaign,
    bool? isLoading,
    bool? isActionLoading,
    String? errorMessage,
    String? errorCode,
    String? conflictError,
    bool? campaignJustCompleted,
    bool clearConflict = false,
    bool clearError = false,
  }) {
    return GroupKhatmDetailState(
      campaign: campaign ?? this.campaign,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      conflictError: clearConflict ? null : (conflictError ?? this.conflictError),
      campaignJustCompleted: campaignJustCompleted ?? this.campaignJustCompleted,
    );
  }

  /// Helper: all slots owned by the current user
  List<GroupKhatmSlot> get mySlots =>
      campaign?.slots.where((s) => s.isMine).toList() ?? const [];

  /// Helper: find user's active (reserved) slot
  GroupKhatmSlot? get myActiveSlot {
    final c = campaign;
    if (c == null) return null;
    try {
      return c.slots.firstWhere(
        (s) => s.isMine && s.status == GroupKhatmSlotStatus.reserved,
      );
    } catch (_) {
      return null;
    }
  }

  /// Helper: find first available free slot for quick 1-click claim
  GroupKhatmSlot? get firstFreeSlot {
    final c = campaign;
    if (c == null) return null;
    try {
      return c.slots.firstWhere((s) => s.isFree);
    } catch (_) {
      return null;
    }
  }
}

final groupKhatmDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<GroupKhatmDetailController, GroupKhatmDetailState, String>((ref, inviteCode) {
  final repository = ref.watch(khatmRepositoryProvider);
  return GroupKhatmDetailController(repository, inviteCode, ref);
});

class GroupKhatmDetailController extends StateNotifier<GroupKhatmDetailState> {
  final IKhatmRepository _repository;
  final String inviteCode;
  final Ref? _ref;

  GroupKhatmDetailController(this._repository, this.inviteCode, [this._ref])
      : super(const GroupKhatmDetailState()) {
    loadCampaign();
  }

  void _refreshGroupList() {
    try {
      _ref?.read(groupKhatmListControllerProvider.notifier).refreshAll();
    } catch (_) {}
  }

  Future<void> loadCampaign({bool silent = false}) async {
    if (!mounted) return;
    if (!silent) {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    final result = await _repository.getCampaignDetail(inviteCode);
    if (!mounted) return;
    result.when(
      (campaign) {
        state = state.copyWith(
          campaign: campaign,
          isLoading: false,
        );
      },
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Claim a slot (juz/hizb unitNumber, or surah quantity)
  Future<bool> reserveSlot({int? unitNumber, int quantity = 1}) async {
    if (!mounted) return false;
    state = state.copyWith(isActionLoading: true, clearError: true, clearConflict: true);
    final result = await _repository.reserveSlot(
      inviteCode,
      unitNumber: unitNumber,
      quantity: quantity,
    );

    return await result.when(
      (updatedCampaign) async {
        if (mounted) {
          await _applyMutationResult(
            returned: updatedCampaign,
            targetUnitNumber: unitNumber,
            newStatus: GroupKhatmSlotStatus.reserved,
            newIsMine: true,
          );
        }
        _refreshGroupList();
        return true;
      },
      (failure) async {
        if (!mounted) return false;
        final isConflict = failure.statusCode == 409 ||
            failure.code == 'slot_already_taken' ||
            failure.code == 'slot_unavailable' ||
            failure.code == 'already_reserved';
        if (isConflict) {
          state = state.copyWith(
            isActionLoading: false,
            conflictError: failure.message,
            errorCode: failure.code,
          );
          await loadCampaign(silent: true);
        } else {
          state = state.copyWith(
            isActionLoading: false,
            errorMessage: failure.message,
            errorCode: failure.code,
          );
          if (failure.statusCode == 400 &&
              failure.code != 'profile_name_required') {
            await loadCampaign(silent: true);
          }
        }
        return false;
      },
    );
  }

  /// Mark reserved slot as completed
  Future<bool> completeSlot({int? slotId, int? unitNumber}) async {
    if (!mounted) return false;
    state = state.copyWith(isActionLoading: true, clearError: true, clearConflict: true);
    final result = await _repository.completeSlot(
      inviteCode,
      slotId: slotId,
      unitNumber: unitNumber,
    );

    return await result.when(
      (updatedCampaign) async {
        if (mounted) {
          await _applyMutationResult(
            returned: updatedCampaign,
            targetSlotId: slotId,
            targetUnitNumber: unitNumber,
            newStatus: GroupKhatmSlotStatus.completed,
            newIsMine: true,
          );
        }
        _refreshGroupList();
        return true;
      },
      (failure) async {
        if (!mounted) return false;
        state = state.copyWith(
          isActionLoading: false,
          errorMessage: failure.message,
          errorCode: failure.code,
        );
        if (failure.statusCode == 409 || failure.statusCode == 404) {
          await loadCampaign(silent: true);
        }
        return false;
      },
    );
  }

  /// Release a slot back to the group
  Future<bool> releaseSlot({int? slotId, int? unitNumber}) async {
    if (!mounted) return false;
    state = state.copyWith(isActionLoading: true, clearError: true, clearConflict: true);
    final result = await _repository.releaseSlot(
      inviteCode,
      slotId: slotId,
      unitNumber: unitNumber,
    );

    return await result.when(
      (updatedCampaign) async {
        if (mounted) {
          await _applyMutationResult(
            returned: updatedCampaign,
            targetSlotId: slotId,
            targetUnitNumber: unitNumber,
            newStatus: GroupKhatmSlotStatus.available,
            newIsMine: false,
          );
        }
        _refreshGroupList();
        return true;
      },
      (failure) async {
        if (!mounted) return false;
        state = state.copyWith(
          isActionLoading: false,
          errorMessage: failure.message,
          errorCode: failure.code,
        );
        if (failure.statusCode == 409 || failure.statusCode == 404) {
          await loadCampaign(silent: true);
        }
        return false;
      },
    );
  }

  /// Applies a mutation response without ever wiping existing slots if the backend
  /// omits `slots` or returns only a partial/summary payload, then performs a
  /// silent detail reload to guarantee authoritative synchronization.
  Future<void> _applyMutationResult({
    required GroupKhatmCampaign returned,
    int? targetSlotId,
    int? targetUnitNumber,
    required GroupKhatmSlotStatus newStatus,
    required bool newIsMine,
  }) async {
    if (!mounted) return;
    final previous = state.campaign;
    final hasFullReturnedSlots =
        returned.id > 0 &&
        returned.slots.isNotEmpty &&
        returned.slots.length >= (previous?.slots.length ?? 0);

    if (hasFullReturnedSlots) {
      state = state.copyWith(
        campaign: returned,
        isActionLoading: false,
        campaignJustCompleted: returned.status == GroupKhatmStatus.completed,
      );
      return;
    }

    if (previous != null) {
      final mergedSlots = _mergeSlotsOptimistically(
        previousSlots: previous.slots,
        returnedSlots: returned.slots,
        targetSlotId: targetSlotId,
        targetUnitNumber: targetUnitNumber,
        newStatus: newStatus,
        newIsMine: newIsMine,
      );

      final hasCampaignStats = returned.id > 0;
      final reservedCount = mergedSlots.where((s) => s.isReserved).length;
      final completedCount = mergedSlots.where((s) => s.isCompleted).length;
      final remainingCount =
          (previous.targetUnits - completedCount - reservedCount)
              .clamp(0, previous.targetUnits);
      final progress = previous.targetUnits > 0
          ? (completedCount / previous.targetUnits) * 100.0
          : previous.progressPercentage;

      final mergedCampaign = GroupKhatmCampaign(
        id: hasCampaignStats ? returned.id : previous.id,
        inviteCode: previous.inviteCode,
        category: (hasCampaignStats ? returned.category : null) ??
            previous.category,
        creatorId: (hasCampaignStats ? returned.creatorId : null) ??
            previous.creatorId,
        creatorDisplayName: hasCampaignStats &&
                returned.creatorDisplayName.isNotEmpty
            ? returned.creatorDisplayName
            : previous.creatorDisplayName,
        title: hasCampaignStats && returned.title.isNotEmpty
            ? returned.title
            : previous.title,
        description: (hasCampaignStats ? returned.description : null) ??
            previous.description,
        unitType: previous.unitType,
        unitTypeDisplay: previous.unitTypeDisplay,
        targetUnits:
            hasCampaignStats ? returned.targetUnits : previous.targetUnits,
        targetSurahId: previous.targetSurahId,
        targetSurahName: previous.targetSurahName,
        reservedUnits:
            hasCampaignStats ? returned.reservedUnits : reservedCount,
        completedUnits:
            hasCampaignStats ? returned.completedUnits : completedCount,
        remainingUnits:
            hasCampaignStats ? returned.remainingUnits : remainingCount,
        progressPercentage:
            hasCampaignStats ? returned.progressPercentage : progress,
        isPublic: hasCampaignStats ? returned.isPublic : previous.isPublic,
        status: hasCampaignStats ? returned.status : previous.status,
        statusDisplay: (hasCampaignStats ? returned.statusDisplay : null) ??
            previous.statusDisplay,
        deadline: (hasCampaignStats ? returned.deadline : null) ??
            previous.deadline,
        createdAt: previous.createdAt,
        isCreator: previous.isCreator,
        slots: mergedSlots,
        inviteUrl: previous.inviteUrl,
        myActiveSlotsCount: hasCampaignStats
            ? returned.myActiveSlotsCount
            : mergedSlots.where((s) => s.isMine && s.isReserved).length,
      );

      state = state.copyWith(
        campaign: mergedCampaign,
        isActionLoading: false,
        campaignJustCompleted:
            mergedCampaign.status == GroupKhatmStatus.completed,
      );
    }

    // Fetch authoritative full detail including all slots and display names
    await loadCampaign(silent: true);
  }

  List<GroupKhatmSlot> _mergeSlotsOptimistically({
    required List<GroupKhatmSlot> previousSlots,
    required List<GroupKhatmSlot> returnedSlots,
    int? targetSlotId,
    int? targetUnitNumber,
    required GroupKhatmSlotStatus newStatus,
    required bool newIsMine,
  }) {
    if (returnedSlots.length == 1) {
      final serverSlot = returnedSlots.first;
      bool matched = false;
      final updated = previousSlots.map((s) {
        if (s.id == serverSlot.id) {
          matched = true;
          return serverSlot;
        }
        return s;
      }).toList();
      if (!matched) {
        updated.add(serverSlot);
      }
      updated.sort(GroupKhatmSlot.compareByUnitOrder);
      return updated;
    }

    return previousSlots.map((s) {
      final matchesById = targetSlotId != null && s.id == targetSlotId;
      final matchesByUnit =
          targetUnitNumber != null && s.unitNumber == targetUnitNumber;
      if (matchesById || matchesByUnit) {
        return GroupKhatmSlot(
          id: s.id,
          campaignId: s.campaignId,
          unitNumber: s.unitNumber,
          quantity: s.quantity,
          status: newStatus,
          userId: newStatus == GroupKhatmSlotStatus.available ? null : s.userId,
          userDisplayName: newStatus == GroupKhatmSlotStatus.available
              ? null
              : (s.userDisplayName ?? 'شما'),
          isMine: newIsMine,
          reservedAt: newStatus == GroupKhatmSlotStatus.reserved
              ? (s.reservedAt ?? DateTime.now())
              : null,
          expiresAt: newStatus == GroupKhatmSlotStatus.reserved
              ? s.expiresAt
              : null,
          completedAt: newStatus == GroupKhatmSlotStatus.completed
              ? DateTime.now()
              : null,
        );
      }
      return s;
    }).toList();
  }

  void clearErrors() {
    state = state.copyWith(clearError: true, clearConflict: true);
  }
}
