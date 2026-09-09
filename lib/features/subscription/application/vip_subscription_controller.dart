import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/payment/i_payment_service.dart';
import '../../../core/services/payment/models/payment_product.dart';
import '../../../core/services/payment/models/purchase_result.dart';
import '../../../core/services/payment/payment_providers.dart';
import '../data/vip_secure_storage.dart';
import '../domain/models/vip_subscription_state.dart';

/// Provider for the secure storage instance.
final vipSecureStorageProvider = Provider<VipSecureStorage>((ref) {
  return const VipSecureStorage();
});

/// Riverpod Notifier controlling VIP subscriptions, trial periods, and donations.
class VipSubscriptionController extends Notifier<VipSubscriptionState> {
  late final IPaymentService _paymentService;
  late final VipSecureStorage _storage;

  @override
  VipSubscriptionState build() {
    _paymentService = ref.watch(paymentServiceProvider);
    _storage = ref.watch(vipSecureStorageProvider);
    _loadPersistedState();
    return const VipSubscriptionState(isLoading: true);
  }

  /// Loads subscription and trial status securely from device storage.
  Future<void> _loadPersistedState() async {
    try {
      final isVip = await _storage.getIsVip();
      final vipExpiry = await _storage.getVipExpiryDate();
      final activePlanId = await _storage.getActivePlanId();
      final isTrialUsed = await _storage.getIsTrialUsed();
      final trialExpiry = await _storage.getTrialExpiryDate();

      final now = DateTime.now();
      bool isTrialActive = false;
      if (trialExpiry != null && now.isBefore(trialExpiry)) {
        isTrialActive = true;
      }

      bool isVipActive = isVip;
      if (isVip && vipExpiry != null && now.isAfter(vipExpiry)) {
        // Subscription has expired
        isVipActive = false;
        await _storage.setIsVip(false);
      }

      state = state.copyWith(
        isVip: isVipActive,
        vipExpiryDate: vipExpiry,
        activePlanId: activePlanId,
        isTrialUsed: isTrialUsed,
        isTrialActive: isTrialActive,
        trialExpiryDate: trialExpiry,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'خطا در بارگذاری اطلاعات اشتراک: $e',
      );
    }
  }

  /// Activates the 3-day free trial period for the user if not previously used.
  Future<bool> activateFreeTrial() async {
    if (state.isTrialUsed) return false;

    state = state.copyWith(isLoading: true);
    final expiry = DateTime.now().add(const Duration(days: 3));

    await _storage.setIsTrialUsed(true);
    await _storage.setTrialExpiryDate(expiry);

    state = state.copyWith(
      isTrialActive: true,
      trialExpiryDate: expiry,
      isTrialUsed: true,
      isLoading: false,
    );

    return true;
  }

  /// Initiates purchase flow for a VIP subscription plan.
  Future<PurchaseResult> purchaseSubscription(PaymentProduct product) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _paymentService.purchaseSubscription(product.id);

    if (result.isSuccess) {
      DateTime? newExpiry;
      final now = DateTime.now();
      final baseDate = (state.vipExpiryDate != null && state.vipExpiryDate!.isAfter(now))
          ? state.vipExpiryDate!
          : now;

      switch (product.subscriptionPlan) {
        case SubscriptionPlan.monthly:
          newExpiry = baseDate.add(const Duration(days: 30));
          break;
        case SubscriptionPlan.quarterly:
          newExpiry = baseDate.add(const Duration(days: 90));
          break;
        case SubscriptionPlan.yearly:
          newExpiry = baseDate.add(const Duration(days: 365));
          break;
        case SubscriptionPlan.lifetime:
          newExpiry = null; // null represents lifetime
          break;
        case null:
          newExpiry = baseDate.add(const Duration(days: 30));
          break;
      }

      await _storage.setIsVip(true);
      await _storage.setVipExpiryDate(newExpiry);
      await _storage.setActivePlanId(product.id);

      state = state.copyWith(
        isVip: true,
        vipExpiryDate: newExpiry,
        activePlanId: product.id,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.errorMessage,
      );
    }

    return result;
  }

  /// Initiates payment for a Nazr / cultural endowment package.
  /// Automatically awards bonus VIP subscription days to the user.
  Future<PurchaseResult> purchaseNazr(PaymentProduct product) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _paymentService.purchaseConsumable(product.id);

    if (result.isSuccess && product.giftSubscriptionDays > 0) {
      final now = DateTime.now();
      final baseDate = (state.vipExpiryDate != null && state.vipExpiryDate!.isAfter(now))
          ? state.vipExpiryDate!
          : now;

      final newExpiry = baseDate.add(Duration(days: product.giftSubscriptionDays));

      await _storage.setIsVip(true);
      await _storage.setVipExpiryDate(newExpiry);

      state = state.copyWith(
        isVip: true,
        vipExpiryDate: newExpiry,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.errorMessage,
      );
    }

    return result;
  }

  /// Restores previous active purchases.
  Future<bool> restorePurchases() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final results = await _paymentService.restorePurchases();

    if (results.isNotEmpty) {
      await _storage.setIsVip(true);
      state = state.copyWith(isVip: true, isLoading: false);
      return true;
    }

    state = state.copyWith(isLoading: false);
    return false;
  }
}

/// Central controller provider for VIP subscriptions.
final vipSubscriptionControllerProvider =
    NotifierProvider<VipSubscriptionController, VipSubscriptionState>(
  VipSubscriptionController.new,
);

/// Convenience provider to easily check if user has VIP or active trial.
final hasVipAccessProvider = Provider<bool>((ref) {
  return ref.watch(vipSubscriptionControllerProvider).hasVipAccess;
});
