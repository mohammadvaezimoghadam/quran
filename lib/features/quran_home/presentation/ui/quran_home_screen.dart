import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_theme_toggle_button.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../main_navigation/application/tab_navigation_controller.dart';
import '../../../mini_audio_player/presentation/widgets/mini_audio_player_bar.dart';
import '../../application/controllers/continue_reading_controller.dart';
import '../../../bookmarks/application/controllers/bookmarks_controller.dart';
import 'widgets/continue_reading_card.dart';
import 'widgets/home_quick_access_grid.dart';
import 'widgets/home_search_bar_widget.dart';
import '../../../quick_access/presentation/ui/quick_access_row.dart';

/// Clean Apple-Style Quran Home Screen with Tafakor Mint Green Theme
class QuranHomeScreen extends ConsumerWidget {
  final bool showBottomMiniPlayer;

  const QuranHomeScreen({
    super.key,
    this.showBottomMiniPlayer = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 8),
        child: Container(
          decoration: BoxDecoration(
            color: colors.cardBackground.withValues(alpha: isDark ? 0.90 : 0.98),
            border: Border(
              bottom: BorderSide(
                color: colors.cardBorder,
                width: 0.8,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 2.0,
              ),
              child: Row(
                children: [
                  // Theme Toggle Button (Apple circular pill on Left)
                  const AppThemeToggleButton(),

                  // Centered Clean Title "قرآن تفکر"
                  Expanded(
                    child: Text(
                      AppConstants.appTitle.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), ''),
                      textAlign: TextAlign.center,
                      style: AppTypography.appBarTitle.copyWith(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),

                  // Balance spacer so title remains perfectly centered
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pinned Top Quran Search Bar Widget (همیشه در بالا ثابت است)
          Padding(
            padding: const EdgeInsets.only(
              top: 4.0,
              left: AppDimens.marginPage,
              right: AppDimens.marginPage,
              bottom: 8.0,
            ),
            child: HomeSearchBarWidget(
              onTap: () =>
                  ref.read(tabNavigationControllerProvider.notifier).switchTab(2),
            ),
          ),

          // Scrollable Content Beneath Pinned Search Bar
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                top: 4.0,
                left: AppDimens.marginPage,
                right: AppDimens.marginPage,
                bottom: AppDimens.marginPage + 60.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Primary Navigation Action Buttons (سوره‌ها، ترجمه، تنظیمات)
                  const HomeQuickAccessGrid(),
                  AppDimens.stackLg.vSpace,

                  // 2. Customizable 4-Slot Toolbox Row (جعبه ابزار شخصی‌سازی‌شده)
                  const QuickAccessRow(),
                  AppDimens.stackLg.vSpace,

                  // 4. Continue Reading Card (در پایین صفحه)
                  Consumer(
                    builder: (context, ref, child) {
                      final continueReadingState =
                          ref.watch(continueReadingControllerProvider);
                      final bookmarks = ref.watch(bookmarksControllerProvider);
                      final bookmarkState = bookmarks.isNotEmpty
                          ? bookmarks.first.toContinueReadingState()
                          : null;

                      return ContinueReadingCard(
                        autoState: continueReadingState,
                        bookmarkState: bookmarkState,
                      );
                    },
                  ),
                  AppDimens.stackLg.vSpace,
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          showBottomMiniPlayer ? const MiniAudioPlayerBar() : null,
    );
  }
}
