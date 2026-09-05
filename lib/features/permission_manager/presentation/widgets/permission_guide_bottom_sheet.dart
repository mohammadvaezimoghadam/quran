import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/app_permission_item.dart';

class PermissionGuideData {
  final String title;
  final String description;
  final String targetOptionText;
  final String actionButtonText;

  const PermissionGuideData({
    required this.title,
    required this.description,
    required this.targetOptionText,
    required this.actionButtonText,
  });
}

class PermissionGuideBottomSheet extends StatelessWidget {
  final AppPermissionItem item;
  final VoidCallback onGrantPressed;

  const PermissionGuideBottomSheet({
    super.key,
    required this.item,
    required this.onGrantPressed,
  });

  static Future<void> show(
    BuildContext context, {
    required AppPermissionItem item,
    required VoidCallback onGrantPressed,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBgColor = isDark ? const Color(0xFF192220) : Colors.white;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => PermissionGuideBottomSheet(
        item: item,
        onGrantPressed: onGrantPressed,
      ),
    );
  }

  PermissionGuideData _getGuideData() {
    switch (item.category) {
      case PermissionTypeCategory.displayOverApps:
      case PermissionTypeCategory.backgroundWindow:
        return const PermissionGuideData(
          title: 'راهنمای سایر مجوزها (نمایش در پس‌زمینه)',
          description:
              'در گوشی‌های شیائومی و سامسونگ، جهت نمایش بنر تمام‌صفحه اذان هنگام قفل بودن دستگاه، روی دکمه زیر زده و در صفحه «سایر مجوزها»، گزینه‌های زیر را روشن کنید:\n\n• نمایش بر روی صفحه قفل\n• باز کردن پنجره‌های جدید هنگام اجرا در پس‌زمینه\n• نمایش پنجره‌های شناور',
          targetOptionText: 'سایر مجوزها / Other permissions > تایید گزینه‌ها',
          actionButtonText: 'ورود به تنظیمات سایر مجوزها',
        );

      case PermissionTypeCategory.batterySaver:
        return const PermissionGuideData(
          title: 'راهنمای تنظیمات بهینه‌سازی باتری',
          description:
              'برخی سیستم‌عامل‌ها جهت صرفه‌جویی در باتری، اجرای اذان در پس‌زمینه را متوقف می‌کنند. روی دکمه زیر بزنید و گزینه «عدم محدودیت» (No Restrictions) یا «استثنا از بهینه‌سازی» را انتخاب کنید.',
          targetOptionText: 'No restrictions / عدم وجود محدودیت باتری',
          actionButtonText: 'تنظیم استثنای باتری',
        );

      case PermissionTypeCategory.exactAlarm:
        return const PermissionGuideData(
          title: 'راهنمای تنظیمات هشدار دقیق (Alarms & Reminders)',
          description:
              'در اندروید ۱۲ به بالا، برای پخش دقیق و سر وقت اذان لازم است مجوز Alarms & Reminders فعال باشد. روی دکمه زیر زده و سوییچ اجازه به برنامه را روشن کنید.',
          targetOptionText: 'Allow setting alarms and reminders / اجازه هشدار',
          actionButtonText: 'تنظیم مجوز هشدار دقیق',
        );

      case PermissionTypeCategory.notifications:
        return const PermissionGuideData(
          title: 'راهنمای تنظیمات اعلان (Notifications)',
          description:
              'برای نمایش نوار اعلان‌های اذان، هشدارهای یادآوری و اوقات شرعی، لازم است مجوز ارسال اعلان‌ها فعال باشد. روی دکمه زیر زده و گزینه Allow notifications را روشن کنید.',
          targetOptionText: 'Show notifications / نمایش اعلان‌ها',
          actionButtonText: 'تنظیم مجوز اعلان‌ها',
        );

      case PermissionTypeCategory.autoStart:
        return const PermissionGuideData(
          title: 'راهنمای آغاز خودکار پس‌زمینه (Auto-Start)',
          description:
              'در گوشی‌های شیائومی، هواوی، سامسونگ و... جهت پخش سر وقت اذان هنگام بسته بودن برنامه، باید مجوز آغاز خودکار را فعال کنید. روی دکمه زیر زده و در صفحه بازشده سوییچ برنامه را روشن کنید.',
          targetOptionText: 'آغاز خودکار پس‌زمینه > روشن کردن سوییچ برنامه',
          actionButtonText: 'ورود به صفحه آغاز خودکار پس‌زمینه',
        );

      case PermissionTypeCategory.location:
        return const PermissionGuideData(
          title: 'راهنمای موقعیت مکانی (GPS)',
          description:
              'جهت محاسبه دقیق اوقات شرعی شهر شما، نیاز به دسترسی موقعیت مکانی است. روی دکمه زیر زده و گزینه «هنگام استفاده از برنامه» را تایید کنید.',
          targetOptionText: 'While using the app / هنگام استفاده از برنامه',
          actionButtonText: 'اعطای دسترسی موقعیت مکانی',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1B1B);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF555555);
    final cardBgColor = isDark ? const Color(0xFF111718) : const Color(0xFFF9F8F6);
    final guideData = _getGuideData();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              guideData.title,
              style: AppTypography.katibahTitle.copyWith(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),

            // Description
            Text(
              guideData.description,
              style: AppTypography.captionText.copyWith(
                color: subtitleColor,
                height: 1.6,
                fontSize: 13.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),

            // Visual Setting Demonstration Box (Similar to BadSaba)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE74C3C),
                    ),
                    child: const Icon(
                      CupertinoIcons.xmark,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      guideData.targetOptionText,
                      style: AppTypography.sectionHeader.copyWith(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.chevron_left,
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Disclaimer Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.info,
                    size: 18,
                    color: subtitleColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'با توجه به تنوع بالای مدل‌های گوشی و نسخه‌های اندروید، امکان مغایرت راهنما با تنظیمات فعلی گوشی شما وجود دارد.',
                      style: AppTypography.captionText.copyWith(
                        color: subtitleColor,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Button (Red / Accent)
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onGrantPressed();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C), // Red accent button like BadSaba
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  guideData.actionButtonText,
                  style: AppTypography.sectionHeader.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
