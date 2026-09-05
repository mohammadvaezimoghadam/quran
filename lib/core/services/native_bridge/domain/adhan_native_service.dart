import 'models/adhan_alarm_dto.dart';

/// Contract for native platform operations related to the Adhan feature.
/// This acts as a bridge to the Android Kotlin (and eventually iOS Swift) code.
abstract interface class AdhanNativeService {
  /// Schedules exact alarms for the given list of adhan times.
  /// Overwrites any previously scheduled adhan alarms.
  Future<bool> scheduleAlarms(List<AdhanAlarmDto> alarms);

  /// Cancels all scheduled adhan alarms.
  Future<bool> cancelAllAlarms();

  /// Opens the OEM-specific auto-start management settings page
  /// (critical for Xiaomi, Huawei, Oppo, Vivo).
  Future<bool> openAutoStartSettings();

  /// Requests the system to ignore battery optimizations for this app.
  Future<bool> requestIgnoreBatteryOptimizations();

  /// Checks if the app is currently ignored from battery optimizations.
  Future<bool> isIgnoringBatteryOptimizations();

  /// Checks if the app has permission to schedule exact alarms (Android 12+).
  Future<bool> canScheduleExactAlarms();

  /// Opens the exact alarm permission settings page (Android 12+).
  Future<bool> requestExactAlarmPermission();

  /// Checks if the app can draw over other apps (System Alert Window / Overlay).
  Future<bool> canDrawOverlays();

  /// Opens the system settings to request overlay permission.
  Future<bool> requestOverlayPermission();

  /// Triggers an immediate adhan foreground playback service test.
  Future<bool> triggerTestAdhanNow({
    int volumeLevel = 100,
    bool vibrate = true,
    bool playInSilentMode = true,
    bool ascendingVolume = false,
    String moezzinId = 'ghalvash',
    String? moezzinFilePath,
  });

  /// Opens system app notification settings (critical for checking MIUI Floating Notifications).
  Future<bool> openNotificationSettings();
}
