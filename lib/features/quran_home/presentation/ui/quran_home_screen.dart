import 'package:flutter/material.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_theme_toggle_button.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../mini_audio_player/presentation/widgets/mini_audio_player_bar.dart';
import 'widgets/ayah_of_the_day_card.dart';
import 'widgets/continue_reading_card.dart';
import 'widgets/home_quick_access_grid.dart';

class QuranHomeScreen extends StatelessWidget {
  const QuranHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          AppConstants.appTitle,
          style: AppTypography.appBarTitle,
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: AppThemeToggleButton(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.marginPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ayah of the Day Widget
            const AyahOfTheDayCard(),
            AppDimens.stackMd.vSpace,

            // Continue Reading Card
            const ContinueReadingCard(),
            AppDimens.stackLg.vSpace,

            // Quick Access Action Buttons Grid
            const HomeQuickAccessGrid(),
            AppDimens.stackMd.vSpace,
          ],
        ),
      ),
      bottomNavigationBar: const MiniAudioPlayerBar(),
    );
  }
}
