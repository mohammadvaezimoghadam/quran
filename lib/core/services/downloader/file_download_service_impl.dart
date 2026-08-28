import 'dart:io';
import 'package:dio/dio.dart';
import 'package:multiple_result/multiple_result.dart';
import '../../../../common/exceptions/failure.dart';
import 'i_file_download_service.dart';

class FileDownloadServiceImpl implements IFileDownloadService {
  final Dio _dio;

  FileDownloadServiceImpl(this._dio);

  @override
  Future<Result<File, Failure>> downloadFile({
    required String url,
    required String savePath,
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      final file = File(savePath);
      if (await file.exists()) {
        return Success(file);
      } else {
        return const Error(Failure(
          message: 'امکان ذخیره فایل وجود ندارد. لطفاً فضای خالی و دسترسی‌های دستگاه را بررسی کنید.',
        ));
      }
    } on DioException catch (e) {
      final file = File(savePath);
      if (await file.exists()) {
        await file.delete();
      }
      return Error(Failure(
        message: 'ارتباط با سرور قطع شد. لطفاً وضعیت اینترنت خود را بررسی کنید.',
        exception: e,
      ));
    } catch (e) {
      // In case of error (e.g. user cancelled), ensure we don't leave a corrupted partial file
      final file = File(savePath);
      if (await file.exists()) {
        await file.delete();
      }
      return Error(Failure(
        message: 'در فرآیند دانلود خطایی رخ داد. لطفاً مجدداً تلاش کنید.',
        exception: Exception(e.toString()),
      ));
    }
  }
}
