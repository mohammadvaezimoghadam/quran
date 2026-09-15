import 'package:flutter/cupertino.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../core/theme/app_typography.dart';

class SearchEmptyState extends StatelessWidget {
  final String query;

  const SearchEmptyState({
    super.key,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 56.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(
                  alpha: isDark ? 0.14 : 0.08,
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                CupertinoIcons.search,
                size: 32,
                color: colorScheme.primary,
              ),
            ),
            18.vSpace,
            Text(
              'نتیجه‌ای یافت نشد',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            8.vSpace,
            Text(
              'برای «$query» هیچ سوره، آیه یا ترجمه‌ای پیدا نشد.\nلطفاً املای کلمه را بررسی کرده یا عبارت دیگری را جستجو کنید.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                height: 1.6,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
