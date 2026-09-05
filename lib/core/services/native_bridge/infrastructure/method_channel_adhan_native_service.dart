import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/adhan_native_service.dart';
import '../domain/models/adhan_alarm_dto.dart';

/// Implementation of [AdhanNativeService] using Flutter's [MethodChannel]
/// to communicate with the Android Kotlin layer.
class MethodChannelAdhanNativeService implements AdhanNativeService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.quran/adhan',
  );

  @override
  Future<bool> scheduleAlarms(List<AdhanAlarmDto> alarms) async {
    if (!Platform.isAndroid) return false;

    try {
      final String alarmsJson = AdhanAlarmDto.listToJson(alarms);
      final bool? result = await _channel.invokeMethod<bool>(
        'scheduleAdhanAlarms',
        {'alarmsJson': alarmsJson},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to schedule adhan alarms: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> cancelAllAlarms() async {
    if (!Platform.isAndroid) return false;

    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'cancelAllAdhanAlarms',
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to cancel adhan alarms: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> openAutoStartSettings() async {
    if (!Platform.isAndroid) return false;

    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'openAutoStartSettings',
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to open auto-start settings: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> requestIgnoreBatteryOptimizations() async {
    if (!Platform.isAndroid) return false;

    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'requestIgnoreBatteryOptimizations',
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint(
        'Failed to request ignore battery optimizations: ${e.message}',
      );
      return false;
    }
  }

  @override
  Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;

    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'isIgnoringBatteryOptimizations',
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to check battery optimization status: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;

    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'canScheduleExactAlarms',
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to check exact alarm permission: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return false;

    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'requestExactAlarmPermission',
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to request exact alarm permission: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> canDrawOverlays() async {
    if (!Platform.isAndroid) return true;

    try {
      final bool? result = await _channel.invokeMethod<bool>('canDrawOverlays');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to check overlay permission: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> requestOverlayPermission() async {
    if (!Platform.isAndroid) return false;

    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'requestOverlayPermission',
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to request overlay permission: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> triggerTestAdhanNow({
    int volumeLevel = 100,
    bool vibrate = true,
    bool playInSilentMode = true,
    bool ascendingVolume = false,
    String moezzinId = 'ghalvash',
    String? moezzinFilePath,
  }) async {
    if (!Platform.isAndroid) return false;

    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'triggerTestAdhanNow',
        {
          'volumeLevel': volumeLevel,
          'vibrate': vibrate,
          'playInSilentMode': playInSilentMode,
          'ascendingVolume': ascendingVolume,
          'moezzinId': moezzinId,
          'moezzinFilePath': moezzinFilePath,
        },
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to trigger test adhan: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> openNotificationSettings() async {
    if (!Platform.isAndroid) return false;

    try {
      final bool? result = await _channel.invokeMethod<bool>('openNotificationSettings');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to open notification settings: ${e.message}');
      return false;
    }
  }
}
