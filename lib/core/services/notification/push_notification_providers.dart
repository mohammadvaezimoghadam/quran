import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_push_notification_service_impl.dart';
import 'i_push_notification_service.dart';

/// Riverpod provider exposing the push notification service abstraction.
final pushNotificationServiceProvider = Provider<IPushNotificationService>((ref) {
  return FirebasePushNotificationServiceImpl();
});
