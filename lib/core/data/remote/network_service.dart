import 'package:dio/dio.dart';
import 'package:dio_http_formatter/dio_http_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'network_service_interceptor.dart';

final networkServiceProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
  );

  final dio = Dio(options);
  final interceptor = ref.watch(networkServiceInterceptorProvider);
  dio.interceptors.addAll([HttpFormatter(), interceptor]);

  return dio;
});
