import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bazaar_payment_service_impl.dart';
import 'i_payment_service.dart';
import 'mock_payment_service_impl.dart';

/// Notifier to toggle between mock testing mode and real Cafe Bazaar production mode.
/// Defaults to true (Mock mode) until Bazaar Developer account and RSA key are configured.
class MockPaymentModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setMockMode(bool isMock) {
    state = isMock;
  }
}

final isMockPaymentProvider =
    NotifierProvider<MockPaymentModeNotifier, bool>(MockPaymentModeNotifier.new);

/// Production Bazaar RSA Public Key
final bazaarRsaPublicKeyProvider = Provider<String>((ref) {
  return 'MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwCwJUEWPVWmufcsZvRUS3rZWmocxuQzArnyZc1V7/pu1fNpOileSuWFZ+EacqLpkEQsLQzL3t4vjyumtjRjpzj1Tlabgre0wjkz7ciGdR/DUH9DmCsbQaarkt8YLoQFGsb3ROr9bK5RobsOioasKU8Xa01Z2K+4GtPRxO+eYMnC8cgzHNhL49m4kf6L6DNj6b3EOaHBcagOYKfAtdC/N6N0H+m8JMAMP606wZ4LTckCAwEAAQ==';
});

/// Central Riverpod Provider exposing the in-app payment service.
final paymentServiceProvider = Provider<IPaymentService>((ref) {
  final isMock = ref.watch(isMockPaymentProvider);

  if (isMock) {
    final mockService = MockPaymentServiceImpl();
    mockService.initialize();
    return mockService;
  } else {
    final rsaKey = ref.watch(bazaarRsaPublicKeyProvider);
    final bazaarService = BazaarPaymentServiceImpl(rsaPublicKey: rsaKey);
    bazaarService.initialize();
    return bazaarService;
  }
});
