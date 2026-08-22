import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final networkServiceInterceptorProvider = Provider<NetworkServiceInterceptor>((ref) {
  return NetworkServiceInterceptor();
});

class NetworkServiceInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Pass errors down to repositories where DioExceptionMapper handles them into Failure objects
    super.onError(err, handler);
  }
}
