import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/enums/prayer_type.dart';
import '../../../permission_manager/application/controllers/permission_providers.dart';
import '../../../permission_manager/domain/entities/app_permission_item.dart';
import '../../domain/repositories/adhan_settings_repository.dart';
import '../services/adhan_scheduler_service.dart';
import 'adhan_manager_providers.dart';
import '../states/adhan_settings_state.dart';

final adhanSettingsControllerProvider = NotifierProvider<AdhanSettingsController, AdhanSettingsState>(() {
  return AdhanSettingsController();
});

class AdhanSettingsController extends Notifier<AdhanSettingsState> {
  AdhanSettingsRepository get _repository => ref.read(adhanSettingsRepositoryProvider);

  @override
  AdhanSettingsState build() {
    final permissionsAsync = ref.watch(permissionControllerProvider);
    final currentState = _loadStateFromRepository();
    final sanitized = _getSanitizedState(currentState, permissionsAsync.value);

    // Asynchronously verify if selected moezzin file is present on device storage
    Future.microtask(() => checkAndSanitizeMoezzinStorage());

    return sanitized;
  }

  AdhanSettingsState _loadStateFromRepository() {
    return AdhanSettingsState(
      isGlobalEnabled: _repository.isAdhanGloballyEnabled(),
      isFajrEnabled: _repository.isAdhanEnabled(PrayerType.fajr),
      isDhuhrEnabled: _repository.isAdhanEnabled(PrayerType.dhuhr),
      isAsrEnabled: _repository.isAdhanEnabled(PrayerType.asr),
      isMaghribEnabled: _repository.isAdhanEnabled(PrayerType.maghrib),
      isIshaEnabled: _repository.isAdhanEnabled(PrayerType.isha),
      fajrMoezzinId: _repository.getMoezzinId(PrayerType.fajr),
      dhuhrMoezzinId: _repository.getMoezzinId(PrayerType.dhuhr),
      asrMoezzinId: _repository.getMoezzinId(PrayerType.asr),
      maghribMoezzinId: _repository.getMoezzinId(PrayerType.maghrib),
      ishaMoezzinId: _repository.getMoezzinId(PrayerType.isha),
      volumeLevel: _repository.getVolumeLevel(),
      isVibrationEnabled: _repository.isVibrationEnabled(),
      isPlayInSilentModeEnabled: _repository.isPlayInSilentModeEnabled(),
      isAscendingVolumeEnabled: _repository.isAscendingVolumeEnabled(),
      isScreenWakeEnabled: _repository.isScreenWakeEnabled(),
    );
  }

  AdhanSettingsState _getSanitizedState(AdhanSettingsState currentState, List<AppPermissionItem>? permissions) {
    if (permissions == null || permissions.isEmpty) return currentState;

    bool isScreenWake = currentState.isScreenWakeEnabled;
    bool isPlayInSilent = currentState.isPlayInSilentModeEnabled;
    bool isGlobal = currentState.isGlobalEnabled;

    final isOverlayGranted = permissions.any(
      (p) => p.category == PermissionTypeCategory.displayOverApps && p.isGranted == true,
    );

    final isExactAlarmGranted = permissions.any(
      (p) => p.category == PermissionTypeCategory.exactAlarm && p.isGranted == true,
    );

    final hasMissingCritical = permissions.any(
      (p) => p.isGranted == false &&
             p.category != PermissionTypeCategory.autoStart &&
             p.category != PermissionTypeCategory.location,
    );

    bool changed = false;

    // Screen wake requires displayOverApps permission
    if (!isOverlayGranted && isScreenWake) {
      isScreenWake = false;
      _repository.setScreenWakeEnabled(false);
      changed = true;
    }

    // Play in silent mode requires exactAlarm permission
    if (!isExactAlarmGranted && isPlayInSilent) {
      isPlayInSilent = false;
      _repository.setPlayInSilentModeEnabled(false);
      changed = true;
    }

    // Global adhan requires critical permissions
    if (hasMissingCritical && isGlobal) {
      isGlobal = false;
      _repository.setAdhanGloballyEnabled(false);
      changed = true;
    }

    if (changed) {
      return currentState.copyWith(
        isScreenWakeEnabled: isScreenWake,
        isPlayInSilentModeEnabled: isPlayInSilent,
        isGlobalEnabled: isGlobal,
      );
    }

    return currentState;
  }

