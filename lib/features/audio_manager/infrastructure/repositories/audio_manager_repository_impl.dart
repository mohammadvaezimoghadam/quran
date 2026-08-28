import 'dart:io';
import 'package:multiple_result/multiple_result.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../common/exceptions/failure.dart';
import '../../../../core/services/audio_storage/i_audio_storage_service.dart';
import '../../domain/repositories/i_audio_manager_repository.dart';

class AudioManagerRepositoryImpl implements IAudioManagerRepository {
  final IAudioStorageService _audioStorageService;

  AudioManagerRepositoryImpl(this._audioStorageService);

  Future<Directory> _getReciterDirectory(int reciterId) async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/audio_cache/reciter_$reciterId');
  }

  @override
  Future<Result<int, Failure>> getReciterAudioSize(int reciterId) async {
    try {
      final dir = await _getReciterDirectory(reciterId);
      if (!await dir.exists()) {
        return const Success(0);
      }

      int totalSize = 0;
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return Success(totalSize);
    } catch (e) {
      return Error(Failure(
        message: 'خطا در محاسبه حجم فایل‌ها',
        exception: Exception(e.toString()),
      ));
    }
  }

  @override
  Future<Result<void, Failure>> deleteAllAudioForReciter(int reciterId) async {
    try {
      final dir = await _getReciterDirectory(reciterId);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }

      // We also need to unmark all surahs in the database for this reciter
      final downloadedSurahs = _audioStorageService.getDownloadedSurahsForReciter(reciterId);
      for (final surahId in downloadedSurahs) {
        await _audioStorageService.unmarkSurahAsDownloaded(reciterId, surahId);
      }

      return const Success(null);
    } catch (e) {
      return Error(Failure(
        message: 'خطا در حذف فایل‌های قاری',
        exception: Exception(e.toString()),
      ));
    }
  }

  @override
  Future<Result<void, Failure>> deleteSurahAudio({
    required int reciterId,
    required int surahId,
  }) async {
    try {
      final dirPath = await _audioStorageService.getSurahSaveDirectory(
        reciterId: reciterId,
        surahId: surahId,
      );
      final dir = Directory(dirPath);
      
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      
      // Unmark in database
      await _audioStorageService.unmarkSurahAsDownloaded(reciterId, surahId);
      
      return const Success(null);
    } catch (e) {
      return Error(Failure(
        message: 'خطا در حذف فایل‌های سوره',
        exception: Exception(e.toString()),
      ));
    }
  }
}
