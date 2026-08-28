import 'dart:io';
import 'package:dio/dio.dart';
import 'package:multiple_result/multiple_result.dart';
import '../../../../common/exceptions/failure.dart';

abstract class IFileDownloadService {
  /// Downloads a file from the given [url] to the specified [savePath].
  /// Provides progress updates through the optional [onProgress] callback.
  Future<Result<File, Failure>> downloadFile({
    required String url,
    required String savePath,
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  });
}
