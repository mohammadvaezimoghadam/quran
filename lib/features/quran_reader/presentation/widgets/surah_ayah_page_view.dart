import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../core/services/audio/audio_player_state.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../application/controllers/quran_audio_controller.dart';
import '../../application/controllers/quran_reader_controller.dart';
import 'ayah_list_item.dart';

class SurahAyahPageView extends ConsumerStatefulWidget {
  final int surahId;
  final String surahName;
  final bool isCurrentPage;
  final int? initialAyahNumber;

  const SurahAyahPageView({
    super.key,
    required this.surahId,
    required this.surahName,
    required this.isCurrentPage,
    this.initialAyahNumber,
  });

  @override
  ConsumerState<SurahAyahPageView> createState() => _SurahAyahPageViewState();
}

class _SurahAyahPageViewState extends ConsumerState<SurahAyahPageView> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  bool _hasUsedInitialScroll = false;

  int _getInitialScrollIndex(List<dynamic> ayahs) {
    if (_hasUsedInitialScroll || widget.initialAyahNumber == null) return 0;
    _hasUsedInitialScroll = true; // Mark as used
    final index = ayahs.indexWhere((a) => a.ayahNumber == widget.initialAyahNumber);
    return index != -1 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isCurrentPage) {
      return const Center(child: CupertinoActivityIndicator());
    }

    // Register active ItemPositionsListener for QuranInfoBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(activeItemPositionsListenerProvider) != _itemPositionsListener) {
        ref.read(activeItemPositionsListenerProvider.notifier).setListener(_itemPositionsListener);
      }
    });

    final state = ref.watch(quranReaderControllerProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.ayahs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppConstants.ayahLoadError,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(quranReaderControllerProvider.notifier).retry(),
              child: const Text(AppConstants.retryButtonLabel),
            ),
          ],
        ),
      );
    }

    if (state.ayahs.isEmpty) {
      return const Center(child: Text(AppConstants.noAyahFound));
    }

    // Auto-scroll listener with suspension support (gated by surah match)
    ref.listen<int?>(activeAyahProvider, (previous, next) {
      if (next != null && next != previous) {
        final audioSurahId = ref.read(quranAudioControllerProvider).currentSurahId;
        if (audioSurahId != widget.surahId) return;

        final isSuspended = ref.read(
          quranAudioControllerProvider.select((s) => s.isAutoScrollSuspended),
        );
        if (!isSuspended) {
          final targetIndex = state.ayahs.indexWhere((a) => a.ayahNumber == next);
          if (targetIndex != -1 && _itemScrollController.isAttached) {
            _itemScrollController.scrollTo(
              index: targetIndex,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              alignment: 0.08,
            );
          }
        }
      }
    });

    // Immediate Re-Sync listener when auto-scroll is resumed via Re-Sync button
    ref.listen<bool>(
      quranAudioControllerProvider.select((s) => s.isAutoScrollSuspended),
      (previous, isSuspended) {
        if (previous == true && !isSuspended) {
          final audioState = ref.read(quranAudioControllerProvider);
          if (audioState.currentSurahId != widget.surahId) return;

          final currentAyah = audioState.currentAyahNumber;
          if (currentAyah != null) {
            final targetIndex = state.ayahs.indexWhere((a) => a.ayahNumber == currentAyah);
            if (targetIndex != -1 && _itemScrollController.isAttached) {
              _itemScrollController.scrollTo(
                index: targetIndex,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                alignment: 0.08,
              );
            }
          }
        }
      },
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final isUserDrag = (notification is ScrollStartNotification && notification.dragDetails != null) ||
            (notification is ScrollUpdateNotification && notification.dragDetails != null);
        if (isUserDrag) {
          final audioState = ref.read(quranAudioControllerProvider);
          final hasActiveSession = audioState.status == AudioStatus.playing || audioState.status == AudioStatus.paused;
          final isThisSurah = audioState.currentSurahId == widget.surahId;
          if (hasActiveSession && isThisSurah) {
            ref.read(quranAudioControllerProvider.notifier).suspendAutoScroll();
          }
        }
        return false;
      },
      child: ScrollablePositionedList.builder(
        key: ValueKey('surah_list_${widget.surahId}'),
        initialScrollIndex: _getInitialScrollIndex(state.ayahs),
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        padding: EdgeInsets.only(
          left: AppDimens.marginPage,
          right: AppDimens.marginPage,
          top: AppDimens.stackSm,
          bottom: MediaQuery.paddingOf(context).bottom + 100,
        ),
        itemCount: state.ayahs.length,
        itemBuilder: (context, index) {
          final ayah = state.ayahs[index];
          final previousAyah = index > 0 ? state.ayahs[index - 1] : null;
          final isPageStart = previousAyah == null || previousAyah.page != ayah.page;
          
          return AyahListItem(
            ayah: ayah,
            surahName: widget.surahName,
            totalAyahsInSurah: state.ayahs.length,
            isPageStart: isPageStart,
          );
        },
      ),
    );
  }
}
