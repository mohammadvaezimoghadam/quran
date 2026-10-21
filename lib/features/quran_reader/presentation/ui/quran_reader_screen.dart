import '../../../../common/extensions/int_extension.dart';
import '../../../topic_studio/application/controllers/in_drawer_editor_controller.dart';
import '../../../topic_studio/domain/entities/topic_drag_data.dart';
import '../../../topic_studio/presentation/ui/tafakor_editor_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'dart:async';
import 'dart:ui';

import '../../../../common/widgets/app_snackbar.dart';
import '../../../../common/widgets/surah_picker_dialog.dart';
import '../widgets/quran_reader_app_bar.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/services/audio/audio_player_state.dart';
import '../../../../core/services/quran_navigation/domain/entities/ayah_target.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../surah_list/application/controllers/surah_list_controller.dart';
import '../../../surah_list/domain/entities/surah_entity.dart';
import '../../application/controllers/quran_audio_controller.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../main_navigation/presentation/widgets/web_docked_audio_player_bar.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import '../../application/controllers/quran_reader_controller.dart';
import '../../application/controllers/selected_ayah_action_provider.dart';
import '../../../mini_audio_player/presentation/widgets/mini_audio_player_bar.dart';
import '../widgets/audio_player_bottom_bar.dart';
import '../widgets/quran_info_bar.dart';
import '../widgets/quick_settings_drawer.dart';
import '../widgets/surah_ayah_page_view.dart';
import '../widgets/word_by_word_bottom_sheet.dart';
import '../../domain/entities/ayah_entity.dart';
import '../../domain/entities/ayah_theme_entity.dart';
import '../../../bookmarks/application/controllers/bookmarks_controller.dart';
import '../../../quick_access/presentation/widgets/bookmarks_manager_bottom_sheet.dart';
import '../../../bookmarks/presentation/widgets/ayah_bookmark_editor_bottom_sheet.dart';
import '../../../../common/extensions/surah_name_extension.dart';
import '../../../quran_home/application/controllers/continue_reading_controller.dart';
import '../../../khatm/presentation/widgets/reader/khatm_reader_bar.dart';
import '../../../khatm/presentation/widgets/reader/khatm_quick_bottom_sheet.dart';
import '../../../khatm/application/controllers/khatm_detail_controller.dart';
import '../../../khatm/domain/services/khatm_quran_resolver.dart';
import '../../../khatm/infrastructure/datasources/khatm_quran_data.dart';
import '../../../study_plan/domain/entities/study_plan.dart';
import '../../../study_plan/application/controllers/study_plan_controller.dart';
import '../../../study_plan/presentation/widgets/study_plan_quick_bottom_sheet.dart';
import '../../../study_plan/presentation/widgets/study_plan_reader_bar.dart';
import '../../../surah_list/infrastructure/datasources/static_surahs_data.dart';

class QuranReaderScreen extends ConsumerStatefulWidget {
  final int surahId;
  final String surahName;
  final int? initialAyahNumber;
  final String? translationId;
  final bool autoPlayAudio;
  final bool isStudyPlan;
  final String? khatmId;
  final int? khatmSession;

