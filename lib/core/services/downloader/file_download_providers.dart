import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'i_file_download_service.dart';
import 'file_download_service_impl.dart';
import 'adapters/http_adapter.dart';

/// Provider for the FileDownloadService with a dedicated clean Dio instance
final fileDownloadServiceProvider = Provider<IFileDownloadService>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 25),
      headers: {
        if (!kIsWeb)
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
        'Accept': '*/*',
        if (!kIsWeb) 'Accept-Encoding': 'gzip, deflate',
      },
    ),
  );

  configureHttpClientAdapter(dio);

  return FileDownloadServiceImpl(dio);
});

