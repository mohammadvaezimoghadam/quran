/// Lightweight pure-Dart converter for Gregorian to Jalali (Solar Hijri / شمسی) calendar.
/// Based on the standard Roozbeh Pournader / Mohammad Toossi conversion algorithm.
class JalaliDate {
  final int year;
  final int month;
  final int day;

  const JalaliDate(this.year, this.month, this.day);

  /// Converts a standard Dart [DateTime] (Gregorian) to [JalaliDate].
  factory JalaliDate.fromDateTime(DateTime date) {
    final gYear = date.year;
    final gMonth = date.month;
    final gDay = date.day;

    const gDaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    final isLeapGregorian = (gYear % 4 == 0 && gYear % 100 != 0) || (gYear % 400 == 0);

    final gy = gYear - 1600;
    final gm = gMonth - 1;
    final gd = gDay - 1;

    var gDayNo = 365 * gy + ((gy + 3) ~/ 4) - ((gy + 99) ~/ 100) + ((gy + 399) ~/ 400);
    for (var i = 0; i < gm; ++i) {
      if (i == 1 && isLeapGregorian) {
        gDayNo += 29;
      } else {
        gDayNo += gDaysInMonth[i];
      }
    }
    gDayNo += gd;

    var jDayNo = gDayNo - 79;

    final jNp = jDayNo ~/ 12053;
    jDayNo %= 12053;

    var jy = 979 + 33 * jNp + 4 * (jDayNo ~/ 1461);
    jDayNo %= 1461;

    if (jDayNo >= 366) {
      jy += ((jDayNo - 1) ~/ 365);
      jDayNo = (jDayNo - 1) % 365;
    }

    final int jm;
    final int jd;
    if (jDayNo < 186) {
      jm = 1 + (jDayNo ~/ 31);
      jd = 1 + (jDayNo % 31);
    } else {
      jm = 7 + ((jDayNo - 186) ~/ 30);
      jd = 1 + ((jDayNo - 186) % 30);
    }

    return JalaliDate(jy, jm, jd);
  }

  /// Returns standard Shamsi date string formatted as YYYY/MM/DD.
  String format() {
    return '$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';
  }

  @override
  String toString() => format();
}
