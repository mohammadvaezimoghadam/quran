/// State representation of the user's VIP membership and trial status.
class VipSubscriptionState {
  final bool isVip;
  final DateTime? vipExpiryDate;
  final bool isTrialActive;
  final DateTime? trialExpiryDate;
  final bool isTrialUsed;
  final String? activePlanId;
  final bool isLoading;
  final String? errorMessage;

  const VipSubscriptionState({
    this.isVip = false,
    this.vipExpiryDate,
    this.isTrialActive = false,
    this.trialExpiryDate,
    this.isTrialUsed = false,
    this.activePlanId,
    this.isLoading = false,
    this.errorMessage,
  });

  /// True if the user has an active paid VIP subscription or an active 3-day free trial.
  bool get hasVipAccess {
    final now = DateTime.now();
    if (isVip) {
      if (vipExpiryDate == null) return true; // Lifetime VIP
      return now.isBefore(vipExpiryDate!);
    }
    if (isTrialActive && trialExpiryDate != null) {
      return now.isBefore(trialExpiryDate!);
    }
    return false;
  }

  /// Remaining days of VIP subscription or trial.
  int get remainingDays {
    final now = DateTime.now();
    if (isVip && vipExpiryDate != null) {
      final diff = vipExpiryDate!.difference(now).inDays;
      return diff >= 0 ? diff : 0;
    }
    if (isTrialActive && trialExpiryDate != null) {
      final diff = trialExpiryDate!.difference(now).inDays;
      return diff >= 0 ? diff : 0;
    }
    return 0;
  }

  VipSubscriptionState copyWith({
    bool? isVip,
    DateTime? vipExpiryDate,
    bool? isTrialActive,
    DateTime? trialExpiryDate,
    bool? isTrialUsed,
    String? activePlanId,
    bool? isLoading,
    String? errorMessage,
  }) {
    return VipSubscriptionState(
      isVip: isVip ?? this.isVip,
      vipExpiryDate: vipExpiryDate ?? this.vipExpiryDate,
      isTrialActive: isTrialActive ?? this.isTrialActive,
      trialExpiryDate: trialExpiryDate ?? this.trialExpiryDate,
      isTrialUsed: isTrialUsed ?? this.isTrialUsed,
      activePlanId: activePlanId ?? this.activePlanId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
