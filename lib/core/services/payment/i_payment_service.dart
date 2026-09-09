import 'models/purchase_result.dart';

/// Abstract contract for In-App Billing (IAB) services.
/// Decouples the application from specific store APIs (Cafe Bazaar Poolakey, Myket, etc.)
/// allowing seamless mocking during development and testing.
abstract interface class IPaymentService {
  /// Initializes connection to the in-app billing service and verifies public RSA keys.
  Future<bool> initialize();

  /// Initiates a purchase flow for a subscription plan (e.g. 1 month, 1 year, lifetime).
  Future<PurchaseResult> purchaseSubscription(String productId);

  /// Initiates a purchase flow for a one-time consumable product (e.g. Nazr / Donation packages).
  Future<PurchaseResult> purchaseConsumable(String productId);

  /// Retrieves list of active subscription and non-consumable product IDs owned by current user.
  Future<List<String>> getPurchasedProductIds();

  /// Restores previous purchases across app reinstalls or device changes.
  Future<List<PurchaseResult>> restorePurchases();

  /// Checks if the billing service is currently connected and operational.
  Future<bool> isConnected();

  /// Disposes and disconnects from the billing client when no longer needed.
  Future<void> dispose();
}
