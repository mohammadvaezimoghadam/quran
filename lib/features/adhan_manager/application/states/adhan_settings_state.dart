import 'package:freezed_annotation/freezed_annotation.dart';

part 'adhan_settings_state.freezed.dart';

@freezed
abstract class AdhanSettingsState with _$AdhanSettingsState {
  const factory AdhanSettingsState({
    // Global toggle
    @Default(false) bool isGlobalEnabled,

    // Per-prayer toggles
    @Default(false) bool isFajrEnabled,
    @Default(false) bool isDhuhrEnabled,
    @Default(false) bool isAsrEnabled,
    @Default(false) bool isMaghribEnabled,
    @Default(false) bool isIshaEnabled,

    // Per-prayer moezzins (holds moezzin ID)
    @Default('ghalvash') String fajrMoezzinId,
    @Default('ghalvash') String dhuhrMoezzinId,
    @Default('ghalvash') String asrMoezzinId,
    @Default('ghalvash') String maghribMoezzinId,
    @Default('ghalvash') String ishaMoezzinId,

    // Advanced settings
    @Default(100) int volumeLevel,
    @Default(false) bool isVibrationEnabled,
    @Default(false) bool isPlayInSilentModeEnabled,
    @Default(false) bool isAscendingVolumeEnabled,
    @Default(false) bool isScreenWakeEnabled,
  }) = _AdhanSettingsState;
}
