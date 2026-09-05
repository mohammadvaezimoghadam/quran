import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/enums/prayer_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../permission_manager/application/controllers/permission_providers.dart';
import '../../application/controllers/adhan_download_controller.dart';
import '../../application/controllers/adhan_manager_providers.dart';
import '../../application/controllers/adhan_settings_controller.dart';
import '../../application/services/adhan_scheduler_service.dart';
import '../../domain/entities/moezzin.dart';

class MoezzinSelectorBottomSheet extends ConsumerWidget {
  final PrayerType? prayerType;
  final String currentMoezzinId;

  const MoezzinSelectorBottomSheet({
    super.key,
    this.prayerType,
    required this.currentMoezzinId,
  });

  static void show(
    BuildContext context, {
    PrayerType? prayerType,
    required String currentMoezzinId,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBgColor = isDark ? const Color(0xFF162220) : Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MoezzinSelectorBottomSheet(
        prayerType: prayerType,
        currentMoezzinId: currentMoezzinId,
      ),
    );
  }

  Future<void> _selectMoezzin(WidgetRef ref, Moezzin moezzin, BuildContext context) async {
    final settingsController = ref.read(adhanSettingsControllerProvider.notifier);
    if (prayerType != null) {
      await settingsController.setMoezzinForPrayer(prayerType!, moezzin.id);
    } else {
      await settingsController.applyMoezzinToAll(moezzin.id);
    }

    // Auto-enable global adhan & prayer switches if permissions are granted
    final permController = ref.read(permissionControllerProvider.notifier);
    if (!permController.hasUngrantedPermissions()) {
      await settingsController.toggleGlobalAdhan(true);
      await settingsController.togglePrayerAdhan(PrayerType.fajr, true);
      await settingsController.togglePrayerAdhan(PrayerType.dhuhr, true);
      await settingsController.togglePrayerAdhan(PrayerType.asr, true);
      await settingsController.togglePrayerAdhan(PrayerType.maghrib, true);
      await settingsController.togglePrayerAdhan(PrayerType.isha, true);
    }

    // Reschedule alarms with the new moezzin
    ref.read(adhanSchedulerServiceProvider).rescheduleAlarms();
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1B1B);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF666666);
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAE7E3);

    final moezzinsAsync = ref.watch(availableMoezzinsProvider);
    final downloadState = ref.watch(adhanDownloadControllerProvider);
    final downloadController = ref.read(adhanDownloadControllerProvider.notifier);
    final storageService = ref.read(adhanStorageServiceProvider);

    final titleText = prayerType != null 
        ? 'انتخاب مؤذن برای ${prayerType!.titleFa}' 
        : 'انتخاب مؤذن اذان';

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            titleText,
            style: AppTypography.katibahTitle.copyWith(color: textColor),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: moezzinsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(color: AppColors.goldMetallic),
                ),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'خطا در دریافت لیست مؤذن‌ها: $err', 
                    style: AppTypography.captionText.copyWith(color: subtitleColor),
                  ),
                ),
              ),
              data: (moezzins) => ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: moezzins.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: dividerColor),
                itemBuilder: (context, index) {
                  final moezzin = moezzins[index];
                  final isSelected = moezzin.id == currentMoezzinId;
                  final isDownloading = downloadState.isDownloading[moezzin.id] ?? false;
                  final progress = downloadState.downloadProgresses[moezzin.id] ?? 0.0;
                  final errorMsg = downloadState.downloadErrors[moezzin.id];

                  return FutureBuilder<bool>(
                    future: storageService.isMoezzinDownloaded(moezzin.id),
                    builder: (context, snapshot) {
                      final isDownloaded = snapshot.data ?? false;

                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          title: Text(
                            moezzin.nameFa, 
                            style: AppTypography.translationText.copyWith(
                              color: textColor,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: errorMsg != null 
                            ? Text(
                                'خطا در دانلود - دوباره تلاش کنید',
                                style: TextStyle(color: Colors.red.shade300, fontSize: 11),
                              )
                            : null,
                          trailing: _buildTrailingIcon(
                            isSelected: isSelected,
                            isDownloaded: isDownloaded,
                            isDownloading: isDownloading,
                            progress: progress,
                            subtitleColor: subtitleColor,
                          ),
                          onTap: () {
                            if (isDownloading) return;

                            if (isDownloaded) {
                              // File exists → select immediately
                              _selectMoezzin(ref, moezzin, context);
                            } else {
                              // File not downloaded → start download, then auto-select
                              _downloadAndSelect(ref, downloadController, moezzin, context);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTrailingIcon({
    required bool isSelected,
    required bool isDownloaded,
    required bool isDownloading,
    required double progress,
    required Color subtitleColor,
  }) {
    if (isDownloading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          value: progress > 0 ? progress : null,
          strokeWidth: 2.5,
          color: AppColors.goldMetallic,
        ),
      );
    }

    if (isSelected) {
      return const Icon(
        CupertinoIcons.checkmark_alt_circle_fill,
        color: AppColors.goldMetallic,
      );
    }

    if (isDownloaded) {
      return Icon(
        CupertinoIcons.circle,
        color: subtitleColor,
      );
    }

    // Not downloaded → show download icon
    return Icon(
      CupertinoIcons.cloud_download,
      color: subtitleColor.withValues(alpha: 0.7),
      size: 22,
    );
  }

  Future<void> _downloadAndSelect(
    WidgetRef ref, 
    AdhanDownloadController downloadController,
    Moezzin moezzin,
    BuildContext context,
  ) async {
    await downloadController.downloadMoezzinAudio(moezzin);

    // After download, check if successful then select
    final downloadState = ref.read(adhanDownloadControllerProvider);
    final hasError = downloadState.downloadErrors.containsKey(moezzin.id);

    if (!hasError && context.mounted) {
      _selectMoezzin(ref, moezzin, context);
    }
  }
}