  /// Verifies if the selected moezzin audio file exists on disk.
  /// If missing, automatically turns OFF global and individual adhan toggles,
  /// saves false to SharedPreferences, and reschedules alarms.
  Future<void> checkAndSanitizeMoezzinStorage() async {
    final storageService = ref.read(adhanStorageServiceProvider);
    final isDownloaded = await storageService.isMoezzinDownloaded(state.fajrMoezzinId);

    if (!isDownloaded) {
      if (state.isGlobalEnabled ||
          state.isFajrEnabled ||
          state.isDhuhrEnabled ||
          state.isAsrEnabled ||
          state.isMaghribEnabled ||
          state.isIshaEnabled) {
        await _repository.setAdhanGloballyEnabled(false);
        await _repository.setAdhanEnabled(PrayerType.fajr, false);
        await _repository.setAdhanEnabled(PrayerType.dhuhr, false);
        await _repository.setAdhanEnabled(PrayerType.asr, false);
        await _repository.setAdhanEnabled(PrayerType.maghrib, false);
        await _repository.setAdhanEnabled(PrayerType.isha, false);

        state = state.copyWith(
          isGlobalEnabled: false,
          isFajrEnabled: false,
          isDhuhrEnabled: false,
          isAsrEnabled: false,
          isMaghribEnabled: false,
          isIshaEnabled: false,
        );
        ref.read(adhanSchedulerServiceProvider).rescheduleAlarms();
      }
    }
  }

  // --- Toggles ---

  Future<void> toggleGlobalAdhan(bool enabled) async {
    await _repository.setAdhanGloballyEnabled(enabled);
    state = state.copyWith(isGlobalEnabled: enabled);
  }

  Future<void> togglePrayerAdhan(PrayerType type, bool enabled) async {
    await _repository.setAdhanEnabled(type, enabled);
    state = _loadStateFromRepository();
  }

  Future<void> setMoezzinForPrayer(PrayerType type, String moezzinId) async {
    await _repository.setMoezzinId(type, moezzinId);
    state = _loadStateFromRepository();
  }

  Future<void> applyMoezzinToAll(String moezzinId) async {
    final types = [PrayerType.fajr, PrayerType.dhuhr, PrayerType.asr, PrayerType.maghrib, PrayerType.isha];
    for (final type in types) {
      await _repository.setMoezzinId(type, moezzinId);
    }
    state = _loadStateFromRepository();
  }

  // --- Advanced Settings ---

  Future<void> setVolumeLevel(int volume) async {
    await _repository.setVolumeLevel(volume);
    state = state.copyWith(volumeLevel: volume);
  }

  Future<void> toggleVibration(bool enabled) async {
    await _repository.setVibrationEnabled(enabled);
    state = state.copyWith(isVibrationEnabled: enabled);
  }

  Future<void> togglePlayInSilentMode(bool enabled) async {
    await _repository.setPlayInSilentModeEnabled(enabled);
    state = state.copyWith(isPlayInSilentModeEnabled: enabled);
  }

  Future<void> toggleAscendingVolume(bool enabled) async {
    await _repository.setAscendingVolumeEnabled(enabled);
    state = state.copyWith(isAscendingVolumeEnabled: enabled);
  }

  Future<void> toggleScreenWake(bool enabled) async {
    await _repository.setScreenWakeEnabled(enabled);
    state = state.copyWith(isScreenWakeEnabled: enabled);
  }
}
