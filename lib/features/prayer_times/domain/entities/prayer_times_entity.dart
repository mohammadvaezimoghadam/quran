import 'package:freezed_annotation/freezed_annotation.dart';

import 'city_entity.dart';

part 'prayer_times_entity.freezed.dart';

/// Enum representing Islamic Prayer & Astronomical timings
enum PrayerType {
  fajr('صبح'),
  sunrise('طلوع'),
  dhuhr('ظهر'),
  asr('عصر'),
  sunset('غروب'),
  maghrib('مغرب'),
  isha('عشاء'),
  midnight('نیمه‌شب');

  final String titleFa;
  const PrayerType(this.titleFa);
}

/// Domain entity holding calculated prayer timings & triple calendar dates
@freezed
abstract class PrayerTimesEntity with _$PrayerTimesEntity {
  const factory PrayerTimesEntity({
    required CityEntity city,
    required DateTime date,
    required String shamsiDate,
    required String hijriDate,
    required DateTime fajr,
    required DateTime sunrise,
    required DateTime dhuhr,
    required DateTime asr,
    required DateTime sunset,
    required DateTime maghrib,
    required DateTime isha,
    required DateTime midnight,
  }) = _PrayerTimesEntity;
}

extension PrayerTimesEntityX on PrayerTimesEntity {
  /// Returns the time for a specific prayer type
  DateTime getTimeForType(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return fajr;
      case PrayerType.sunrise:
        return sunrise;
      case PrayerType.dhuhr:
        return dhuhr;
      case PrayerType.asr:
        return asr;
      case PrayerType.sunset:
        return sunset;
      case PrayerType.maghrib:
        return maghrib;
      case PrayerType.isha:
        return isha;
      case PrayerType.midnight:
        return midnight;
    }
  }

  /// Determines the next upcoming prayer type based on current time
  PrayerType getNextPrayerType([DateTime? now]) {
    final currentTime = now ?? DateTime.now();
    if (currentTime.isBefore(fajr)) return PrayerType.fajr;
    if (currentTime.isBefore(sunrise)) return PrayerType.sunrise;
    if (currentTime.isBefore(dhuhr)) return PrayerType.dhuhr;
    if (currentTime.isBefore(asr)) return PrayerType.asr;
    if (currentTime.isBefore(sunset)) return PrayerType.sunset;
    if (currentTime.isBefore(maghrib)) return PrayerType.maghrib;
    if (currentTime.isBefore(isha)) return PrayerType.isha;
    if (currentTime.isBefore(midnight)) return PrayerType.midnight;
    return PrayerType.fajr;
  }

  /// Returns the DateTime of the next upcoming prayer
  DateTime getNextPrayerTime([DateTime? now]) {
    final type = getNextPrayerType(now);
    final currentTime = now ?? DateTime.now();
    final time = getTimeForType(type);
    if (time.isBefore(currentTime)) {
      return time.add(const Duration(days: 1));
    }
    return time;
  }

  /// Returns remaining Duration until next prayer
  Duration getTimeRemainingToNextPrayer([DateTime? now]) {
    final nextTime = getNextPrayerTime(now);
    final currentTime = now ?? DateTime.now();
    final remaining = nextTime.difference(currentTime);
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
