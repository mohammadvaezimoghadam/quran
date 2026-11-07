import 'package:flutter_test/flutter_test.dart';
import 'package:quran/common/utils/arabic_text_helper.dart';
import 'package:quran/common/utils/sajdah_helper.dart';

void main() {
  group('SajdahHelper tests', () {
    test('identifies all 4 Wajib Sajdah verses', () {
      expect(SajdahHelper.getSajdahType(32, 15), equals(SajdahType.wajib));
      expect(SajdahHelper.getSajdahType(41, 38), equals(SajdahType.wajib));
      expect(SajdahHelper.getSajdahType(53, 62), equals(SajdahType.wajib));
      expect(SajdahHelper.getSajdahType(96, 19), equals(SajdahType.wajib));

      expect(SajdahHelper.isWajib(32, 15), isTrue);
      expect(SajdahHelper.hasSajdah(32, 15), isTrue);
    });

    test('identifies Mustahabb Sajdah verses', () {
      expect(SajdahHelper.getSajdahType(7, 206), equals(SajdahType.mustahabb));
      expect(SajdahHelper.getSajdahType(13, 15), equals(SajdahType.mustahabb));
      expect(SajdahHelper.getSajdahType(84, 21), equals(SajdahType.mustahabb));

      expect(SajdahHelper.isWajib(7, 206), isFalse);
      expect(SajdahHelper.hasSajdah(7, 206), isTrue);
    });

    test('identifies regular verses as none', () {
      expect(SajdahHelper.getSajdahType(1, 1), equals(SajdahType.none));
      expect(SajdahHelper.getSajdahType(2, 255), equals(SajdahType.none));
      expect(SajdahHelper.hasSajdah(1, 1), isFalse);
    });
  });

  group('Pause Marks filtering tests', () {
    const textWithPause = 'ٱلَّذِينَ ءَامَنُوا۟ ۖ وَعَمِلُوا۟ ۗ ٱلصَّـٰلِحَـٰتِ ۚ';

    test('retains pause marks when keepPauseMarks is true', () {
      final result = ArabicTextHelper.removeAnnotationMarks(
        textWithPause,
        keepPauseMarks: true,
      );
      expect(result.contains('ۖ'), isTrue);
      expect(result.contains('ۗ'), isTrue);
      expect(result.contains('ۚ'), isTrue);
    });

    test('strips pause marks when keepPauseMarks is false', () {
      final result = ArabicTextHelper.removeAnnotationMarks(
        textWithPause,
        keepPauseMarks: false,
      );
      expect(result.contains('ۖ'), isFalse);
      expect(result.contains('ۗ'), isFalse);
      expect(result.contains('ۚ'), isFalse);
      expect(result, contains('ٱلَّذِينَ'));
    });
  });
}

