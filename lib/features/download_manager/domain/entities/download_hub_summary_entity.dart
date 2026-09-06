import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_hub_summary_entity.freezed.dart';

/// Domain Entity representing the aggregated statistics of downloaded Quran resources
@freezed
abstract class DownloadHubSummaryEntity with _$DownloadHubSummaryEntity {
  const DownloadHubSummaryEntity._();

  const factory DownloadHubSummaryEntity({
    required int totalAudioStorageBytes,
    required String storagePath,
    required int downloadedQuranSurahs,
    @Default(114) int totalQuranSurahs,
    required String activeReciterName,
    int? activeReciterId,
    required int downloadedTranslationSurahs,
    @Default(114) int totalTranslationSurahs,
    required String activeTranslationReciterName,
    int? activeTranslationReciterId,
    required int downloadedTextTranslations,
    required int totalTextTranslations,
    required bool isWifiOnly,
  }) = _DownloadHubSummaryEntity;

  /// Formatted storage size for human-readable Persian presentation
  String get formattedStorageSize {
    if (totalAudioStorageBytes <= 0) return '۰ بایت';
    if (totalAudioStorageBytes < 1024) return '$totalAudioStorageBytes بایت';
    if (totalAudioStorageBytes < 1024 * 1024) {
      final kb = (totalAudioStorageBytes / 1024).toStringAsFixed(1);
      return '$kb کیلوبایت';
    }
    if (totalAudioStorageBytes < 1024 * 1024 * 1024) {
      final mb = (totalAudioStorageBytes / (1024 * 1024)).toStringAsFixed(1);
      return '$mb مگابایت';
    }
    final gb = (totalAudioStorageBytes / (1024 * 1024 * 1024)).toStringAsFixed(2);
    return '$gb گیگابایت';
  }
}
