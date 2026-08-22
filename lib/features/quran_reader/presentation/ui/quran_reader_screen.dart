import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../common/widgets/islamic_katibah_app_bar.dart';
import '../../../../core/services/audio/audio_player_state.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/quran_audio_controller.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import '../../application/controllers/quran_reader_controller.dart';
import '../../application/controllers/selected_ayah_action_provider.dart';
import '../../application/states/quran_reader_state.dart';
import '../../../mini_audio_player/presentation/widgets/mini_audio_player_bar.dart';
import '../widgets/audio_player_bottom_bar.dart';
import '../widgets/ayah_list_item.dart';
import '../widgets/quick_settings_drawer.dart';
import '../widgets/quran_info_bar.dart';

class QuranReaderScreen extends ConsumerStatefulWidget {
  final int surahId;
  final String surahName;

  const QuranReaderScreen({
    super.key,
    required this.surahId,
    required this.surahName,
  });

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    // Fetch ayahs when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quranReaderControllerProvider.notifier).fetchAyahs(widget.surahId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quranReaderControllerProvider);

    // Listen to reader errors
    ref.listen(quranReaderControllerProvider, (previous, next) {
      if (next.errorMessage != null && previous?.errorMessage != next.errorMessage) {
        AppSnackBar.showError(context, next.errorMessage!);
      }
    });

    // Listen to audio errors
    ref.listen(quranAudioControllerProvider, (previous, next) {
      if (next.errorMessage != null && previous?.errorMessage != next.errorMessage) {
        AppSnackBar.showError(context, next.errorMessage!);
      }
    });

    // Auto-scroll listener with suspension support (gated by surah match)
    ref.listen<int?>(activeAyahProvider, (previous, next) {
      if (next != null && next != previous) {
        // Only auto-scroll if audio is for THIS surah
        final audioSurahId = ref.read(quranAudioControllerProvider).currentSurahId;
        if (audioSurahId != widget.surahId) return;

        final isSuspended = ref.read(
          quranAudioControllerProvider.select((s) => s.isAutoScrollSuspended),
        );
        if (!isSuspended) {
          final ayahs = ref.read(quranReaderControllerProvider).ayahs;
          final targetIndex = ayahs.indexWhere((a) => a.ayahNumber == next);
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
          // Only re-sync if audio is for THIS surah
          final audioState = ref.read(quranAudioControllerProvider);
          if (audioState.currentSurahId != widget.surahId) return;

          final currentAyah = audioState.currentAyahNumber;
          if (currentAyah != null) {
            final ayahs = ref.read(quranReaderControllerProvider).ayahs;
            final targetIndex = ayahs.indexWhere((a) => a.ayahNumber == currentAyah);
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

    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final fontFamily = AppTypography.getFontFamilyByScript(fontScript);

    // Determine if audio is playing for a DIFFERENT surah
    final isAudioPlayingOtherSurah = ref.watch(
      quranAudioControllerProvider.select((s) =>
          s.currentSurahId != null &&
          s.currentSurahId != widget.surahId &&
          s.status != AudioStatus.stopped),
    );

    return Scaffold(
      extendBody: true,
      appBar: IslamicKatibahAppBar(
        surahName: widget.surahName,
        surahNumber: widget.surahId,
        fontFamily: fontFamily,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.tune_rounded,
              size: 20,
              color: Color(0xFFF4E0A5),
            ),
            tooltip: 'تنظیمات نمایش',
            onPressed: () => QuickSettingsDrawer.show(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (!state.isLoading && state.ayahs.isNotEmpty)
                QuranInfoBar(
                  itemPositionsListener: _itemPositionsListener,
                  ayahs: state.ayahs,
                ),
              Expanded(
                child: GestureDetector(
                  onTap: () => ref.read(selectedAyahActionProvider.notifier).clearSelection(),
                  behavior: HitTestBehavior.translucent,
                  child: _buildBody(state),
                ),
              ),
            ],
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: isAudioPlayingOtherSurah
                ? const MiniAudioPlayerBar()
                : AudioPlayerBottomBar(surahId: widget.surahId),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(QuranReaderState state) {
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
          return AyahListItem(
            ayah: ayah,
            surahName: widget.surahName,
            totalAyahsInSurah: state.ayahs.length,
          );
        },
      ),
    );
  }
}
