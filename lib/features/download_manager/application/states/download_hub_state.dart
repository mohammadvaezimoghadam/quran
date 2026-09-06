import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_hub_state.freezed.dart';

@freezed
abstract class DownloadHubState with _$DownloadHubState {
  const DownloadHubState._();

  const factory DownloadHubState({
    @Default(0) int totalAudioStorageBytes,
    @Default('') String storagePath,
    @Default(0) int downloadedQuranSurahs,
    @Default(114) int totalQuranSurahs,
    @Default('') String activeReciterName,
    int? activeReciterId,
    @Default(0) int downloadedTranslationSurahs,
    @Default(114) int totalTranslationSurahs,
    @Default('') String activeTranslationReciterName,
    int? activeTranslationReciterId,
    @Default(0) int downloadedTextTranslations,
    @Default(0) int totalTextTranslations,
    @Default(false) bool isWifiOnly,
    @Default(true) bool isLoading,
  }) = _DownloadHubState;

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
