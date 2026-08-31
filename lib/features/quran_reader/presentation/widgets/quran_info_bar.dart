import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../core/services/quran_navigation/domain/entities/ayah_target.dart';
import '../../application/controllers/quran_reader_controller.dart';
import '../../domain/entities/ayah_entity.dart';
import 'quran_quick_jump_bottom_sheet.dart';

/// A sticky info bar displayed below the AppBar that shows the current
/// Juz, Hizb, Page, and Ayah with interactive chips for Quick Jump.
class QuranInfoBar extends ConsumerWidget {
  final ValueChanged<AyahTarget>? onTargetSelected;

  const QuranInfoBar({
    super.key,
    this.onTargetSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayahs = ref.watch(quranReaderControllerProvider.select((s) => s.ayahs));
    if (ayahs.isEmpty) return const SizedBox.shrink();

    final itemPositionsListener = ref.watch(activeItemPositionsListenerProvider);

    if (itemPositionsListener == null) {
      return _buildContent(context, ayahs.first);
    }

    return ValueListenableBuilder<Iterable<ItemPosition>>(
      valueListenable: itemPositionsListener.itemPositions,
      builder: (context, positions, child) {
        int currentIndex = 0;
        if (positions.isNotEmpty) {
          final visiblePositions = positions.where((p) => p.itemTrailingEdge > 0);
          if (visiblePositions.isNotEmpty) {
            currentIndex = visiblePositions
                .reduce((min, current) => current.index < min.index ? current : min)
                .index;
          }
        }

        if (currentIndex < 0 || currentIndex >= ayahs.length) {
          currentIndex = 0;
        }

        return _buildContent(context, ayahs[currentIndex]);
      },
    );
  }

  Widget _buildContent(BuildContext context, AyahEntity currentAyah) {
    final ayahStr = currentAyah.ayahNumber.toPersianDigit();
    final juzStr = currentAyah.juz?.toPersianDigit() ?? '؟';
    final hizbStr = currentAyah.hizb?.toPersianDigit() ?? '؟';
    final pageStr = currentAyah.page?.toPersianDigit() ?? '؟';

    return Container(
      width: double.infinity,
      height: 38.0,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildChip(context, 'آیه $ayahStr', QuickJumpTab.surah),
          _buildDotDivider(context),
          _buildChip(context, 'جزء $juzStr', QuickJumpTab.juz),
          _buildDotDivider(context),
          _buildChip(context, 'حزب $hizbStr', QuickJumpTab.hizb),
          _buildDotDivider(context),
          _buildChip(context, 'صفحه $pageStr', QuickJumpTab.page),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String text, QuickJumpTab tab) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () async {
        final target = await QuranQuickJumpBottomSheet.show(
          context,
          initialTab: tab,
        );
        if (target != null) {
          onTargetSelected?.call(target);
        }
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        '•',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          fontSize: 12,
        ),
      ),
    );
  }
}
