import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../core/services/audio/audio_player_state.dart';
import '../../../../core/services/quran_navigation/domain/entities/ayah_target.dart';
import '../../application/controllers/quran_audio_controller.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import '../../application/controllers/quran_reader_controller.dart';
import '../../domain/entities/ayah_entity.dart';
import '../../domain/entities/ayah_theme_entity.dart';
import '../../../khatm/application/controllers/group_khatm_reading_controller.dart';
import '../../../khatm/application/controllers/khatm_detail_controller.dart';
import '../../../khatm/application/controllers/khatm_reading_dispatcher.dart';
import '../../../khatm/infrastructure/datasources/khatm_quran_data.dart';
import '../../../khatm/presentation/widgets/reader/group_khatm_reader_bar.dart';
import '../../../khatm/presentation/widgets/reader/khatm_reader_bar.dart';
import '../../../quran_home/application/controllers/continue_reading_controller.dart';
import '../../../study_plan/application/controllers/study_plan_controller.dart';
import '../../../study_plan/domain/entities/study_plan.dart'
    show getGlobalAyahIndex;
import 'ayah_list_item.dart';
import 'package:quran/features/app_walkthrough/app_walkthrough.dart';
import 'surah_end_navigation_section.dart';

class SurahAyahPageView extends ConsumerStatefulWidget {
  final int surahId;
  final String surahName;
  final bool isCurrentPage;
  final int? initialAyahNumber;
  final String? translationId;
  final double? topPadding;
  final VoidCallback? onNextSurah;
  final VoidCallback? onPreviousSurah;

  const SurahAyahPageView({
    super.key,
    required this.surahId,
    required this.surahName,
    required this.isCurrentPage,
    this.initialAyahNumber,
    this.translationId,
    this.topPadding,
    this.onNextSurah,
    this.onPreviousSurah,
  });

  @override
  ConsumerState<SurahAyahPageView> createState() => _SurahAyahPageViewState();
}

