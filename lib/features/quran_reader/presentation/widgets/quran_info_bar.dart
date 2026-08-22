import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../domain/entities/ayah_entity.dart';

/// A sticky info bar displayed below the AppBar that shows the current
/// Juz and Page based on the user's scroll position.
/// Uses ValueListenableBuilder to rebuild independently of the main screen.
class QuranInfoBar extends StatelessWidget {
  final ItemPositionsListener itemPositionsListener;
  final List<AyahEntity> ayahs;

  const QuranInfoBar({
    super.key,
    required this.itemPositionsListener,
    required this.ayahs,
  });

  @override
  Widget build(BuildContext context) {
    if (ayahs.isEmpty) return const SizedBox.shrink();

    return ValueListenableBuilder<Iterable<ItemPosition>>(
      valueListenable: itemPositionsListener.itemPositions,
      builder: (context, positions, child) {
        int currentIndex = 0;
        if (positions.isNotEmpty) {
          // Find the first visible item (the one closest to the top of the viewport)
          // itemTrailingEdge > 0 ensures we don't pick items that have completely scrolled out of view upwards
          final visiblePositions = positions.where((p) => p.itemTrailingEdge > 0);
          if (visiblePositions.isNotEmpty) {
            currentIndex = visiblePositions
                .reduce((min, current) => current.index < min.index ? current : min)
                .index;
          }
        }

        // Failsafe bounds check
        if (currentIndex < 0 || currentIndex >= ayahs.length) {
          currentIndex = 0;
        }

        final currentAyah = ayahs[currentIndex];
        final ayahStr = currentAyah.ayahNumber.toPersianDigit();
        final juzStr = currentAyah.juz?.toPersianDigit() ?? '؟';
        final hizbStr = currentAyah.hizb?.toPersianDigit() ?? '؟';
        final pageStr = currentAyah.page?.toPersianDigit() ?? '؟';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'آیه $ayahStr',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '•',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                'جزء $juzStr',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '•',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                'حزب $hizbStr',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '•',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                'صفحه $pageStr',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
