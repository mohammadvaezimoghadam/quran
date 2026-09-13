/// Pre-defined subscription durations
enum SubscriptionPlan {
  monthly,
  quarterly,
  semiAnnual,
  yearly,
  lifetime,
}

/// Represents a purchasable subscription plan in the app.
class PaymentProduct {
  final String id;
  final String title;
  final String description;
  final int priceToman;
  final String? formattedPrice;
  final SubscriptionPlan subscriptionPlan;
  final String? discountBadge;
  final bool isRecommended;

  const PaymentProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.priceToman,
    required this.subscriptionPlan,
    this.formattedPrice,
    this.discountBadge,
    this.isRecommended = false,
  });

  /// Approximate duration in days for this subscription plan.
  /// Null represents lifetime access.
  int? get durationDays {
    switch (subscriptionPlan) {
      case SubscriptionPlan.monthly:
        return 30;
      case SubscriptionPlan.quarterly:
        return 90;
      case SubscriptionPlan.semiAnnual:
        return 180;
      case SubscriptionPlan.yearly:
        return 365;
      case SubscriptionPlan.lifetime:
        return null;
    }
  }

  PaymentProduct copyWith({
    String? id,
    String? title,
    String? description,
    int? priceToman,
    String? formattedPrice,
    SubscriptionPlan? subscriptionPlan,
    String? discountBadge,
    bool? isRecommended,
  }) {
    return PaymentProduct(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priceToman: priceToman ?? this.priceToman,
      formattedPrice: formattedPrice ?? this.formattedPrice,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      discountBadge: discountBadge ?? this.discountBadge,
      isRecommended: isRecommended ?? this.isRecommended,
    );
  }

  /// 1 Month Subscription (۳۹,۰۰۰ تومان)
  static const PaymentProduct vipMonthly = PaymentProduct(
    id: 'sub_vip_1m',
    title: 'اشتراک ۱ ماهه',
    description: 'دسترسی نامحدود به تمام قاریان برجسته و ترجمه گویای صوتی به مدت ۳۰ روز',
    priceToman: 39000,
    subscriptionPlan: SubscriptionPlan.monthly,
  );

  /// 3 Months Subscription (۸۹,۰۰۰ تومان - ۲۵٪ تخفیف)
  static const PaymentProduct vipQuarterly = PaymentProduct(
    id: 'sub_vip_3m',
    title: 'اشتراک ۳ ماهه (فصلی)',
    description: 'دسترسی نامحدود برای یک فصل همراه با ۲۵٪ تخفیف',
    priceToman: 89000,
    subscriptionPlan: SubscriptionPlan.quarterly,
    discountBadge: '۲۵٪ تخفیف',
  );

  /// 6 Months Subscription (۱۴۹,۰۰۰ تومان - ۴۰٪ تخفیف ویژه - پیشنهاد طلایی)
  static const PaymentProduct vipSemiAnnual = PaymentProduct(
    id: 'sub_vip_6m',
    title: 'اشتراک ۶ ماهه (طلایی)',
    description: 'محبوب‌ترین و به‌صرفه‌ترین پلن با دسترسی نامحدود برای ۱۸۰ روز همراه با تخفیف ویژه',
    priceToman: 149000,
    subscriptionPlan: SubscriptionPlan.semiAnnual,
    discountBadge: '۴۰٪ تخفیف ویژه',
    isRecommended: true,
  );

  /// All subscription plans (1 Month, 3 Months, 6 Months)
  static const List<PaymentProduct> allSubscriptions = [
    vipMonthly,
    vipQuarterly,
    vipSemiAnnual,
  ];

  /// Find a product by its SKU ID
  static PaymentProduct? findById(String id) {
    try {
      return allSubscriptions.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
