import '../../features/quran_reader/domain/entities/ayah_entity.dart';
import 'int_extension.dart';

extension AyahEntityShareHelper on AyahEntity {
  /// Formats the Ayah for copying to clipboard or sharing.
  /// Includes Arabic text, translation (if available), and reference.
  String toShareableText({required String surahName}) {
    final buffer = StringBuffer();
    final persianAyahNumber = ayahNumber.toPersianDigit();
    
    // 1. Arabic Text with Ayah number
    buffer.writeln('$arabicText ﴿$persianAyahNumber﴾');
    
    // 2. Translation (if available) with Ayah number
    if (translationText != null && translationText!.isNotEmpty) {
      buffer.writeln(); // Empty line for separation
      buffer.writeln('$translationText ﴿$persianAyahNumber﴾');
    }
    
    return buffer.toString().trim();
  }
}
