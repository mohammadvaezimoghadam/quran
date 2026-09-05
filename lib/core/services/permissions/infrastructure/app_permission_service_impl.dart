import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

import '../domain/app_permission_service.dart';
import '../../native_bridge/domain/adhan_native_service.dart';

/// Implementation of [AppPermissionService].
/// Uses `permission_handler` for standard permissions (Notifications)
/// and delegates to [AdhanNativeService] for complex OEM/Android 12+ settings.
class AppPermissionServiceImpl implements AppPermissionService {
  final AdhanNativeService _nativeService;

  AppPermissionServiceImpl(this._nativeService);

  @override
  Future<bool> checkNotificationPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;
    
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  @override
  Future<bool> checkExactAlarmPermission() async {
    // We delegate this to the native bridge because permission_handler's 
    // exact_alarm support can sometimes be inconsistent across Android versions.
    return await _nativeService.canScheduleExactAlarms();
  }

  @override
  Future<void> requestExactAlarmPermission() async {
    await _nativeService.requestExactAlarmPermission();
  }

  @override
  Future<bool> isBatteryOptimizationIgnored() async {
    return await _nativeService.isIgnoringBatteryOptimizations();
  }

  @override
  Future<void> requestBatteryOptimizationIgnore() async {
    await _nativeService.requestIgnoreBatteryOptimizations();
  }
}
