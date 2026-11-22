import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quran/common/extensions/context_extension.dart';
import '../../../domain/models/quran_game_item.dart';

/// کارت بازی Squircle با الهام از استایل کافه‌بازار
/// شامل آیکون گوشه‌گرد ۲۲ پیکسلی، برچسب‌ها، تعداد ستاره‌ها و عنوان ۲ خطی.
class BazaarGameCard extends StatelessWidget {
  final QuranGameItem item;
  final VoidCallback onTap;

  const BazaarGameCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.0),
      child: SizedBox(
        width: 96,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Squircle Thumbnail (مستطیل گوشه‌گرد ۲۲ پیکسلی)
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.0),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: item.gradientColors,
                    ),
                    border: Border.all(
                      color: item.isPlayable
                          ? const Color(0xFFFFD54F).withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: isDark ? 0.12 : 0.2),
                      width: item.isPlayable ? 1.6 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: item.gradientColors.last.withValues(
                          alpha: isDark ? 0.35 : 0.22,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Subdued inner background pattern / glow
                      Positioned(
                        right: -10,
                        top: -10,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                      ),

                      // Central Icon Artwork
                      Center(
                        child: Icon(
                          item.icon,
                          size: 38,
                          color: Colors.white,
                        ),
                      ),

                      // Playable badge or Corner Tag
                      if (item.badge != null)
                        Positioned(
                          bottom: 6,
                          right: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.badge!,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'IRANSans',
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: item.badgeColor ?? Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Star badge for playable Hoopoe game
                if (item.isPlayable && item.stars != null && item.stars! > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFB300),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.star_fill,
                        size: 11,
                        color: Color(0xFF1B2332),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 7.0),

            // 2. Game Title (متن عنوان دو خطی تمیز زیر آیکون)
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'IRANSans',
                fontSize: 12.0,
                height: 1.25,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
