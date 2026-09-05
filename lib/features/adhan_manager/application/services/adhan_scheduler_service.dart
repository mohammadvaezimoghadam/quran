import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/enums/prayer_type.dart';
import '../../../../core/services/native_bridge/adhan_native_service_provider.dart';
import '../../../../core/services/native_bridge/domain/adhan_native_service.dart';
import '../../../../core/services/native_bridge/domain/models/adhan_alarm_dto.dart';
import '../../../../core/services/prayer_times_provider/i_prayer_times_provider.dart';
import '../../domain/repositories/adhan_settings_repository.dart';
import '../../domain/services/i_adhan_storage_service.dart';
import '../controllers/adhan_manager_providers.dart';
import '../../infrastructure/services/prayer_times_provider_impl.dart';

/// The central brain of the adhan_manager feature.
/// Orchestrates settings, prayer times calculation, and native alarm scheduling.
class AdhanSchedulerService {
  final IPrayerTimesProvider _prayerTimesProvider;
  final AdhanSettingsRepository _settingsRepo;
  final AdhanNativeService _nativeService;
  final IAdhanStorageService _storageService;

  DateTime? _activeTestAlarmTime;

  AdhanSchedulerService(
    this._prayerTimesProvider,
    this._settingsRepo,
    this._nativeService,
    this._storageService,
  );

  /// Recalculates and reschedules all active adhan alarms for today and tomorrow.
  Future<void> rescheduleAlarms() async {
    // 1. Always cancel existing alarms first to start fresh
    await _nativeService.cancelAllAlarms();

    // 2. Check master switch
    if (!_settingsRepo.isAdhanGloballyEnabled()) {
      return; // If globally off, we just stop here (alarms are already canceled)
    }

    // 3. Fetch times for today and tomorrow
    final todayTimes = await _prayerTimesProvider.getTodayPrayerTimes();
    final tomorrowTimes = await _prayerTimesProvider.getTomorrowPrayerTimes();

    final now = DateTime.now();
    final alarmsToSchedule = <AdhanAlarmDto>[];
    int idCounter = 1;

    // Helper to process a single day's times
    Future<void> processTimes(Map<PrayerType, DateTime> times, bool isTomorrow) async {
      for (final entry in times.entries) {
        final type = entry.key;
        final time = entry.value;

        // Skip if not enabled
        if (!_settingsRepo.isAdhanEnabled(type)) continue;

        // Skip past alarms
        if (!isTomorrow && time.isBefore(now)) continue;

        final moezzinId = _settingsRepo.getMoezzinId(type);
        final moezzinAsset = 'adhan_$moezzinId';
        final moezzinFilePath = await _storageService.getMoezzinAudioPath(moezzinId);

        final volumeLevel = _settingsRepo.getVolumeLevel();
        final vibrate = _settingsRepo.isVibrationEnabled();
        final playInSilentMode = _settingsRepo.isPlayInSilentModeEnabled();
        final ascendingVolume = _settingsRepo.isAscendingVolumeEnabled();
        final wakeScreen = _settingsRepo.isScreenWakeEnabled();

        // Create the DTO
        alarmsToSchedule.add(AdhanAlarmDto(
          id: int.parse('${isTomorrow ? 2 : 1}$idCounter${time.hour}${time.minute}'), // Simple unique ID
          prayerName: type.titleFa,
          epochMillis: time.millisecondsSinceEpoch,
          moezzinAsset: moezzinAsset,
          moezzinFilePath: moezzinFilePath,
          volumeLevel: volumeLevel,
          vibrate: vibrate,
          playInSilentMode: playInSilentMode,
          ascendingVolume: ascendingVolume,
          wakeScreen: wakeScreen,
        ));
        idCounter++;
      }
    }

    // 4. Process today and tomorrow
    await processTimes(todayTimes, false);
    await processTimes(tomorrowTimes, true);

    // 5. Re-include active pending test alarm if present and in the future
    if (_activeTestAlarmTime != null) {
      if (_activeTestAlarmTime!.isAfter(now)) {
        final moezzinId = _settingsRepo.getMoezzinId(PrayerType.dhuhr);
        final moezzinAsset = 'adhan_$moezzinId';
        final moezzinFilePath = await _storageService.getMoezzinAudioPath(moezzinId);

        alarmsToSchedule.add(AdhanAlarmDto(
          id: 9999,
          prayerName: 'اذان (تست سیستم)',
          epochMillis: _activeTestAlarmTime!.millisecondsSinceEpoch,
          moezzinAsset: moezzinAsset,
          moezzinFilePath: moezzinFilePath,
          volumeLevel: _settingsRepo.getVolumeLevel(),
          vibrate: _settingsRepo.isVibrationEnabled(),
          playInSilentMode: _settingsRepo.isPlayInSilentModeEnabled(),
          ascendingVolume: _settingsRepo.isAscendingVolumeEnabled(),
          wakeScreen: _settingsRepo.isScreenWakeEnabled(),
        ));
      } else {
        _activeTestAlarmTime = null;
      }
    }

    // 6. Send to native Android layer if there are alarms
    if (alarmsToSchedule.isNotEmpty) {
      await _nativeService.scheduleAlarms(alarmsToSchedule);
    }
  }

  /// Schedules a test alarm after [delay] (default 2 minutes) to test background/killed execution.
  /// Dynamically reads all current settings (volume, silent mode, ascending volume, vibration, wake screen, moezzin).
  Future<void> scheduleTestAlarm({
    Duration delay = const Duration(minutes: 2),
    PrayerType prayerType = PrayerType.dhuhr,
  }) async {
    final testTime = DateTime.now().add(delay);
    _activeTestAlarmTime = testTime;

    final moezzinId = _settingsRepo.getMoezzinId(prayerType);
    final moezzinAsset = 'adhan_$moezzinId';
    final moezzinFilePath = await _storageService.getMoezzinAudioPath(moezzinId);

    final testAlarm = AdhanAlarmDto(
      id: 9999,
      prayerName: 'اذان (تست سیستم)',
      epochMillis: testTime.millisecondsSinceEpoch,
      moezzinAsset: moezzinAsset,
      moezzinFilePath: moezzinFilePath,
      volumeLevel: _settingsRepo.getVolumeLevel(),
      vibrate: _settingsRepo.isVibrationEnabled(),
      playInSilentMode: _settingsRepo.isPlayInSilentModeEnabled(),
      ascendingVolume: _settingsRepo.isAscendingVolumeEnabled(),
      wakeScreen: _settingsRepo.isScreenWakeEnabled(),
    );

    await _nativeService.scheduleAlarms([testAlarm]);
  }
}

/// Riverpod provider for the AdhanSchedulerService
final adhanSchedulerServiceProvider = Provider<AdhanSchedulerService>((ref) {
  final prayerTimesProvider = ref.watch(prayerTimesProviderImplProvider);
  final settingsRepo = ref.watch(adhanSettingsRepositoryProvider);
  final nativeService = ref.watch(adhanNativeServiceProvider);
  final storageService = ref.watch(adhanStorageServiceProvider);

  return AdhanSchedulerService(
    prayerTimesProvider,
    settingsRepo,
    nativeService,
    storageService,
  );
});
