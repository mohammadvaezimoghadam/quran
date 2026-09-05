import 'package:freezed_annotation/freezed_annotation.dart';

part 'adhan_download_state.freezed.dart';

@freezed
abstract class AdhanDownloadState with _$AdhanDownloadState {
  const factory AdhanDownloadState({
    /// Map of moezzinId -> progress (0.0 to 1.0)
    @Default({}) Map<String, double> downloadProgresses,
    
    /// Map of moezzinId -> isDownloading
    @Default({}) Map<String, bool> isDownloading,
    
    /// Map of moezzinId -> error message if any
    @Default({}) Map<String, String> downloadErrors,
  }) = _AdhanDownloadState;
}
