import 'package:flutter/widgets.dart';
import 'i_analytics_service.dart';

/// Fallback / Mock analytics implementation for Web, Desktop, and Unit Tests.
/// Safely ignores or stubs calls without making network or native calls.
class NoOpAnalyticsServiceImpl implements IAnalyticsService {
  const NoOpAnalyticsServiceImpl();

  @override
  Future<void> initialize() async {}

  @override
  NavigatorObserver? get navigatorObserver => null;

  @override
  Future<void> logScreenView(String screenName) async {}

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {}

  @override
  Future<void> logSurahOpen({
    required int surahNumber,
    required String surahName,
    int? ayahNumber,
  }) async {}

  @override
  Future<void> logAudioPlay({
    required int surahNumber,
    int? ayahNumber,
    String? reciterName,
  }) async {}

  @override
  Future<void> logAudioPause({
    required int surahNumber,
    int? ayahNumber,
  }) async {}

  @override
  Future<void> logBookmarkToggle({
    required int surahNumber,
    required int ayahNumber,
    required bool isBookmarked,
  }) async {}

  @override
  Future<void> logTafsirView({
    required int surahNumber,
    required int ayahNumber,
    String? tafsirId,
  }) async {}

  @override
  Future<void> logTranslationChange({required String translationId}) async {}

  @override
  Future<void> logKhatmAction({
    required String action,
    String? khatmId,
    String? khatmType,
    int? sessionCount,
  }) async {}

  @override
  Future<void> logSearch({
    required String query,
    int? resultCount,
  }) async {}

  @override
  Future<void> logVipView() async {}

  @override
  Future<void> logVipPurchaseStarted({
    required String planId,
    double? price,
  }) async {}

  @override
  Future<void> logVipPurchaseSuccess({
    required String planId,
    String? orderId,
  }) async {}

  @override
  Future<void> logVipPurchaseFailed({
    required String planId,
    required String error,
  }) async {}
}