  const QuranReaderScreen({
    super.key,
    required this.surahId,
    required this.surahName,
    this.initialAyahNumber,
    this.translationId,
    this.autoPlayAudio = false,
    this.isStudyPlan = false,
    this.khatmId,
    this.khatmSession,
  });

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> with WidgetsBindingObserver {
  late PageController _pageController;
  late final ContinueReadingController _continueReadingNotifier;
  late final ReaderControlsNotifier _readerControlsNotifier;
  late final StudyPlanController _studyPlanNotifier;
  late final StudyPlanSessionActiveNotifier _studyPlanSessionNotifier;

  // Full-screen mode state
  bool _isFullScreen = false;
  bool _isControlsVisible = true;
  bool _isAudioBarCollapsed = false;
  bool _isExitButtonVisible = false;
  Timer? _exitButtonFadeTimer;

  // Quick jump tracking
  int? _targetSurahId;
  int? _targetAyahNumber;
  late int _activePageSurahId;

  // Active Khatm session tracking
  String? _activeKhatmId;
  int? _activeKhatmSession;
  late final ActiveKhatmSessionNotifier _activeKhatmSessionNotifier;

  static const Duration _exitButtonFadeDelay = Duration(milliseconds: 3500);

  @override
  void initState() {
    super.initState();
    _activePageSurahId = widget.surahId;
    _activeKhatmId = widget.khatmId;
    _activeKhatmSession = widget.khatmSession;
    _continueReadingNotifier = ref.read(continueReadingControllerProvider.notifier);
    _readerControlsNotifier = ref.read(readerControlsProvider.notifier);
    _studyPlanNotifier = ref.read(studyPlanControllerProvider.notifier);
    _studyPlanSessionNotifier = ref.read(isStudyPlanSessionActiveProvider.notifier);
    _activeKhatmSessionNotifier = ref.read(activeKhatmSessionProvider.notifier);
    _pageController = PageController(initialPage: widget.surahId - 1);

    // Fetch ayahs when screen loads & ensure clean normal controls state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _studyPlanSessionNotifier.set(widget.isStudyPlan);
      if (_activeKhatmId != null && _activeKhatmSession != null) {
        _activeKhatmSessionNotifier.setActive(
          khatmId: _activeKhatmId!,
          sessionIndex: _activeKhatmSession!,
        );
        final initialAyah = widget.initialAyahNumber ?? 1;
        final initialPage = KhatmQuranData.getPageForAyah(widget.surahId, initialAyah);
        ref
            .read(khatmDetailControllerProvider(_activeKhatmId!).notifier)
            .recordReadingProgress(
              sessionIndex: _activeKhatmSession!,
              surahId: widget.surahId,
              ayahNumber: initialAyah,
              page: initialPage,
              isEndOfPage: false,
              pageFraction: 0.0,
            );
      }
      _readerControlsNotifier.reset();
      ref.read(quranReaderControllerProvider.notifier).fetchAyahs(widget.surahId);

      if (widget.autoPlayAudio) {
        final targetAyah = widget.initialAyahNumber ?? 1;
        final totalAyahs = widget.surahId >= 1 && widget.surahId <= 114
            ? kStaticQuranSurahs[widget.surahId - 1].numberOfAyahs
            : 7;
        ref.read(quranAudioControllerProvider.notifier).playAyah(
          surahId: widget.surahId,
          ayahNumber: targetAyah,
          totalAyahsInSurah: totalAyahs,
        );
      }
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(QuranReaderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isStudyPlan != widget.isStudyPlan) {
      _studyPlanSessionNotifier.set(widget.isStudyPlan);
    }
    if (oldWidget.khatmId != widget.khatmId || oldWidget.khatmSession != widget.khatmSession) {
      _activeKhatmId = widget.khatmId;
      _activeKhatmSession = widget.khatmSession;
      if (_activeKhatmId != null && _activeKhatmSession != null) {
        _activeKhatmSessionNotifier.setActive(
          khatmId: _activeKhatmId!,
          sessionIndex: _activeKhatmSession!,
        );
      } else {
        _activeKhatmSessionNotifier.clear();
      }
    }
  }

  @override
  void dispose() {
    _exitButtonFadeTimer?.cancel();
    _activeKhatmSessionNotifier.clear();
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    // Save reading progress when leaving screen
    _continueReadingNotifier.saveStateToStorage();
    _studyPlanNotifier.flushPendingSave();
    Future.microtask(() => _studyPlanSessionNotifier.set(false));
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _continueReadingNotifier.saveStateToStorage();
      _studyPlanNotifier.flushPendingSave();
    }
  }

