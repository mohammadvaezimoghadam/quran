import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/city_entity.dart';

/// Infrastructure data source for loading cities asset & persisting user preferences
class PrayerTimesLocalDataSource {
  static const String _keySelectedCityId = 'prayer_times_selected_city_id';
  static const String _keyHijriAdjustment = 'prayer_times_hijri_adjustment';
  static const String _assetCitiesJson = 'assets/json/iran_cities.json';

  final SharedPreferences _prefs;

  PrayerTimesLocalDataSource(this._prefs);

  /// Loads the list of Iranian cities from the local JSON asset
  Future<List<CityEntity>> getIranianCities() async {
    try {
      final jsonString = await rootBundle.loadString(_assetCitiesJson);
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      return jsonList
          .map((item) => CityEntity.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Fallback default city (Tehran) if asset loading fails
      return [
        const CityEntity(
          id: 'tehran',
          namePersian: 'تهران',
          nameEnglish: 'Tehran',
          province: 'تهران',
          latitude: 35.6892,
          longitude: 51.3890,
          isDefault: true,
          isGpsLocation: false,
        ),
      ];
    }
  }

  /// Gets saved city ID or returns default 'tehran'
  String getSavedCityId() {
    return _prefs.getString(_keySelectedCityId) ?? 'tehran';
  }

  /// Saves the selected city ID
  Future<void> saveCityId(String cityId) async {
    await _prefs.setString(_keySelectedCityId, cityId);
  }

  /// Gets saved Hijri adjustment in days (default 0)
  int getSavedHijriAdjustment() {
    return _prefs.getInt(_keyHijriAdjustment) ?? 0;
  }

  /// Saves Hijri adjustment in days
  Future<void> saveHijriAdjustment(int days) async {
    await _prefs.setInt(_keyHijriAdjustment, days);
  }
}
