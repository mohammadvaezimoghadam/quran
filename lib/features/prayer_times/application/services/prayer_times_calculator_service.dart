import '../../../../common/extensions/string_extension.dart';

/// Helper service for formatting prayer times and duration countdowns
class PrayerTimesCalculatorService {
  const PrayerTimesCalculatorService();

  /// Formats duration into Persian digital format (e.g. 02:14:45 or 14:45)
  static String formatRemainingDuration(Duration duration) {
    if (duration.isNegative) return '00:00:00';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final hoursStr = hours.toString().padLeft(2, '0').toPersianDigit();
    final minutesStr = minutes.toString().padLeft(2, '0').toPersianDigit();
    final secondsStr = seconds.toString().padLeft(2, '0').toPersianDigit();

    if (hours > 0) {
      return '$hoursStr:$minutesStr:$secondsStr';
    } else {
      return '$minutesStr:$secondsStr';
    }
  }

  /// Formats DateTime time of day into Persian digital format (e.g. 05:20)
  static String formatTimeString(DateTime time) {
    final hourStr = time.hour.toString().padLeft(2, '0').toPersianDigit();
    final minuteStr = time.minute.toString().padLeft(2, '0').toPersianDigit();
    return '$hourStr:$minuteStr';
  }
}
