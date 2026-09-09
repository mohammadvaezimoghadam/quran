import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class VipBenefitsList extends StatelessWidget {
  const VipBenefitsList({super.key});

  @override
  Widget build(BuildContext context) {
    final benefits = [
      (
        icon: Icons.record_voice_over_rounded,
        title: 'آرشیو قاریان برجسته جهان اسلام',
        desc: 'دسترسی نامحدود به صوت استاد عبدالباسط، منشاوی، العفاسی و...',
      ),
      (
        icon: Icons.hearing_rounded,
        title: 'ترجمه صوتی گویای فارسی',
        desc: 'شنیدن همگام ترجمه شیوا و باکیفیت پس از قرائت هر آیه',
      ),
      (
        icon: Icons.menu_book_rounded,
        title: 'واژه‌شناسی و ترجمه لغت‌به‌لغت',
        desc: 'درک عمیق معانی تک‌تک کلمات و ریشه‌های قرآنی آیات',
      ),
      (
        icon: Icons.format_color_text_rounded,
        title: 'رنگ‌آمیزی اعراب و فونت‌های اصیل',
        desc: 'شخصی‌سازی رنگ حرکات متن و دسترسی به فونت‌های ثلث و نیریزی',
      ),
      (
        icon: Icons.devices_rounded,
        title: 'اتصال به سخت‌افزار هوشمند قرآنی',
        desc: 'همگام‌سازی نمایشگر هوشمند رومیزی (NodeMCU) با تلاوت',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.goldMetallic.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: AppColors.goldAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'امکانات ویژه اشتراک VIP',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...benefits.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        b.icon,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.title,
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            b.desc,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
