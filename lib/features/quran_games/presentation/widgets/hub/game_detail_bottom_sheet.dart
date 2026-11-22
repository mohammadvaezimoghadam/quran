import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:quran/common/extensions/context_extension.dart';
import '../../../domain/models/quran_game_item.dart';

/// باتم‌شیت جزییات بازی به سبک صفحه اختصاصی اپلیکیشن‌ها در کافه‌بازار
class GameDetailBottomSheet extends StatelessWidget {
  final QuranGameItem game;

  const GameDetailBottomSheet({
    super.key,
    required this.game,
  });

  static Future<void> show(BuildContext context, QuranGameItem game) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GameDetailBottomSheet(game: game),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            decoration: BoxDecoration(
              color: colors.cardBackground.withValues(alpha: 0.96),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28.0)),
              border: Border.all(
                color: colors.cardBorder,
                width: 0.8,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // App Header Row (Icon + Title + Category + Badge)
                Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: game.gradientColors,
                        ),
                      ),
                      child: Center(
                        child: Icon(game.icon, color: Colors.white, size: 32),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.title,
                            style: TextStyle(
                              fontFamily: 'IRANSans',
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            game.category,
                            style: TextStyle(
                              fontFamily: 'IRANSans',
                              fontSize: 12.5,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (game.badge != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (game.badgeColor ?? const Color(0xFFFF9800))
                                    .withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                game.badge!,
                                style: TextStyle(
                                  fontFamily: 'IRANSans',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: game.badgeColor ?? const Color(0xFFFF9800),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Description
                Text(
                  'درباره این بازی',
                  style: TextStyle(
                    fontFamily: 'IRANSans',
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  game.description,
                  style: TextStyle(
                    fontFamily: 'IRANSans',
                    fontSize: 13.0,
                    height: 1.6,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 24),

                // Action Button (Notify Me / Close)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'به‌محض انتشار این بازی به شما اطلاع داده خواهد شد.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'IRANSans'),
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text(
                    'به من اطلاع بده',
                    style: TextStyle(
                      fontFamily: 'IRANSans',
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
