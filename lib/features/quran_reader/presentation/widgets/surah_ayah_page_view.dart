import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../core/services/audio/audio_player_state.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../application/controllers/quran_audio_controller.dart';
import '../../application/controllers/quran_reader_controller.dart';
import '../../domain/entities/ayah_entity.dart';
import '../../../quran_home/application/controllers/continue_reading_controller.dart';
import 'ayah_list_item.dart';

class SurahAyahPageView extends ConsumerStatefulWidget {
  final int surahId;
  final String surahName;
  final bool isCurrentPage;
  final int? initialAyahNumber;
  final String? translationId;

  const SurahAyahPageView({
    super.key,
    required this.surahId,
    required this.surahName,
    required this.isCurrentPage,
    this.initialAyahNumber,
    this.translationId,
  });

  @override
  ConsumerState<SurahAyahPageView> createState() => _SurahAyahPageViewState();
}

class _SurahAyahPageViewState extends ConsumerState<SurahAyahPageView> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  bool _hasUsedInitialScroll = false;

  int _getInitialScrollIndex(List<dynamic> ayahs) {
    if (_hasUsedInitialScroll) return 0;

    final targetAyah = widget.initialAyahNumber ?? ref.read(activeAyahProvider);
    if (targetAyah != null) {
      final index = ayahs.indexWhere((a) => a.ayahNumber == targetAyah);
      if (index != -1) {
        _hasUsedInitialScroll = true;
        return index;
      }
    }
    _hasUsedInitialScroll = true;
    return 0;
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

    // Auto-scroll listener for ayah navigation and audio playback
    ref.listen<int?>(activeAyahProvider, (previous, next) {
      if (next != null) {
        final targetIndex = state.ayahs.indexWhere((a) => a.ayahNumber == next);
        if (targetIndex != -1 && _itemScrollController.isAttached) {
          final isAudioPlaying = ref.read(quranAudioControllerProvider).status == AudioStatus.playing;
          final isSuspended = ref.read(
            quranAudioControllerProvider.select((s) => s.isAutoScrollSuspended),
          );

          if (isAudioPlaying && isSuspended) return;

          _itemScrollController.scrollTo(
            index: targetIndex,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            alignment: 0.0,
          );
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
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                alignment: 0.0,
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
        
        // Track reading progress on scroll end
        if (notification is ScrollEndNotification) {
          final positions = _itemPositionsListener.itemPositions.value;
          if (positions.isNotEmpty && state.ayahs.isNotEmpty) {
            // Find the item that is currently near the top (index 0)
            final firstVisible = positions.reduce((min, position) =>
                position.itemLeadingEdge < min.itemLeadingEdge ? position : min);
            
            final index = firstVisible.index;
            if (index >= 0 && index < state.ayahs.length) {
              final ayah = state.ayahs[index];
              ref.read(continueReadingControllerProvider.notifier).updateStateInMemory(
                surahId: widget.surahId,
                surahName: widget.surahName,
                ayahNumber: ayah.ayahNumber,
                totalAyahs: state.ayahs.length,
              );
            }
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
          top: 12.0,
          bottom: MediaQuery.paddingOf(context).bottom + 140,
        ),
        itemCount: state.ayahs.length,
        itemBuilder: (context, index) {
          final ayah = state.ayahs[index];
          final previousAyah = index > 0 ? state.ayahs[index - 1] : null;
          
          final isPageStart = previousAyah == null || previousAyah.page != ayah.page;
          final isJuzStart = (previousAyah != null)
              ? (ayah.juz != null && previousAyah.juz != ayah.juz)
              : (ayah.juz != null);
          final isHizbStart = (previousAyah != null)
              ? (ayah.hizb != null && previousAyah.hizb != ayah.hizb)
              : (ayah.hizb != null);
          
          return AyahListItem(
            ayah: ayah,
            surahName: widget.surahName,
            totalAyahsInSurah: state.ayahs.length,
            isPageStart: isPageStart,
            isJuzStart: isJuzStart,
            isHizbStart: isHizbStart,
            translationId: widget.translationId,
          );
        },
      ),
    );
  }
}
