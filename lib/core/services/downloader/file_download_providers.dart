import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'i_file_download_service.dart';
import 'file_download_service_impl.dart';

/// Provider for the FileDownloadService with a dedicated clean Dio instance
final fileDownloadServiceProvider = Provider<IFileDownloadService>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 25),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
        'Accept': '*/*',
        'Accept-Encoding': 'gzip, deflate',
      },
    ),
  );

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

  return FileDownloadServiceImpl(dio);
});

