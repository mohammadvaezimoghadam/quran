import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_theme_toggle_button.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../mini_audio_player/presentation/widgets/mini_audio_player_bar.dart';
import '../../application/controllers/continue_reading_controller.dart';
import '../../../bookmarks/application/controllers/bookmarks_controller.dart';
import 'widgets/continue_reading_card.dart';
import 'widgets/daily_ayah_banner_widget.dart';
import 'widgets/home_quick_access_grid.dart';
import 'widgets/home_search_bar_widget.dart';
import '../../../quick_access/presentation/ui/quick_access_row.dart';

/// Home Screen with Permanent Calligraphic Header & Theme Toggle Button
class QuranHomeScreen extends ConsumerWidget {
  const QuranHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 12),
        child: SafeArea(
          child: Container(
            height: kToolbarHeight + 12,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.marginPage,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Centered Large Calligraphic Title "قرآن کریم"
                Center(
                  child: Text(
                    AppConstants.appTitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.appBarTitle.copyWith(
                      fontFamily: AppTypography.thuluthFont,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Theme Toggle Button (Permanently Available on Left)
                const Positioned(
                  left: 0,
                  child: AppThemeToggleButton(),
                ),
              ],
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
              onTap: () => context.pushNamed(searchRoute),
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
                  // 1. Daily Ayah Banner (هر روز یک آیه)
                  const DailyAyahBannerWidget(),
                  AppDimens.stackLg.vSpace,

                  // 2. Primary Navigation Action Buttons (سوره‌ها، ترجمه، تنظیمات)
                  const HomeQuickAccessGrid(),
                  AppDimens.stackLg.vSpace,

                  // 3. Customizable 4-Slot Toolbox Row (جعبه ابزار شخصی‌سازی‌شده)
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
      bottomNavigationBar: const MiniAudioPlayerBar(),
    );
  }
}
