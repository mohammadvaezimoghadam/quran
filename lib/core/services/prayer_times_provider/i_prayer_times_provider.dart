import '../../../common/enums/prayer_type.dart';

/// Contract for providing prayer times to any consumer (e.g., adhan_manager).
/// This interface prevents direct coupling between the adhan feature and 
/// the prayer_times calculation logic.
abstract interface class IPrayerTimesProvider {
  /// Returns prayer times for today as a map of PrayerType → DateTime.
  Future<Map<PrayerType, DateTime>> getTodayPrayerTimes();

  /// Returns prayer times for tomorrow.
  Future<Map<PrayerType, DateTime>> getTomorrowPrayerTimes();
}
