import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/enums/prayer_type.dart';
import '../../../../core/data/local/preferences/preferences_keys.dart';
import '../../domain/repositories/adhan_settings_repository.dart';

/// SharedPreferences implementation of [AdhanSettingsRepository].
class AdhanSettingsRepositoryImpl implements AdhanSettingsRepository {
  final SharedPreferences _prefs;

  AdhanSettingsRepositoryImpl(this._prefs);

  @override
  bool isAdhanEnabled(PrayerType type) {
    final key = _getEnabledKeyForType(type);
    if (key == null) return false;
    // Default to false if not set
    return _prefs.getBool(key) ?? false;
  }

  @override
  Future<void> setAdhanEnabled(PrayerType type, bool enabled) async {
    final key = _getEnabledKeyForType(type);
    if (key != null) {
      await _prefs.setBool(key, enabled);
    }
  }

  @override
  String getMoezzinId(PrayerType type) {
    final key = _getMoezzinKeyForType(type);
    if (key == null) return 'ghalvash'; // Default fallback
    return _prefs.getString(key) ?? 'ghalvash';
  }

  @override
  Future<void> setMoezzinId(PrayerType type, String moezzinId) async {
    final key = _getMoezzinKeyForType(type);
    if (key != null) {
      await _prefs.setString(key, moezzinId);
    }
  }

  @override
  int getPreAlertMinutes() {
    return _prefs.getInt(PreferencesKeys.adhanPreAlertMinutes) ?? 0;
  }

  @override
  Future<void> setPreAlertMinutes(int minutes) async {
    await _prefs.setInt(PreferencesKeys.adhanPreAlertMinutes, minutes);
  }

  @override
  bool isAdhanGloballyEnabled() {
    // Default to false for first time
    return _prefs.getBool(PreferencesKeys.adhanGlobalEnabled) ?? false;
  }

  @override
  Future<void> setAdhanGloballyEnabled(bool enabled) async {
    await _prefs.setBool(PreferencesKeys.adhanGlobalEnabled, enabled);
  }

  // --- Advanced Settings ---

  @override
  int getVolumeLevel() => _prefs.getInt(PreferencesKeys.adhanVolume) ?? 100;

  @override
  Future<void> setVolumeLevel(int volume) async {
    await _prefs.setInt(PreferencesKeys.adhanVolume, volume);
  }

  @override
  bool isVibrationEnabled() => _prefs.getBool(PreferencesKeys.adhanVibration) ?? false;

  @override
  Future<void> setVibrationEnabled(bool enabled) async {
    await _prefs.setBool(PreferencesKeys.adhanVibration, enabled);
  }

  @override
  bool isPlayInSilentModeEnabled() => _prefs.getBool(PreferencesKeys.adhanPlayInSilent) ?? false;

  @override
  Future<void> setPlayInSilentModeEnabled(bool enabled) async {
    await _prefs.setBool(PreferencesKeys.adhanPlayInSilent, enabled);
  }

  @override
  bool isAscendingVolumeEnabled() => _prefs.getBool(PreferencesKeys.adhanAscendingVolume) ?? false;

  @override
  Future<void> setAscendingVolumeEnabled(bool enabled) async {
    await _prefs.setBool(PreferencesKeys.adhanAscendingVolume, enabled);
  }

  @override
  bool isScreenWakeEnabled() => _prefs.getBool(PreferencesKeys.adhanScreenWake) ?? false;

  @override
  Future<void> setScreenWakeEnabled(bool enabled) async {
    await _prefs.setBool(PreferencesKeys.adhanScreenWake, enabled);
  }

  // --- Helper Methods ---

  String? _getEnabledKeyForType(PrayerType type) {
    switch (type) {
      case PrayerType.fajr: return PreferencesKeys.adhanFajrEnabled;
      case PrayerType.dhuhr: return PreferencesKeys.adhanDhuhrEnabled;
      case PrayerType.asr: return PreferencesKeys.adhanAsrEnabled;
      case PrayerType.maghrib: return PreferencesKeys.adhanMaghribEnabled;
      case PrayerType.isha: return PreferencesKeys.adhanIshaEnabled;
      default: return null; // No adhan for sunrise or midnight
    }
  }

  String? _getMoezzinKeyForType(PrayerType type) {
    switch (type) {
      case PrayerType.fajr: return PreferencesKeys.adhanFajrMoezzin;
      case PrayerType.dhuhr: return PreferencesKeys.adhanDhuhrMoezzin;
      case PrayerType.asr: return PreferencesKeys.adhanAsrMoezzin;
      case PrayerType.maghrib: return PreferencesKeys.adhanMaghribMoezzin;
      case PrayerType.isha: return PreferencesKeys.adhanIshaMoezzin;
      default: return null;
    }
  }
}
