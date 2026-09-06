import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'i_file_download_service.dart';
import 'file_download_service_impl.dart';

/// Provider for the FileDownloadService with a dedicated clean Dio instance
final fileDownloadServiceProvider = Provider<IFileDownloadService>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );
  return FileDownloadServiceImpl(dio);
});
