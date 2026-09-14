import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../quran_reader/application/controllers/quran_audio_controller.dart';
import '../../../quran_reader/application/controllers/reciter_providers.dart';
import '../../../surah_list/application/controllers/surah_list_controller.dart';
import '../../application/states/download_manager_state.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../common/widgets/islamic_katibah_app_bar.dart';
import '../widgets/download_manager_reciter_selector.dart';
import '../widgets/download_manager_surah_list.dart';

class AudioDownloadManagerScreen extends ConsumerStatefulWidget {
  final int? initialSurahId;
  final bool isTranslationMode;

  const AudioDownloadManagerScreen({
    super.key,
    this.initialSurahId,
    this.isTranslationMode = false,
  });

  @override
  ConsumerState<AudioDownloadManagerScreen> createState() =>
      _AudioDownloadManagerScreenState();
}

class _AudioDownloadManagerScreenState
    extends ConsumerState<AudioDownloadManagerScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  late final SurahListController _surahListController;

  @override
  void initState() {
    super.initState();
    _surahListController = ref.read(surahListControllerProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure search query starts clean
      _surahListController.searchSurahs('');

      final audioState = ref.read(quranAudioControllerProvider);
      if (widget.isTranslationMode) {
        final currentTrans = audioState.selectedTranslationReciter;
        if (currentTrans != null) {
          ref
              .read(downloadManagerSelectedReciterProvider.notifier)
              .setReciter(currentTrans);
        } else {
          final transList = ref
              .read(translationRecitersListProvider)
              .asData
              ?.value
              .tryGetSuccess();
          if (transList != null && transList.isNotEmpty) {
            ref
                .read(downloadManagerSelectedReciterProvider.notifier)
                .setReciter(transList.first);
          }
        }
      } else {
        final currentReciter = audioState.selectedReciter;
        if (currentReciter != null) {
          ref
              .read(downloadManagerSelectedReciterProvider.notifier)
              .setReciter(currentReciter);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    // Reset search query safely without calling ref after unmount
    _surahListController.searchSurahs('');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: IslamicKatibahAppBar(
        surahName: widget.isTranslationMode
            ? 'مدیریت دانلود ترجمه صوتی'
            : 'مدیریت دانلود صوت',
        fontFamily: AppTypography.fontFamily,
        showSearchField: true,
        searchFocusNode: _searchFocusNode,
        searchController: _searchController,
        onSearchChanged: (query) {
          ref.read(surahListControllerProvider.notifier).searchSurahs(query);
        },
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            DownloadManagerReciterSelector(
              isTranslationMode: widget.isTranslationMode,
            ),
            Expanded(
              child: DownloadManagerSurahList(
                initialSurahId: widget.initialSurahId,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
