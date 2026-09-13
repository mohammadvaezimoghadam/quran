import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';

import 'i_payment_service.dart';
import 'models/payment_product.dart';
import 'models/purchase_result.dart';

/// Production implementation of [IPaymentService] interfacing with Cafe Bazaar's
/// In-App Billing system via the official `flutter_poolakey` SDK.
final class BazaarPaymentServiceImpl implements IPaymentService {
  final String rsaPublicKey;
  bool _isConnected = false;

  BazaarPaymentServiceImpl({required this.rsaPublicKey});

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(message, name: 'BazaarPayment', error: error, stackTrace: stackTrace);
    debugPrint('[BazaarPayment] $message');
  }

  @override
  Future<bool> initialize() async {
    _log('🚀 Connecting to Cafe Bazaar Poolakey...');
    
    if (rsaPublicKey.isEmpty || rsaPublicKey == 'YOUR_BAZAAR_RSA_PUBLIC_KEY') {
      _log('⚠️ Warning: Cafe Bazaar RSA key is not yet configured. Please set a valid RSA public key.');
      _isConnected = false;
      return false;
    }

    final completer = Completer<bool>();

    try {
      await FlutterPoolakey.connect(
        rsaPublicKey,
        onSucceed: () {
          _log('✅ Connected to Cafe Bazaar billing service successfully.');
          _isConnected = true;
          if (!completer.isCompleted) completer.complete(true);
        },
        onFailed: () {
          _log('❌ Failed to connect to Cafe Bazaar billing service.');
          _isConnected = false;
          if (!completer.isCompleted) completer.complete(false);
        },
        onDisconnected: () {
          _log('🔌 Disconnected from Cafe Bazaar billing service.');
          _isConnected = false;
        },
      );

      // Timeout fallback after 8 seconds
      return await completer.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          _log('⏱️ Connection to Cafe Bazaar timed out after 8s.');
          return _isConnected;
        },
      );
    } catch (e, stack) {
      _log('❌ Error initializing Cafe Bazaar Poolakey: $e', error: e, stackTrace: stack);
      _isConnected = false;
      return false;
    }
  }

  @override
  Future<PurchaseResult> subscribe(String productId) async {
    _log('🛒 [subscribe] Initiating subscription for SKU: $productId');
    if (!_isConnected) {
      _log('⚠️ [subscribe] Not connected, attempting reconnection...');
      final reconnected = await initialize();
      if (!reconnected) {
        _log('❌ [subscribe] Reconnection to Cafe Bazaar failed.');
        return PurchaseResult.error(
          'ارتباط با کافه بازار برقرار نشد. لطفاً از نصب و به‌روز بودن کافه بازار اطمینان حاصل کنید.',
          productId: productId,
        );
      }
    }

    try {
      _log('📲 [subscribe] Opening Cafe Bazaar purchase dialog for $productId...');
      final purchaseInfo = await FlutterPoolakey.subscribe(productId);

      _log('✅ [subscribe] Purchase succeeded in Cafe Bazaar!');
      _log('   ↳ Product ID: ${purchaseInfo.productId}');
      _log('   ↳ Order ID: ${purchaseInfo.orderId}');
      _log('   ↳ Purchase Token: ${purchaseInfo.purchaseToken}');

      return PurchaseResult.success(
        productId: purchaseInfo.productId,
        orderId: purchaseInfo.orderId,
        purchaseToken: purchaseInfo.purchaseToken,
      );
    } on PlatformException catch (e) {
      _log('⚠️ [subscribe] Bazaar PlatformException: code=${e.code}, message=${e.message}');
      
      String userFriendlyMessage;
      if (e.message?.contains('cancel') == true || e.code.toLowerCase().contains('cancel')) {
        userFriendlyMessage = 'فرآیند خرید توسط کاربر لغو شد.';
        _log('ℹ️ [subscribe] User cancelled the purchase dialog.');
      } else {
        userFriendlyMessage = e.message ?? 'خطا در انجام تراکنش در کافه بازار';
      }

      return PurchaseResult.error(userFriendlyMessage, productId: productId);
    } catch (e, stack) {
      _log('❌ [subscribe] Unexpected error during purchase: $e', error: e, stackTrace: stack);
      return PurchaseResult.error('خطا در خرید اشتراک: $e', productId: productId);
    }
  }

  @override
  Future<List<PaymentProduct>> getSubscriptionProducts(List<String> skuIds) async {
    _log('🔍 [getSkuDetails] Requesting SKU details from Bazaar for: $skuIds');
    if (!_isConnected) {
      final reconnected = await initialize();
      if (!reconnected) {
        _log('⚠️ [getSkuDetails] Not connected to Bazaar. Returning local default products.');
        return PaymentProduct.allSubscriptions;
      }
    }

    try {
      final skuDetailsList = await FlutterPoolakey.getSubscriptionSkuDetails(skuIds);
      _log('📦 [getSkuDetails] Received ${skuDetailsList.length} products from Bazaar:');
      for (final sku in skuDetailsList) {
        _log('   ↳ SKU: ${sku.sku} | Title: ${sku.title} | Price: ${sku.price}');
      }

      if (skuDetailsList.isEmpty) return PaymentProduct.allSubscriptions;

      final updatedProducts = <PaymentProduct>[];
      for (final defaultProduct in PaymentProduct.allSubscriptions) {
        final matchingDetails = skuDetailsList.cast<SkuDetails?>().firstWhere(
          (sku) => sku?.sku == defaultProduct.id,
          orElse: () => null,
        );

        if (matchingDetails != null) {
          int parsedPriceToman = defaultProduct.priceToman;
          final rawPrice = int.tryParse(matchingDetails.price.replaceAll(RegExp(r'[^0-9]'), ''));
          if (rawPrice != null && rawPrice > 0) {
            parsedPriceToman = rawPrice > 1000 ? rawPrice ~/ 10 : rawPrice;
          }

          updatedProducts.add(
            defaultProduct.copyWith(
              title: matchingDetails.title.isNotEmpty ? matchingDetails.title : defaultProduct.title,
              description: matchingDetails.description.isNotEmpty ? matchingDetails.description : defaultProduct.description,
              priceToman: parsedPriceToman,
              formattedPrice: matchingDetails.price,
            ),
          );
        } else {
          updatedProducts.add(defaultProduct);
        }
      }

      return updatedProducts;
    } catch (e, stack) {
      _log('❌ [getSkuDetails] Failed to fetch SkuDetails: $e. Using local defaults.', error: e, stackTrace: stack);
      return PaymentProduct.allSubscriptions;
    }
  }

  @override
  Future<List<String>> getPurchasedProductIds() async {
    _log('🔍 [getPurchasedProductIds] Querying Cafe Bazaar for active subscribed products...');
    if (!_isConnected) {
      _log('⚠️ [getPurchasedProductIds] Not connected, attempting reconnection...');
      final reconnected = await initialize();
      if (!reconnected) {
        _log('❌ [getPurchasedProductIds] Could not connect to Cafe Bazaar.');
        return [];
      }
    }

    try {
      final purchases = await FlutterPoolakey.getAllSubscribedProducts();
      final ids = purchases.map((p) => p.productId).toList();
      _log('📦 [getPurchasedProductIds] Response from Bazaar: found ${purchases.length} active subscriptions: $ids');
      for (final p in purchases) {
        _log('   ↳ Active Sub: productId=${p.productId}, orderId=${p.orderId}, token=${p.purchaseToken}');
      }
      return ids;
    } catch (e, stack) {
      _log('❌ [getPurchasedProductIds] Error fetching subscribed products from Bazaar: $e', error: e, stackTrace: stack);
      return [];
    }
  }

  @override
  Future<List<PurchaseResult>> restorePurchases() async {
    _log('🔄 [restorePurchases] Querying Cafe Bazaar to restore active purchases...');
    if (!_isConnected) {
      final reconnected = await initialize();
      if (!reconnected) {
        _log('❌ [restorePurchases] Could not connect to Cafe Bazaar.');
        return [];
      }
    }

    try {
      final purchases = await FlutterPoolakey.getAllSubscribedProducts();
      _log('📦 [restorePurchases] Received ${purchases.length} active purchases from Bazaar:');
      for (final p in purchases) {
        _log('   ↳ Restoring: productId=${p.productId}, orderId=${p.orderId}');
      }
      return purchases
          .map(
            (p) => PurchaseResult.success(
              productId: p.productId,
              orderId: p.orderId,
              purchaseToken: p.purchaseToken,
            ),
          )
          .toList();
    } catch (e, stack) {
      _log('❌ [restorePurchases] Error restoring purchases: $e', error: e, stackTrace: stack);
      return [];
    }
  }

  @override
  Future<bool> isConnected() async => _isConnected;

  @override
  Future<void> dispose() async {
    try {
      _log('🔌 Disposing and disconnecting from Cafe Bazaar Poolakey...');
      await FlutterPoolakey.disconnect();
    } catch (_) {}
    _isConnected = false;
  }
}
