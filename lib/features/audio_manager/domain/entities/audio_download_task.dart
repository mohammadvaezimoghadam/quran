import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_download_task.freezed.dart';

enum DownloadTaskStatus {
  idle,
  downloading,
  completed,
  failed,
  canceled,
}

@freezed
abstract class AudioDownloadTask with _$AudioDownloadTask {
  const factory AudioDownloadTask({
    required int surahId,
    required int reciterId,
    @Default(0.0) double progress,
    @Default(DownloadTaskStatus.idle) DownloadTaskStatus status,
    @Default(0) int currentAyah,
    @Default(0) int totalAyahs,
    @Default(0) int completedAyahs,
    String? errorMessage,
  }) = _AudioDownloadTask;
}
