/// Status of a purchase transaction.
enum PurchaseStatus {
  /// Purchase was successful and verified
  success,

  /// User explicitly cancelled the purchase sheet
  userCancelled,

  /// General error during communication with market or server
  error,

  /// Item is already owned by this user
  alreadyOwned,

  /// Purchase is being processed asynchronously
  pending,
}

/// Represents the outcome of an in-app billing transaction.
class PurchaseResult {
  final PurchaseStatus status;
  final String? productId;
  final String? purchaseToken;
  final String? orderId;
  final String? errorMessage;

  const PurchaseResult({
    required this.status,
    this.productId,
    this.purchaseToken,
    this.orderId,
    this.errorMessage,
  });

  bool get isSuccess => status == PurchaseStatus.success;
  bool get isCancelled => status == PurchaseStatus.userCancelled;

  factory PurchaseResult.success({
    required String productId,
    required String purchaseToken,
    String? orderId,
  }) {
    return PurchaseResult(
      status: PurchaseStatus.success,
      productId: productId,
      purchaseToken: purchaseToken,
      orderId: orderId,
    );
  }

  factory PurchaseResult.userCancelled({String? productId}) {
    return PurchaseResult(
      status: PurchaseStatus.userCancelled,
      productId: productId,
      errorMessage: 'خرید توسط کاربر لغو شد.',
    );
  }

  factory PurchaseResult.error(String message, {String? productId}) {
    return PurchaseResult(
      status: PurchaseStatus.error,
      productId: productId,
      errorMessage: message,
    );
  }

  factory PurchaseResult.alreadyOwned({String? productId}) {
    return PurchaseResult(
      status: PurchaseStatus.alreadyOwned,
      productId: productId,
      errorMessage: 'این محصول یا اشتراک پیش‌تر توسط شما خریداری شده است.',
    );
  }

  @override
  String toString() {
    return 'PurchaseResult(status: $status, productId: $productId, orderId: $orderId, error: $errorMessage)';
  }
}
