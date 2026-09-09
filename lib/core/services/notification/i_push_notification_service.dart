import 'models/notification_payload.dart';

/// Abstract contract for push notification services.
/// Decouples the application from specific vendors (Firebase FCM, OneSignal, etc.).
abstract interface class IPushNotificationService {
  /// Initializes notification channels, permissions, and foreground/background listeners.
  Future<void> initialize();

  /// Retrieves the unique device registration token for push notifications.
  Future<String?> getDeviceToken();

  /// Stream of token updates if the device token gets refreshed.
  Stream<String> get onTokenRefresh;

  /// Subscribes the device to a notification topic (e.g. 'all_users', 'daily_ayah').
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribes the device from a previously subscribed topic.
  Future<void> unsubscribeFromTopic(String topic);

  /// Callback listener for incoming notifications while the app is in the foreground.
  void onMessageReceived(void Function(NotificationPayload payload) onData);

  /// Callback listener when a user taps a notification to open the app.
  void onNotificationOpenedApp(void Function(NotificationPayload payload) onData);
}
