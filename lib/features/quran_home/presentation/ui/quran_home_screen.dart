import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_theme_toggle_button.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../mini_audio_player/presentation/widgets/mini_audio_player_bar.dart';
import '../../../prayer_times/presentation/widgets/prayer_times_card.dart';
import '../../application/controllers/continue_reading_controller.dart';
import 'widgets/continue_reading_card.dart';
import 'widgets/home_quick_access_grid.dart';

/// Home Screen with Animated Receding Header, Matching Calligraphic Title Size & Synchronized Theme Button Fade
class QuranHomeScreen extends ConsumerStatefulWidget {
  const QuranHomeScreen({super.key});

  @override
  ConsumerState<QuranHomeScreen> createState() => _QuranHomeScreenState();
}

class _QuranHomeScreenState extends ConsumerState<QuranHomeScreen> {
  late final ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (mounted) {
          setState(() {
            _scrollOffset = _scrollController.offset;
          });
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Progress from 0.0 (top) to 1.0 (scrolled down 65px)
    final double progress = (_scrollOffset / 65.0).clamp(0.0, 1.0);
    final double scale = 1.0 - (progress * 0.15); // Recedes into depth
    final double opacity =
        (1.0 - (progress * 1.5)).clamp(0.0, 1.0); // Fades out completely
    final double translateY = progress * 16.0;

    // Header completely ignores touch events once faded out
    final bool isHeaderHidden = opacity <= 0.05;

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // 1. Scrollable Body Content
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: kToolbarHeight + 72.0, // Generous space below header
                  left: AppDimens.marginPage,
                  right: AppDimens.marginPage,
                  bottom: AppDimens.marginPage + 60.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Prayer Times & Calendar Card
                    const PrayerTimesCard(),
                    AppDimens.stackLg.vSpace,

                    // Continue Reading Card
                    Consumer(
                      builder: (context, ref, child) {
                        final continueReadingState =
                            ref.watch(continueReadingControllerProvider);
                        final bookmarkState =
                            ref.watch(manualBookmarkControllerProvider);

                        if (continueReadingState == null &&
                            bookmarkState == null) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ContinueReadingCard(
                              autoState: continueReadingState,
                              bookmarkState: bookmarkState,
                            ),
                            AppDimens.stackLg.vSpace,
                          ],
                        );
                      },
                    ),

                    // Quick Access Action Buttons Grid
                    const HomeQuickAccessGrid(),
                    AppDimens.stackMd.vSpace,
                  ],
                ),
              ),
            ),

            // 2. Animated Header Layer (On top for 100% reliable clicks, completely fades & disables touch on scroll)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: IgnorePointer(
                  ignoring: isHeaderHidden,
                  child: Transform.translate(
                    offset: Offset(0, translateY),
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          height: kToolbarHeight + 12,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.marginPage,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Centered Large Calligraphic Title "قرآن کریم" (Matching original screenshot size)
                              Center(
                                child: Text(
                                  AppConstants.appTitle,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.appBarTitle.copyWith(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // Theme Toggle Button (Synchronized with Header)
                              const Positioned(
                                left: 0,
                                child: AppThemeToggleButton(),
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
          ],
        ),
      ),
      bottomNavigationBar: const MiniAudioPlayerBar(),
    );
  }
}
