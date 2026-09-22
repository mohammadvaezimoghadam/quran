import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

void configureHttpClientAdapter(Dio dio) {
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      // Bypass SSL handshake errors caused by deep packet inspection or proxy certificates in Iran
      client.badCertificateCallback = (cert, host, port) => true;
      // Short idleTimeout ensures stale sockets are purged before reusing dead keep-alive sockets
      client.idleTimeout = const Duration(seconds: 5);
      client.connectionTimeout = const Duration(seconds: 15);
      return client;
    },
  );
}
