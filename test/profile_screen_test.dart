import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/features/profile/presentation/ui/profile_screen.dart';
import 'package:quran/features/subscription/application/vip_subscription_controller.dart';
import 'package:quran/features/subscription/domain/models/vip_subscription_state.dart';

class MockVipSubscriptionController extends VipSubscriptionController {
  final bool mockIsVip;

  MockVipSubscriptionController({this.mockIsVip = false});

  @override
  VipSubscriptionState build() {
    return VipSubscriptionState(
      isVip: mockIsVip,
      isLoading: false,
      vipExpiryDate: mockIsVip ? DateTime.now().add(const Duration(days: 30)) : null,
    );
  }
}

void main() {
  testWidgets('ProfileScreen renders user header, subscription card, and purchase item', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vipSubscriptionControllerProvider.overrideWith(
            () => MockVipSubscriptionController(mockIsVip: false),
          ),
        ],
        child: const MaterialApp(
          home: ProfileScreen(showBackButton: false),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify user header
    expect(find.text('کاربر قرآن تفکر'), findsOneWidget);

    // Verify subscription status section & card
    expect(find.text('وضعیت حساب'), findsOneWidget);
    expect(find.textContaining('کاربر عادی'), findsWidgets);

    // Verify status card has NO icon and NO caption
    expect(find.byIcon(Icons.info_outline_rounded), findsNothing);
    expect(find.textContaining('دسترسی نامحدود به قاریان برجسته نیازمند اشتراک است'), findsNothing);

    // Verify VIP subscription item (without "خرید")
    expect(find.text('خرید اشتراک ویژه'), findsNothing);
    expect(find.text('اشتراک ویژه'), findsNWidgets(2)); // Section header & tile title

    // Verify "امکانات" section is completely removed
    expect(find.text('امکانات'), findsNothing);
  });

  testWidgets('ProfileScreen renders cleanly with back button', (tester) async {
    bool backPressed = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vipSubscriptionControllerProvider.overrideWith(
            () => MockVipSubscriptionController(mockIsVip: false),
          ),
        ],
        child: MaterialApp(
          home: ProfileScreen(
            showBackButton: true,
            onBackPressed: () => backPressed = true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify back button is present and functional
    final backBtn = find.byTooltip('بازگشت');
    expect(backBtn, findsOneWidget);

    await tester.tap(backBtn);
    expect(backPressed, isTrue);
  });

  testWidgets('ProfileScreen renders VIP active status for VIP user without icon/caption', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vipSubscriptionControllerProvider.overrideWith(
            () => MockVipSubscriptionController(mockIsVip: true),
          ),
        ],
        child: const MaterialApp(
          home: ProfileScreen(showBackButton: false),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('اشتراک ویژه شما فعال است'), findsOneWidget);
    expect(find.text('عضویت ویژه تفکر'), findsOneWidget);
    expect(find.byIcon(Icons.verified_rounded), findsNothing);
    expect(find.text('اشتراک ویژه'), findsNWidgets(2)); // Section header & tile title
  });
}
