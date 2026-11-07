import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_analytics_service_impl.dart';
import 'i_analytics_service.dart';
import 'noop_analytics_service_impl.dart';

/// Riverpod provider delivering the application-wide [IAnalyticsService].
final analyticsServiceProvider = Provider<IAnalyticsService>((ref) {
  // Gracefully fallback to NoOp on web or unsupported desktop platforms
  if (kIsWeb) {
    return const NoOpAnalyticsServiceImpl();
  }

  final isSupported = defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  if (!isSupported) {
    return const NoOpAnalyticsServiceImpl();
  }

  return FirebaseAnalyticsServiceImpl();
});

/// Exposes the NavigatorObserver for GoRouter or Navigator to automatically track screen views.
final analyticsObserverProvider = Provider<NavigatorObserver?>((ref) {
  final service = ref.watch(analyticsServiceProvider);
  return service.navigatorObserver;
});

