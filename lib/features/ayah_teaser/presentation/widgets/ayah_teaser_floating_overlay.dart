import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/controllers/ayah_teaser_controller.dart';
import 'ayah_teaser_card.dart';

/// Floating notification overlay widget displayed above the bottom audio bar
/// when an active Ayah has community notes.
/// Provides smooth animated entrance, exit, and transitions between Ayahs.
class AyahTeaserFloatingOverlay extends ConsumerWidget {
  final int surahId;
  final String? surahName;

  const AyahTeaserFloatingOverlay({
    super.key,
    required this.surahId,
    this.surahName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teaserState = ref.watch(ayahTeaserControllerProvider);
    final isVisible = teaserState.isVisible &&
        teaserState.activeTeaser != null &&
        teaserState.currentSurahId == surahId;

    final teaserItem = teaserState.activeTeaser;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(animation),
            alignment: const Alignment(0.8, 1.0), // Anchored at bottom-right beak!
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.14),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
        );
      },
      child: isVisible && teaserItem != null
          ? KeyedSubtree(
              key: ValueKey('teaser_${teaserItem.ayah}_${teaserItem.postId}'),
              child: AyahTeaserCard(
                item: teaserItem,
                surahId: surahId,
                surahName: surahName,
                onDismiss: () {
                  ref.read(ayahTeaserControllerProvider.notifier).dismiss();
                },
              ),
            )
          : const SizedBox.shrink(key: ValueKey('teaser_hidden')),
    );
  }
}

