import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'i_push_notification_service.dart';
import 'models/notification_payload.dart';

/// Top-level background message handler required by FCM.
/// Must be annotated with @pragma('vm:entry-point') so it's not stripped by tree shaking.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📥 [FCM Background Message Received]');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
  developer.log(
    'FCM Background message received: ${message.messageId} - ${message.notification?.title}',
    name: 'PushNotificationService',
  );
}

final class FirebasePushNotificationServiceImpl implements IPushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const String channelId = 'quran_notifications';
  static const String channelName = 'پیام‌ها و اعلان‌های قرآنی';
  static const String channelDescription = 'دریافت آیات، یادآوری‌ها و اطلاعیه‌های قرآنی';

  final _messageReceivedController = StreamController<NotificationPayload>.broadcast();
  final _notificationOpenedAppController = StreamController<NotificationPayload>.broadcast();

  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Firebase Messaging is supported primarily on mobile (Android/iOS) and Web
    if (!kIsWeb &&
        defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      developer.log(
        'Push notifications are not supported on current platform: $defaultTargetPlatform',
        name: 'PushNotificationService',
      );
      return;
    }

    try {
      // 1. Request user permission
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      developer.log(
        'User granted notification permission: ${settings.authorizationStatus}',
        name: 'PushNotificationService',
      );

      // 2. Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 3. Initialize local notifications for Android foreground presentation
      await _setupLocalNotifications();

      // 4. Foreground notification presentation options on iOS
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 5. Listen to foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 6. Listen to notification opened app events
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpenedApp);

      // 7. Check if app was opened from a terminated state via notification
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationOpenedApp(initialMessage);
      }

      // Auto-subscribe to default general topic
      await subscribeToTopic('all_users');

      // Fetch and log device token for testing/console targeting
      final token = await getDeviceToken();
      if (kDebugMode) {
        debugPrint('====================================================');
        debugPrint('🔔 FCM Registration Token: $token');
        debugPrint('====================================================');
      }

      _isInitialized = true;
      developer.log('Push notification service initialized successfully.', name: 'PushNotificationService');
    } catch (e, s) {
      developer.log(
        'Error initializing PushNotificationService: $e',
        name: 'PushNotificationService',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _notificationOpenedAppController.add(NotificationPayload(
            id: response.id,
            data: {'payload': payload},
          ));
        }
      },
    );

    // Create high-importance Android notification channel
    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
      playSound: true,
    );

    final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(androidChannel);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('🔔 [FCM Foreground Message Received]');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');
    developer.log(
      'FCM Foreground message received: ${message.messageId}',
      name: 'PushNotificationService',
    );

    final payload = _mapRemoteMessage(message);
    _messageReceivedController.add(payload);

    // Show local notification banner when notification content exists
    final notification = message.notification;
    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_notification',
            color: Color(0xFF005C55),
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  void _handleNotificationOpenedApp(RemoteMessage message) {
    debugPrint('🚀 [Notification Opened App Clicked]');
    debugPrint('Data: ${message.data}');
    developer.log(
      'Notification opened app: ${message.messageId}',
      name: 'PushNotificationService',
    );
    _notificationOpenedAppController.add(_mapRemoteMessage(message));
  }

  NotificationPayload _mapRemoteMessage(RemoteMessage message) {
    return NotificationPayload(
      id: message.messageId.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
      sentTime: message.sentTime,
    );
  }

  @override
  Future<String?> getDeviceToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      developer.log('FCM Device Token: $token', name: 'PushNotificationService');
      return token;
    } catch (e) {
      developer.log('Failed to get FCM Device Token: $e', name: 'PushNotificationService');
      return null;
    }
  }

  @override
  Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      developer.log('Subscribed to topic: $topic', name: 'PushNotificationService');
    } catch (e) {
      developer.log('Failed to subscribe to topic: $topic ($e)', name: 'PushNotificationService');
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      developer.log('Unsubscribed from topic: $topic', name: 'PushNotificationService');
    } catch (e) {
      developer.log('Failed to unsubscribe from topic: $topic ($e)', name: 'PushNotificationService');
    }
  }

  @override
  void onMessageReceived(void Function(NotificationPayload payload) onData) {
    _messageReceivedController.stream.listen(onData);
  }

  @override
  void onNotificationOpenedApp(void Function(NotificationPayload payload) onData) {
    _notificationOpenedAppController.stream.listen(onData);
  }
}
