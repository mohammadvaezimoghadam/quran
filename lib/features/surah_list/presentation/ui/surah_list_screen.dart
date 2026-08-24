import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/widgets/islamic_katibah_app_bar.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/surah_list_controller.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../../mini_audio_player/presentation/widgets/mini_audio_player_bar.dart';
import '../widgets/surah_error_view.dart';
import '../widgets/surah_list_item.dart';

class SurahListScreen extends ConsumerWidget {
  const SurahListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(surahListControllerProvider);
    final controller = ref.read(surahListControllerProvider.notifier);

    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final fontFamily = AppTypography.getFontFamilyByScript(fontScript);

    return Scaffold(
      extendBody: true,
      appBar: IslamicKatibahAppBar(
        surahName: AppConstants.surahListScreenTitle,
        fontFamily: fontFamily,
        showSearchField: true,
        onSearchChanged: (query) {
          controller.searchSurahs(query);
        },
      ),
      body: _buildBody(context, ref, state, controller),
      bottomNavigationBar: const MiniAudioPlayerBar(),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, state, controller) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return SurahErrorView(
        errorMessage: state.errorMessage!,
        onRetry: () {
          controller.build();
        },
      );
    }

    final filteredSurahs = state.filteredSurahs;

    if (filteredSurahs.isEmpty) {
      return const Center(
        child: Text(
          AppConstants.noSurahFound,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 12,
        bottom: MediaQuery.paddingOf(context).bottom + 16,
      ),
      itemCount: filteredSurahs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        final surah = filteredSurahs[index];
        return SurahListItem(
          surah: surah,
          onTap: () {
            ref.read(quranDisplaySettingsControllerProvider.notifier).toggleArabicText(true);
            Future.microtask(() {
              if (context.mounted) {
                context.pushNamed(
                  quranReaderRoute,
                  pathParameters: {'id': surah.number.toString()},
                  queryParameters: {'name': surah.name},
                );
              }
            });
          },
        );
      },
    );
  }
}
