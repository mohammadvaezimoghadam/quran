import 'package:flutter/material.dart';

/// دکمه شناور با ۴ نقطه رنگی مطابق با دکمه دسته‌بندی کافه‌بازار در اسکرین‌شات
class BazaarCategoryFab extends StatelessWidget {
  final VoidCallback onTap;

  const BazaarCategoryFab({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF232A38),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.16),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildDot(const Color(0xFF4CAF50)), // سبز
                _buildDot(const Color(0xFFE91E63)), // قرمز/صورتی
                _buildDot(const Color(0xFFFF9800)), // نارنجی
                _buildDot(const Color(0xFF2196F3)), // آبی
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }
}
