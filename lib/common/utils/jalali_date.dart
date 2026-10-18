import '../extensions/int_extension.dart';

/// Lightweight pure-Dart converter between Gregorian and Jalali (Solar Hijri / شمسی) calendar.
/// Based on the standard Roozbeh Pournader / Mohammad Toossi conversion algorithm.
class JalaliDate implements Comparable<JalaliDate> {
  final int year;
  final int month;
  final int day;

  const JalaliDate(this.year, this.month, this.day);

  /// Returns current date in Jalali.
  factory JalaliDate.now() => JalaliDate.fromDateTime(DateTime.now());

  /// Converts a standard Dart [DateTime] (Gregorian) to [JalaliDate].
  factory JalaliDate.fromDateTime(DateTime date) {
    final gYear = date.year;
    final gMonth = date.month;
    final gDay = date.day;

    const gDaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    final isLeapGregorian =
        (gYear % 4 == 0 && gYear % 100 != 0) || (gYear % 400 == 0);

    final gy = gYear - 1600;
    final gm = gMonth - 1;
    final gd = gDay - 1;

    var gDayNo = 365 * gy +
        ((gy + 3) ~/ 4) -
        ((gy + 99) ~/ 100) +
        ((gy + 399) ~/ 400);
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

  /// Converts this [JalaliDate] back to a Gregorian [DateTime].
  DateTime toDateTime() {
    final jy = year - 979;
    final jm = month - 1;
    final jd = day - 1;

    var jDayNo = 365 * jy + (jy ~/ 33) * 8 + ((jy % 33 + 3) ~/ 4);
    for (var i = 0; i < jm; ++i) {
      jDayNo += (i < 6) ? 31 : 30;
    }
    jDayNo += jd;

    var gDayNo = jDayNo + 79;
    var gy = 1600 + 400 * (gDayNo ~/ 146097);
    gDayNo %= 146097;

    var leap = true;
    if (gDayNo >= 36525) {
      gDayNo--;
      gy += 100 * (gDayNo ~/ 36524);
      gDayNo %= 36524;
      if (gDayNo >= 365) {
        gDayNo++;
      } else {
        leap = false;
      }
    }

    gy += 4 * (gDayNo ~/ 1461);
    gDayNo %= 1461;

    if (gDayNo >= 366) {
      leap = false;
      gDayNo--;
      gy += (gDayNo ~/ 365);
      gDayNo = gDayNo % 365;
    }

    const gDaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    var gm = 0;
    while (gm < 12) {
      final dim = (gm == 1 && leap) ? 29 : gDaysInMonth[gm];
      if (gDayNo < dim) break;
      gDayNo -= dim;
      gm++;
    }
    return DateTime(gy, gm + 1, gDayNo + 1);
  }

  /// Persian name of the Jalali month (فروردین ... اسفند).
  String get monthName {
    const months = [
      'فروردین',
      'اردیبهشت',
      'خرداد',
      'تیر',
      'مرداد',
      'شهریور',
      'مهر',
      'آبان',
      'آذر',
      'دی',
      'بهمن',
      'اسفند',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  /// Persian name of the weekday (شنبه ... جمعه).
  String get weekdayName {
    const names = {
      1: 'دوشنبه',
      2: 'سه‌شنبه',
      3: 'چهارشنبه',
      4: 'پنج‌شنبه',
      5: 'جمعه',
      6: 'شنبه',
      7: 'یکشنبه',
    };
    return names[toDateTime().weekday] ?? '';
  }

  /// Human-readable long format: «یکشنبه ۲۶ مهر ۱۴۰۵»
  String formatLong() {
    return '$weekdayName ${day.toPersianDigit()} $monthName ${year.toPersianDigit()}';
  }

  /// Determines whether the current Jalali year is a leap year (کبیسه).
  bool get isLeapYear {
    final a = year - (year > 0 ? 474 : 473);
    return ((a % 2820 + 474 + 38) * 682) % 2816 < 682;
  }

  /// Total days in the current Jalali month.
  int get daysInMonth {
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    return isLeapYear ? 30 : 29;
  }

  /// Standard short format formatted as YYYY/MM/DD with English digits.
  String format() {
    return '$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';
  }

  /// Standard short format formatted as YYYY/MM/DD with Persian digits.
  String formatFa() {
    final mStr = month < 10 ? '۰${month.toPersianDigit()}' : month.toPersianDigit();
    final dStr = day < 10 ? '۰${day.toPersianDigit()}' : day.toPersianDigit();
    return '${year.toPersianDigit()}/$mStr/$dStr';
  }

  @override
  int compareTo(JalaliDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JalaliDate &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ day.hashCode;

  @override
  String toString() => format();
}
