import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../common/extensions/size_extension.dart';

class SearchEmptyState extends StatelessWidget {
  final String query;

  const SearchEmptyState({
    super.key,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF3EFE9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.search,
                size: 40,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
            16.vSpace,
            Text(
              'نتیجه‌ای یافت نشد',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            8.vSpace,
            Text(
              'برای «$query» هیچ سوره، آیه یا ترجمه‌ای پیدا نشد.\nلطفاً املای کلمه را بررسی کرده یا عبارت دیگری را جستجو کنید.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.6,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
