import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../quran_home/application/controllers/continue_reading_controller.dart';

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

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> with WidgetsBindingObserver {
  late PageController _pageController;
  late final ContinueReadingController _continueReadingNotifier;

  // Full-screen mode state
  bool _isFullScreen = false;
  bool _isControlsVisible = true;
  bool _isAudioBarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _continueReadingNotifier = ref.read(continueReadingControllerProvider.notifier);
    _pageController = PageController(initialPage: widget.surahId - 1);

    // Fetch ayahs when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quranReaderControllerProvider.notifier).fetchAyahs(widget.surahId);
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    // Save reading progress when leaving screen
    _continueReadingNotifier.saveStateToStorage();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _continueReadingNotifier.saveStateToStorage();
    }
  }

  void _syncProviderState() {
    ref.read(readerControlsProvider.notifier).updateState(
      isFullScreen: _isFullScreen,
      isControlsVisible: _isControlsVisible,
      isAudioBarCollapsed: _isAudioBarCollapsed,
    );
  }

  void _enterFullScreen() {
    // Immediately hide header & collapse audio player capsule upon entering full screen
    setState(() {
      _isFullScreen = true;
      _isControlsVisible = false;
      _isAudioBarCollapsed = true;
    });
    _syncProviderState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitFullScreen() {
    setState(() {
      _isFullScreen = false;
      _isControlsVisible = true;
      _isAudioBarCollapsed = false;
    });
    _syncProviderState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _toggleControls() {
    if (!_isFullScreen) return;
    setState(() {
      _isControlsVisible = !_isControlsVisible;
      _isAudioBarCollapsed = !_isControlsVisible;
    });
    _syncProviderState();
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
    // Listen to readerControlsProvider so taps on AyahItems correctly toggle screen controls
    ref.listen<ReaderControlsState>(readerControlsProvider, (previous, next) {
      if (next.isFullScreen &&
          (next.isControlsVisible != _isControlsVisible ||
              next.isAudioBarCollapsed != _isAudioBarCollapsed)) {
        setState(() {
          _isControlsVisible = next.isControlsVisible;
          _isAudioBarCollapsed = next.isAudioBarCollapsed;
        });
      }
    });

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
        final isTranslation = errorMessage.contains('ترجمه');

        if (isDownloadRelated) {
          AppSnackBar.showInfo(
            context,
            errorMessage,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: isTranslation ? 'دانلود ترجمه' : 'دانلود صوت',
              textColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                final targetSurahId = next.currentSurahId ?? widget.surahId;
                context.pushNamed(
                  audioDownloadManagerRoute,
                  queryParameters: {
                    'surahId': targetSurahId.toString(),
                    if (isTranslation) 'isTranslation': 'true',
                  },
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

    // Controls state in full-screen mode
    final bool controlsHidden = _isFullScreen && !_isControlsVisible;
    final double topPadding = MediaQuery.paddingOf(context).top;
    final double appBarHeight = topPadding + kToolbarHeight;

    final double infoBarHeight = 35.0;
    final double headerHeight = appBarHeight + infoBarHeight;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // 1. Column containing Header (AppBar + InfoBar) and Bounded PageView (Expanded)
          Column(
            children: [
              // Top Header & QuranInfoBar (AnimatedContainer collapses height in full-screen)
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                height: controlsHidden ? 0 : headerHeight,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.bottomCenter,
                    minHeight: 0,
                    maxHeight: headerHeight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: appBarHeight,
                          child: IslamicKatibahAppBar(
                            surahName: currentSurahName,
                            surahNumber: currentSurahId,
                            fontFamily: fontFamily,
                            actions: [
                              IconButton(
                                icon: const Icon(
                                  CupertinoIcons.bookmark,
                                  size: 20,
                                  color: Color(0xFFF4E0A5),
                                ),
                                tooltip: 'ذخیره نشانک (بوک‌مارک)',
                                onPressed: () {
                                  final currentState = _continueReadingNotifier.state;
                                  if (currentState != null) {
                                    ref.read(manualBookmarkControllerProvider.notifier).saveBookmark(currentState);
                                    AppSnackBar.showInfo(
                                      context,
                                      'نشانک با موفقیت برای این آیه ذخیره شد.',
                                      duration: const Duration(seconds: 2),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  CupertinoIcons.slider_horizontal_3,
                                  size: 20,
                                  color: Color(0xFFF4E0A5),
                                ),
                                tooltip: 'تنظیمات نمایش',
                                onPressed: () => QuickSettingsDrawer.show(context),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  CupertinoIcons.ellipsis_vertical,
                                  size: 22,
                                  color: Color(0xFFF4E0A5),
                                ),
                                tooltip: 'منو',
                                onSelected: (value) {
                                  if (value == 'fullscreen') {
                                    _enterFullScreen();
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem<String>(
                                    value: 'fullscreen',
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(CupertinoIcons.fullscreen, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'حالت تمام صفحه',
                                          style: TextStyle(
                                            fontFamily: AppTypography.fontFamily,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const QuranInfoBar(),
                      ],
                    ),
                  ),
                ),
              ),

              // Quran PageView (Bounded directly below QuranInfoBar — zero scroll under header!)
              Expanded(
                child: RepaintBoundary(
                  child: GestureDetector(
                    onTap: () {
                      if (_isFullScreen) {
                        _toggleControls();
                      }
                    },
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
                ),
              ),
            ],
          ),

          // 3. Bottom Audio Player Bar (Positioned at bottom, capsule slides behind disc)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: RepaintBoundary(
              child: isAudioPlayingOtherSurah
                  ? const MiniAudioPlayerBar()
                  : AudioPlayerBottomBar(
                      surahId: currentSurahId,
                      isFullScreen: _isFullScreen,
                      isCollapsed: _isAudioBarCollapsed,
                      onToggleCollapse: () {
                        _toggleControls();
                      },
                    ),
            ),
          ),

          // 4. Exit Full-Screen Button – ALWAYS visible in fullscreen mode!
          if (_isFullScreen)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              top: controlsHidden
                  ? topPadding + 10
                  : appBarHeight + 36,
              left: 12,
              child: RepaintBoundary(
                child: Material(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(20),
                  elevation: 6,
                  child: InkWell(
                    onTap: _exitFullScreen,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.fullscreen_exit,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'خروج از تمام‌صفحه',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
