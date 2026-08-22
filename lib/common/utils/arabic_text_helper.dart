import 'package:flutter/material.dart';

/// Helper utility for parsing and styling Arabic text, specifically for
/// separating Arabic letters from Tashkeel (diacritics/harakat) and applying
/// custom colors.
abstract final class ArabicTextHelper {
  /// Returns true if the given Unicode code point [rune] is a standard primary
  /// Arabic Tashkeel (haraka):
  ///
  ///   U+064B–U+0652  Standard Tashkeel (Fathah, Dammah, Kasrah,
  ///                   Tanween, Shaddah, Sukun)
  ///
  /// Note: Combining marks such as Superscript Alef (U+0670), Maddah, Hamza,
  /// and Quranic stop marks are intentionally excluded. In Uthmanic and Arabic
  /// fonts, those marks merge into single OpenType ligature glyphs with the
  /// base letter. Keeping them with the base color avoids splitting or bleeding
  /// base letter stems (e.g. Lam, Yaa).
  static bool isHarakaRune(int rune) {
    return rune >= 0x064B && rune <= 0x0652;
  }

  /// Parses a hex color string (e.g. '#FF4444', 'FF4444') into a [Color].
  static Color? parseHexColor(String? hexString) {
    if (hexString == null || hexString.trim().isEmpty) return null;
    var hex = hexString.trim().replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length == 8) {
      final v = int.tryParse(hex, radix: 16);
      if (v != null) return Color(v);
    }
    return null;
  }

  /// Returns true if [index] points to a Lam ('ل', U+0644) that is part of a
  /// Lam-Alef ligature sequence (e.g. لا, لأ, لإ, لآ, لٱ).
  static bool _isLamAlefSequence(int index, List<int> runes) {
    if (runes[index] != 0x0644) return false;
    int next = index + 1;
    while (next < runes.length && isHarakaRune(runes[next])) {
      next++;
    }
    if (next < runes.length) {
      final r = runes[next];
      return (r == 0x0627 || (r >= 0x0622 && r <= 0x0626) || r == 0x0671);
    }
    return false;
  }

  /// Returns true if the given Unicode code point [rune] is a Quranic annotation sign,
  /// pause mark, or small high/low auxiliary mark (e.g. Small Low Meem for Iqlab,
  /// Small High Stop marks, Small High Noon/Yaa, etc.).
  static bool isAnnotationOrPauseMark(int rune) {
    return (rune >= 0x0610 && rune <= 0x061A) ||
        (rune >= 0x06D6 && rune <= 0x06DC) ||
        (rune >= 0x06DF && rune <= 0x06E4) ||
        (rune >= 0x06E7 && rune <= 0x06E8) ||
        (rune >= 0x06EA && rune <= 0x06ED);
  }

  /// Strips Quranic annotation marks, pause signs, and small auxiliary marks
  /// (e.g. Small Low Meem for Iqlab, Small High Stop marks, etc.) to keep
  /// the Quranic text clean, modern, and uncluttered.
  static String removeAnnotationMarks(String text) {
    if (text.isEmpty) return text;
    final buf = StringBuffer();
    for (final rune in text.runes) {
      if (isAnnotationOrPauseMark(rune)) continue;
      buf.writeCharCode(rune);
    }
    return buf.toString();
  }

  /// Builds a flat list of [TextSpan]s from [text] where every base-letter
  /// run gets [baseColor] and every diacritics run gets [harakatColor].
  static List<TextSpan> buildColoredSpans({
    required String text,
    required TextStyle baseStyle,
    required Color baseColor,
    required Color harakatColor,
  }) {
    final sanitizedText = removeAnnotationMarks(text);
    if (sanitizedText.isEmpty) return const [];

    final spans = <TextSpan>[];
    final buf = StringBuffer();
    final runes = sanitizedText.runes.toList();

    // Remove text color to ensure foreground Paint takes full precedence
    final cleanedBaseStyle = baseStyle.copyWith(color: null);

    final baseStyleColored = cleanedBaseStyle.copyWith(
      foreground: Paint()..color = baseColor,
    );
    final harakatStyleColored = cleanedBaseStyle.copyWith(
      foreground: Paint()..color = harakatColor,
    );

    int lamAlefEndIndex = -1;
    bool prevWasHamzaLetter = false;
    bool currentIsHaraka = false;

    for (int i = 0; i < runes.length; i++) {
      final rune = runes[i];
      bool isHaraka = isHarakaRune(rune);
      final isHamzaLetter = (rune >= 0x0622 && rune <= 0x0626);

      // Check if a true Lam-Alef ligature starts at i
      if (rune == 0x0644 && _isLamAlefSequence(i, runes)) {
        int target = i + 1;
        while (target < runes.length && isHarakaRune(runes[target])) {
          target++;
        }
        if (target < runes.length) {
          target++; // Include Alef
        }
        while (target < runes.length && isHarakaRune(runes[target])) {
          target++; // Include harakat on Alef
        }
        lamAlefEndIndex = target;
      }

      // Force base color ONLY inside an actual Lam-Alef ligature or right after a Hamza letter
      if (i < lamAlefEndIndex || (isHaraka && prevWasHamzaLetter)) {
        isHaraka = false;
      }

      prevWasHamzaLetter = isHamzaLetter;

      if (i == 0) {
        currentIsHaraka = isHaraka;
      }

      if (isHaraka == currentIsHaraka) {
        buf.writeCharCode(rune);
      } else {
        if (buf.isNotEmpty) {
          spans.add(
            TextSpan(
              text: buf.toString(),
              style: currentIsHaraka ? harakatStyleColored : baseStyleColored,
            ),
          );
          buf.clear();
        }
        currentIsHaraka = isHaraka;
        buf.writeCharCode(rune);
      }
    }

    if (buf.isNotEmpty) {
      spans.add(
        TextSpan(
          text: buf.toString(),
          style: currentIsHaraka ? harakatStyleColored : baseStyleColored,
        ),
      );
    }

    return spans;
  }
}
