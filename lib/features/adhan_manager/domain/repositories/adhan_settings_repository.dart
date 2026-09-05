import '../../../../common/enums/prayer_type.dart';

/// Contract for managing user settings related to adhan alarms.
abstract interface class AdhanSettingsRepository {
  /// Whether adhan is enabled for a specific prayer type.
  bool isAdhanEnabled(PrayerType type);
  
  /// Enables or disables adhan for a specific prayer type.
  Future<void> setAdhanEnabled(PrayerType type, bool enabled);

  /// The selected moezzin (reciter) ID for a prayer type.
  String getMoezzinId(PrayerType type);
  
  /// Sets the selected moezzin ID for a prayer type.
  Future<void> setMoezzinId(PrayerType type, String moezzinId);

  /// Pre-adhan alert (minutes before adhan).
  int getPreAlertMinutes();
  
  /// Sets the pre-adhan alert (minutes before adhan).
  Future<void> setPreAlertMinutes(int minutes);

  /// Master switch — global on/off for all adhan alarms.
  bool isAdhanGloballyEnabled();
  
  /// Turns all adhan alarms globally on or off.
  Future<void> setAdhanGloballyEnabled(bool enabled);

  // --- Advanced Settings ---
  
  int getVolumeLevel();
  Future<void> setVolumeLevel(int volume);

  bool isVibrationEnabled();
  Future<void> setVibrationEnabled(bool enabled);

  bool isPlayInSilentModeEnabled();
  Future<void> setPlayInSilentModeEnabled(bool enabled);

  bool isAscendingVolumeEnabled();
  Future<void> setAscendingVolumeEnabled(bool enabled);

  bool isScreenWakeEnabled();
  Future<void> setScreenWakeEnabled(bool enabled);
}
