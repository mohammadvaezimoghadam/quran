import 'models/payment_product.dart';
import 'models/purchase_result.dart';

/// Abstract contract for In-App Billing (IAB) services.
/// Decouples the application from specific store APIs (Cafe Bazaar Poolakey, Myket, etc.)
/// allowing seamless mocking during development and testing.
abstract interface class IPaymentService {
  /// Initializes connection to the in-app billing service and verifies public RSA keys.
  Future<bool> initialize();

  /// Initiates a subscription flow for a specific SKU product ID (e.g. sub_vip_1m, sub_vip_1y).
  Future<PurchaseResult> subscribe(String productId);

  /// Fetches live product details and localized prices from the store (e.g. getSkuDetails in Poolakey).
  Future<List<PaymentProduct>> getSubscriptionProducts(List<String> skuIds);

  /// Retrieves list of active subscription product IDs owned by current user.
  Future<List<String>> getPurchasedProductIds();

  /// Restores previous active purchases across app reinstalls or device changes.
  Future<List<PurchaseResult>> restorePurchases();

  /// Checks if the billing service is currently connected and operational.
  Future<bool> isConnected();

  /// Disposes and disconnects from the billing client when no longer needed.
  Future<void> dispose();
}
