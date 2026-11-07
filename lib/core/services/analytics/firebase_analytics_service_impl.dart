import 'dart:developer' as developer;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'i_analytics_service.dart';

/// Production implementation of [IAnalyticsService] backed by Firebase Analytics.
class FirebaseAnalyticsServiceImpl implements IAnalyticsService {
  final FirebaseAnalytics _analytics;
  final NavigatorObserver _observer;

  FirebaseAnalyticsServiceImpl([FirebaseAnalytics? analytics])
      : _analytics = analytics ?? FirebaseAnalytics.instance,
        _observer = FirebaseAnalyticsObserver(
          analytics: analytics ?? FirebaseAnalytics.instance,
        );

  void _log(String message) {
    developer.log(message, name: 'FirebaseAnalytics');
    if (kDebugMode) {
      debugPrint('📊 [FirebaseAnalytics] $message');
    }
  }

  @override
  NavigatorObserver? get navigatorObserver => _observer;

  @override
  Future<void> initialize() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      _log('Firebase Analytics initialized successfully.');
    } catch (e, s) {
      developer.log(
        'Failed to initialize Firebase Analytics: $e',
        name: 'FirebaseAnalytics',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
      _log('Screen view: $screenName');
    } catch (e) {
      developer.log('Error logging screen view: $e', name: 'FirebaseAnalytics');
    }
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {
    try {
      final sanitized = parameters != null
          ? Map<String, Object>.fromEntries(
              parameters.entries
                  .where((e) => e.value != null)
                  .map((e) => MapEntry(e.key, e.value!)),
            )
          : null;

      await _analytics.logEvent(name: name, parameters: sanitized);
      _log('Event [$name] -> $sanitized');
    } catch (e) {
      developer.log('Error logging event $name: $e', name: 'FirebaseAnalytics');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
      _log('User ID set: $userId');
    } catch (e) {
      developer.log('Error setting user ID: $e', name: 'FirebaseAnalytics');
    }
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      _log('User Property [$name] = $value');
    } catch (e) {
      developer.log('Error setting user property: $e', name: 'FirebaseAnalytics');
    }
  }

  @override
  Future<void> logSurahOpen({
    required int surahNumber,
    required String surahName,
    int? ayahNumber,
  }) async {
    await logEvent(
      name: 'surah_opened',
      parameters: {
        'surah_number': surahNumber,
        'surah_name': surahName,
        'ayah_number': ayahNumber,
      },
    );
  }

  @override
  Future<void> logAudioPlay({
    required int surahNumber,
    int? ayahNumber,
    String? reciterName,
  }) async {
    await logEvent(
      name: 'audio_playback_started',
      parameters: {
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
        'reciter': reciterName,
      },
    );
  }

  @override
  Future<void> logAudioPause({
    required int surahNumber,
    int? ayahNumber,
  }) async {
    await logEvent(
      name: 'audio_playback_paused',
      parameters: {
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
      },
    );
  }

  @override
  Future<void> logBookmarkToggle({
    required int surahNumber,
    required int ayahNumber,
    required bool isBookmarked,
  }) async {
    await logEvent(
      name: isBookmarked ? 'bookmark_added' : 'bookmark_removed',
      parameters: {
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
      },
    );
  }

  @override
  Future<void> logTafsirView({
    required int surahNumber,
    required int ayahNumber,
    String? tafsirId,
  }) async {
    await logEvent(
      name: 'tafsir_viewed',
      parameters: {
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
        'tafsir_id': tafsirId,
      },
    );
  }

  @override
  Future<void> logTranslationChange({required String translationId}) async {
    await logEvent(
      name: 'translation_changed',
      parameters: {'translation_id': translationId},
    );
  }

  @override
  Future<void> logKhatmAction({
    required String action,
    String? khatmId,
    String? khatmType,
    int? sessionCount,
  }) async {
    await logEvent(
      name: 'khatm_action',
      parameters: {
        'action': action,
        'khatm_id': khatmId,
        'khatm_type': khatmType,
        'session_count': sessionCount,
      },
    );
  }

  @override
  Future<void> logSearch({
    required String query,
    int? resultCount,
  }) async {
    await logEvent(
      name: 'quran_search',
      parameters: {
        'search_term': query,
        'result_count': resultCount,
      },
    );
  }

  @override
  Future<void> logVipView() async {
    await logEvent(name: 'vip_screen_viewed');
  }

  @override
  Future<void> logVipPurchaseStarted({
    required String planId,
    double? price,
  }) async {
    await logEvent(
      name: 'vip_purchase_started',
      parameters: {
        'plan_id': planId,
        'price': price,
      },
    );
  }

  @override
  Future<void> logVipPurchaseSuccess({
    required String planId,
    String? orderId,
  }) async {
    await logEvent(
      name: 'vip_purchase_success',
      parameters: {
        'plan_id': planId,
        'order_id': orderId,
      },
    );
  }

  @override
  Future<void> logVipPurchaseFailed({
    required String planId,
    required String error,
  }) async {
    await logEvent(
      name: 'vip_purchase_failed',
      parameters: {
        'plan_id': planId,
        'error': error,
      },
    );
  }
}
