import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quran/common/extensions/context_extension.dart';
import '../../../infrastructure/datasources/quran_games_catalog.dart';

/// باتم‌شیت انتخاب دسته‌بندی بازی‌ها
class GameCategoriesBottomSheet extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;

  const GameCategoriesBottomSheet({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  static Future<void> show({
    required BuildContext context,
    required String selectedCategory,
    required ValueChanged<String> onSelectCategory,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GameCategoriesBottomSheet(
        selectedCategory: selectedCategory,
        onSelectCategory: (category) {
          onSelectCategory(category);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final categories = QuranGamesCatalog.categories;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'دسته‌بندی بازی‌ها',
                style: TextStyle(
                  fontFamily: 'IRANSans',
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...categories.map((c) {
              final title = c['title'] as String;
              final icon = c['icon'] as IconData;
              final isSelected = selectedCategory == title;

              return ListTile(
                leading: Icon(
                  icon,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'IRANSans',
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                  ),
                ),
                trailing: isSelected
                    ? Icon(CupertinoIcons.checkmark,
                        color: colorScheme.primary, size: 18)
                    : null,
                onTap: () => onSelectCategory(title),
              );
            }),
          ],
        ),
      ),
    );
  }
}
