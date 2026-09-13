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
        desc: 'دسترسی نامحدود به صوت استاد عبدالباسط، منشاوی، خلیل الحصری، العفاسی و...',
      ),
      (
        icon: Icons.hearing_rounded,
        title: 'ترجمه صوتی گویای فارسی',
        desc: 'شنیدن همگام ترجمه شیوا و باکیفیت فارسی پس از قرائت هر آیه برای تمام سوره‌ها',
      ),
      (
        icon: Icons.cloud_download_rounded,
        title: 'دانلود نامحدود و دسترسی آفلاین',
        desc: 'دانلود یکجا و آفلاین تمامی سوره‌ها با صدای هر یک از قاریان منتخب بدون محدودیت',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
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
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'امکانات اشتراک ویژه',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
                      padding: const EdgeInsets.all(5),
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
                              height: 1.4,
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
