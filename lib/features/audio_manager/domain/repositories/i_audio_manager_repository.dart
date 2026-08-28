import 'package:multiple_result/multiple_result.dart';
import '../../../../common/exceptions/failure.dart';

abstract class IAudioManagerRepository {
  /// Calculate total size (in bytes) of downloaded audio for a specific reciter.
  Future<Result<int, Failure>> getReciterAudioSize(int reciterId);

  /// Delete all audio files for a specific reciter.
  Future<Result<void, Failure>> deleteAllAudioForReciter(int reciterId);

  /// Delete audio files for a specific Surah and Reciter.
  Future<Result<void, Failure>> deleteSurahAudio({
    required int reciterId,
    required int surahId,
  });
}
