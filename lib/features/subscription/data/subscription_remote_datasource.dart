import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/remote/tafakor_api_client.dart';

final subscriptionRemoteDataSourceProvider = Provider<SubscriptionRemoteDataSource>((ref) {
  final dio = ref.watch(tafakorDioProvider);
  return SubscriptionRemoteDataSource(dio);
});

/// Remote data source communicating with Tafakor Subscriptions API (`/api/subscriptions/`)
class SubscriptionRemoteDataSource {
  final Dio _dio;

  SubscriptionRemoteDataSource(this._dio);

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(message, name: 'SubscriptionRemoteDS', error: error, stackTrace: stackTrace);
    debugPrint('[SubscriptionRemoteDS] $message');
  }

  /// Verifies a Cafe Bazaar purchase token with Tafakor Backend:
  /// POST /api/subscriptions/verify/
  Future<Map<String, dynamic>> verifyPurchase({
    required String sku,
    required String purchaseToken,
    String marketplace = 'cafebazaar',
  }) async {
    _log('🌐 [verifyPurchase] Sending purchase token to Tafakor backend for SKU: $sku');
    try {
      final response = await _dio.post(
        'subscriptions/verify/',
        data: {
          'sku': sku,
          'purchase_token': purchaseToken,
          'marketplace': marketplace,
        },
      );

      _log('✅ [verifyPurchase] Backend verified successfully: ${response.statusCode}');
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'success': true, 'data': response.data};
    } on DioException catch (e, stack) {
      _log('❌ [verifyPurchase] Dio error: ${e.response?.statusCode} - ${e.response?.data}', error: e, stackTrace: stack);
      String errorMessage = 'خطا در ارتباط با سرور تفکر';
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        errorMessage = data['detail'] ??
            data['message'] ??
            data['purchase_token'] ??
            data['error'] ??
            errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'مهلت زمان ارتباط با سرور تفکر به پایان رسید.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'اتصال با اینترنت برقرار نیست.';
      }
      throw Exception(errorMessage);
    } catch (e, stack) {
      _log('❌ [verifyPurchase] Unexpected error: $e', error: e, stackTrace: stack);
      throw Exception('خطای غیرمنتظره در اعتبارسنجی خرید: $e');
    }
  }

  /// Fetches the user's active subscription status from Tafakor Backend:
  /// GET /api/subscriptions/my-status/?plugin=quran
  Future<Map<String, dynamic>> getMyStatus({String plugin = 'quran'}) async {
    _log('🔍 [getMyStatus] Querying backend for user subscription status (plugin=$plugin)...');
    try {
      final response = await _dio.get(
        'subscriptions/my-status/',
        queryParameters: {'plugin': plugin},
      );

      _log('📥 [getMyStatus] Status response received: ${response.data}');
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e, stack) {
      _log('⚠️ [getMyStatus] Failed to fetch subscription status: ${e.message}', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Fetches the active subscription plans from Tafakor Backend:
  /// GET /api/subscriptions/plans/?plugin=quran
  Future<List<Map<String, dynamic>>> getPlans({String plugin = 'quran'}) async {
    _log('📦 [getPlans] Fetching subscription plans for plugin: $plugin');
    try {
      final response = await _dio.get(
        'subscriptions/plans/',
        queryParameters: {'plugin': plugin},
      );

      if (response.data is List) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e, stack) {
      _log('⚠️ [getPlans] Failed to fetch plans: ${e.message}', error: e, stackTrace: stack);
      return [];
    }
  }
}

