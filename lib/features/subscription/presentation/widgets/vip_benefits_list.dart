import 'package:flutter/cupertino.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';

class VipBenefitsList extends StatelessWidget {
  const VipBenefitsList({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    final benefits = [
      (
        icon: CupertinoIcons.mic_fill,
        title: 'آرشیو قاریان برجسته جهان اسلام',
        desc: 'دسترسی نامحدود به صوت استاد عبدالباسط، منشاوی، خلیل الحصری، العفاسی و...',
      ),
      (
        icon: CupertinoIcons.textformat,
        title: 'ترجمه‌های گویای صوتی',
        desc: 'شنیدن همگام ترجمه شیوا و باکیفیت فارسی پس از قرائت هر آیه برای تمام سوره‌ها',
      ),
      (
        icon: CupertinoIcons.cloud_download_fill,
        title: 'دانلود نامحدود و دسترسی آفلاین',
        desc: 'دانلود یکجا و آفلاین تمامی سوره‌ها با صدای هر یک از قاریان منتخب بدون محدودیت',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppDimens.stackMd),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
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
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.sparkles,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'امکانات اشتراک ویژه',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorScheme.primary,
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
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      ),
                      child: Icon(
                        b.icon,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.title,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            b.desc,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              height: 1.4,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
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
