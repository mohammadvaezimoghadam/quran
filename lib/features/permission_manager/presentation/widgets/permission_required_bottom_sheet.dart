import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/permission_providers.dart';
import '../../domain/entities/app_permission_item.dart';
import 'permission_guide_bottom_sheet.dart';

/// Shown when the user tries to enable adhan or a prayer switch but permissions are missing.
/// Displays an interactive list of required permissions with live checkmarks.
class PermissionRequiredBottomSheet extends ConsumerWidget {
  const PermissionRequiredBottomSheet({super.key});

  static Future<void> show(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBgColor = isDark ? const Color(0xFF192220) : Colors.white;

    await showModalBottomSheet(
      context: context,
      backgroundColor: sheetBgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const PermissionRequiredBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1B1B);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF666666);
    final cardBgColor = isDark ? const Color(0xFF222C2E) : const Color(0xFFF9F8F6);
    final dividerColor = isDark ? Colors.white10 : const Color(0xFFEAE7E3);

    final permissionsAsync = ref.watch(permissionControllerProvider);
    final controller = ref.read(permissionControllerProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              'تنظیم دسترسی‌های اذان‌گو',
              style: AppTypography.katibahTitle.copyWith(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'برای پخش دقیق اذان، لطفاً دسترسی‌های زیر را فعال کنید:',
              style: AppTypography.captionText.copyWith(
                color: subtitleColor,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            permissionsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.goldMetallic),
                ),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('خطا: $err', style: AppTypography.captionText.copyWith(color: textColor)),
              ),
              data: (items) {
                // Core adhan permissions shown in this dialog
                final coreCategories = [
                  PermissionTypeCategory.notifications,
                  PermissionTypeCategory.exactAlarm,
                  PermissionTypeCategory.displayOverApps,
                  PermissionTypeCategory.batterySaver,
                  PermissionTypeCategory.autoStart,
                ];

                final coreItems = items.where((item) => coreCategories.contains(item.category)).toList();

                return Column(
                  children: coreItems.map((item) {
                    final isGranted = item.isGranted;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(14),
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isGranted
                                  ? AppColors.goldMetallic.withValues(alpha: 0.5)
                                  : dividerColor,
                              width: isGranted ? 1.5 : 1.0,
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              if (!isGranted) {
                                PermissionGuideBottomSheet.show(
                                  context,
                                  item: item,
                                  onGrantPressed: () => controller.togglePermission(item),
                                );
                              }
                            },
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isGranted
                                ? AppColors.goldMetallic
                                : Colors.grey.withValues(alpha: 0.2),
                          ),
                          child: Icon(
                            isGranted ? CupertinoIcons.checkmark_alt : CupertinoIcons.lock_fill,
                            color: isGranted ? Colors.white : Colors.grey.shade600,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: AppTypography.sectionHeader.copyWith(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          isGranted ? 'فعال شده است' : 'لمس کنید جهت فعال‌سازی',
                          style: AppTypography.captionText.copyWith(
                            color: isGranted ? AppColors.goldMetallic : subtitleColor,
                            fontSize: 12,
                            fontWeight: isGranted ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: Icon(
                          isGranted ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.chevron_left,
                          size: isGranted ? 20 : 16,
                          color: isGranted ? AppColors.goldMetallic : subtitleColor,
                        ),
                      ),
                    ),
                  ),
                );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldMetallic,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'متوجه شدم',
                  style: AppTypography.sectionHeader.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
