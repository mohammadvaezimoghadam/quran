import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bazaar_payment_service_impl.dart';
import 'i_payment_service.dart';
import 'mock_payment_service_impl.dart';

/// Notifier to toggle between mock testing mode and real Cafe Bazaar production mode.
/// Defaults to true (Mock mode) until Bazaar Developer account and RSA key are configured.
class MockPaymentModeNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setMockMode(bool isMock) {
    state = isMock;
  }
}

final isMockPaymentProvider =
    NotifierProvider<MockPaymentModeNotifier, bool>(MockPaymentModeNotifier.new);

/// Production Bazaar RSA Public Key placeholder
final bazaarRsaPublicKeyProvider = Provider<String>((ref) {
  return 'YOUR_BAZAAR_RSA_PUBLIC_KEY';
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
