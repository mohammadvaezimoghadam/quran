import 'package:flutter/widgets.dart';

/// Abstract contract for Analytics services following Clean Architecture principles.
/// Decouples the application from any specific analytics vendor (Firebase, Mixpanel, etc.).
abstract interface class IAnalyticsService {
  /// Initializes the analytics service.
  Future<void> initialize();

  /// Logs a screen view manually.
  Future<void> logScreenView(String screenName);

  /// Logs a generic custom event with optional parameters.
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  });

  /// Sets a persistent user ID.
  Future<void> setUserId(String? userId);

  /// Sets a user property key/value pair.
  Future<void> setUserProperty({
    required String name,
    required String? value,
  });

  /// Provides a NavigatorObserver to automatically track screen transitions in GoRouter.
  NavigatorObserver? get navigatorObserver;

  // ── Quran Domain-Specific Events ──────────────────────────────────────────

  /// Logs when user opens a Surah to read.
  Future<void> logSurahOpen({
    required int surahNumber,
    required String surahName,
    int? ayahNumber,
  });

  /// Logs when Quran audio playback starts.
  Future<void> logAudioPlay({
    required int surahNumber,
    int? ayahNumber,
    String? reciterName,
  });

  /// Logs when Quran audio playback pauses or stops.
  Future<void> logAudioPause({
    required int surahNumber,
    int? ayahNumber,
  });

  /// Logs when an Ayah bookmark is added or removed.
  Future<void> logBookmarkToggle({
    required int surahNumber,
    required int ayahNumber,
    required bool isBookmarked,
  });

  /// Logs when a Tafsir explanation is viewed.
  Future<void> logTafsirView({
    required int surahNumber,
    required int ayahNumber,
    String? tafsirId,
  });

  /// Logs when translation selection changes.
  Future<void> logTranslationChange({
    required String translationId,
  });

  /// Logs Khatm creation or completion actions.
  Future<void> logKhatmAction({
    required String action,
    String? khatmId,
    String? khatmType,
    int? sessionCount,
  });

  /// Logs a search performed by the user.
  Future<void> logSearch({
    required String query,
    int? resultCount,
  });

  /// Logs when the VIP subscription paywall/screen is presented.
  Future<void> logVipView();

  /// Logs when user starts the purchase flow for a VIP plan.
  Future<void> logVipPurchaseStarted({
    required String planId,
    double? price,
  });

  /// Logs when a VIP purchase completes successfully.
  Future<void> logVipPurchaseSuccess({
    required String planId,
    String? orderId,
  });

  /// Logs when a VIP purchase fails or is cancelled.
  Future<void> logVipPurchaseFailed({
    required String planId,
    required String error,
  });
}

