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

    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      _log('ℹ️ Cafe Bazaar billing is not supported on Web/non-Android.');
      _isConnected = false;
      return false;
    }

    if (rsaPublicKey.isEmpty || rsaPublicKey == 'YOUR_BAZAAR_RSA_PUBLIC_KEY') {
      _log('⚠️ Warning: Cafe Bazaar RSA key is not yet configured. Please set a valid RSA public key.');
      _isConnected = false;
      return false;
    }

    final completer = Completer<bool>();

    try {
      // NOTE: FlutterPoolakey.connect invokes native channel method 'connect'
      // where the native Kotlin plugin forgets to call result.success(), causing
      // the returned Future to never complete!
      // Therefore, we must NOT await FlutterPoolakey.connect itself.
      // Instead, we listen to the callbacks and attach a strict timeout.
      unawaited(
        FlutterPoolakey.connect(
          rsaPublicKey,
          onSucceed: () {
            _log('✅ Connected to Cafe Bazaar billing service successfully.');
            _isConnected = true;
            if (!completer.isCompleted) completer.complete(true);
          },
          onFailed: () {
            _log('❌ Failed to connect to Cafe Bazaar billing service (Bazaar app not installed or service unavailable).');
            _isConnected = false;
            if (!completer.isCompleted) completer.complete(false);
          },
          onDisconnected: () {
            _log('🔌 Disconnected from Cafe Bazaar billing service.');
            _isConnected = false;
          },
        ).catchError((e, stack) {
          _log('❌ Error initializing Cafe Bazaar Poolakey: $e', error: e, stackTrace: stack);
          _isConnected = false;
          if (!completer.isCompleted) completer.complete(false);
        }),
      );

      // Fast timeout: 2.5 seconds is ample time for local Android IPC service connection.
      // If Bazaar is not installed or unreachable, it immediately falls back to false.
      return await completer.future.timeout(
        const Duration(milliseconds: 2500),
        onTimeout: () {
          _log('⏱️ Connection to Cafe Bazaar timed out after 2.5s (Cafe Bazaar app is not installed or unreachable).');
          _isConnected = false;
          return false;
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
        _log('❌ [subscribe] Cafe Bazaar is not reachable or not installed.');
        return PurchaseResult.error(
          'برنامه کافه بازار بر روی این دستگاه یا شبیه‌ساز نصب نیست یا در دسترس نمی‌باشد. لطفاً برنامه بازار را نصب کرده و با حساب خود وارد آن شوید.',
          productId: productId,
        );
      }
    }

    try {
      _log('📲 [subscribe] Opening Cafe Bazaar purchase dialog for $productId...');
      final purchaseInfo = await FlutterPoolakey.subscribe(productId).timeout(
        const Duration(seconds: 40),
        onTimeout: () {
          _log('⏱️ [subscribe] Purchase flow timed out after 40s.');
          throw TimeoutException('مهلت ارتباط با کافه بازار به پایان رسید.');
        },
      );

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

      final codeLower = e.code.toLowerCase();
      final msgLower = (e.message ?? '').toLowerCase();

      if (codeLower.contains('cancel') || msgLower.contains('cancel')) {
        _log('ℹ️ [subscribe] User cancelled the purchase dialog.');
        return PurchaseResult.userCancelled(productId: productId);
      } else if (codeLower.contains('not_connected') ||
          msgLower.contains('connect') ||
          (codeLower.contains('purchase_failed') && msgLower.contains('poolakey'))) {
        _isConnected = false;
        return PurchaseResult.error(
          'ارتباط با درگاه کافه بازار برقرار نشد. لطفاً از نصب و فعال بودن برنامه بازار اطمینان حاصل کنید.',
          productId: productId,
        );
      } else if (msgLower.contains('already') || codeLower.contains('already')) {
        return PurchaseResult.alreadyOwned(productId: productId);
      } else {
        final userFriendlyMessage = e.message ?? 'خطا در انجام تراکنش در کافه بازار';
        return PurchaseResult.error(userFriendlyMessage, productId: productId);
      }
    } on TimeoutException {
      return PurchaseResult.error(
        'پاسخی از درگاه کافه بازار دریافت نشد (مهلت زمانی پایان یافت).',
        productId: productId,
      );
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
      final skuDetailsList = await FlutterPoolakey.getSubscriptionSkuDetails(skuIds).timeout(
        const Duration(seconds: 3),
        onTimeout: () => [],
      );
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
      final purchases = await FlutterPoolakey.getAllSubscribedProducts().timeout(
        const Duration(seconds: 3),
        onTimeout: () => [],
      );
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
      final purchases = await FlutterPoolakey.getAllSubscribedProducts().timeout(
        const Duration(seconds: 4),
        onTimeout: () => [],
      );
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
