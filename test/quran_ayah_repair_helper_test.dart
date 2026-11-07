import 'package:flutter_test/flutter_test.dart';
import 'package:quran/common/utils/quran_ayah_repair_helper.dart';

void main() {
  test('QuranAyahRepairHelper repairs 6:24 with 100% clean text', () {
    const rawBad =
        'ٱنظُرْ كَيْفَ كَذَبُوا۟ عَلَىٰٓ أ\uFFFD\uFFFDنفُسِهِمْ ۚ وَضَلَّ عَنْهُم مَّا كَانُوا۟ يَفْتَرُونَ';
    final repaired = QuranAyahRepairHelper.getRepairedText(6, 24, rawBad);

    expect(repaired.contains('\uFFFD'), isFalse);
    expect(repaired, contains('أَنفُسِهِمْ'));
  });

  test('QuranAyahRepairHelper repairs 2:38 correctly', () {
    const rawBad = '...وَلَا هُمْ يَ\uFFFDْزَنُونَ';
    final repaired = QuranAyahRepairHelper.getRepairedText(2, 38, rawBad);

    expect(repaired.contains('\uFFFD'), isFalse);
    expect(repaired, contains('يَحْزَنُونَ'));
  });

  test('QuranAyahRepairHelper leaves healthy ayahs untouched', () {
    const healthy = 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ';
    final result = QuranAyahRepairHelper.getRepairedText(1, 2, healthy);

    expect(result, equals(healthy));
  });
}
