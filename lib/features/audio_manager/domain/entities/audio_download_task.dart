import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_download_task.freezed.dart';

enum DownloadTaskStatus {
  idle,
  downloading,
  paused,
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

extension AudioDownloadTaskSerialization on AudioDownloadTask {
  Map<String, dynamic> toJsonMap() => {
        'surahId': surahId,
        'reciterId': reciterId,
        'progress': progress,
        'status': status.name,
        'currentAyah': currentAyah,
        'totalAyahs': totalAyahs,
        'completedAyahs': completedAyahs,
        if (errorMessage != null) 'errorMessage': errorMessage,
      };

  static AudioDownloadTask fromJsonMap(Map<String, dynamic> map) {
    return AudioDownloadTask(
      surahId: (map['surahId'] as num).toInt(),
      reciterId: (map['reciterId'] as num).toInt(),
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      status: DownloadTaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DownloadTaskStatus.paused,
      ),
      currentAyah: (map['currentAyah'] as num?)?.toInt() ?? 0,
      totalAyahs: (map['totalAyahs'] as num?)?.toInt() ?? 0,
      completedAyahs: (map['completedAyahs'] as num?)?.toInt() ?? 0,
      errorMessage: map['errorMessage'] as String?,
    );
  }
}
