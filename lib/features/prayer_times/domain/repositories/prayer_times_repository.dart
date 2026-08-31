import 'package:multiple_result/multiple_result.dart';

import '../../../../common/exceptions/failure.dart';
import '../entities/city_entity.dart';
import '../entities/prayer_times_entity.dart';

/// Domain contract for prayer times & city management
abstract class PrayerTimesRepository {
  /// Calculates prayer times for a given city & date (with optional Hijri adjustment)
  Future<Result<PrayerTimesEntity, Failure>> getPrayerTimes({
    required CityEntity city,
    required DateTime date,
    int hijriAdjustment = 0,
  });

  /// Retrieves the saved selected city (defaults to Tehran if none saved)
  Future<Result<CityEntity, Failure>> getSavedCity();

  /// Saves user's selected city
  Future<Result<void, Failure>> saveCity(CityEntity city);

  /// Returns the list of major Iranian cities
  Future<Result<List<CityEntity>, Failure>> getIranianCities();

  /// Returns unique list of provinces in Iran
  Future<Result<List<String>, Failure>> getProvinces();

  /// Returns cities belonging to a specific province
  Future<Result<List<CityEntity>, Failure>> getCitiesByProvince(String province);

  /// Detects the user's current city & coordinates via GPS (returns null if permission denied or GPS off)
  Future<Result<CityEntity?, Failure>> getCurrentLocationCity();

  /// Retrieves the saved Hijri calendar adjustment (-2 to +2 days)
  Future<Result<int, Failure>> getSavedHijriAdjustment();

  /// Saves user's Hijri calendar adjustment (-2 to +2 days)
  Future<Result<void, Failure>> saveHijriAdjustment(int adjustmentDays);
}
