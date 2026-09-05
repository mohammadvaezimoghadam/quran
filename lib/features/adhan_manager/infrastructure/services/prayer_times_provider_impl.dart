import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/enums/prayer_type.dart';
import '../../../../core/services/prayer_times_provider/i_prayer_times_provider.dart';
import '../../../prayer_times/domain/repositories/prayer_times_repository.dart';
import '../../../prayer_times/application/controllers/prayer_times_controller.dart';

/// Implementation of [IPrayerTimesProvider] that connects the [adhan_manager]
/// feature to the [prayer_times] feature's calculation logic.
class PrayerTimesProviderImpl implements IPrayerTimesProvider {
  final PrayerTimesRepository _prayerTimesRepo;

  PrayerTimesProviderImpl(this._prayerTimesRepo);

  @override
  Future<Map<PrayerType, DateTime>> getTodayPrayerTimes() async {
    return _getPrayerTimesForDate(DateTime.now());
  }

  @override
  Future<Map<PrayerType, DateTime>> getTomorrowPrayerTimes() async {
    return _getPrayerTimesForDate(DateTime.now().add(const Duration(days: 1)));
  }

  Future<Map<PrayerType, DateTime>> _getPrayerTimesForDate(DateTime date) async {
    // 1. Get the user's saved city
    final cityResult = await _prayerTimesRepo.getSavedCity();
    
    return cityResult.when(
      (city) async {
        // 2. Calculate prayer times for that city and date
        final timesResult = await _prayerTimesRepo.getPrayerTimes(
          city: city,
          date: date,
        );

        return timesResult.when(
          (entity) {
            // 3. Map the calculated times to the required format
            return {
              PrayerType.fajr: entity.fajr,
              PrayerType.sunrise: entity.sunrise,
              PrayerType.dhuhr: entity.dhuhr,
              PrayerType.asr: entity.asr,
              PrayerType.sunset: entity.sunset,
              PrayerType.maghrib: entity.maghrib,
              PrayerType.isha: entity.isha,
              PrayerType.midnight: entity.midnight,
            };
          },
          (error) => <PrayerType, DateTime>{},
        );
      },
      (error) => <PrayerType, DateTime>{},
    );
  }
}

/// Riverpod provider for the implementation
final prayerTimesProviderImplProvider = Provider<IPrayerTimesProvider>((ref) {
  final repo = ref.watch(prayerTimesRepositoryProvider);
  return PrayerTimesProviderImpl(repo);
});
