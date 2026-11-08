import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/analytics/analytics_providers.dart';
import '../../../core/services/analytics/i_analytics_service.dart';
import '../../../core/services/payment/i_payment_service.dart';
import '../../../core/services/payment/models/payment_product.dart';
import '../../../core/services/payment/models/purchase_result.dart';
import '../../../core/services/payment/payment_providers.dart';
import '../../tafakor/application/controllers/tafakor_auth_controller.dart';
import '../data/subscription_remote_datasource.dart';
import '../data/vip_secure_storage.dart';
import '../domain/models/vip_subscription_state.dart';
import '../domain/policy/audio_vip_policy.dart';

/// Provider for the secure storage instance.
final vipSecureStorageProvider = Provider<VipSecureStorage>((ref) {
  return const VipSecureStorage();
});

/// Riverpod Notifier controlling VIP audio subscriptions and license checks.
/// Architecture: Offline-First with Background Server Revalidation (Stale-While-Revalidate).
class VipSubscriptionController extends Notifier<VipSubscriptionState> {
  late IPaymentService _paymentService;
  late VipSecureStorage _storage;
  late SubscriptionRemoteDataSource _remoteDataSource;
  late IAnalyticsService _analyticsService;

  Timer? _periodicSyncTimer;
  Timer? _exactExpiryTimer;
  AppLifecycleListener? _lifecycleListener;

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(message, name: 'VipSubscription', error: error, stackTrace: stackTrace);
    debugPrint('[VipSubscription] $message');
  }

  @override
  VipSubscriptionState build() {
    _paymentService = ref.watch(paymentServiceProvider);
    _storage = ref.watch(vipSecureStorageProvider);
    _remoteDataSource = ref.watch(subscriptionRemoteDataSourceProvider);
    _analyticsService = ref.watch(analyticsServiceProvider);

    _log('🚀 [Init] Initializing VipSubscriptionController (Offline-First)...');

    // Listen to Tafakor authentication state changes
    ref.listen<bool>(isTafakorAuthenticatedProvider, (previous, current) {
      if (current && previous != true) {
        _log('🔑 [Auth Event] User logged into Tafakor! Triggering backend subscription sync...');
        syncWithTafakorBackend();
      } else if (!current && previous == true) {
        _log('🚪 [Auth Event] User logged out of Tafakor! Clearing local VIP subscription...');
        _handleLogout();
      }
    });

    // 1. Immediately load local persisted state for 0ms offline rendering
    _loadPersistedState().then((_) async {
      // 2. In background, revalidate with server and Cafe Bazaar
      await syncWithTafakorBackend();
      await syncWithStore();
      await fetchLiveProducts();
    });

    _startPeriodicVerification();

    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        _log('📱 [App Resume] App returned to foreground. Checking local expiry & syncing in background...');
        _checkLocalExpiry();
        syncWithTafakorBackend();
        syncWithStore();
      },
    );

    ref.onDispose(() {
      _periodicSyncTimer?.cancel();
      _exactExpiryTimer?.cancel();
      _lifecycleListener?.dispose();
    });

    return const VipSubscriptionState(isLoading: true);
  }

  /// Starts periodic background check with server and store while user is in-app.
  void _startPeriodicVerification() {
    _periodicSyncTimer?.cancel();
    // Verify every 60 seconds while user is active
    _periodicSyncTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _checkLocalExpiry();
      if (state.isVip) {
        syncWithTafakorBackend();
        syncWithStore();
      }
    });
  }

  /// Schedules a timer to revoke VIP the exact second the expiration timestamp is reached.
  void _scheduleExactExpiryTimer(DateTime? expiryDate) {
    _exactExpiryTimer?.cancel();
    if (expiryDate == null) return;

    final diff = expiryDate.difference(DateTime.now());
    if (diff.isNegative) {
      _handleLocalExpiry();
    } else {
      _exactExpiryTimer = Timer(diff, () {
        _log('⏰ [Exact Expiry Timer] VIP expiration timestamp reached!');
        _handleLocalExpiry();
        syncWithTafakorBackend();
      });
    }
  }

  /// Local calculation check: revokes access immediately if expiration date has passed.
  void _checkLocalExpiry() {
    if (state.isVip && state.vipExpiryDate != null) {
      if (DateTime.now().isAfter(state.vipExpiryDate!)) {
        _log('⏰ [Local Check] VIP expiration date passed locally.');
        _handleLocalExpiry();
      }
    }
  }

  Future<void> _handleLocalExpiry() async {
    _log('🔒 [Expiry Calculation] Revoking local VIP access because expiration date passed.');
    _exactExpiryTimer?.cancel();
    await _storage.setIsVip(false);
    await _storage.setActivePlanId(null);
    state = state.copyWith(isVip: false, activePlanId: null);
  }

  Future<void> _handleLogout() async {
    _log('🔒 [Logout Cleanup] Wiping local VIP subscription storage on user logout.');
    _exactExpiryTimer?.cancel();
    await _storage.clear();
    state = state.copyWith(isVip: false, activePlanId: null, vipExpiryDate: null);
  }

  /// Loads subscription status securely from device storage (Offline-First).
  Future<void> _loadPersistedState() async {
    try {
      _log('📱 [App Startup] Reading subscription state from local secure storage...');
      final isVip = await _storage.getIsVip();
      var vipExpiry = await _storage.getVipExpiryDate();
      final activePlanId = await _storage.getActivePlanId();
      final purchaseToken = await _storage.getPurchaseToken();

      _log('💾 [Local Storage State]:');
      _log('   ↳ isVip in storage: $isVip');
      _log('   ↳ activePlanId: $activePlanId');
      _log('   ↳ vipExpiryDate: $vipExpiry');
      _log('   ↳ purchaseToken: ${purchaseToken != null ? (purchaseToken.length > 12 ? "${purchaseToken.substring(0, 12)}..." : purchaseToken) : "none"}');

      final now = DateTime.now();
      bool isVipActive = isVip;

      // Local expiry calculation
      if (vipExpiry != null) {
        final diff = vipExpiry.difference(now);
        if (diff.isNegative) {
          final minsAgo = (-diff.inSeconds / 60).toStringAsFixed(1);
          _log('⏰ [Expiry Calculation] Local subscription has EXPIRED ($minsAgo minutes ago on $vipExpiry).');
          _log('🔒 [Expiry Calculation] Revoking local VIP access.');
          isVipActive = false;
          await _storage.setIsVip(false);
        } else {
          final days = diff.inDays;
          final hours = diff.inHours % 24;
          final mins = diff.inMinutes % 60;
          _log('⏳ [Expiry Calculation] Local subscription is ACTIVE! Remaining: ${days}d ${hours}h ${mins}m (Expires at $vipExpiry)');
        }
      } else if (isVip) {
        // Subscriptions in Tafakor are time-bound; if expiry is missing, do not assume lifetime.
        _log('⚠️ [Expiry Calculation] isVip was true but expiryDate is null. Revalidating with server...');
        isVipActive = false;
        await _storage.setIsVip(false);
      } else {
        _log('ℹ️ [Expiry Calculation] No active VIP subscription in local storage.');
      }

      // Render local state immediately without waiting for network
      state = state.copyWith(
        isVip: isVipActive,
        vipExpiryDate: vipExpiry,
        activePlanId: activePlanId,
        availableProducts: const [],
        isLoading: false,
      );

      if (isVipActive && vipExpiry != null) {
        _scheduleExactExpiryTimer(vipExpiry);
      }
      _log('🎯 [Local State Ready] UI unlocked with local offline state (isVip=$isVipActive).');
    } catch (e, stack) {
      _log('❌ Error loading persisted subscription state: $e', error: e, stackTrace: stack);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'خطا در بارگذاری اطلاعات اشتراک',
      );
    }
  }

  bool _isFetchingProducts = false;
  bool _isSyncingServer = false;
  bool _isSyncingStore = false;

  /// Fetches subscription plans dynamically from Tafakor Backend (configured in Admin).
  /// Plans are strictly loaded live from server without local caching.
  Future<void> fetchLiveProducts() async {
    if (_isFetchingProducts) return;
    _isFetchingProducts = true;
    state = state.copyWith(isPlansLoading: true, clearPlansError: true);
    try {
      _log('🌐 [Live Products] Querying Tafakor server for subscription plans (plugin=quran)...');
      final serverPlans = await _remoteDataSource.getPlans(plugin: 'quran');

      List<PaymentProduct> products = [];
      if (serverPlans.isNotEmpty) {
        _log('📦 [Live Products] Received ${serverPlans.length} plans from Tafakor backend.');
        products = serverPlans.map((plan) {
          final sku = plan['sku'] as String? ?? '';
          final title = plan['title'] as String? ?? '';
          final description = plan['description'] as String? ?? '';
          final durationDays = (plan['duration_days'] as num?)?.toInt() ?? 30;
          final priceToman = (plan['price_toman'] as num?)?.toInt() ??
              ((plan['price'] as num?) != null ? ((plan['price'] as num).toInt() ~/ 10) : 0);

          SubscriptionPlan subscriptionPlan;
          if (durationDays <= 31) {
            subscriptionPlan = SubscriptionPlan.monthly;
          } else if (durationDays <= 95) {
            subscriptionPlan = SubscriptionPlan.quarterly;
          } else if (durationDays <= 185) {
            subscriptionPlan = SubscriptionPlan.semiAnnual;
          } else if (durationDays <= 370) {
            subscriptionPlan = SubscriptionPlan.yearly;
          } else {
            subscriptionPlan = SubscriptionPlan.monthly;
          }

          final features = plan['features'];
          String? discountBadge;
          bool isRecommended = false;
          if (features is Map) {
            discountBadge = features['discount_badge']?.toString();
            isRecommended = features['is_recommended'] == true;
          }
          if (discountBadge == null) {
            if (durationDays == 90) {
              discountBadge = 'تخفیف فصلی';
            } else if (durationDays == 180) {
              discountBadge = 'محبوب‌ترین (۳۰٪ تخفیف)';
              isRecommended = true;
            }
          }

          return PaymentProduct(
            id: sku,
            title: title,
            description: description,
            priceToman: priceToman,
            subscriptionPlan: subscriptionPlan,
            discountBadge: discountBadge,
            isRecommended: isRecommended,
          );
        }).toList();
      }

      // Plans and prices are strictly loaded from Tafakor Server (Django Admin).
      // We do NOT overwrite prices with Cafe Bazaar test/developer prices.
      if (products.isNotEmpty) {
        state = state.copyWith(
          availableProducts: products,
          isPlansLoading: false,
          clearPlansError: true,
        );
        _log('✅ [Live Products] Successfully loaded ${products.length} live plans strictly from Tafakor server.');
      } else {
        _log('⚠️ [Live Products] Server returned 0 plans.');
        state = state.copyWith(
          availableProducts: const [],
          isPlansLoading: false,
          plansError: 'طرحی برای اشتراک یافت نشد.',
        );
      }
    } catch (e, stack) {
      _log('❌ Error fetching subscription plans from server: $e', error: e, stackTrace: stack);
      state = state.copyWith(
        availableProducts: const [],
        isPlansLoading: false,
        plansError: 'خطا در دریافت لیست اشتراک‌ها از سرور',
      );
    } finally {
      _isFetchingProducts = false;
    }
  }

  /// Background sync with Tafakor Backend:
  /// Calls GET /api/subscriptions/my-status/?plugin=quran
  /// Authoritative server state takes precedence over local state when online.
  Future<void> syncWithTafakorBackend() async {
    if (_isSyncingServer) return;
    final isAuthenticated = ref.read(isTafakorAuthenticatedProvider);
    if (!isAuthenticated) {
      _log('ℹ️ [Backend Sync] User not authenticated in Tafakor. Skipping server sync.');
      return;
    }

    _isSyncingServer = true;
    try {
      _log('🔄 [Backend Sync] Querying Tafakor server for live subscription status...');
      final status = await _remoteDataSource.getMyStatus(plugin: 'quran');
      final hasActive = status['has_active_subscription'] == true;
      final serverExpiryStr = status['expires_at'] as String?;
      final serverSku = status['sku'] as String?;

      if (hasActive && serverExpiryStr != null) {
        final serverExpiry = DateTime.tryParse(serverExpiryStr);
        _log('✅ [Backend Sync] Server confirmed ACTIVE VIP subscription: $serverSku (Expires: $serverExpiry)');

        await _storage.setIsVip(true);
        await _storage.setVipExpiryDate(serverExpiry);
        if (serverSku != null) await _storage.setActivePlanId(serverSku);

        state = state.copyWith(
          isVip: true,
          vipExpiryDate: serverExpiry,
          activePlanId: serverSku ?? state.activePlanId,
        );
        _scheduleExactExpiryTimer(serverExpiry);
      } else {
        _log('ℹ️ [Backend Sync] Server reports NO active subscription.');
        if (state.isVip) {
          _log('🔒 [Backend Sync] Revoking local VIP access to match server authoritative status.');
          _exactExpiryTimer?.cancel();
          await _storage.setIsVip(false);
          await _storage.setActivePlanId(null);
          await _storage.setVipExpiryDate(null);
          state = state.copyWith(isVip: false, activePlanId: null, vipExpiryDate: null);
        }
      }
    } catch (e) {
      _log('🛡️ [Backend Sync] Network offline or unreachable ($e). Preserving local offline state until expiry.');
      // Do nothing: offline graceful degradation
    } finally {
      _isSyncingServer = false;
    }
  }

  /// Background sync to check active subscriptions with Cafe Bazaar.
  /// 🔒 SECURITY: This method NEVER activates VIP locally without backend validation.
  /// Authoritative VIP status is strictly determined by Tafakor backend.
  Future<void> syncWithStore() async {
    if (_isSyncingStore) return;
    _isSyncingStore = true;
    try {
      _log('🔄 [Bazaar Sync] Checking Cafe Bazaar connection and subscriptions...');
      final isConnected = await _paymentService.isConnected();
      if (!isConnected) {
        _log('ℹ️ [Bazaar Sync] Cafe Bazaar not connected.');
        return;
      }

      final purchasedIds = await _paymentService.getPurchasedProductIds();
      _log('📥 [Bazaar Sync Response] Subscribed product IDs from Bazaar: $purchasedIds');

      if (purchasedIds.isNotEmpty) {
        _log('ℹ️ [Bazaar Sync] Bazaar reports purchased products: $purchasedIds. Verifying with backend...');
        // If user is authenticated, ensure backend status is in sync
        if (ref.read(isTafakorAuthenticatedProvider)) {
          await syncWithTafakorBackend();
        }
      }
    } catch (e, stack) {
      _log('❌ [Bazaar Sync Error] Failed to sync with Cafe Bazaar: $e', error: e, stackTrace: stack);
    } finally {
      _isSyncingStore = false;
    }
  }

  /// Initiates purchase flow for a VIP subscription plan:
  /// 1. Prompts for Tafakor login if not authenticated.
  /// 2. Opens Cafe Bazaar in-app billing.
  /// 3. Sends purchase token to Tafakor Backend for server-side verification.
  /// 4. Activates VIP upon backend confirmation.
  Future<PurchaseResult> purchaseSubscription(PaymentProduct product) async {
    _log('🛒 [Purchase Flow] User tapped to buy: ${product.id} (${product.title}) - ${product.priceToman} Tomans');
    _analyticsService.logVipPurchaseStarted(
      planId: product.id,
      price: product.priceToman.toDouble(),
    );

    // 1. Guard: User MUST be authenticated in Tafakor to bind subscription to account
    final isAuthenticated = ref.read(isTafakorAuthenticatedProvider);
    if (!isAuthenticated) {
      _log('⚠️ [Purchase Flow] User not logged in to Tafakor.');
      return PurchaseResult.error(
        'برای ثبت دائمی اشتراک و اتصال آن به شماره شما، لطفاً ابتدا وارد حساب کاربری تفکر شوید.',
        productId: product.id,
      );
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 2. Open Cafe Bazaar purchase dialog
      final bazaarResult = await _paymentService.subscribe(product.id);

      _log('📦 [Purchase Flow] Bazaar response received:');
      _log('   ↳ isSuccess: ${bazaarResult.isSuccess}');
      _log('   ↳ orderId: ${bazaarResult.orderId}');
      _log('   ↳ purchaseToken: ${bazaarResult.purchaseToken != null ? (bazaarResult.purchaseToken!.length > 15 ? "${bazaarResult.purchaseToken!.substring(0, 15)}..." : bazaarResult.purchaseToken) : "null"}');
      _log('   ↳ errorMessage: ${bazaarResult.errorMessage}');

      if (!bazaarResult.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: bazaarResult.errorMessage,
        );
        _analyticsService.logVipPurchaseFailed(
          planId: product.id,
          error: bazaarResult.errorMessage ?? 'Cafe Bazaar purchase cancelled or failed',
        );
        return bazaarResult;
      }

      final purchaseToken = bazaarResult.purchaseToken;
      if (purchaseToken == null || purchaseToken.isEmpty) {
        throw Exception('توکن خرید از درگاه کافه‌بازار دریافت نشد.');
      }

      // Save token in local storage immediately so it can always be recovered
      await _storage.setPurchaseToken(purchaseToken);

      // 3. Verify purchase token with Tafakor Backend
      _log('🌐 [Purchase Flow] Verifying purchase token with Tafakor Backend: POST /api/subscriptions/verify/...');
      final verifyResponse = await _remoteDataSource.verifyPurchase(
        sku: product.id,
        purchaseToken: purchaseToken,
        marketplace: 'cafebazaar',
      );

      _log('🎉 [Purchase Flow] Backend verification SUCCEEDED: $verifyResponse');

      // 4. Parse official expiration date returned by server
      final subData = verifyResponse['subscription'] as Map<String, dynamic>?;
      final serverExpiryStr = subData?['expires_at'] as String?;
      final now = DateTime.now();
      final newExpiry = serverExpiryStr != null
          ? (DateTime.tryParse(serverExpiryStr) ?? now.add(Duration(days: product.durationDays ?? 30)))
          : now.add(Duration(days: product.durationDays ?? 30));

      // 5. Save verified subscription in local secure storage
      await _storage.setIsVip(true);
      await _storage.setVipExpiryDate(newExpiry);
      await _storage.setActivePlanId(product.id);

      // 6. Update state and schedule exact timer
      state = state.copyWith(
        isVip: true,
        vipExpiryDate: newExpiry,
        activePlanId: product.id,
        isLoading: false,
      );
      _scheduleExactExpiryTimer(newExpiry);

      _analyticsService.logVipPurchaseSuccess(
        planId: product.id,
        orderId: bazaarResult.orderId,
      );
      _log('✨ [Purchase Complete] VIP state active for user! Expiry: $newExpiry');
      return PurchaseResult.success(
        productId: product.id,
        orderId: bazaarResult.orderId,
        purchaseToken: purchaseToken,
      );

    } catch (e, stack) {
      _log('❌ [Purchase Exception] Error during purchase or verification: $e', error: e, stackTrace: stack);
      final rawError = e.toString().replaceFirst('Exception: ', '');
      final errorMsg = rawError.startsWith('خطا')
          ? rawError
          : 'خطا در تایید خرید با سرور: $rawError';
      _analyticsService.logVipPurchaseFailed(
        planId: product.id,
        error: errorMsg,
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMsg,
      );
      return PurchaseResult.error(errorMsg, productId: product.id);
    }
  }

  /// Restores previous active purchases from Bazaar and verifies with Tafakor backend.
  /// 🔒 SECURITY: VIP is ONLY activated after backend verifies the purchase token.
  Future<bool> restorePurchases() async {
    _log('🔄 [Restore Flow] User requested to restore previous purchases...');
    _analyticsService.logEvent(name: 'vip_restore_attempted');
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Guard: user must be logged in to Tafakor so subscription can be bound to account
    final isAuthenticated = ref.read(isTafakorAuthenticatedProvider);
    if (!isAuthenticated) {
      const msg = 'برای بازیابی خرید، لطفاً ابتدا وارد حساب کاربری تفکر شوید.';
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    }

    try {
      final results = await _paymentService.restorePurchases();

      _log('📥 [Restore Response] Received ${results.length} purchases from Cafe Bazaar:');
      for (final r in results) {
        _log('   ↳ Product: ${r.productId}, OrderId: ${r.orderId}, Token: ${r.purchaseToken}');
      }

      if (results.isEmpty) {
        _log('ℹ️ [Restore Result] No active purchases found in Cafe Bazaar to restore.');
        state = state.copyWith(isLoading: false);
        return false;
      }

      bool anyVerified = false;
      String? lastError;

      for (final activeProduct in results) {
        final sku = activeProduct.productId;
        final token = activeProduct.purchaseToken;

        if (sku != null && token != null && token.isNotEmpty) {
          try {
            _log('🌐 [Restore] Verifying restored token with backend: $sku...');
            final verifyResponse = await _remoteDataSource.verifyPurchase(
              sku: sku,
              purchaseToken: token,
              marketplace: 'cafebazaar',
            );
            _log('🎉 [Restore] Backend verified token: $verifyResponse');
            anyVerified = true;
            await _storage.setPurchaseToken(token);
            break; // Successfully verified an active subscription
          } catch (e) {
            _log('⚠️ [Restore] Backend verification failed for $sku: $e');
            lastError = e.toString().replaceFirst('Exception: ', '');
          }
        }
      }

      if (anyVerified) {
        // Authoritatively refresh state from backend
        await syncWithTafakorBackend();
        state = state.copyWith(isLoading: false);
        _log('✨ [Restore Complete] Subscription verified and synced with backend! isVip=${state.isVip}');
        return state.isVip;
      } else {
        final err = lastError ?? 'اشتراک معتبری در سرور برای بازیابی یافت نشد یا منقضی شده است.';
        state = state.copyWith(isLoading: false, errorMessage: err);
        return false;
      }
    } catch (e, stack) {
      _log('❌ [Restore Exception] Error restoring purchases: $e', error: e, stackTrace: stack);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'خطا در بازیابی اشتراک از کافه بازار: $e',
      );
      return false;
    }
  }

  /// Policy check: Can play the given reciter for the given surah?
  bool canPlayReciter({required String? reciterIdentifier, required int surahId}) {
    return AudioVipPolicy.canPlayReciter(
      reciterIdentifier: reciterIdentifier,
      surahId: surahId,
      isVip: state.hasVipAccess,
    );
  }

  /// Policy check: Can play Persian audio translation?
  bool canPlayAudioTranslation() {
    return AudioVipPolicy.canPlayAudioTranslation(isVip: state.hasVipAccess);
  }
}

/// Central controller provider for VIP subscriptions.
final vipSubscriptionControllerProvider =
    NotifierProvider<VipSubscriptionController, VipSubscriptionState>(
  VipSubscriptionController.new,
);

/// Convenience provider to easily check if current user holds VIP access.
final hasVipAccessProvider = Provider<bool>((ref) {
  if (VipSubscriptionState.isAllFeaturesFree) return true;
  return ref.watch(vipSubscriptionControllerProvider).hasVipAccess;
});
