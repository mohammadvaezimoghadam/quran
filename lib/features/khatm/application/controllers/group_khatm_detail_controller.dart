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
    if (!silent) {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    final result = await _repository.getCampaignDetail(inviteCode);
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
    state = state.copyWith(isActionLoading: true, clearError: true, clearConflict: true);
    final result = await _repository.reserveSlot(
      inviteCode,
      unitNumber: unitNumber,
      quantity: quantity,
    );

    return result.when(
      (updatedCampaign) {
        state = state.copyWith(
          campaign: updatedCampaign,
          isActionLoading: false,
        );
        _refreshGroupList();
        return true;
      },
      (failure) {
        // Check for 409 conflict
        if (failure.statusCode == 409) {
          state = state.copyWith(
            isActionLoading: false,
            conflictError: failure.message,
            errorCode: failure.code,
          );
          // Silently refresh the campaign to update slot grid in real-time
          loadCampaign(silent: true);
        } else {
          state = state.copyWith(
            isActionLoading: false,
            errorMessage: failure.message,
            errorCode: failure.code,
          );
        }
        return false;
      },
    );
  }

  /// Mark reserved slot as completed
  Future<bool> completeSlot({int? slotId, int? unitNumber}) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.completeSlot(
      inviteCode,
      slotId: slotId,
      unitNumber: unitNumber,
    );

    return result.when(
      (updatedCampaign) {
        final wasCompleted = updatedCampaign.status == GroupKhatmStatus.completed;
        state = state.copyWith(
          campaign: updatedCampaign,
          isActionLoading: false,
          campaignJustCompleted: wasCompleted,
        );
        _refreshGroupList();
        return true;
      },
      (failure) {
        state = state.copyWith(
          isActionLoading: false,
          errorMessage: failure.message,
          errorCode: failure.code,
        );
        return false;
      },
    );
  }

  /// Release a slot back to the group
  Future<bool> releaseSlot({int? slotId, int? unitNumber}) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.releaseSlot(
      inviteCode,
      slotId: slotId,
      unitNumber: unitNumber,
    );

    return result.when(
      (updatedCampaign) {
        state = state.copyWith(
          campaign: updatedCampaign,
          isActionLoading: false,
        );
        _refreshGroupList();
        return true;
      },
      (failure) {
        state = state.copyWith(
          isActionLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  void clearErrors() {
    state = state.copyWith(clearError: true, clearConflict: true);
  }
}
