import '../entities/khatm_enums.dart';

/// Calendar & schedule generator for Khatm sessions.
class KhatmDateEngine {
  /// Generates a list of [DateTime] targets corresponding to each session index.
  ///
  /// - [startDate]: Starting reference date.
  /// - [sessionCount]: Total number of sessions to generate.
  /// - [cadence]: Frequency of sessions (daily, everyOtherDay, weekly, customWeekdays).
  /// - [selectedWeekdays]: 1-based ISO weekday integers (1 = Monday ... 7 = Sunday)
  ///   used when [cadence] is [KhatmCadence.customWeekdays].
  static List<DateTime> generateSessionDates({
    required DateTime startDate,
    required int sessionCount,
    required KhatmCadence cadence,
    List<int> selectedWeekdays = const [],
  }) {
    if (sessionCount <= 0) return const [];

    final dates = <DateTime>[];
    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);

    // If custom weekdays are selected, ensure start date snaps to the first allowed weekday
    if (cadence == KhatmCadence.customWeekdays && selectedWeekdays.isNotEmpty) {
      while (!selectedWeekdays.contains(current.weekday)) {
        current = DateTime(current.year, current.month, current.day + 1);
      }
    }

    for (int i = 0; i < sessionCount; i++) {
      dates.add(current);

      switch (cadence) {
        case KhatmCadence.daily:
          current = DateTime(current.year, current.month, current.day + 1);
          break;
        case KhatmCadence.everyOtherDay:
          current = DateTime(current.year, current.month, current.day + 2);
          break;
        case KhatmCadence.weekly:
          current = DateTime(current.year, current.month, current.day + 7);
          break;
        case KhatmCadence.customWeekdays:
          current = _nextSelectedWeekday(current, selectedWeekdays);
          break;
      }
    }

    return dates;
  }

  /// Calculates the exact ending date for a Khatm plan.
  static DateTime calculateEndDate({
    required DateTime startDate,
    required int sessionCount,
    required KhatmCadence cadence,
    List<int> selectedWeekdays = const [],
  }) {
    final dates = generateSessionDates(
      startDate: startDate,
      sessionCount: sessionCount,
      cadence: cadence,
      selectedWeekdays: selectedWeekdays,
    );
    if (dates.isEmpty) {
      return DateTime(startDate.year, startDate.month, startDate.day);
    }
    return dates.last;
  }

  static DateTime _nextSelectedWeekday(DateTime current, List<int> weekdays) {
    if (weekdays.isEmpty) {
      return DateTime(current.year, current.month, current.day + 1);
    }
    var next = DateTime(current.year, current.month, current.day + 1);
    for (int i = 0; i < 7; i++) {
      if (weekdays.contains(next.weekday)) return next;
      next = DateTime(next.year, next.month, next.day + 1);
    }
    return next;
  }
}