class _SurahAyahPageViewState extends ConsumerState<SurahAyahPageView> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  ActiveItemPositionsListenerNotifier? _listenerNotifier;
  bool _hasScrolledToInitialAyah = false;
  bool _hasCompletedInitialScroll = false;
  bool _hasUserScrolled = false;
  bool _isAtScrollBottom = false;
  bool _isProgrammaticScroll = false;
  bool _hasDweltCurrentView = false;

  int? _lastRecordedTopIndex;
  int? _lastRecordedCoverStart;
  int? _lastRecordedCoverEnd;
  int? _lastVisibleStartIndex;
  int? _lastVisibleEndIndex;
  DateTime? _lastProgressUpdateTime;
  Timer? _dwellTimer;

  @override
  void initState() {
    super.initState();
    _listenerNotifier = ref.read(activeItemPositionsListenerProvider.notifier);
    _itemPositionsListener.itemPositions.addListener(_onItemPositionsChanged);
  }

  void _onItemPositionsChanged() {
    if (!mounted || !widget.isCurrentPage) return;
    if (_hasUserScrolled || _hasDweltCurrentView || _isProgrammaticScroll) {
      return;
    }
    final state = ref.read(quranReaderControllerProvider);
    if (state.isLoading ||
        state.currentSurahId != widget.surahId ||
        state.ayahs.isEmpty) {
      return;
    }
    _scheduleDwellTimerIfEligible(state.ayahs);
  }

  ({
    double readingBaseline,
    double stableTopCutoff,
    double actualTopCutoff,
    double actualBottomCutoff,
  }) _computeViewCutoffs(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final screenHeight = size.height;
    final viewPadding = MediaQuery.paddingOf(context);
    final safeTop = viewPadding.top;
    final safeBottom = viewPadding.bottom;

    final controlsState = ref.read(readerControlsProvider);
    final controlsHidden = controlsState.isControlsHidden;
    final isAudioBarCollapsed = controlsState.isAudioBarCollapsed;

    final hasPersonalKhatm = ref.read(activeKhatmSessionProvider) != null;
    final hasGroupKhatm = ref.read(activeGroupKhatmSlotProvider) != null;
    final isKhatmCollapsed = ref.read(isKhatmReaderBarCollapsedProvider);
    final expandedBarHeight = hasPersonalKhatm
        ? KhatmReaderBar.barHeight
        : GroupKhatmReaderBar.barHeight;

    final double stableTopPadding =
        controlsHidden ? (safeTop + 8.0) : (widget.topPadding ?? 140.0);
    final double stableTopCutoff = screenHeight > 0
        ? (stableTopPadding / screenHeight).clamp(0.0, 0.6)
        : 0.18;
    final double readingBaseline =
        stableTopCutoff + (18.0 / (screenHeight > 0 ? screenHeight : 800.0));

    final double actualTopPadding = controlsHidden
        ? safeTop
        : (widget.topPadding ?? 140.0) -
            ((hasPersonalKhatm || hasGroupKhatm) && isKhatmCollapsed
                ? (expandedBarHeight - KhatmReaderBar.collapsedHeight)
                : 0.0);
    final double actualTopCutoff = screenHeight > 0
        ? (actualTopPadding / screenHeight).clamp(0.0, 0.6)
        : 0.18;

    final audioState = ref.read(quranAudioControllerProvider);
    final bool isAudioPlayingOtherSurah =
        audioState.currentSurahId != null &&
        audioState.currentSurahId != widget.surahId &&
        audioState.status != AudioStatus.stopped;

    final double bottomOcclusionPx;
    if (context.isWideScreen) {
      final hasWebBar =
          audioState.currentSurahId != null &&
          audioState.status != AudioStatus.stopped;
      bottomOcclusionPx = hasWebBar ? 82.0 : 0.0;
    } else if (isAudioPlayingOtherSurah) {
      bottomOcclusionPx = 48.0 + safeBottom;
    } else if (isAudioBarCollapsed) {
      bottomOcclusionPx = safeBottom + 12.0;
    } else {
      bottomOcclusionPx = 94.0 + safeBottom;
    }

    final double actualBottomCutoff = screenHeight > 0
        ? ((screenHeight - bottomOcclusionPx) / screenHeight)
            .clamp(actualTopCutoff + 0.1, 1.0)
        : 0.85;

    return (
      readingBaseline: readingBaseline,
      stableTopCutoff: stableTopCutoff,
      actualTopCutoff: actualTopCutoff,
      actualBottomCutoff: actualBottomCutoff,
    );
  }

  void _resetJumpTracking() {
    _dwellTimer?.cancel();
    _dwellTimer = null;
    _hasDweltCurrentView = false;
    _hasUserScrolled = false;
    _isAtScrollBottom = false;
    _lastVisibleStartIndex = null;
    _lastVisibleEndIndex = null;
    _lastRecordedTopIndex = null;
    _lastRecordedCoverStart = null;
    _lastRecordedCoverEnd = null;
  }

  void _scheduleDwellTimerIfEligible(List<AyahEntity> ayahs) {
    if (!mounted ||
        !widget.isCurrentPage ||
        _hasDweltCurrentView ||
        _isProgrammaticScroll ||
        ayahs.isEmpty) {
      return;
    }
    final state = ref.read(quranReaderControllerProvider);
    if (state.isLoading || state.currentSurahId != widget.surahId) {
      return;
    }
    if (!hasAnyActiveKhatm(ref.read) &&
        !ref.read(isStudyPlanSessionActiveProvider)) {
      return;
    }
    final audioState = ref.read(quranAudioControllerProvider);
    final isAudioDrivingThisSurah =
        (audioState.status == AudioStatus.playing ||
            audioState.status == AudioStatus.loading) &&
        !audioState.isAutoScrollSuspended &&
        audioState.currentSurahId == widget.surahId;
    if (isAudioDrivingThisSurah) return;

    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final cutoffs = _computeViewCutoffs(context);
    final firstPos = positions.where((p) => p.index == 0).firstOrNull;
    final lastPos =
        positions.where((p) => p.index == ayahs.length - 1).firstOrNull;

    final allAyahsFitOnScreen =
        firstPos != null &&
        lastPos != null &&
        firstPos.itemLeadingEdge >= cutoffs.actualTopCutoff - 0.03 &&
        lastPos.itemTrailingEdge <= cutoffs.actualBottomCutoff + 0.03;

    if (!allAyahsFitOnScreen) return;
    if (_dwellTimer?.isActive ?? false) return;

    _dwellTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted || !widget.isCurrentPage) return;
      _hasDweltCurrentView = true;
      _updateReadingAndPlanProgress(force: true, fromDwell: true);
    });
  }

  void _updateReadingAndPlanProgress({
    bool force = false,
    bool fromDwell = false,
  }) {
    if (!mounted || !widget.isCurrentPage) return;
    try {
      final state = ref.read(quranReaderControllerProvider);
      if (state.isLoading ||
          state.currentSurahId != widget.surahId ||
          state.ayahs.isEmpty) {
        return;
      }

      // 1. Audio guard: audio is the source of truth ONLY while actively playing or loading
      // this surah with auto-scroll active. When paused or manually scrolled away, scroll
      // tracking works normally!
      final audioState = ref.read(quranAudioControllerProvider);
      final isAudioDrivingThisSurah =
          (audioState.status == AudioStatus.playing ||
              audioState.status == AudioStatus.loading) &&
          !audioState.isAutoScrollSuspended &&
          audioState.currentSurahId == widget.surahId;
      if (isAudioDrivingThisSurah) {
        return;
      }

      final positions = _itemPositionsListener.itemPositions.value;
      if (positions.isEmpty) return;

      final cutoffs = _computeViewCutoffs(context);
      final readingBaseline = cutoffs.readingBaseline;
      final stableTopCutoff = cutoffs.stableTopCutoff;
      final actualTopCutoff = cutoffs.actualTopCutoff;
      final actualBottomCutoff = cutoffs.actualBottomCutoff;

      ItemPosition? topPosition;
      for (final p in positions) {
        if (p.itemLeadingEdge <= readingBaseline &&
            p.itemTrailingEdge > readingBaseline) {
          topPosition = p;
          break;
        }
      }

      if (topPosition == null) {
        final lastPos = positions
            .where((p) => p.index == state.ayahs.length - 1)
            .firstOrNull;
        if (lastPos != null && lastPos.itemTrailingEdge <= readingBaseline) {
          topPosition = lastPos;
        } else {
          final visible = positions
              .where(
                (p) =>
                    p.itemTrailingEdge > stableTopCutoff &&
                    p.index < state.ayahs.length,
              )
              .toList();
          if (visible.isNotEmpty) {
            topPosition = visible.reduce(
              (min, cur) => cur.index < min.index ? cur : min,
            );
          } else {
            final ayahPositions =
                positions.where((p) => p.index < state.ayahs.length).toList();
            if (ayahPositions.isEmpty) return;
            topPosition = ayahPositions.reduce(
              (min, cur) => cur.index < min.index ? cur : min,
            );
          }
        }
      }

      final topIndex = topPosition.index.clamp(0, state.ayahs.length - 1);

      // Only advance focus to the last ayah when the user has actually scrolled
      // to the bottom of the list (no premature jump when endSectionPos peeks in).
      final effectiveReadingIndex =
          (_isAtScrollBottom && _hasUserScrolled)
              ? state.ayahs.length - 1
              : topIndex;

      // Determine all ayahs whose full body down to their trailing edge is visible
      // within [actualTopCutoff .. actualBottomCutoff] (preventing giant ayahs such
      // as 2:282 or 73:20 from completing on a tiny 4% top peek above the bottom bar).
      int? visStart;
      int? visEnd;
      for (final p in positions) {
        if (p.index < 0 || p.index >= state.ayahs.length) continue;
        final visibleTop = math.max(p.itemLeadingEdge, actualTopCutoff);
        final visibleBottom = math.min(p.itemTrailingEdge, actualBottomCutoff);
        final visibleSpan = visibleBottom - visibleTop;
        final itemSpan =
            (p.itemTrailingEdge - p.itemLeadingEdge).clamp(0.01, 2.0);
        final isTrailingClear =
            p.itemTrailingEdge <= actualBottomCutoff + 0.02 ||
            (_isAtScrollBottom &&
                _hasUserScrolled &&
                p.itemLeadingEdge < actualBottomCutoff - 0.01);
        final isMeaningfullyVisible =
            visibleSpan >= math.min(0.04, itemSpan * 0.5) && isTrailingClear;
        if (isMeaningfullyVisible) {
          visStart = visStart == null ? p.index : math.min(visStart, p.index);
          visEnd = visEnd == null ? p.index : math.max(visEnd, p.index);
        }
      }

      // If user hasn't scrolled or dwelled yet (e.g. initial open / horizontal swipe),
      // only schedule the dwell timer for single-screen surahs and do NOT dispatch
      // false progress to Khatm or StudyPlan.
      if (!_hasUserScrolled && !fromDwell) {
        _scheduleDwellTimerIfEligible(state.ayahs);
        return;
      }

      final bool hasCoveredSpan = visStart != null && visEnd != null;
      int? coverStartIndex = visStart;
      int? coverEndIndex = visEnd;
      if (hasCoveredSpan) {
        if (!_isProgrammaticScroll &&
            !fromDwell &&
            _lastVisibleStartIndex != null &&
            _lastVisibleEndIndex != null) {
          final downGap = visStart - _lastVisibleEndIndex!;
          if (downGap > 1 && downGap <= 15) {
            coverStartIndex = _lastVisibleEndIndex! + 1;
          }
          final upGap = _lastVisibleStartIndex! - visEnd;
          if (upGap > 1 && upGap <= 15) {
            coverEndIndex = _lastVisibleStartIndex! - 1;
          }
        }
        _lastVisibleStartIndex = visStart;
        _lastVisibleEndIndex = visEnd;
      }

      // Deduplicate: skip if neither focused ayah nor covered range changed
      if (!force &&
          effectiveReadingIndex == _lastRecordedTopIndex &&
          coverStartIndex == _lastRecordedCoverStart &&
          coverEndIndex == _lastRecordedCoverEnd) {
        return;
      }
      _lastRecordedTopIndex = effectiveReadingIndex;
      _lastRecordedCoverStart = coverStartIndex;
      _lastRecordedCoverEnd = coverEndIndex;

      if (effectiveReadingIndex >= 0 &&
          effectiveReadingIndex < state.ayahs.length) {
        final readingAyah = state.ayahs[effectiveReadingIndex];
        ref
            .read(continueReadingControllerProvider.notifier)
            .updateStateInMemory(
              surahId: widget.surahId,
              surahName: widget.surahName,
              ayahNumber: readingAyah.ayahNumber,
              totalAyahs: state.ayahs.length,
            );

        final int? coverStartGlobal = hasCoveredSpan
            ? getGlobalAyahIndex(
                widget.surahId,
                state.ayahs[coverStartIndex!].ayahNumber,
              )
            : null;
        final int? coverEndGlobal = hasCoveredSpan
            ? getGlobalAyahIndex(
                widget.surahId,
                state.ayahs[coverEndIndex!].ayahNumber,
              )
            : null;
        final readingGlobal = getGlobalAyahIndex(
          widget.surahId,
          readingAyah.ayahNumber,
        );
        final page = readingAyah.page ??
            KhatmQuranData.getPageForAyah(
              widget.surahId,
              readingAyah.ayahNumber,
            );
        final pageRange = KhatmQuranData.getGlobalAyahRangeForPage(page);
        final bool isEndOfPage =
            (_hasUserScrolled || fromDwell) &&
            hasCoveredSpan &&
            (coverEndGlobal! >= pageRange.endGlobal ||
                (_isAtScrollBottom &&
                    effectiveReadingIndex == state.ayahs.length - 1 &&
                    readingGlobal == pageRange.endGlobal));

        final totalOnPage =
            (pageRange.endGlobal - pageRange.startGlobal + 1).clamp(1, 100);
        final ayahsReadOnPage =
            (readingGlobal - pageRange.startGlobal + 1).clamp(0, totalOnPage);
        final double pageFraction = isEndOfPage
            ? 1.0
            : (ayahsReadOnPage / totalOnPage).clamp(0.0, 1.0);

        if (ref.read(isStudyPlanSessionActiveProvider)) {
          ref
              .read(studyPlanControllerProvider.notifier)
              .recordProgress(
                surahId: widget.surahId,
                surahName: widget.surahName,
                ayahNumber: readingAyah.ayahNumber,
                page: page,
                juz: readingAyah.juz,
                hizb: readingAyah.hizb,
                isEndOfPage: isEndOfPage,
                pageFraction: pageFraction,
              );
        }

        if (hasAnyActiveKhatm(ref.read)) {
          dispatchActiveKhatmProgress(
            read: ref.read,
            surahId: widget.surahId,
            ayahNumber: readingAyah.ayahNumber,
            page: page,
            juz: readingAyah.juz,
            hizb: readingAyah.hizb,
            isEndOfPage: isEndOfPage,
            pageFraction: pageFraction,
            coverStartGlobal: coverStartGlobal,
            coverEndGlobal: coverEndGlobal,
            recordCoverage: hasCoveredSpan,
          );
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    _dwellTimer = null;
    _itemPositionsListener.itemPositions.removeListener(_onItemPositionsChanged);
    final listener = _itemPositionsListener;
    final notifier = _listenerNotifier;
    if (notifier != null) {
      Future.microtask(() => notifier.clearIfMatches(listener));
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(SurahAyahPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.surahId != oldWidget.surahId ||
        widget.isCurrentPage != oldWidget.isCurrentPage) {
      _resetJumpTracking();
    }
    if (widget.initialAyahNumber != null &&
        widget.initialAyahNumber != oldWidget.initialAyahNumber) {
      _hasScrolledToInitialAyah = false;
      _hasCompletedInitialScroll = false;
      _resetJumpTracking();
      _scrollToAyah(widget.initialAyahNumber!);
    }
  }

  void _scrollToAyah(int ayahNumber, {bool highlight = true}) {
    _resetJumpTracking();
    void attemptScroll([int attempt = 0]) {
      if (!mounted) return;
      final state = ref.read(quranReaderControllerProvider);
      final ayahs = state.ayahs;

      // If ayahs are loading or not yet available for this surah, retry
      if (state.isLoading ||
          ayahs.isEmpty ||
          state.currentSurahId != widget.surahId) {
        if (attempt < 25) {
          Future.delayed(Duration(milliseconds: 50 + (attempt * 20)), () {
            attemptScroll(attempt + 1);
          });
        }
        return;
      }

      final targetIndex = ayahs.indexWhere((a) => a.ayahNumber == ayahNumber);
      if (targetIndex == -1) return;

      if (highlight) {
        ref.read(activeAyahProvider.notifier).setActiveAyah(ayahNumber);
      }

      final hasPositions =
          _itemPositionsListener.itemPositions.value.isNotEmpty;
      if (_itemScrollController.isAttached && hasPositions) {
        try {
          _isProgrammaticScroll = true;
          final alignTarget =
              (widget.topPadding ?? 0) / MediaQuery.sizeOf(context).height;
          _itemScrollController.scrollTo(
            index: targetIndex,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            alignment: alignTarget,
          ).whenComplete(() {
            if (mounted) {
              _isProgrammaticScroll = false;
              _scheduleDwellTimerIfEligible(ayahs);
            }
          });
          return;
        } catch (_) {
          _isProgrammaticScroll = false;
        }
      }

      if (attempt < 25) {
        Future.delayed(Duration(milliseconds: 50 + (attempt * 20)), () {
          attemptScroll(attempt + 1);
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      attemptScroll();
    });
  }

  void _scrollToInitialAyahIfNeeded(List<AyahEntity> ayahs) {
    if (_hasScrolledToInitialAyah) return;
    final targetAyah = widget.initialAyahNumber;
    if (targetAyah == null || ayahs.isEmpty) return;

    final targetIndex = ayahs.indexWhere((a) => a.ayahNumber == targetAyah);
    if (targetIndex == -1) return;

    _hasScrolledToInitialAyah = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final audioState = ref.read(quranAudioControllerProvider);
      final isPlayingOther =
          audioState.status != AudioStatus.stopped &&
          audioState.status != AudioStatus.initial &&
          audioState.currentSurahId != null &&
          audioState.currentSurahId != widget.surahId;
      if (!isPlayingOther) {
        ref.read(activeAyahProvider.notifier).setActiveAyah(targetAyah);
      }

      void attemptScroll([int attempt = 0]) {
        if (!mounted) return;
        final hasPositions =
            _itemPositionsListener.itemPositions.value.isNotEmpty;
        if (_itemScrollController.isAttached && hasPositions) {
          try {
            _hasCompletedInitialScroll = true;
            if (targetIndex > 0) {
              final alignTarget =
                  (widget.topPadding ?? 0) / MediaQuery.sizeOf(context).height;
              final currentTargetPos = _itemPositionsListener
                  .itemPositions
                  .value
                  .where((p) => p.index == targetIndex)
                  .firstOrNull;
              final alreadyAligned =
                  currentTargetPos != null &&
                  (currentTargetPos.itemLeadingEdge - alignTarget).abs() < 0.03;
              if (!alreadyAligned) {
                _isProgrammaticScroll = true;
                _itemScrollController.scrollTo(
                  index: targetIndex,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeInOutCubic,
                  alignment: alignTarget,
                ).whenComplete(() {
                  if (mounted) {
                    _isProgrammaticScroll = false;
                    _scheduleDwellTimerIfEligible(ayahs);
                  }
                });
              }
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && widget.isCurrentPage) {
                _scheduleDwellTimerIfEligible(ayahs);
              }
            });
          } catch (_) {
            _isProgrammaticScroll = false;
          }
        } else if (attempt < 15) {
          Future.delayed(Duration(milliseconds: 60 + (attempt * 25)), () {
            attemptScroll(attempt + 1);
          });
        }
      }

      // Small delay to allow the layout to settle before programmatic scroll
      Future.delayed(const Duration(milliseconds: 100), () {
        attemptScroll();
      });
    });
  }

  int _getInitialScrollIndex(List<dynamic> ayahs) {
    int? targetAyah = widget.initialAyahNumber;
    final navTarget = ref.read(navigationTargetProvider);
    if (navTarget != null && navTarget.surahId == widget.surahId) {
      targetAyah = navTarget.ayahNumber;
    }
    if (targetAyah == null) {
      final audioState = ref.read(quranAudioControllerProvider);
      if (audioState.currentSurahId == widget.surahId) {
        targetAyah = audioState.currentAyahNumber;
      }
    }
    if (targetAyah != null) {
      final index = ayahs.indexWhere((a) => a.ayahNumber == targetAyah);
      if (index != -1) {
        return index;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isCurrentPage) {
      return const Center(child: CupertinoActivityIndicator());
    }

    // Register active ItemPositionsListener for QuranInfoBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(activeItemPositionsListenerProvider) !=
          _itemPositionsListener) {
        ref
            .read(activeItemPositionsListenerProvider.notifier)
            .setListener(_itemPositionsListener);
      }
      _updateReadingAndPlanProgress();
    });

    final state = ref.watch(quranReaderControllerProvider);
    final ayahThemeId = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.ayahThemeId),
    );
    final activeTheme = AyahThemePresets.getById(ayahThemeId);

    if (state.isLoading || state.currentSurahId != widget.surahId) {
      if (!state.isLoading && state.currentSurahId != widget.surahId) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !widget.isCurrentPage) return;
          ref
              .read(quranReaderControllerProvider.notifier)
              .fetchAyahs(widget.surahId);
        });
      }
      return ColoredBox(
        color: activeTheme.evenColor,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null && state.ayahs.isEmpty) {
      return ColoredBox(
        color: activeTheme.evenColor,
        child: Center(
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
                onPressed: () =>
                    ref.read(quranReaderControllerProvider.notifier).retry(),
                child: const Text(AppConstants.retryButtonLabel),
              ),
            ],
          ),
        ),
      );
    }

    if (state.ayahs.isEmpty) {
      return ColoredBox(
        color: activeTheme.evenColor,
        child: const Center(child: Text(AppConstants.noAyahFound)),
      );
    }

    // Check if there is a pending navigation target for this surah
    final pendingTarget = ref.read(navigationTargetProvider);
    if (pendingTarget != null && pendingTarget.surahId == widget.surahId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToAyah(pendingTarget.ayahNumber);
          ref.read(navigationTargetProvider.notifier).setTarget(null);
        }
      });
    } else if (widget.initialAyahNumber != null && !_hasScrolledToInitialAyah) {
      _scrollToInitialAyahIfNeeded(state.ayahs);
    }

    // Target navigation listener (e.g. QuickJump triggered while already viewing this surah)
    ref.listen<AyahTarget?>(navigationTargetProvider, (previous, target) {
      if (target != null && target.surahId == widget.surahId) {
        _scrollToAyah(target.ayahNumber);
        Future.microtask(() {
          if (mounted) {
            ref.read(navigationTargetProvider.notifier).setTarget(null);
          }
        });
      }
    });

    // Auto-scroll listener for ayah audio playback.
    // Reading progress and unit completion are recorded strictly when an ayah
    // finishes playing in QuranAudioController._advanceNextAyah — NEVER at t=0:00 here.
    ref.listen<int?>(activeAyahProvider, (previous, next) {
      if (next != null) {
        // Skip duplicate scroll while initial scroll is handling this ayah
        if (next == widget.initialAyahNumber && !_hasCompletedInitialScroll) {
          return;
        }

        // CRITICAL GUARD: Audio auto-scroll MUST only scroll the Surah currently being played!
        final audioState = ref.read(quranAudioControllerProvider);
        if (audioState.currentSurahId != widget.surahId) {
          return;
        }

        final targetIndex = state.ayahs.indexWhere((a) => a.ayahNumber == next);
        if (targetIndex != -1) {
          final currentPlayingAyah = state.ayahs[targetIndex];
          ref
              .read(continueReadingControllerProvider.notifier)
              .updateStateInMemory(
                surahId: widget.surahId,
                surahName: widget.surahName,
                ayahNumber: currentPlayingAyah.ayahNumber,
                totalAyahs: state.ayahs.length,
              );

          if (_itemScrollController.isAttached) {
            final isAudioPlaying = audioState.status == AudioStatus.playing;
            final isSuspended = audioState.isAutoScrollSuspended;

            if (isAudioPlaying && isSuspended) return;

            try {
              if (_itemPositionsListener.itemPositions.value.isNotEmpty) {
                _isProgrammaticScroll = true;
                final alignTarget =
                    (widget.topPadding ?? 0) /
                    MediaQuery.sizeOf(context).height;
                _itemScrollController.scrollTo(
                  index: targetIndex,
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeInOutCubic,
                  alignment: alignTarget,
                ).whenComplete(() {
                  if (mounted) {
                    _isProgrammaticScroll = false;
                  }
                });
              }
            } catch (_) {
              _isProgrammaticScroll = false;
            }
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
            final targetIndex = state.ayahs.indexWhere(
              (a) => a.ayahNumber == currentAyah,
            );
            if (targetIndex != -1 && _itemScrollController.isAttached) {
              try {
                if (_itemPositionsListener.itemPositions.value.isNotEmpty) {
                  _isProgrammaticScroll = true;
                  final alignTarget =
                      (widget.topPadding ?? 0) /
                      MediaQuery.sizeOf(context).height;
                  _itemScrollController.scrollTo(
                    index: targetIndex,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOutCubic,
                    alignment: alignTarget,
                  ).whenComplete(() {
                    if (mounted) {
                      _isProgrammaticScroll = false;
                    }
                  });
                }
              } catch (_) {
                _isProgrammaticScroll = false;
              }
            }
          }
        }
      },
    );

    // Maintain scroll offset when display settings change (e.g. font size, brackets)
    // because height changes cause ListView to jump.
    // Skip jumping during interactive pinch-to-zoom to prevent violent stuttering!
    ref.listen(quranDisplaySettingsControllerProvider, (previous, next) {
      if (ref.read(isInteractivePinchZoomingProvider)) {
        return;
      }
      if (previous != next && _itemScrollController.isAttached) {
        final positions = _itemPositionsListener.itemPositions.value;
        if (positions.isNotEmpty) {
          // Find the item that is currently near the top
          final firstVisible = positions.reduce(
            (min, position) =>
                position.itemLeadingEdge.abs() < min.itemLeadingEdge.abs()
                ? position
                : min,
          );

          final index = firstVisible.index.clamp(0, state.ayahs.length - 1);
          final alignment = firstVisible.itemLeadingEdge > 0
              ? 0.0
              : firstVisible.itemLeadingEdge;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (_itemScrollController.isAttached) {
              try {
                if (_itemPositionsListener.itemPositions.value.isNotEmpty) {
                  _itemScrollController.jumpTo(
                    index: index,
                    alignment: alignment,
                  );
                }
              } catch (_) {}
            }
          });
        }
      }
    });

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      color: activeTheme.evenColor,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isWideScreen ? 1150 : double.infinity,
          ),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axis != Axis.vertical) {
                return false;
              }
              final isUserDrag =
                  (notification is ScrollStartNotification &&
                      notification.dragDetails != null) ||
                  (notification is ScrollUpdateNotification &&
                      notification.dragDetails != null);
              if (isUserDrag) {
                _hasUserScrolled = true;
                _dwellTimer?.cancel();
                _dwellTimer = null;
                final audioState = ref.read(quranAudioControllerProvider);
                final hasActiveSession =
                    audioState.status == AudioStatus.playing ||
                    audioState.status == AudioStatus.loading ||
                    audioState.status == AudioStatus.paused;
                final isThisSurah = audioState.currentSurahId == widget.surahId;
                if (hasActiveSession && isThisSurah) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    ref
                        .read(quranAudioControllerProvider.notifier)
                        .suspendAutoScroll();
                  });
                }
              }

              // Scroll-based collapse/expand for active Khatm bar (Personal or Group)
              if (hasAnyActiveKhatm(ref.read)) {
                if (notification is UserScrollNotification) {
                  if (notification.direction == ScrollDirection.reverse &&
                      notification.metrics.pixels > 35) {
                    ref
                        .read(isKhatmReaderBarCollapsedProvider.notifier)
                        .setCollapsed(true);
                  } else if (notification.direction ==
                      ScrollDirection.forward) {
                    ref
                        .read(isKhatmReaderBarCollapsedProvider.notifier)
                        .setCollapsed(false);
                  }
                } else if (notification is ScrollUpdateNotification &&
                    notification.dragDetails != null) {
                  final delta = notification.scrollDelta;
                  if (delta != null) {
                    if (delta > 3.0 && notification.metrics.pixels > 35) {
                      ref
                          .read(isKhatmReaderBarCollapsedProvider.notifier)
                          .setCollapsed(true);
                    } else if (delta < -3.0) {
                      ref
                          .read(isKhatmReaderBarCollapsedProvider.notifier)
                          .setCollapsed(false);
                    }
                  }
                }
                if (notification.metrics.pixels <= 15) {
                  ref
                      .read(isKhatmReaderBarCollapsedProvider.notifier)
                      .setCollapsed(false);
                }
              }

              // Check scroll bottom using actual scroll metrics
              final metrics = notification.metrics;
              final atBottom =
                  metrics.maxScrollExtent > 20 &&
                  metrics.pixels >= (metrics.maxScrollExtent - 25);
              if (_isAtScrollBottom != atBottom) {
                _isAtScrollBottom = atBottom;
              }

              // Track reading progress: throttled (250ms) during active drag, immediate on scroll end
              if (notification is ScrollEndNotification) {
                _lastProgressUpdateTime = null;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _updateReadingAndPlanProgress(force: true);
                });
              } else if (notification is ScrollUpdateNotification) {
                if (notification.dragDetails != null) {
                  _hasUserScrolled = true;
                }
                final now = DateTime.now();
                if (_lastProgressUpdateTime == null ||
                    now.difference(_lastProgressUpdateTime!).inMilliseconds >=
                        250) {
                  _lastProgressUpdateTime = now;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateReadingAndPlanProgress();
                  });
                }
              }
              return false;
            },
            child: Builder(
              builder: (context) {
                final initialIndex = _getInitialScrollIndex(state.ayahs);
                final screenH = MediaQuery.sizeOf(context).height;
                final initialAlign = (initialIndex > 0 && screenH > 0)
                    ? ((widget.topPadding ?? 0) / screenH).clamp(0.0, 0.6)
                    : 0.0;
                return ScrollablePositionedList.builder(
                  key: ValueKey('surah_list_${widget.surahId}'),
                  initialScrollIndex: initialIndex,
                  initialAlignment: initialAlign,
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
              padding: EdgeInsets.only(
                left: context.isWideScreen ? 24.0 : 0.0,
                right: context.isWideScreen ? 24.0 : 0.0,
                top: widget.topPadding ?? (context.isWideScreen ? 16.0 : 0.0),
                bottom: MediaQuery.viewPaddingOf(context).bottom + 110.0,
              ),
              itemCount: state.ayahs.length + 1,
              itemBuilder: (context, index) {
                if (index == state.ayahs.length) {
                  return SurahEndNavigationSection(
                    surahId: widget.surahId,
                    surahName: widget.surahName,
                    totalAyahs: state.ayahs.length,
                    onNextSurah: widget.onNextSurah,
                    onPreviousSurah: widget.onPreviousSurah,
                  );
                }

                final ayah = state.ayahs[index];
                final previousAyah = index > 0 ? state.ayahs[index - 1] : null;

                final isPageStart =
                    previousAyah == null || previousAyah.page != ayah.page;
                final isJuzStart = (previousAyah != null)
                    ? (ayah.juz != null && previousAyah.juz != ayah.juz)
                    : (ayah.juz != null);
                final isHizbStart = (previousAyah != null)
                    ? (ayah.hizb != null && previousAyah.hizb != ayah.hizb)
                    : (ayah.hizb != null);

                return WalkthroughAnchor(
                  id: WalkthroughTargetId.readerFirstAyah,
                  enabled: widget.isCurrentPage && index == 0,
                  child: AyahListItem(
                    ayah: ayah,
                    surahName: widget.surahName,
                    totalAyahsInSurah: state.ayahs.length,
                    isPageStart: isPageStart,
                    isJuzStart: isJuzStart,
                    isHizbStart: isHizbStart,
                    translationId: widget.translationId,
                  ),
                );
              },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
