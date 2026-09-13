import 'package:flutter_test/flutter_test.dart';
import 'package:quran/features/subscription/domain/models/vip_subscription_state.dart';

void main() {
  group('VipSubscriptionState Expiry & Access Tests', () {
    test('User with isVip=true and future expiry date should have active VIP access', () {
      final state = VipSubscriptionState(
        isVip: true,
        vipExpiryDate: DateTime.now().add(const Duration(minutes: 5)),
        activePlanId: 'sub_vip_1m',
      );

      expect(state.hasVipAccess, isTrue);
    });

    test('User with isVip=true but past expiry date should IMMEDIATELY lose VIP access', () {
      final state = VipSubscriptionState(
        isVip: true,
        vipExpiryDate: DateTime.now().subtract(const Duration(seconds: 1)),
        activePlanId: 'sub_vip_1m',
      );

      // In-memory hasVipAccess checks DateTime.now().isBefore(vipExpiryDate)
      expect(state.hasVipAccess, isFalse);
    });

    test('User with isVip=false should not have VIP access regardless of expiry', () {
      final state = VipSubscriptionState(
        isVip: false,
        vipExpiryDate: DateTime.now().add(const Duration(days: 30)),
      );

      expect(state.hasVipAccess, isFalse);
    });

    test('Lifetime subscription (vipExpiryDate == null and isVip == true) has perpetual access', () {
      const state = VipSubscriptionState(
        isVip: true,
        vipExpiryDate: null,
        activePlanId: 'lifetime',
      );

      expect(state.hasVipAccess, isTrue);
    });
  });
}
