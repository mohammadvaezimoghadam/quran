import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/app_permission_item.dart';
import '../../application/controllers/permission_controller.dart';
import '../../application/controllers/permission_providers.dart';
import '../widgets/permission_guide_bottom_sheet.dart';

class PermissionManagementScreen extends ConsumerWidget {
  const PermissionManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F1615) : const Color(0xFFF7F5F0);
    final cardBgColor = isDark ? const Color(0xFF162220) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1B1B);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF666666);
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAE7E3);

    final permissionsAsync = ref.watch(permissionControllerProvider);
    final controller = ref.read(permissionControllerProvider.notifier);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'مدیریت دسترسی‌ها',
          style: AppTypography.appBarTitle.copyWith(color: textColor),
        ),
        backgroundColor: cardBgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: permissionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.goldMetallic),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'خطا در دریافت وضعیت دسترسی‌ها: $err',
              style: AppTypography.captionText.copyWith(color: textColor),
            ),
          ),
        ),
        data: (items) => ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = items[index];

            // Auto-start is special: can't be queried, show as a guidance tile
            if (item.category == PermissionTypeCategory.autoStart) {
              return _buildAutoStartTile(
                context: context,
                item: item,
                controller: controller,
                cardBgColor: cardBgColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                dividerColor: dividerColor,
              );
            }

            return _buildPermissionTile(
              context: context,
              item: item,
              controller: controller,
              cardBgColor: cardBgColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              dividerColor: dividerColor,
            );
          },
        ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required BuildContext context,
    required AppPermissionItem item,
    required PermissionController controller,
    required Color cardBgColor,
    required Color textColor,
    required Color subtitleColor,
    required Color dividerColor,
  }) {
    return Material(
      color: cardBgColor,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: dividerColor),
        ),
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          title: Text(
            item.title,
            style: AppTypography.sectionHeader.copyWith(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              item.subtitle,
              style: AppTypography.captionText.copyWith(
                color: subtitleColor,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
          value: item.isGranted,
          activeThumbColor: AppColors.goldMetallic,
          onChanged: (val) {
            if (!item.isGranted) {
              // Not granted → show educational guide then request
              PermissionGuideBottomSheet.show(
                context,
                item: item,
                onGrantPressed: () => controller.togglePermission(item),
              );
            } else {
              // Already granted → open settings to let user revoke if they want
              controller.togglePermission(item);
            }
          },
        ),
      ),
    );
  }

  /// Auto-start cannot be queried programmatically. 
  /// Show a guidance button instead of a misleading switch.
  Widget _buildAutoStartTile({
    required BuildContext context,
    required AppPermissionItem item,
    required PermissionController controller,
    required Color cardBgColor,
    required Color textColor,
    required Color subtitleColor,
    required Color dividerColor,
  }) {
    return Material(
      color: cardBgColor,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: dividerColor),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          title: Text(
            item.title,
            style: AppTypography.sectionHeader.copyWith(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              item.subtitle,
              style: AppTypography.captionText.copyWith(
                color: subtitleColor,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
          trailing: TextButton(
            onPressed: () {
              PermissionGuideBottomSheet.show(
                context,
                item: item,
                onGrantPressed: () => controller.togglePermission(item),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.goldMetallic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: Text(
              'بررسی کنید',
              style: AppTypography.captionText.copyWith(
                color: AppColors.goldMetallic,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
