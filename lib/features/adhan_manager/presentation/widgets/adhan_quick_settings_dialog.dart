import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/enums/prayer_type.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../permission_manager/application/controllers/permission_providers.dart';
import '../../../permission_manager/presentation/widgets/permission_required_bottom_sheet.dart';
import '../../application/controllers/adhan_settings_controller.dart';
import '../../application/services/adhan_scheduler_service.dart';

class AdhanQuickSettingsDialog extends ConsumerWidget {
  const AdhanQuickSettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBgColor = isDark ? const Color(0xFF192220) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1B1B);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF666666);

    final state = ref.watch(adhanSettingsControllerProvider);
    final controller = ref.read(adhanSettingsControllerProvider.notifier);

    return Dialog(
      backgroundColor: dialogBgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(CupertinoIcons.speaker_2_fill, color: AppColors.goldMetallic),
                const SizedBox(width: 8),
                Text('پخش سریع اذان', style: AppTypography.sectionHeader.copyWith(color: textColor)),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildCheckboxTile(
              title: 'اذان صبح',
              textColor: textColor,
              value: state.isFajrEnabled,
              onChanged: (val) => _handleToggle(context, ref, controller, PrayerType.fajr, val ?? false),
            ),
            _buildCheckboxTile(
              title: 'اذان ظهر',
              textColor: textColor,
              value: state.isDhuhrEnabled,
              onChanged: (val) => _handleToggle(context, ref, controller, PrayerType.dhuhr, val ?? false),
            ),
            _buildCheckboxTile(
              title: 'اذان عصر',
              textColor: textColor,
              value: state.isAsrEnabled,
              onChanged: (val) => _handleToggle(context, ref, controller, PrayerType.asr, val ?? false),
            ),
            _buildCheckboxTile(
              title: 'اذان مغرب',
              textColor: textColor,
              value: state.isMaghribEnabled,
              onChanged: (val) => _handleToggle(context, ref, controller, PrayerType.maghrib, val ?? false),
            ),
            _buildCheckboxTile(
              title: 'اذان عشا',
              textColor: textColor,
              value: state.isIshaEnabled,
              onChanged: (val) => _handleToggle(context, ref, controller, PrayerType.isha, val ?? false),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () {
                    Navigator.pop(context);
                    context.pushNamed(adhanSettingsRoute);
                  },
                  child: const Text('تنظیمات بیشتر', style: TextStyle(color: AppColors.goldMetallic, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('بستن', style: TextStyle(color: subtitleColor)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleToggle(
    BuildContext context, 
    WidgetRef ref, 
    AdhanSettingsController controller, 
    PrayerType type, 
    bool enabled,
  ) {
    if (enabled) {
      final permController = ref.read(permissionControllerProvider.notifier);
      if (permController.hasUngrantedPermissions()) {
        Navigator.pop(context); // Close dialog first
        PermissionRequiredBottomSheet.show(context);
        return;
      }
    }
    controller.togglePrayerAdhan(type, enabled);
    ref.read(adhanSchedulerServiceProvider).rescheduleAlarms();
  }

  Widget _buildCheckboxTile({
    required String title,
    required Color textColor,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Theme(
      data: ThemeData(unselectedWidgetColor: Colors.grey),
      child: CheckboxListTile(
        title: Text(title, style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14, color: textColor)),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.goldMetallic,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      ),
    );
  }
}
