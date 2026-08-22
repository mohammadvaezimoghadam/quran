import '../../../common/constants/app_constants.dart';

abstract class AudioUrlHelper {
  /// Builds the direct EveryAyah MP3 CDN URL for a given ayah and reciter subfolder.
  /// Example output: https://everyayah.com/data/Parhizgar_48kbps/002255.mp3
  static String buildAyahUrl({
    required String subfolder,
    required int surahNumber,
    required int ayahNumber,
  }) {
    final surahStr = surahNumber.toString().padLeft(3, '0');
    final ayahStr = ayahNumber.toString().padLeft(3, '0');
    return '${AppConstants.everyAyahAudioBaseUrl}/$subfolder/$surahStr$ayahStr.mp3';
  }
}
