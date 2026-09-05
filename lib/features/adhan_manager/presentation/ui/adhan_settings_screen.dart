import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/enums/prayer_type.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/services/native_bridge/adhan_native_service_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../permission_manager/application/controllers/permission_providers.dart';
import '../../../permission_manager/domain/entities/app_permission_item.dart';
import '../../../permission_manager/presentation/widgets/permission_guide_bottom_sheet.dart';
import '../../../permission_manager/presentation/widgets/permission_required_bottom_sheet.dart';
import '../../application/controllers/adhan_manager_providers.dart';
import '../../application/controllers/adhan_settings_controller.dart';
import '../../application/services/adhan_scheduler_service.dart';
import '../../application/services/adhan_volume_test_service.dart';
import '../../application/states/adhan_settings_state.dart';
import '../widgets/moezzin_selector_bottom_sheet.dart';

class AdhanSettingsScreen extends ConsumerWidget {
  const AdhanSettingsScreen({super.key});

  /// Returns true if critical permissions are granted, false otherwise.
  /// If false, shows the permission required bottom sheet.
  bool _checkPermissionsOrShowGuide(BuildContext context, WidgetRef ref) {
    final permController = ref.read(permissionControllerProvider.notifier);
    if (permController.hasUngrantedPermissions()) {
      PermissionRequiredBottomSheet.show(context);
      return false;
    }
    return true;
  }

