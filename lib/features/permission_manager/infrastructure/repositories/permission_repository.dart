import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/native_bridge/domain/adhan_native_service.dart';
import '../../domain/entities/app_permission_item.dart';
import '../../domain/repositories/i_permission_repository.dart';

class PermissionRepository implements IPermissionRepository {
  static const _autoStartCheckedKey = 'auto_start_checked_key';
  final AdhanNativeService _nativeService;

  PermissionRepository(this._nativeService);

  @override
  Future<List<AppPermissionItem>> getPermissionsStatus() async {
    bool notificationGranted = false;
    try {
      notificationGranted = await Permission.notification.status.isGranted;
    } catch (e) {
      debugPrint('Error checking notification status: $e');
      notificationGranted = false;
    }

    bool exactAlarmGranted = false;
    try {
      exactAlarmGranted = await _nativeService.canScheduleExactAlarms();
    } catch (e) {
      debugPrint('Error checking exact alarm status: $e');
      exactAlarmGranted = false;
    }

    bool batteryIgnored = false;
    try {
      batteryIgnored = await _nativeService.isIgnoringBatteryOptimizations();
    } catch (e) {
      debugPrint('Error checking battery optimization status: $e');
      batteryIgnored = false;
    }

    bool overlayGranted = false;
    try {
      overlayGranted = await _nativeService.canDrawOverlays();
    } catch (e) {
      debugPrint('Error checking overlay status: $e');
      overlayGranted = false;
    }

    bool locationGranted = false;
    try {
      locationGranted = await Permission.locationWhenInUse.status.isGranted;
    } catch (e) {
      debugPrint('Error checking location status: $e');
      locationGranted = false;
    }

    bool autoStartChecked = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      autoStartChecked = prefs.getBool(_autoStartCheckedKey) ?? false;
    } catch (e) {
      debugPrint('Error reading autoStartChecked: $e');
    }

    return [
      AppPermissionItem(
        id: 'notifications',
        title: 'تنظیمات اعلان (Show Notifications)',
        subtitle: 'مدیریت و نمایش نوار اعلان‌های تاریخ، هشدار اذان، هشدار یادآوری و...',
        category: PermissionTypeCategory.notifications,
        isGranted: notificationGranted,
      ),
      AppPermissionItem(
        id: 'exact_alarm',
        title: 'تنظیمات هشدار و یادآور (Alarms & Reminders)',
        subtitle: 'پخش دقیق و سر وقت اذان و هشدارهای برنامه در اندروید ۱۲ به بالا',
        category: PermissionTypeCategory.exactAlarm,
        isGranted: exactAlarmGranted,
      ),
      AppPermissionItem(
        id: 'display_over_apps',
        title: 'تنظیمات نمایش در پس‌زمینه (Display over other apps)',
        subtitle: 'پخش اذان و نمایش صفحه تمام‌صفحه هنگام اذان در پس‌زمینه',
        category: PermissionTypeCategory.displayOverApps,
        isGranted: overlayGranted,
      ),
      AppPermissionItem(
        id: 'battery_saver',
        title: 'تنظیمات باتری (App battery saver)',
        subtitle: 'استثنا از برنامه‌های محدودشده باتری جهت جلوگیری از بسته شدن سرویس اذان',
        category: PermissionTypeCategory.batterySaver,
        isGranted: batteryIgnored,
      ),
      AppPermissionItem(
        id: 'location',
        title: 'دسترسی به موقعیت مکانی (GPS)',
        subtitle: 'محاسبه دقیق اوقات شرعی بر اساس موقعیت جغرافیایی شما',
        category: PermissionTypeCategory.location,
        isGranted: locationGranted,
      ),
      AppPermissionItem(
        id: 'auto_start',
        title: 'آغاز خودکار در پس‌زمینه (Auto-start)',
        subtitle: autoStartChecked
            ? 'توسط کاربر بررسی و فعال‌سازی گردید'
            : 'مجوز آغاز خودکار در گوشی‌های شیائومی، سامسونگ و غیره',
        category: PermissionTypeCategory.autoStart,
        isGranted: autoStartChecked,
      ),
    ];
  }

  @override
  Future<bool> requestOrOpenPermission(AppPermissionItem item) async {
    try {
      switch (item.category) {
        case PermissionTypeCategory.notifications:
          final status = await Permission.notification.request();
          if (status.isPermanentlyDenied) {
            return openAppSettings();
          }
          return status.isGranted;

        case PermissionTypeCategory.exactAlarm:
          return await _nativeService.requestExactAlarmPermission();

        case PermissionTypeCategory.displayOverApps:
        case PermissionTypeCategory.backgroundWindow:
          return await _nativeService.requestOverlayPermission();

        case PermissionTypeCategory.batterySaver:
          return await _nativeService.requestIgnoreBatteryOptimizations();

        case PermissionTypeCategory.location:
          final status = await Permission.locationWhenInUse.request();
          if (status.isPermanentlyDenied) {
            return openAppSettings();
          }
          return status.isGranted;

        case PermissionTypeCategory.autoStart:
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(_autoStartCheckedKey, true);
          } catch (_) {}
          return await _nativeService.openAutoStartSettings();
      }
    } catch (e) {
      debugPrint('Error requesting permission ${item.id}: $e');
      return openAppSettings();
    }
  }
}
