import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/app_snackbar.dart';
import '../../../../common/widgets/islamic_katibah_app_bar.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/services/audio/audio_player_state.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../surah_list/application/controllers/surah_list_controller.dart';
import '../../../surah_list/domain/entities/surah_entity.dart';
import '../../application/controllers/quran_audio_controller.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import '../../application/controllers/quran_reader_controller.dart';
import '../../application/controllers/selected_ayah_action_provider.dart';
import '../../../mini_audio_player/presentation/widgets/mini_audio_player_bar.dart';
import '../widgets/audio_player_bottom_bar.dart';
import '../widgets/quran_info_bar.dart';
import '../widgets/quick_settings_drawer.dart';
import '../widgets/surah_ayah_page_view.dart';

class QuranReaderScreen extends ConsumerStatefulWidget {
  final int surahId;
  final String surahName;
  final int? initialAyahNumber;
  final String? translationId;

  const QuranReaderScreen({
    super.key,
    required this.surahId,
    required this.surahName,
    this.initialAyahNumber,
    this.translationId,
  });

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.surahId - 1);

    // Fetch ayahs when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quranReaderControllerProvider.notifier).fetchAyahs(widget.surahId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int pageIndex) {
    final newSurahId = pageIndex + 1;
    final activeSurahId = ref.read(quranReaderControllerProvider).currentSurahId;
    if (activeSurahId == newSurahId) return;

    ref.read(quranReaderControllerProvider.notifier).fetchAyahs(newSurahId);
    ref.read(selectedAyahActionProvider.notifier).clearSelection();
  }

  String _getSurahName(WidgetRef ref, int surahId) {
    final surahs = ref.watch(surahListControllerProvider.select((s) => s.surahs));
    if (surahs.isNotEmpty) {
      final found = surahs.firstWhere(
        (s) => s.number == surahId,
        orElse: () => SurahEntity(
          number: surahId,
          name: widget.surahName,
          englishName: '',
          englishNameTranslation: '',
          numberOfAyahs: 0,
          revelationType: '',
          startPage: 1,
          startJuz: 1,
        ),
      );
      return found.name;
    }
    return widget.surahName;
  }

  @override
  Widget build(BuildContext context) {
    final currentSurahId = ref.watch(
      quranReaderControllerProvider.select((s) => s.currentSurahId),
    );

    // Listen to reader errors
    ref.listen(quranReaderControllerProvider, (previous, next) {
      if (next.errorMessage != null && previous?.errorMessage != next.errorMessage) {
        AppSnackBar.showError(context, next.errorMessage!);
      }
    });

    // Listen to audio errors – distinguish download-related messages
    ref.listen(quranAudioControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        final errorMessage = next.errorMessage!;
        final isDownloadRelated = errorMessage.contains('دانلود');

        if (isDownloadRelated) {
          AppSnackBar.showInfo(
            context,
            errorMessage,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'دانلود صوت',
              textColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                final targetSurahId = next.currentSurahId ?? widget.surahId;
                context.pushNamed(
                  audioDownloadManagerRoute,
                  queryParameters: {'surahId': targetSurahId.toString()},
                );
              },
            ),
          );
        } else {
          AppSnackBar.showError(context, errorMessage);
        }

        // Immediately reset error in state so subsequent taps will trigger ref.listen again
        ref.read(quranAudioControllerProvider.notifier).clearError();
      }
    });

    // Automatic page transition when audio moves to another surah
    ref.listen<int?>(
      quranAudioControllerProvider.select((s) => s.currentSurahId),
      (previous, nextSurahId) {
        if (nextSurahId != null && nextSurahId != currentSurahId) {
          final targetPageIndex = nextSurahId - 1;
          if (_pageController.hasClients && targetPageIndex >= 0 && targetPageIndex < 114) {
            _pageController.animateToPage(
              targetPageIndex,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOutCubic,
            );
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
          s.currentSurahId != currentSurahId &&
          s.status != AudioStatus.stopped),
    );

    final currentSurahName = _getSurahName(ref, currentSurahId);

    return Scaffold(
        extendBody: true,
        appBar: IslamicKatibahAppBar(
          surahName: currentSurahName,
        surahNumber: currentSurahId,
        fontFamily: fontFamily,
        actions: [
          IconButton(
            icon: const Icon(
              CupertinoIcons.slider_horizontal_3,
              size: 20,
              color: Color(0xFFF4E0A5),
            ),
            tooltip: 'تنظیمات نمایش',
            onPressed: () => QuickSettingsDrawer.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const QuranInfoBar(),
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => ref.read(selectedAyahActionProvider.notifier).clearSelection(),
                  behavior: HitTestBehavior.translucent,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: 114,
                    onPageChanged: _onPageChanged,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, pageIndex) {
                      final pageSurahId = pageIndex + 1;
                      return SurahAyahPageView(
                        key: ValueKey('surah_page_$pageSurahId'),
                        surahId: pageSurahId,
                        surahName: _getSurahName(ref, pageSurahId),
                        isCurrentPage: pageSurahId == currentSurahId,
                        initialAyahNumber: pageSurahId == widget.surahId ? widget.initialAyahNumber : null,
                        translationId: widget.translationId,
                      );
                    },
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: isAudioPlayingOtherSurah
                      ? const MiniAudioPlayerBar()
                      : AudioPlayerBottomBar(surahId: currentSurahId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


