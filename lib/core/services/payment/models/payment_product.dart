/// Type of in-app product available for purchase.
enum PaymentProductType {
  /// Recurring or duration-based subscription (1 month, 3 months, 1 year, lifetime)
  subscription,

  /// One-time consumable donation / Nazr
  consumable,
}

/// Pre-defined subscription durations outlined in monetization_strategy.md
enum SubscriptionPlan {
  monthly,
  quarterly,
  yearly,
  lifetime,
}

/// Pre-defined Nazr / Cultural Donation tiers
enum NazrPlan {
  bronze,
  silver,
  gold,
}

/// Represents a purchasable product or subscription in the app.
class PaymentProduct {
  final String id;
  final String title;
  final String description;
  final int priceToman;
  final PaymentProductType type;
  final SubscriptionPlan? subscriptionPlan;
  final NazrPlan? nazrPlan;
  final String? discountBadge;
  final bool isRecommended;
  final int giftSubscriptionDays;

  const PaymentProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.priceToman,
    required this.type,
    this.subscriptionPlan,
    this.nazrPlan,
    this.discountBadge,
    this.isRecommended = false,
    this.giftSubscriptionDays = 0,
  });

  /// 1 Month Subscription (۳۹,۰۰۰ تومان)
  static const PaymentProduct vipMonthly = PaymentProduct(
    id: 'sub_vip_1m',
    title: 'اشتراک ۱ ماهه',
    description: 'دسترسی کامل به تمام قاریان، ترجمه گویا و امکانات VIP به مدت ۳۰ روز',
    priceToman: 39000,
    type: PaymentProductType.subscription,
    subscriptionPlan: SubscriptionPlan.monthly,
  );

  /// 3 Months Subscription (۸۹,۰۰۰ تومان - ۲۵٪ تخفیف)
  static const PaymentProduct vipQuarterly = PaymentProduct(
    id: 'sub_vip_3m',
    title: 'اشتراک ۳ ماهه (فصلی)',
    description: 'دسترسی نامحدود VIP برای یک فصل معنوی همراه با ۲۵٪ تخفیف',
    priceToman: 89000,
    type: PaymentProductType.subscription,
    subscriptionPlan: SubscriptionPlan.quarterly,
    discountBadge: '۲۵٪ تخفیف',
  );

  /// 1 Year Subscription (۱۷۹,۰۰۰ تومان - ۶۰٪ تخفیف - پیشنهاد طلایی)
  static const PaymentProduct vipYearly = PaymentProduct(
    id: 'sub_vip_1y',
    title: 'اشتراک ۱ ساله (طلایی)',
    description: 'محبوب‌ترین و به‌صرفه‌ترین پلن با دسترسی نامحدود برای ۳۶۵ روز',
    priceToman: 179000,
    type: PaymentProductType.subscription,
    subscriptionPlan: SubscriptionPlan.yearly,
    discountBadge: '۶۰٪ تخفیف ویژه',
    isRecommended: true,
  );

  /// Lifetime Subscription (۳۴۹,۰۰۰ تومان)
  static const PaymentProduct vipLifetime = PaymentProduct(
    id: 'sub_vip_lifetime',
    title: 'اشتراک مادام‌العمر (دائمی)',
    description: 'دسترسی همیشگی و نامحدود به تمامی امکانات فعلی و آینده نرم‌افزار',
    priceToman: 349000,
    type: PaymentProductType.subscription,
    subscriptionPlan: SubscriptionPlan.lifetime,
    discountBadge: 'دائمی',
  );

  /// Nazr Bronze (۵۰,۰۰۰ تومان + ۱ ماه اشتراک هدیه)
  static const PaymentProduct nazrBronze = PaymentProduct(
    id: 'nazr_bronze_50k',
    title: 'نذر فرهنگی برنزی',
    description: 'کمک به توسعه نرم‌افزار + ۱ ماه اشتراک هدیه VIP',
    priceToman: 50000,
    type: PaymentProductType.consumable,
    nazrPlan: NazrPlan.bronze,
    giftSubscriptionDays: 30,
  );

  /// Nazr Silver (۱۰۰,۰۰۰ تومان + ۳ ماه اشتراک هدیه)
  static const PaymentProduct nazrSilver = PaymentProduct(
    id: 'nazr_silver_100k',
    title: 'نذر فرهنگی نقره‌ای',
    description: 'مشارکت مؤثر در نشر فرهنگ قرآنی + ۳ ماه اشتراک هدیه VIP',
    priceToman: 100000,
    type: PaymentProductType.consumable,
    nazrPlan: NazrPlan.silver,
    giftSubscriptionDays: 90,
  );

  /// Nazr Gold (۳۰۰,۰۰۰ تومان + ۱ سال اشتراک هدیه)
  static const PaymentProduct nazrGold = PaymentProduct(
    id: 'nazr_gold_300k',
    title: 'نذر فرهنگی طلایی',
    description: 'حمایت ویژه از تولید محتوای قرآنی + ۱ سال اشتراک هدیه VIP',
    priceToman: 300000,
    type: PaymentProductType.consumable,
    nazrPlan: NazrPlan.gold,
    giftSubscriptionDays: 365,
  );

  /// All subscription plans
  static const List<PaymentProduct> allSubscriptions = [
    vipMonthly,
    vipQuarterly,
    vipYearly,
    vipLifetime,
  ];

  /// All Nazr / Donation packages
  static const List<PaymentProduct> allNazrPackages = [
    nazrBronze,
    nazrSilver,
    nazrGold,
  ];
}
