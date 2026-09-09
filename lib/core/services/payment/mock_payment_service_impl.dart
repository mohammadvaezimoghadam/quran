import 'dart:async';
import 'dart:developer' as developer;

import 'i_payment_service.dart';
import 'models/purchase_result.dart';

/// Mock implementation of [IPaymentService] for local development,
/// device testing, and QA prior to obtaining Cafe Bazaar RSA production keys.
final class MockPaymentServiceImpl implements IPaymentService {
  bool _isConnected = false;
  final Set<String> _simulatedPurchasedProductIds = {};

  /// Set to true to simulate purchase cancellation by the user.
  bool simulateUserCancel = false;

  /// Set to true to simulate network/billing errors.
  bool simulateError = false;

  @override
  Future<bool> initialize() async {
    developer.log('Initializing MockPaymentService...', name: 'PaymentService');
    await Future.delayed(const Duration(milliseconds: 300));
    _isConnected = true;
    developer.log('MockPaymentService connected successfully.', name: 'PaymentService');
    return true;
  }

  @override
  Future<PurchaseResult> purchaseSubscription(String productId) async {
    developer.log('Initiating mock subscription for: $productId', name: 'PaymentService');
    await Future.delayed(const Duration(milliseconds: 700));

    if (simulateError) {
      return PurchaseResult.error('خطای تستی در برقراری ارتباط با درگاه پرداخت.', productId: productId);
    }

    if (simulateUserCancel) {
      return PurchaseResult.userCancelled(productId: productId);
    }

    if (_simulatedPurchasedProductIds.contains(productId)) {
      return PurchaseResult.alreadyOwned(productId: productId);
    }

    final token = 'mock_sub_token_${DateTime.now().millisecondsSinceEpoch}';
    final orderId = 'ORD_MCK_${DateTime.now().millisecondsSinceEpoch}';

    _simulatedPurchasedProductIds.add(productId);

    developer.log(
      'Mock subscription successful: $productId, Token: $token, Order: $orderId',
      name: 'PaymentService',
    );

    return PurchaseResult.success(
      productId: productId,
      purchaseToken: token,
      orderId: orderId,
    );
  }

  @override
  Future<PurchaseResult> purchaseConsumable(String productId) async {
    developer.log('Initiating mock consumable purchase for: $productId', name: 'PaymentService');
    await Future.delayed(const Duration(milliseconds: 700));

    if (simulateError) {
      return PurchaseResult.error('خطای تستی در برقراری ارتباط با درگاه پرداخت.', productId: productId);
    }

    if (simulateUserCancel) {
      return PurchaseResult.userCancelled(productId: productId);
    }

    final token = 'mock_cons_token_${DateTime.now().millisecondsSinceEpoch}';
    final orderId = 'ORD_NZR_${DateTime.now().millisecondsSinceEpoch}';

    developer.log(
      'Mock consumable purchase successful: $productId, Token: $token, Order: $orderId',
      name: 'PaymentService',
    );

    return PurchaseResult.success(
      productId: productId,
      purchaseToken: token,
      orderId: orderId,
    );
  }

  @override
  Future<List<String>> getPurchasedProductIds() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _simulatedPurchasedProductIds.toList();
  }

  @override
  Future<List<PurchaseResult>> restorePurchases() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _simulatedPurchasedProductIds.map((id) {
      return PurchaseResult.success(
        productId: id,
        purchaseToken: 'restored_token_$id',
        orderId: 'restored_order_$id',
      );
    }).toList();
  }

  @override
  Future<bool> isConnected() async => _isConnected;

  @override
  Future<void> dispose() async {
    _isConnected = false;
    _simulatedPurchasedProductIds.clear();
  }
}
