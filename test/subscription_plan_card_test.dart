import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/core/services/payment/models/payment_product.dart';
import 'package:quran/features/subscription/presentation/widgets/subscription_plan_card.dart';

void main() {
  testWidgets('SubscriptionPlanCard renders title and price without descriptions or icons', (tester) async {
    const product = PaymentProduct(
      id: 'test_id',
      title: 'اشتراک یک ماهه',
      description: 'این متن نباید نمایش داده شود',
      priceToman: 15000,
      subscriptionPlan: SubscriptionPlan.monthly,
    );

    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.light,
        home: Scaffold(
          body: SubscriptionPlanCard(
            product: product,
            isSelected: true,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    // Verify title and price are present
    expect(find.text('اشتراک یک ماهه'), findsOneWidget);
    expect(find.textContaining('۱۵٬۰۰۰ تومان'), findsOneWidget);

    // Verify verbose description is NOT displayed
    expect(find.text('این متن نباید نمایش داده شود'), findsNothing);

    // Verify dedicated action button exists with «خرید»
    expect(find.text('خرید'), findsOneWidget);

    // Verify tap works
    await tester.tap(find.byType(SubscriptionPlanCard));
    expect(tapped, isTrue);
  });

  testWidgets('SubscriptionPlanCard adapts correctly in dark mode', (tester) async {
    const product = PaymentProduct(
      id: 'test_id',
      title: 'اشتراک ۶ ماهه',
      description: 'توضیحات طولانی',
      priceToman: 75000,
      subscriptionPlan: SubscriptionPlan.semiAnnual,
      discountBadge: 'تخفیف ویژه',
    );

    await tester.pumpWidget(
      MaterialApp(
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: Scaffold(
          body: SubscriptionPlanCard(
            product: product,
            isSelected: false,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('اشتراک ۶ ماهه'), findsOneWidget);
    expect(find.text('تخفیف ویژه'), findsOneWidget);
    expect(find.textContaining('۷۵٬۰۰۰ تومان'), findsOneWidget);
    expect(find.text('توضیحات طولانی'), findsNothing);
  });

  testWidgets('SubscriptionPlanCard shows renew text when isVip is true', (tester) async {
    const product = PaymentProduct(
      id: 'test_id',
      title: 'اشتراک ۱ ماهه',
      description: 'توضیحات',
      priceToman: 39000,
      subscriptionPlan: SubscriptionPlan.monthly,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubscriptionPlanCard(
            product: product,
            isVip: true,
            onPurchase: () {},
          ),
        ),
      ),
    );

    expect(find.text('تمدید'), findsOneWidget);
  });

  testWidgets('SubscriptionPlanCard shows loading indicator when isLoading is true', (tester) async {
    const product = PaymentProduct(
      id: 'test_id',
      title: 'اشتراک ۱ ماهه',
      description: 'توضیحات',
      priceToman: 39000,
      subscriptionPlan: SubscriptionPlan.monthly,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubscriptionPlanCard(
            product: product,
            isLoading: true,
            onPurchase: () {},
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('خرید'), findsNothing);
  });

  testWidgets('SubscriptionPlanCard does NOT overflow on narrow screen with long Bazaar title and badge', (tester) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const product = PaymentProduct(
      id: 'sub_vip_6m',
      title: 'اشتراک ۶ ماهه (طلایی)',
      description: 'توضیحات',
      priceToman: 149000,
      subscriptionPlan: SubscriptionPlan.semiAnnual,
      discountBadge: '۴۰٪ تخفیف ویژه',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: SubscriptionPlanCard(
              product: product,
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('۴۰٪ تخفیف ویژه'), findsOneWidget);
  });
}
