import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/services/payment/models/payment_product.dart';

/// Secure persistence layer for VIP subscription data using [FlutterSecureStorage].
/// Prevents tampering or unauthorized elevation of privileges on rooted/modified devices.
class VipSecureStorage {
  final FlutterSecureStorage _storage;

  static const String _keyIsVip = 'quran_vip_active';
  static const String _keyVipExpiry = 'quran_vip_expiry_iso';
  static const String _keyActivePlanId = 'quran_vip_plan_id';
  static const String _keyPurchaseToken = 'quran_vip_purchase_token';
  static const String _keyCachedProducts = 'quran_vip_cached_products_json';

  const VipSecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  Future<bool> getIsVip() async {
    final value = await _storage.read(key: _keyIsVip);
    return value == 'true';
  }

  Future<void> setIsVip(bool isVip) async {
    await _storage.write(key: _keyIsVip, value: isVip ? 'true' : 'false');
  }

  Future<DateTime?> getVipExpiryDate() async {
    final value = await _storage.read(key: _keyVipExpiry);
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  Future<void> setVipExpiryDate(DateTime? date) async {
    if (date == null) {
      await _storage.delete(key: _keyVipExpiry);
    } else {
      await _storage.write(key: _keyVipExpiry, value: date.toIso8601String());
    }
  }

  Future<String?> getActivePlanId() async {
    return _storage.read(key: _keyActivePlanId);
  }

  Future<void> setActivePlanId(String? planId) async {
    if (planId == null) {
      await _storage.delete(key: _keyActivePlanId);
    } else {
      await _storage.write(key: _keyActivePlanId, value: planId);
    }
  }

  Future<String?> getPurchaseToken() async {
    return _storage.read(key: _keyPurchaseToken);
  }

  Future<void> setPurchaseToken(String? token) async {
    if (token == null) {
      await _storage.delete(key: _keyPurchaseToken);
    } else {
      await _storage.write(key: _keyPurchaseToken, value: token);
    }
  }

  /// Retrieves cached subscription products fetched from Cafe Bazaar.
  Future<List<PaymentProduct>?> getCachedProducts() async {
    final value = await _storage.read(key: _keyCachedProducts);
    if (value == null || value.isEmpty) return null;
    try {
      final list = jsonDecode(value) as List<dynamic>;
      return list
          .map((item) => PaymentProduct.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Persists latest live products fetched from Cafe Bazaar for instant offline availability.
  Future<void> setCachedProducts(List<PaymentProduct> products) async {
    try {
      final jsonString = jsonEncode(products.map((p) => p.toJson()).toList());
      await _storage.write(key: _keyCachedProducts, value: jsonString);
    } catch (_) {}
  }

  /// Clears all subscription data (used for testing or logout)
  Future<void> clear() async {
    await _storage.delete(key: _keyIsVip);
    await _storage.delete(key: _keyVipExpiry);
    await _storage.delete(key: _keyActivePlanId);
    await _storage.delete(key: _keyPurchaseToken);
  }
}
