/// Centralized service for shared app-level permissions.
/// 
/// Note: Feature-specific permissions (like GPS for LocationService) 
/// should remain in their respective features. This service is for 
/// permissions needed globally or shared across features, like 
/// Notifications, Battery Optimization, and Exact Alarms.
abstract interface class AppPermissionService {
  /// Checks if the app has notification permission (Required for Android 13+).
  Future<bool> checkNotificationPermission();

  /// Prompts the user to grant notification permission.
  /// Returns true if granted.
  Future<bool> requestNotificationPermission();

  /// Checks if the app has permission to schedule exact alarms (Required for Android 12+).
  Future<bool> checkExactAlarmPermission();

  /// Opens the settings page for the user to grant exact alarm permission.
  Future<void> requestExactAlarmPermission();

  /// Checks if the app is excluded from Android battery optimizations.
  Future<bool> isBatteryOptimizationIgnored();

  /// Prompts the user to exclude the app from battery optimizations.
  Future<void> requestBatteryOptimizationIgnore();
}
