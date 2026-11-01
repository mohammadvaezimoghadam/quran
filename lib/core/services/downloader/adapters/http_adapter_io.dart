import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

void configureHttpClientAdapter(Dio dio) {
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      // Bypass SSL handshake errors caused by deep packet inspection or proxy certificates in Iran
      client.badCertificateCallback = (cert, host, port) => true;
      
      // Bypass local proxy (e.g. 127.0.0.1:2080) for localhost, internal network, domestic .ir domains, and Tafakor/OTA servers
      client.findProxy = (uri) {
        final host = uri.host.toLowerCase();
        if (host == 'localhost' ||
            host == '127.0.0.1' ||
            host.startsWith('172.') ||
            host.startsWith('192.168.') ||
            host.startsWith('10.') ||
            host.endsWith('.ir') ||
            host.contains('tafakormag') ||
            host == '5.22.203.61') {
          return 'DIRECT';
        }
        return HttpClient.findProxyFromEnvironment(uri);
      };

      // Short idleTimeout ensures stale sockets are purged before reusing dead keep-alive sockets
      client.idleTimeout = const Duration(seconds: 5);
      client.connectionTimeout = const Duration(seconds: 30);
      return client;
    },
  );
}
