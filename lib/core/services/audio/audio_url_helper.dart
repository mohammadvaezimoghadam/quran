import '../../../common/constants/app_constants.dart';

abstract class AudioUrlHelper {
  /// Builds the direct EveryAyah MP3 CDN URL for a given ayah and reciter subfolder.
  /// Example output: https://www.everyayah.com/data/Parhizgar_48kbps/002255.mp3
  static String buildAyahUrl({
    required String subfolder,
    required int surahNumber,
    required int ayahNumber,
  }) {
    final surahStr = surahNumber.toString().padLeft(3, '0');
    final ayahStr = ayahNumber.toString().padLeft(3, '0');
    if (subfolder.startsWith('http://') || subfolder.startsWith('https://')) {
      return subfolder
          .replaceAll('{surah}', surahNumber.toString())
          .replaceAll('{surah_2digit}', surahNumber.toString().padLeft(2, '0'))
          .replaceAll('{surah_3digit}', surahStr)
          .replaceAll('{ayah}', ayahNumber.toString())
          .replaceAll('{ayah_3digit}', ayahStr);
    }
    return '${AppConstants.everyAyahAudioBaseUrl}/$subfolder/$surahStr$ayahStr.mp3';
  }
}