  void _startExitButtonFadeTimer() {
    _exitButtonFadeTimer?.cancel();
    _exitButtonFadeTimer = Timer(_exitButtonFadeDelay, () {
      if (mounted && _isFullScreen) {
        setState(() {
          _isExitButtonVisible = false;
        });
      }
    });
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
      _isExitButtonVisible = true;
    });
    ref.read(readerControlsProvider.notifier).enterFullScreen();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startExitButtonFadeTimer();
  }

  void _exitFullScreen() {
    _exitButtonFadeTimer?.cancel();
    setState(() {
      _isFullScreen = false;
      _isControlsVisible = true;
      _isAudioBarCollapsed = false;
      _isExitButtonVisible = false;
    });
    ref.read(readerControlsProvider.notifier).exitFullScreen();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  void _toggleControls() {
    if (!_isFullScreen) return;
    final nextVisible = !_isControlsVisible;
    setState(() {
      _isControlsVisible = nextVisible;
      _isAudioBarCollapsed = !nextVisible;
      _isExitButtonVisible = true;
    });
    if (!nextVisible) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      ref.read(isKhatmReaderBarCollapsedProvider.notifier).setCollapsed(false);
    }
    _syncProviderState();
    _startExitButtonFadeTimer();
  }

  void _onPageChanged(int pageIndex) {
    if (!mounted) return;
    final newSurahId = pageIndex + 1;
    setState(() {
      _activePageSurahId = newSurahId;
      _targetSurahId = null;
      _targetAyahNumber = null;
    });

    final activeSurahId = ref.read(quranReaderControllerProvider).currentSurahId;
    if (activeSurahId == newSurahId) return;

    ref.read(quranReaderControllerProvider.notifier).fetchAyahs(newSurahId);
    ref.read(selectedAyahActionProvider.notifier).clearSelection();

    if (_activeKhatmId != null && _activeKhatmSession != null) {
      final startPage = kStaticQuranSurahs[newSurahId - 1].startPage;
      ref
          .read(khatmDetailControllerProvider(_activeKhatmId!).notifier)
          .recordReadingProgress(
            sessionIndex: _activeKhatmSession!,
            surahId: newSurahId,
            ayahNumber: 1,
            page: startPage,
          );
    }
  }

  void _handleTargetSelected(AyahTarget target) {
    if (!mounted) return;
    setState(() {
      _activePageSurahId = target.surahId;
      _targetSurahId = target.surahId;
      _targetAyahNumber = target.ayahNumber;
    });

    final currentSurahId = ref.read(quranReaderControllerProvider).currentSurahId;
    if (target.surahId != currentSurahId) {
      ref.read(quranReaderControllerProvider.notifier).fetchAyahs(target.surahId);
      if (_pageController.hasClients) {
        _pageController.jumpToPage(target.surahId - 1);
      }
    }

    ref.read(navigationTargetProvider.notifier).forceTarget(target);

    // Track active Khatm session progress upon navigation target
    if (_activeKhatmId != null && _activeKhatmSession != null) {
      final targetPage = KhatmQuranData.getPageForAyah(target.surahId, target.ayahNumber);
      ref
          .read(khatmDetailControllerProvider(_activeKhatmId!).notifier)
          .recordReadingProgress(
            sessionIndex: _activeKhatmSession!,
            surahId: target.surahId,
            ayahNumber: target.ayahNumber,
            page: targetPage,
            isEndOfPage: false,
          );
    }
  }

  String _getSurahName(WidgetRef ref, int surahId) {
    if (surahId >= 1 && surahId <= 114) {
      return 'سوره ${surahId.surahNameFa}';
    }
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
      return 'سوره ${found.nameFa}';
    }
    return widget.surahName;
  }

  int _resolveVisibleAyahNumber(
    Iterable<ItemPosition>? positions,
    List<AyahEntity> ayahs,
    int currentSurahId,
  ) {
    if (ayahs.isNotEmpty && positions != null && positions.isNotEmpty) {
      const topCutoff = 0.18;
      const readingBaseline = 0.22;
      ItemPosition? targetPos;
      for (final p in positions) {
        if (p.itemLeadingEdge <= readingBaseline && p.itemTrailingEdge > readingBaseline) {
          targetPos = p;
          break;
        }
      }
      if (targetPos == null) {
        final lastPos = positions.where((p) => p.index == ayahs.length - 1).firstOrNull;
        if (lastPos != null && lastPos.itemTrailingEdge <= readingBaseline) {
          targetPos = lastPos;
        } else {
          final visiblePositions = positions.where((p) => p.itemTrailingEdge > topCutoff).toList();
          if (visiblePositions.isNotEmpty) {
            targetPos = visiblePositions.reduce((min, cur) => cur.index < min.index ? cur : min);
          }
        }
      }
      if (targetPos != null && targetPos.index >= 0 && targetPos.index < ayahs.length) {
        return ayahs[targetPos.index].ayahNumber;
      }
    }

    final audioState = ref.read(quranAudioControllerProvider);
    if (audioState.currentSurahId == currentSurahId && audioState.currentAyahNumber != null) {
      return audioState.currentAyahNumber!;
    }

    final continueReading = ref.read(continueReadingControllerProvider);
    if (continueReading?.surahId == currentSurahId && continueReading?.ayahNumber != null) {
      return continueReading!.ayahNumber;
    }

    return 1;
  }

  int _getActiveOrVisibleAyahNumber() {
    final selectedSet = ref.read(selectedAyahActionProvider);
    if (selectedSet.isNotEmpty) {
      return selectedSet.first;
    }
    final listener = ref.read(activeItemPositionsListenerProvider);
    final ayahs = ref.read(quranReaderControllerProvider).ayahs;
    final currentSurahId = _activePageSurahId;
    return _resolveVisibleAyahNumber(listener?.itemPositions.value, ayahs, currentSurahId);
  }

  // --- Gesture Zoom State ---
  final Map<int, Offset> _activePointers = {};
  double? _initialDistance;
  double? _initialArabicFontSize;
  double? _initialTranslationFontSize;

  void _onPointerDown(PointerDownEvent event) {
    _activePointers[event.pointer] = event.position;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_activePointers.containsKey(event.pointer)) return;
    _activePointers[event.pointer] = event.position;

    if (_activePointers.length == 2) {
      final positions = _activePointers.values.toList();
      final distance = (positions[0] - positions[1]).distance;

      if (_initialDistance == null) {
        _initialDistance = distance;
        final settings = ref.read(quranDisplaySettingsControllerProvider);
        _initialArabicFontSize = settings.arabicFontSize;
        _initialTranslationFontSize = settings.translationFontSize;
        ref.read(isInteractivePinchZoomingProvider.notifier).setZooming(true);
      } else {
        final scale = distance / _initialDistance!;
        
        final newArabic = (_initialArabicFontSize! * scale).clamp(18.0, 42.0);
        final newTranslation = (_initialTranslationFontSize! * scale).clamp(12.0, 26.0);
        
        final currentArabic = ref.read(quranDisplaySettingsControllerProvider).arabicFontSize;
        // Throttle updates: only apply if change is >= 0.5 points to eliminate micro-jitter
        if ((newArabic - currentArabic).abs() >= 0.5) {
          ref.read(quranDisplaySettingsControllerProvider.notifier)
              .updateFontSizes(arabicFontSize: newArabic, translationFontSize: newTranslation);
        }
      }
    }
  }

  void _onPointerUp(PointerEvent event) {
    _activePointers.remove(event.pointer);
    if (_activePointers.length < 2) {
      if (_initialDistance != null) {
        // Pinch zoom ended: reset interactive flag and save settings
        ref.read(isInteractivePinchZoomingProvider.notifier).setZooming(false);
        ref.read(quranDisplaySettingsControllerProvider.notifier).saveSettingsIfChanged();
      }
      _initialDistance = null;
      _initialArabicFontSize = null;
      _initialTranslationFontSize = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to readerControlsProvider so taps on AyahItems correctly toggle screen controls
    ref.listen<ReaderControlsState>(readerControlsProvider, (previous, next) {
      if (next.isControlsVisible != _isControlsVisible ||
          next.isAudioBarCollapsed != _isAudioBarCollapsed ||
          next.isFullScreen != _isFullScreen) {
        setState(() {
          _isFullScreen = next.isFullScreen;
          _isControlsVisible = next.isControlsVisible;
          _isAudioBarCollapsed = next.isAudioBarCollapsed;
          _isExitButtonVisible = next.isFullScreen;
        });
        if (!next.isControlsVisible) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        } else if (!next.isFullScreen) {
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: SystemUiOverlay.values,
          );
        }
        if (next.isFullScreen) {
          _startExitButtonFadeTimer();
        } else {
          _exitButtonFadeTimer?.cancel();
        }
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
          setState(() {
            _activePageSurahId = nextSurahId;
            _targetSurahId = null;
            _targetAyahNumber = null;
          });
          ref.read(quranReaderControllerProvider.notifier).fetchAyahs(nextSurahId);
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

    // Listen to study plan goal completion
    ref.listen<StudyPlan?>(todayGoalCompletedEventProvider, (prev, completedPlan) {
      if (completedPlan != null) {
        ref.read(todayGoalCompletedEventProvider.notifier).clear();
        HapticFeedback.lightImpact();
        // Stop audio immediately when today's goal is completed
        final audioState = ref.read(quranAudioControllerProvider);
        if (audioState.status == AudioStatus.playing || audioState.status == AudioStatus.loading) {
          ref.read(quranAudioControllerProvider.notifier).stop();
        }
        AppSnackBar.showInfo(
          context,
          'هدف مطالعه امروز تکمیل شد.',
        );
      }
    });

    // Listen to jump target from StudyPlanQuickBottomSheet
    ref.listen(studyPlanJumpTargetProvider, (prev, target) {
      if (target != null) {
        ref.read(studyPlanJumpTargetProvider.notifier).clear();
        _handleTargetSelected(target);
      }
    });

    // Determine if audio is playing for a DIFFERENT surah
    final isAudioPlayingOtherSurah = ref.watch(
      quranAudioControllerProvider.select((s) =>
          s.currentSurahId != null &&
          s.currentSurahId != currentSurahId &&
          s.status != AudioStatus.stopped),
    );

    // OPTIMIZATION: Only rebuild the entire screen when entering/exiting selection mode.
    // The specific count changes are handled locally via a Consumer around the AppBar.
    final isSelectionMode = ref.watch(
      selectedAyahActionProvider.select((set) => set.isNotEmpty),
    );

    final currentSurahName = _getSurahName(ref, currentSurahId);

    // Controls state in full-screen mode
    final bool controlsHidden = _isFullScreen && !_isControlsVisible;
    final double topPadding = MediaQuery.paddingOf(context).top;
    final double appBarHeight = topPadding + 60.0;

    final double infoBarHeight = 40.0;
    final bool isSessionActive = ref.watch(isStudyPlanSessionActiveProvider);
    final bool hasActivePlan = isSessionActive && ref.watch(
      studyPlanControllerProvider.select(
        (s) => s.activePlan != null && s.activePlan!.status == StudyPlanStatus.active,
      ),
    );
    ref.listen<ActiveKhatmSession?>(
      activeKhatmSessionProvider,
      (prev, next) {
        if (next != null) {
          if (_activeKhatmId != next.khatmId || _activeKhatmSession != next.sessionIndex) {
            setState(() {
              _activeKhatmId = next.khatmId;
              _activeKhatmSession = next.sessionIndex;
            });
          }
        } else {
          if (_activeKhatmId != null || _activeKhatmSession != null) {
            setState(() {
              _activeKhatmId = null;
              _activeKhatmSession = null;
            });
          }
        }
      },
    );

    final activeKhatmSession = ref.watch(activeKhatmSessionProvider);
    final bool hasKhatmSession = activeKhatmSession != null;
    final bool isKhatmCollapsed = ref.watch(isKhatmReaderBarCollapsedProvider);
    final double khatmBarHeight = hasKhatmSession
        ? (isKhatmCollapsed ? KhatmReaderBar.collapsedHeight : KhatmReaderBar.barHeight)
        : 0.0;
    final double studyPlanBarHeight = (hasActivePlan && !hasKhatmSession) ? 36.0 : 0.0;
    final double headerHeight = appBarHeight + infoBarHeight + studyPlanBarHeight + khatmBarHeight;
    final double expandedHeaderHeight = appBarHeight +
        infoBarHeight +
        studyPlanBarHeight +
        (hasKhatmSession ? KhatmReaderBar.barHeight : 0.0);

    final ayahThemeId = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.ayahThemeId),
    );
    final activeTheme = AyahThemePresets.getById(ayahThemeId);
    final scaffoldBgColor = activeTheme.evenColor;

    return PopScope(
      canPop: !isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && isSelectionMode) {
          ref.read(selectedAyahActionProvider.notifier).clearSelection();
          return;
        }
        if (didPop) {
          _exitButtonFadeTimer?.cancel();
          _isFullScreen = false;
          _isExitButtonVisible = false;
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: SystemUiOverlay.values,
          );
          ref.read(readerControlsProvider.notifier).reset();
          ref.read(isStudyPlanSessionActiveProvider.notifier).set(false);
          ref.read(activeKhatmSessionProvider.notifier).clear();
          ref.read(isKhatmReaderBarCollapsedProvider.notifier).setCollapsed(false);
        }
      },
      child: Scaffold(
        backgroundColor: scaffoldBgColor,
        extendBody: true,
        body: Stack(
          children: [
          // 1. Quran PageView (Full Screen, underneath the header overlay)
          Positioned.fill(
                child: RepaintBoundary(
                  child: Listener(
                    onPointerDown: _onPointerDown,
                    onPointerMove: _onPointerMove,
                    onPointerUp: _onPointerUp,
                    onPointerCancel: _onPointerUp,
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
                        physics: const HighResistancePageScrollPhysics(
                          parent: PageScrollPhysics(parent: BouncingScrollPhysics()),
                        ),
                        itemBuilder: (context, pageIndex) {
                          final pageSurahId = pageIndex + 1;
                          final isTargetPage = pageSurahId == _activePageSurahId;
                          final initialAyahForPage = (pageSurahId == _targetSurahId)
                              ? _targetAyahNumber
                              : (pageSurahId == widget.surahId ? widget.initialAyahNumber : null);
                          return SurahAyahPageView(
                            key: ValueKey('surah_page_$pageSurahId'),
                            surahId: pageSurahId,
                            surahName: _getSurahName(ref, pageSurahId),
                            isCurrentPage: isTargetPage,
                            initialAyahNumber: initialAyahForPage,
                            translationId: widget.translationId,
                            topPadding: expandedHeaderHeight + 8.0,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Animated Header (Overlaid on top of the PageView)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                top: controlsHidden ? -headerHeight : 0,
                left: 0,
                right: 0,
                height: headerHeight,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    minHeight: 0,
                    maxHeight: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: appBarHeight,
                          child: Consumer(
                            builder: (context, ref, child) {
                              final selectedCount = ref.watch(
                                selectedAyahActionProvider.select((set) => set.length),
                              );
                              final selectedSet = ref.watch(selectedAyahActionProvider);
                              final itemPositionsListener = ref.watch(activeItemPositionsListenerProvider);
                              final allAyahs = ref.watch(quranReaderControllerProvider.select((s) => s.ayahs));
                              final targetAyah = selectedSet.isNotEmpty
                                  ? selectedSet.first
                                  : _resolveVisibleAyahNumber(
                                      itemPositionsListener?.itemPositions.value,
                                      allAyahs,
                                      currentSurahId,
                                    );
                              final isAyahBookmarked = ref.watch(
                                bookmarksControllerProvider.select(
                                  (list) => list.any(
                                    (b) =>
                                        b.surahId == currentSurahId &&
                                        b.ayahNumber == targetAyah,
                                  ),
                                ),
                              );

                              return QuranReaderAppBar(
                                surahName: currentSurahName,
                                surahNumber: currentSurahId,
                                isSelectionMode: isSelectionMode,
                                selectedCount: selectedCount,
                                isBookmarked: isAyahBookmarked,
                                onBackPressed: () {
                                  _exitButtonFadeTimer?.cancel();
                                  _isFullScreen = false;
                                  _isExitButtonVisible = false;
                                  SystemChrome.setEnabledSystemUIMode(
                                    SystemUiMode.manual,
                                    overlays: SystemUiOverlay.values,
                                  );
                                  ref.read(readerControlsProvider.notifier).reset();
                                  ref.read(isStudyPlanSessionActiveProvider.notifier).set(false);
                                  Navigator.of(context).maybePop();
                                },
                                onSurahTap: () async {
                                  final surahs = ref.read(surahListControllerProvider).surahs;
                                  final currentSurah = surahs.where((s) => s.number == currentSurahId).firstOrNull;
                                  final selected = await SurahPickerDialog.show(
                                    context,
                                    activeSurah: currentSurah,
                                    surahs: surahs,
                                  );
                                  if (selected != null && _pageController.hasClients) {
                                    _pageController.jumpToPage(selected.number - 1);
                                  }
                                },
                                onClearSelection: () {
                                  ref.read(selectedAyahActionProvider.notifier).clearSelection();
                                },
                            onCopySelected: () {
                              final allAyahs = ref.read(quranReaderControllerProvider).ayahs;
                              ref.read(selectedAyahActionProvider.notifier).copySelectedAyahs(
                                    context: context,
                                    ayahs: allAyahs,
                                    surahName: currentSurahName,
                                  );
                            },
                            onShareSelected: () {
                              final allAyahs = ref.read(quranReaderControllerProvider).ayahs;
                              ref.read(selectedAyahActionProvider.notifier).shareSelectedAyahs(
                                    context: context,
                                    ayahs: allAyahs,
                                    surahName: currentSurahName,
                                  );
                            },
                            onTafakorSelected: () {
                              HapticFeedback.lightImpact();
                              final currentSelected = ref.read(selectedAyahActionProvider);
                              final allAyahs = ref.read(quranReaderControllerProvider).ayahs;
                              final targetAyahs = allAyahs
                                  .where((a) => currentSelected.contains(a.ayahNumber))
                                  .toList();
                              targetAyahs.sort((a, b) => a.ayahNumber.compareTo(b.ayahNumber));

                              final removeBrackets = ref
                                  .read(quranDisplaySettingsControllerProvider)
                                  .removeTranslationBrackets;

                              final dragData = TopicDragData(
                                ayahs: targetAyahs,
                                surahName: currentSurahName,
                                removeBrackets: removeBrackets,
                              );
                              final blocks = dragData.toBlocks();

                              ref.read(inDrawerEditorControllerProvider.notifier).setBlocks(blocks);
                              ref.read(selectedAyahActionProvider.notifier).clearSelection();

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const TafakorEditorScreen(),
                                ),
                              );
                            },
                            onDictionarySelected: () {
                              final selectedSet = ref.read(selectedAyahActionProvider);
                              if (selectedSet.isNotEmpty) {
                                final firstAyahNum = selectedSet.first;
                                ref.read(selectedAyahActionProvider.notifier).clearSelection();
                                WordByWordBottomSheet.show(
                                  context,
                                  surahId: currentSurahId,
                                  surahName: currentSurahName,
                                  ayahNumber: firstAyahNum,
                                );
                              }
                            },
                             onBookmarkPressed: () {
                               final currentSelected = ref.read(selectedAyahActionProvider);
                               final hasSelection = currentSelected.isNotEmpty;
                               final ayahNum = hasSelection
                                   ? currentSelected.first
                                   : _getActiveOrVisibleAyahNumber();
                               final currentState = ref.read(continueReadingControllerProvider);
                               final allAyahs = ref.read(quranReaderControllerProvider).ayahs;
                               final totalAyahs = (currentState?.surahId == currentSurahId && (currentState?.totalAyahs ?? 0) > 0)
                                   ? currentState!.totalAyahs
                                   : allAyahs.length;
                               final ayahEntity = allAyahs.where((a) => a.ayahNumber == ayahNum).firstOrNull;
                               final existingBookmark = ref.read(bookmarksControllerProvider).where(
                                     (b) => b.surahId == currentSurahId && b.ayahNumber == ayahNum,
                                   ).firstOrNull;

                               if (hasSelection) {
                                 ref.read(selectedAyahActionProvider.notifier).clearSelection();
                               }

                               if (existingBookmark != null) {
                                 HapticFeedback.lightImpact();
                                 ref.read(bookmarksControllerProvider.notifier).removeBookmark(currentSurahId, ayahNum);
                                 AppSnackBar.showSuccess(
                                   context,
                                   'آیه ${ayahNum.toPersianDigit()} سوره $currentSurahName از نشانه‌ها حذف شد.',
                                 );
                                 return;
                               }

                               final isAyahBookmark = hasSelection;

                               HapticFeedback.lightImpact();
                               AyahBookmarkEditorBottomSheet.show(
                                 context,
                                 surahId: currentSurahId,
                                 surahName: currentSurahName,
                                 ayahNumber: ayahNum,
                                 totalAyahs: totalAyahs,
                                 arabicText: ayahEntity?.arabicText,
                                 initialNote: null,
                                 initialLabelIds: const [],
                                 isAlreadyBookmarked: false,
                                 isAyahBookmark: isAyahBookmark,
                               );
                             },
                             onMenuSelected: (value) {
                               if (value == 'fullscreen') {
                                 if (_isFullScreen) {
                                   _exitFullScreen();
                                 } else {
                                   _enterFullScreen();
                                 }
                               } else if (value == 'settings') {
                                 QuickSettingsDrawer.show(context);
                               } else if (value == 'khatm_plan' || value == 'study_plan') {
                                 final readingState = ref.read(continueReadingControllerProvider);
                                 final curSurah = readingState?.surahId ?? currentSurahId;
                                 final curAyah = readingState?.ayahNumber ?? 1;
                                 final curPage = KhatmQuranData.getPageForAyah(curSurah, curAyah);

                                 KhatmQuickBottomSheet.show(
                                   context,
                                   activeKhatmId: activeKhatmSession?.khatmId ?? _activeKhatmId,
                                   currentSurahId: curSurah,
                                   currentAyahNumber: curAyah,
                                   currentPage: curPage,
                                 ).then((result) {
                                   if (result != null && mounted) {
                                     setState(() {
                                       _activeKhatmId = result.khatmId;
                                       _activeKhatmSession = result.sessionIndex;
                                     });
                                     ref.read(activeKhatmSessionProvider.notifier).setActive(
                                           khatmId: result.khatmId,
                                           sessionIndex: result.sessionIndex,
                                         );
                                     if (result.shouldJump && result.target != null) {
                                       _handleTargetSelected(result.target!);
                                     } else {
                                       ref
                                           .read(khatmDetailControllerProvider(result.khatmId).notifier)
                                           .recordReadingProgress(
                                             sessionIndex: result.sessionIndex,
                                             surahId: curSurah,
                                             ayahNumber: curAyah,
                                             page: curPage,
                                           );
                                     }
                                   }
                                 });
                               } else if (value == 'bookmarks') {
                                 BookmarksManagerBottomSheet.show(context);
                               } else if (value == 'toggle_brackets') {
                                 final current = ref.read(quranDisplaySettingsControllerProvider).removeTranslationBrackets;
                                 final notifier = ref.read(quranDisplaySettingsControllerProvider.notifier);
                                 notifier.recordInitialState();
                                 notifier.toggleRemoveTranslationBrackets(!current);
                                 notifier.saveSettingsIfChanged();
                                }
                             },
                             menuItemBuilder: (context) {
                               final removeBrackets = ref.watch(quranDisplaySettingsControllerProvider.select((s) => s.removeTranslationBrackets));
                               return [
                                 const PopupMenuItem<String>(
                                   value: 'khatm_plan',
                                   child: Row(
                                     mainAxisSize: MainAxisSize.min,
                                     children: [
                                       Icon(CupertinoIcons.book, size: 18),
                                       SizedBox(width: 8),
                                       Text(
                                         'ختم‌های قرآن',
                                         style: TextStyle(
                                           fontFamily: AppTypography.fontFamily,
                                           fontSize: 13,
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                                 const PopupMenuItem<String>(
                                   value: 'settings',
                                   child: Row(
                                     mainAxisSize: MainAxisSize.min,
                                     children: [
                                       Icon(CupertinoIcons.slider_horizontal_3, size: 18),
                                       SizedBox(width: 8),
                                       Text(
                                         'تنظیمات نمایش',
                                         style: TextStyle(
                                           fontFamily: AppTypography.fontFamily,
                                           fontSize: 13,
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                                 const PopupMenuItem<String>(
                                   value: 'bookmarks',
                                   child: Row(
                                     mainAxisSize: MainAxisSize.min,
                                     children: [
                                       Icon(CupertinoIcons.bookmark, size: 18),
                                       SizedBox(width: 8),
                                       Text(
                                         'نشان‌شده‌ها',
                                         style: TextStyle(
                                           fontFamily: AppTypography.fontFamily,
                                           fontSize: 13,
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                                 PopupMenuItem<String>(
                                   value: 'toggle_brackets',
                                   child: Row(
                                     mainAxisSize: MainAxisSize.min,
                                     children: [
                                       Icon(
                                         removeBrackets ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                                         size: 18,
                                       ),
                                       const SizedBox(width: 8),
                                       Text(
                                         removeBrackets ? 'نمایش متن داخل پرانتز' : 'مخفی کردن متن داخل پرانتز',
                                         style: const TextStyle(
                                           fontFamily: AppTypography.fontFamily,
                                           fontSize: 13,
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                                 PopupMenuItem<String>(
                                   value: 'fullscreen',
                                   child: Row(
                                     mainAxisSize: MainAxisSize.min,
                                     children: [
                                       Icon(
                                         _isFullScreen ? CupertinoIcons.fullscreen_exit : CupertinoIcons.fullscreen,
                                         size: 18,
                                       ),
                                       const SizedBox(width: 8),
                                       Text(
                                         _isFullScreen ? 'خروج از تمام‌صفحه' : 'حالت تمام صفحه',
                                         style: const TextStyle(
                                           fontFamily: AppTypography.fontFamily,
                                           fontSize: 13,
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                               ];
                             },
                           );
                         },
                       ),
                       ),
                        QuranInfoBar(
                          onTargetSelected: _handleTargetSelected,
                        ),
                        if (activeKhatmSession != null)
                          KhatmReaderBar(
                            khatmId: activeKhatmSession.khatmId,
                            sessionIndex: activeKhatmSession.sessionIndex,
                            onTap: () {
                              final readingState = ref.read(continueReadingControllerProvider);
                              final curSurah = readingState?.surahId ?? currentSurahId;
                              final curAyah = readingState?.ayahNumber ?? 1;
                              final curPage = KhatmQuranData.getPageForAyah(curSurah, curAyah);

                              KhatmQuickBottomSheet.show(
                                context,
                                activeKhatmId: activeKhatmSession.khatmId,
                                currentSurahId: curSurah,
                                currentAyahNumber: curAyah,
                                currentPage: curPage,
                              ).then((result) {
                                if (result != null && mounted) {
                                  setState(() {
                                    _activeKhatmId = result.khatmId;
                                    _activeKhatmSession = result.sessionIndex;
                                  });
                                  ref.read(activeKhatmSessionProvider.notifier).setActive(
                                        khatmId: result.khatmId,
                                        sessionIndex: result.sessionIndex,
                                      );
                                  if (result.shouldJump && result.target != null) {
                                    _handleTargetSelected(result.target!);
                                  } else {
                                    ref
                                        .read(khatmDetailControllerProvider(result.khatmId).notifier)
                                        .recordReadingProgress(
                                          sessionIndex: result.sessionIndex,
                                          surahId: curSurah,
                                          ayahNumber: curAyah,
                                          page: curPage,
                                        );
                                  }
                                }
                              });
                            },
                            onClose: () {
                              setState(() {
                                _activeKhatmId = null;
                                _activeKhatmSession = null;
                              });
                              ref.read(activeKhatmSessionProvider.notifier).clear();
                              ref.read(isKhatmReaderBarCollapsedProvider.notifier).setCollapsed(false);
                            },
                            onNextSession: () {
                              final plan = ref
                                  .read(khatmDetailControllerProvider(activeKhatmSession.khatmId))
                                  .plan;
                              if (plan != null &&
                                  activeKhatmSession.sessionIndex + 1 < plan.sessions.length) {
                                final nextIndex = activeKhatmSession.sessionIndex + 1;
                                final nextSession = plan.sessions[nextIndex];
                                final unitToNavigate = (nextSession.lastReadUnit != null &&
                                        nextSession.lastReadUnit! >= nextSession.fromUnit &&
                                        nextSession.lastReadUnit! <= nextSession.toUnit)
                                    ? nextSession.lastReadUnit!
                                    : nextSession.fromUnit;
                                final target = KhatmQuranResolver.resolveUnit(
                                  unitType: plan.unitType,
                                  unitNumber: unitToNavigate,
                                );
                                setState(() {
                                  _activeKhatmSession = nextIndex;
                                });
                                ref.read(activeKhatmSessionProvider.notifier).setActive(
                                      khatmId: activeKhatmSession.khatmId,
                                      sessionIndex: nextIndex,
                                    );
                                _handleTargetSelected(
                                  AyahTarget(
                                    surahId: target.surahId,
                                    ayahNumber: target.ayahNumber,
                                  ),
                                );
                              }
                            },
                          )
                        else if (hasActivePlan)
                          StudyPlanReaderBar(
                            onJumpToTarget: _handleTargetSelected,
                          ),
                      ],
                    ),
                  ),
                ),
              ),

          // 3. Bottom Audio Player Bar (Positioned at bottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: RepaintBoundary(
              child: context.isWideScreen
                  ? const WebDockedAudioPlayerBar()
                  : (isAudioPlayingOtherSurah
                      ? MiniAudioPlayerBar(
                          includeBottomInset: true,
                          onTap: () {
                            final audioState = ref.read(quranAudioControllerProvider);
                            final targetSurahId = audioState.currentSurahId;
                            if (targetSurahId != null) {
                              final targetAyah = audioState.currentAyahNumber ?? 1;
                              _handleTargetSelected(
                                AyahTarget(
                                  surahId: targetSurahId,
                                  ayahNumber: targetAyah,
                                ),
                              );
                            }
                          },
                        )
                      : AudioPlayerBottomBar(
                          surahId: currentSurahId,
                          isFullScreen: _isFullScreen,
                          isCollapsed: _isAudioBarCollapsed,
                          onToggleCollapse: () {
                            if (_isFullScreen) {
                              _toggleControls();
                            } else {
                              setState(() {
                                _isAudioBarCollapsed = !_isAudioBarCollapsed;
                              });
                              ref.read(readerControlsProvider.notifier).updateState(
                                isAudioBarCollapsed: _isAudioBarCollapsed,
                              );
                            }
                          },
                        )),
            ),
          ),

          // 4. Exit Full-Screen Button – Visible in fullscreen mode, auto-fades after delay
          if (_isFullScreen)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              top: controlsHidden
                  ? (topPadding > 0 ? topPadding + 10 : 16)
                  : headerHeight + 8,
              left: 12,
              child: IgnorePointer(
                ignoring: !_isExitButtonVisible,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  opacity: _isExitButtonVisible ? 1.0 : 0.0,
                  child: RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: _exitFullScreen,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  width: 0.8,
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
                                  SizedBox(width: 5),
                                  Text(
                                    'خروج از تمام‌صفحه',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 11.5,
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
                  ),
                ),
              ),
            ),


        ],
      ),
    ),
  );
}
}

/// Custom scroll physics for Quran PageView:
/// Requires an intentional, firm horizontal swipe (higher drag threshold & resistance)
/// so accidental diagonal thumb motions during vertical ayah reading won't prematurely skip whole surahs.
class HighResistancePageScrollPhysics extends ScrollPhysics {
  const HighResistancePageScrollPhysics({super.parent});

  @override
  HighResistancePageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return HighResistancePageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double? get dragStartDistanceMotionThreshold => 38.0;

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return super.applyPhysicsToUserOffset(position, offset * 0.65);
  }
}
