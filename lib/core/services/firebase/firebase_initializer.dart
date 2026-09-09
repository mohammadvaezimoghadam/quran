import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../firebase_options.dart';

/// Centralized, safe initializer for Firebase services across platforms.
abstract class FirebaseInitializer {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Initializes Firebase if the platform is supported.
  /// Gracefully fails or skips on desktop/unsupported platforms without crashing.
  static Future<void> init() async {
    if (_isInitialized) return;

    // Check if platform is configured in DefaultFirebaseOptions
    final isSupported = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    if (!isSupported) {
      developer.log(
        'Firebase is not configured for platform $defaultTargetPlatform. Skipping initialization.',
        name: 'FirebaseInitializer',
      );
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      developer.log('Firebase initialized successfully.', name: 'FirebaseInitializer');
    } catch (e, s) {
      developer.log(
        'Failed to initialize Firebase: $e',
        name: 'FirebaseInitializer',
        error: e,
        stackTrace: s,
      );
    }
  }
}
