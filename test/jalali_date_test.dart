import 'package:flutter_test/flutter_test.dart';
import 'package:quran/common/utils/jalali_date.dart';

void main() {
  group('JalaliDate conversion tests', () {
    test('converts known Gregorian dates to correct Shamsi dates', () {
      // 2024-03-20 -> 1403/01/01 (Nowruz leap year)
      final nowruz1403 = JalaliDate.fromDateTime(DateTime(2024, 3, 20));
      expect(nowruz1403.year, 1403);
      expect(nowruz1403.month, 1);
      expect(nowruz1403.day, 1);
      expect(nowruz1403.format(), '1403/01/01');

      // 2024-09-20 -> 1403/06/30
      final shahrivar1403 = JalaliDate.fromDateTime(DateTime(2024, 9, 20));
      expect(shahrivar1403.year, 1403);
      expect(shahrivar1403.month, 6);
      expect(shahrivar1403.day, 30);
      expect(shahrivar1403.format(), '1403/06/30');

      // 2026-09-20 -> 1405/06/29
      final date2026 = JalaliDate.fromDateTime(DateTime(2026, 9, 20));
      expect(date2026.year, 1405);
      expect(date2026.month, 6);
      expect(date2026.day, 29);
      expect(date2026.format(), '1405/06/29');
    });
  });
}
