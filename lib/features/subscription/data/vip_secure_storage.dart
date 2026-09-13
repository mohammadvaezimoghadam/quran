import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure persistence layer for VIP subscription data using [FlutterSecureStorage].
/// Prevents tampering or unauthorized elevation of privileges on rooted/modified devices.
class VipSecureStorage {
  final FlutterSecureStorage _storage;

  static const String _keyIsVip = 'quran_vip_active';
  static const String _keyVipExpiry = 'quran_vip_expiry_iso';
  static const String _keyActivePlanId = 'quran_vip_plan_id';
  static const String _keyPurchaseToken = 'quran_vip_purchase_token';

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

  /// Clears all subscription data (used for testing or logout)
  Future<void> clear() async {
    await _storage.delete(key: _keyIsVip);
    await _storage.delete(key: _keyVipExpiry);
    await _storage.delete(key: _keyActivePlanId);
    await _storage.delete(key: _keyPurchaseToken);
  }
}