  /// Checks if the moezzin audio file is downloaded on the device.
  /// If not, shows an error snackbar and opens the moezzin download sheet.
  Future<bool> _ensureMoezzinDownloaded(BuildContext context, WidgetRef ref, String moezzinId) async {
    final storageService = ref.read(adhanStorageServiceProvider);
    final isDownloaded = await storageService.isMoezzinDownloaded(moezzinId);
    
    if (!isDownloaded) {
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          'برای فعال‌سازی اذان‌گو ابتدا باید حداقل یک صوت مؤذن دانلود کنید.',
        );
        MoezzinSelectorBottomSheet.show(
          context,
          currentMoezzinId: moezzinId,
        );
      }
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F1615) : const Color(0xFFF7F5F0);
    final cardBgColor = isDark ? const Color(0xFF162220) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1B1B);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF666666);
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAE7E3);

    final state = ref.watch(adhanSettingsControllerProvider);
    final controller = ref.read(adhanSettingsControllerProvider.notifier);
    final moezzinsAsync = ref.watch(availableMoezzinsProvider);

    final selectedMoezzinName = moezzinsAsync.maybeWhen(
      data: (list) {
        final found = list.where((m) => m.id == state.fajrMoezzinId);
        return found.isNotEmpty ? found.first.nameFa : state.fajrMoezzinId;
      },
      orElse: () => state.fajrMoezzinId,
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'تنظیمات اذان‌گو',
          style: AppTypography.appBarTitle.copyWith(color: textColor),
        ),
        backgroundColor: cardBgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Master Switch
          _buildCard(
            context: context,
            child: SwitchListTile(
              title: Text('فعال‌سازی اذان‌گو', style: AppTypography.sectionHeader.copyWith(color: textColor)),
              subtitle: Text('فعال بودن کلی پخش اذان در اپلیکیشن', style: AppTypography.captionText.copyWith(color: subtitleColor)),
              value: state.isGlobalEnabled,
              onChanged: (val) async {
                if (val) {
                  // 1. Check permissions first
                  if (!_checkPermissionsOrShowGuide(context, ref)) return;

                  // 2. Check if moezzin audio file is downloaded
                  final hasMoezzin = await _ensureMoezzinDownloaded(context, ref, state.fajrMoezzinId);
                  if (!hasMoezzin) return;
                }
                controller.toggleGlobalAdhan(val);
                // Reschedule alarms after toggling
                ref.read(adhanSchedulerServiceProvider).rescheduleAlarms();
              },
              activeThumbColor: AppColors.goldMetallic,
            ),
          ),
          const SizedBox(height: 24),

          // Test Service Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text('تست عملکرد سیستم اذان', style: AppTypography.katibahTitle.copyWith(color: textColor)),
          ),
          _buildCard(
            context: context,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(CupertinoIcons.play_circle_fill, color: AppColors.goldMetallic, size: 28),
                  title: Text('تست فوری و آنی بنر اذان (همین حالا)', style: AppTypography.sectionHeader.copyWith(color: textColor)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'پخش آنی سرویس اذان و رندر فوری بنر در بالای صفحه گوشی جهت مشاهده بنر طلاکوب شیرازی.',
                      style: AppTypography.captionText.copyWith(color: subtitleColor),
                    ),
                  ),
                  onTap: () async {
                    // Check if moezzin is downloaded first
                    final hasMoezzin = await _ensureMoezzinDownloaded(context, ref, state.fajrMoezzinId);
                    if (!hasMoezzin) return;

                    final storageService = ref.read(adhanStorageServiceProvider);
                    final moezzinFilePath = await storageService.getMoezzinAudioPath(state.fajrMoezzinId);

                    final nativeService = ref.read(adhanNativeServiceProvider);
                    await nativeService.triggerTestAdhanNow(
                      volumeLevel: state.volumeLevel,
                      vibrate: state.isVibrationEnabled,
                      playInSilentMode: state.isPlayInSilentModeEnabled,
                      ascendingVolume: state.isAscendingVolumeEnabled,
                      moezzinId: state.fajrMoezzinId,
                      moezzinFilePath: moezzinFilePath,
                    );
                    if (context.mounted) {
                      AppSnackBar.showSuccess(
                        context, 
                        'سرویس اذان و بنر بنفش/طلایی پخش گردید. نوار اعلان‌ها را به پایین بکشید.',
                      );
                    }
                  },
                ),
                Divider(height: 1, color: dividerColor),
                ListTile(
                  leading: const Icon(CupertinoIcons.timer, color: AppColors.goldMetallic, size: 28),
                  title: Text('تست سریع اذان (۱۰ ثانیه دیگر)', style: AppTypography.sectionHeader.copyWith(color: textColor)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'برای تست فوری تنظیمات (صدا: ${state.volumeLevel}٪ | افزایشی: ${state.isAscendingVolumeEnabled ? "فعال" : "غیرفعال"} | بی‌صدا: ${state.isPlayInSilentModeEnabled ? "فعال" : "غیرفعال"} | ویبره: ${state.isVibrationEnabled ? "فعال" : "غیرفعال"})\nپس از فشردن، فوری برنامه را ببندید یا گوشی را قفل کنید.',
                      style: AppTypography.captionText.copyWith(color: subtitleColor),
                    ),
                  ),
                  isThreeLine: true,
                  onTap: () async {
                    if (!_checkPermissionsOrShowGuide(context, ref)) return;
                    final hasMoezzin = await _ensureMoezzinDownloaded(context, ref, state.fajrMoezzinId);
                    if (!hasMoezzin) return;

                    final scheduler = ref.read(adhanSchedulerServiceProvider);
                    await scheduler.scheduleTestAlarm(delay: const Duration(seconds: 10));
                    if (context.mounted) {
                      AppSnackBar.showSuccess(
                        context, 
                        'آلارم تست اذان برای ۱۰ ثانیه دیگر تنظیم شد. بلافاصله برنامه را ببندید یا گوشی را قفل کنید.',
                      );
                    }
                  },
                ),
                Divider(height: 1, color: dividerColor),
                ListTile(
                  leading: const Icon(CupertinoIcons.alarm_fill, color: AppColors.goldMetallic, size: 26),
                  title: Text('تنظیم آلارم تست (۲ دقیقه دیگر)', style: AppTypography.sectionHeader.copyWith(color: textColor)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'تست عملکرد اذان در پس‌زمینه طولانی‌مدت',
                      style: AppTypography.captionText.copyWith(color: subtitleColor),
                    ),
                  ),
                  onTap: () async {
                    if (!_checkPermissionsOrShowGuide(context, ref)) return;
                    final hasMoezzin = await _ensureMoezzinDownloaded(context, ref, state.fajrMoezzinId);
                    if (!hasMoezzin) return;

                    final scheduler = ref.read(adhanSchedulerServiceProvider);
                    await scheduler.scheduleTestAlarm(delay: const Duration(minutes: 2));
                    if (context.mounted) {
                      AppSnackBar.showSuccess(
                        context, 
                        'آلارم تست اذان برای ۲ دقیقه دیگر تنظیم شد. برنامه را ببندید یا گوشی را قفل کنید.',
                      );
                    }
                  },
                ),
                ],
            ),
          ),
          const SizedBox(height: 24),

          // Compact Prayer Times Selector (Moved directly under Test section)
          _buildCompactPrayerSelector(context, ref, state),
          const SizedBox(height: 24),

          // Advanced Playback Settings
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text('تنظیمات پخش', style: AppTypography.katibahTitle.copyWith(color: textColor)),
          ),
          _buildCard(
            context: context,
            child: Column(
              children: [
                // Unified Moezzin Selector
                ListTile(
                  leading: const Icon(CupertinoIcons.person_alt_circle, color: AppColors.goldMetallic, size: 26),
                  title: Text('صوت و مؤذن اذان', style: AppTypography.translationText.copyWith(color: textColor)),
                  subtitle: Text(selectedMoezzinName, style: AppTypography.captionText.copyWith(color: subtitleColor)),
                  trailing: Icon(CupertinoIcons.chevron_left, size: 16, color: subtitleColor),
                  onTap: () {
                    MoezzinSelectorBottomSheet.show(
                      context,
                      currentMoezzinId: state.fajrMoezzinId,
                    );
                  },
                ),
                Divider(height: 1, color: dividerColor),

                // Volume Slider
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          ref.read(adhanVolumeTestServiceProvider).playTestBeep(state.volumeLevel);
                        },
                        child: Icon(CupertinoIcons.volume_down, color: subtitleColor),
                      ),
                      Expanded(
                        child: Slider(
                          value: state.volumeLevel.toDouble(),
                          min: 10,
                          max: 100,
                          activeColor: AppColors.goldMetallic,
                          inactiveColor: isDark ? AppColors.surface : Colors.grey.shade300,
                          onChanged: (val) => controller.setVolumeLevel(val.toInt()),
                          onChangeEnd: (val) {
                            ref.read(adhanVolumeTestServiceProvider).playTestBeep(val.toInt());
                            // Reschedule with new volume
                            ref.read(adhanSchedulerServiceProvider).rescheduleAlarms();
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(adhanVolumeTestServiceProvider).playTestBeep(state.volumeLevel);
                        },
                        child: Icon(CupertinoIcons.volume_up, color: subtitleColor),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: dividerColor),
                SwitchListTile(
                  title: Text('پخش افزایشی صدا', style: AppTypography.translationText.copyWith(color: textColor)),
                  subtitle: Text('صدا در ۳۰ ثانیه اول کم کم زیاد می‌شود', style: AppTypography.captionText.copyWith(color: subtitleColor)),
                  value: state.isAscendingVolumeEnabled,
                  onChanged: (val) {
                    controller.toggleAscendingVolume(val);
                    ref.read(adhanSchedulerServiceProvider).rescheduleAlarms();
                  },
                  activeThumbColor: AppColors.goldMetallic,
                ),
                Divider(height: 1, color: dividerColor),
                SwitchListTile(
                  title: Text('پخش در حالت بی‌صدا', style: AppTypography.translationText.copyWith(color: textColor)),
                  subtitle: Text('اذان حتی در صورت سایلنت بودن گوشی پخش می‌شود', style: AppTypography.captionText.copyWith(color: subtitleColor)),
                  value: state.isPlayInSilentModeEnabled,
                  onChanged: (val) {
                    if (val) {
                      final permController = ref.read(permissionControllerProvider.notifier);
                      if (!permController.isCategoryGranted(PermissionTypeCategory.exactAlarm)) {
                        final item = permController.getItemForCategory(PermissionTypeCategory.exactAlarm);
                        if (item != null) {
                          PermissionGuideBottomSheet.show(
                            context,
                            item: item,
                            onGrantPressed: () => permController.togglePermission(item),
                          );
                        } else {
                          _checkPermissionsOrShowGuide(context, ref);
                        }
                        return;
                      }
                    }
                    controller.togglePlayInSilentMode(val);
                    ref.read(adhanSchedulerServiceProvider).rescheduleAlarms();
                  },
                  activeThumbColor: AppColors.goldMetallic,
                ),
                Divider(height: 1, color: dividerColor),
                SwitchListTile(
                  title: Text('روشن شدن صفحه', style: AppTypography.translationText.copyWith(color: textColor)),
                  subtitle: Text('حتی در صورت قفل بودن گوشی، صفحه هنگام اذان بیدار و روشن می‌شود', style: AppTypography.captionText.copyWith(color: subtitleColor)),
                  value: state.isScreenWakeEnabled,
                  onChanged: (val) {
                    if (val) {
                      final permController = ref.read(permissionControllerProvider.notifier);
                      if (!permController.isCategoryGranted(PermissionTypeCategory.displayOverApps)) {
                        final item = permController.getItemForCategory(PermissionTypeCategory.displayOverApps);
                        if (item != null) {
                          PermissionGuideBottomSheet.show(
                            context,
                            item: item,
                            onGrantPressed: () => permController.togglePermission(item),
                          );
                        } else {
                          _checkPermissionsOrShowGuide(context, ref);
                        }
                        return;
                      }
                    }
                    controller.toggleScreenWake(val);
                    ref.read(adhanSchedulerServiceProvider).rescheduleAlarms();
                  },
                  activeThumbColor: AppColors.goldMetallic,
                ),
                Divider(height: 1, color: dividerColor),
                SwitchListTile(
                  title: Text('لرزش گوشی (ویبره)', style: AppTypography.translationText.copyWith(color: textColor)),
                  value: state.isVibrationEnabled,
                  onChanged: (val) {
                    HapticFeedback.vibrate();
                    controller.toggleVibration(val);
                    ref.read(adhanSchedulerServiceProvider).rescheduleAlarms();
                  },
                  activeThumbColor: AppColors.goldMetallic,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCompactPrayerSelector(
    BuildContext context,
    WidgetRef ref,
    AdhanSettingsState state,
  ) {
    final prayers = [
      (title: 'صبح', type: PrayerType.fajr, isEnabled: state.isFajrEnabled, icon: CupertinoIcons.sun_min_fill),
      (title: 'ظهر', type: PrayerType.dhuhr, isEnabled: state.isDhuhrEnabled, icon: CupertinoIcons.sun_max_fill),
      (title: 'عصر', type: PrayerType.asr, isEnabled: state.isAsrEnabled, icon: CupertinoIcons.sun_haze_fill),
      (title: 'مغرب', type: PrayerType.maghrib, isEnabled: state.isMaghribEnabled, icon: CupertinoIcons.moon_fill),
      (title: 'عشا', type: PrayerType.isha, isEnabled: state.isIshaEnabled, icon: CupertinoIcons.moon_stars_fill),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1B1B);
    final controller = ref.read(adhanSettingsControllerProvider.notifier);

    return _buildCard(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(CupertinoIcons.clock_fill, color: AppColors.goldMetallic, size: 20),
                const SizedBox(width: 8),
                Text(
                  'انتخاب اذان',
                  style: AppTypography.sectionHeader.copyWith(color: textColor, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: prayers.map((p) {
                final isEnabled = p.isEnabled;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () async {
                        if (!isEnabled) {
                          if (!_checkPermissionsOrShowGuide(context, ref)) return;
                          final hasMoezzin = await _ensureMoezzinDownloaded(context, ref, state.fajrMoezzinId);
                          if (!hasMoezzin) return;
                        }
                        HapticFeedback.vibrate();
                        controller.togglePrayerAdhan(p.type, !isEnabled);
                        ref.read(adhanSchedulerServiceProvider).rescheduleAlarms();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isEnabled
                              ? (isDark ? AppColors.goldMetallic.withValues(alpha: 0.2) : const Color(0xFFFFF9E6))
                              : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF2F0EB)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isEnabled
                                ? AppColors.goldMetallic
                                : (isDark ? Colors.white10 : Colors.black12),
                            width: isEnabled ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              p.icon,
                              size: 20,
                              color: isEnabled ? AppColors.goldMetallic : Colors.grey,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p.title,
                              style: AppTypography.captionText.copyWith(
                                color: isEnabled ? textColor : Colors.grey,
                                fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              isEnabled
                                  ? CupertinoIcons.checkmark_circle_fill
                                  : CupertinoIcons.circle,
                              size: 14,
                              color: isEnabled ? AppColors.goldMetallic : Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required BuildContext context, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF162220) : Colors.white;
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAE7E3);

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
        ),
        child: child,
      ),
    );
  }
}
