import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:multiple_result/multiple_result.dart';
import '../../../../common/exceptions/failure.dart';
import 'i_file_download_service.dart';

class FileDownloadServiceImpl implements IFileDownloadService {
  final Dio _dio;
  static const int _maxRetries = 3;

  FileDownloadServiceImpl(this._dio);

  @override
  Future<Result<File, Failure>> downloadFile({
    required String url,
    required String savePath,
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final file = File(savePath);

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      if (cancelToken?.isCancelled ?? false) {
        await _cleanupPartialFile(file);
        return const Error(
          Failure(message: 'دانلود توسط کاربر لغو شد.'),
        );
      }

      // Determine URL to use (Option 2):
      // Fallback between www.everyayah.com and everyayah.com over HTTPS.
      // Never downgrade to unencrypted HTTP, which gets intercepted in Iran to return HTML block pages.
      String currentUrl = url;
      if (url.contains('everyayah.com')) {
        if (attempt == 1) {
          currentUrl = url.replaceFirst('https://everyayah.com', 'https://www.everyayah.com');
        } else if (attempt == 2) {
          currentUrl = url.replaceFirst('https://www.everyayah.com', 'https://everyayah.com');
        } else {
          currentUrl = url.replaceFirst('https://everyayah.com', 'https://www.everyayah.com');
        }
      }

      try {
        developer.log(
          'Starting download (attempt $attempt/$_maxRetries): $currentUrl -> $savePath',
          name: 'FileDownload',
        );

        // Remove any 0-byte or corrupted partial file before downloading
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (_) {}
        }

        await _dio.download(
          currentUrl,
          savePath,
          onReceiveProgress: onProgress,
          cancelToken: cancelToken,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            validateStatus: (status) => status != null && status < 400,
          ),
        );

        if (await file.exists()) {
          final fileSize = await file.length();
          final isValid = await _isAudioFileValid(file, fileSize);
          if (isValid) {
            developer.log(
              'Download success: $savePath ($fileSize bytes)',
              name: 'FileDownload',
            );
            return Success(file);
          } else {
            developer.log(
              'Download attempt $attempt produced invalid audio/HTML block file ($fileSize bytes). Deleting.',
              name: 'FileDownload',
            );
            await _cleanupPartialFile(file);
            throw DioException(
              requestOptions: RequestOptions(path: currentUrl),
              type: DioExceptionType.badResponse,
              error:
                  'فایل دریافتی معتبر نیست (احتمالاً صفحه فیلترینگ یا خطای شبکه با حجم $fileSize بایت)',
            );
          }
        } else {
          developer.log(
            'Download attempt $attempt finished but file does not exist or is 0 bytes',
            name: 'FileDownload',
          );
          if (attempt == _maxRetries) {
            await _cleanupPartialFile(file);
            return const Error(
              Failure(
                message:
                    'امکان ذخیره فایل وجود ندارد. لطفاً فضای خالی و دسترسی‌های دستگاه را بررسی کنید.',
              ),
            );
          }
        }
      } on DioException catch (e) {
        developer.log(
          'Download attempt $attempt failed (DioException): $currentUrl, error: ${e.type} - ${e.message}',
          name: 'FileDownload',
          error: e,
        );

        await _cleanupPartialFile(file);

        if (cancelToken?.isCancelled ?? false) {
          return const Error(
            Failure(message: 'دانلود توسط کاربر لغو شد.'),
          );
        }

        if (attempt == _maxRetries) {
          return Error(
            Failure(
              message:
                  'ارتباط با سرور دانلود برقرار نشد. لطفاً وضعیت اینترنت خود را بررسی کرده و مجدداً تلاش کنید.',
              exception: e,
            ),
          );
        }

        // Exponential backoff before next retry
        await Future.delayed(Duration(milliseconds: 400 * attempt));
      } catch (e) {
        developer.log(
          'Download attempt $attempt failed (Exception): $currentUrl, error: $e',
          name: 'FileDownload',
          error: e,
        );

        await _cleanupPartialFile(file);

        if (cancelToken?.isCancelled ?? false) {
          return const Error(
            Failure(message: 'دانلود توسط کاربر لغو شد.'),
          );
        }

        if (attempt == _maxRetries) {
          return Error(
            Failure(
              message: 'در فرآیند دانلود خطایی رخ داد. لطفاً مجدداً تلاش کنید.',
              exception: Exception(e.toString()),
            ),
          );
        }

        await Future.delayed(Duration(milliseconds: 400 * attempt));
      }
    }

    await _cleanupPartialFile(file);
    return const Error(
      Failure(message: 'دانلود فایل پس از چند تلاش ناموفق بود.'),
    );
  }

  Future<void> _cleanupPartialFile(File file) async {
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
    }
  }

  /// Option 1: Validates audio file magic bytes and ensures it is not an HTML block/error page
  Future<bool> _isAudioFileValid(File file, int fileSize) async {
    // A real Quran ayah audio MP3 is at least ~5 KB.
    // HTML block pages / captive portals in Iran are typically 3-4 KB.
    if (fileSize < 5000) {
      return false;
    }

    try {
      final raf = await file.open(mode: FileMode.read);
      try {
        final header = await raf.read(16);
        if (header.isEmpty) return false;

        // Check if starts with HTML or JSON text: '<' (0x3C) or '{' (0x7B)
        if (header[0] == 0x3C || header[0] == 0x7B) {
          return false;
        }

        // Check ID3 tag: 'ID3' (0x49, 0x44, 0x33)
        if (header.length >= 3 &&
            header[0] == 0x49 &&
            header[1] == 0x44 &&
            header[2] == 0x33) {
          return true;
        }

        // Check MPEG Audio Frame Sync: 11 consecutive 1 bits (0xFF followed by 0xE0..0xFF)
        if (header.length >= 2 &&
            header[0] == 0xFF &&
            (header[1] & 0xE0) == 0xE0) {
          return true;
        }

        // Check RIFF / WAV
        if (header.length >= 4 &&
            header[0] == 0x52 &&
            header[1] == 0x49 &&
            header[2] == 0x46 &&
            header[3] == 0x46) {
          return true;
        }

        // Check OggS
        if (header.length >= 4 &&
            header[0] == 0x4F &&
            header[1] == 0x67 &&
            header[2] == 0x67 &&
            header[3] == 0x53) {
          return true;
        }

        // If not explicitly HTML/JSON and larger than 8 KB, allow it
        return fileSize > 8000;
      } finally {
        await raf.close();
      }
    } catch (_) {
      return false;
    }
  }
}
