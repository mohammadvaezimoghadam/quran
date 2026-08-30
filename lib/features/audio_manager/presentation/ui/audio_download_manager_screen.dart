import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../quran_reader/application/controllers/quran_audio_controller.dart';
import '../../../quran_reader/application/controllers/reciter_providers.dart';
import '../../application/states/download_manager_state.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../common/widgets/islamic_katibah_app_bar.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../application/states/download_manager_selected_surahs_provider.dart';
import '../widgets/download_manager_reciter_selector.dart';
import '../widgets/download_manager_surah_list.dart';
import '../widgets/download_manager_action_bar.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialSurahId != null) {
        ref
            .read(downloadManagerSelectedSurahsProvider.notifier)
            .setSurahs({widget.initialSurahId!});
      } else {
        ref.read(downloadManagerSelectedSurahsProvider.notifier).setSurahs({});
      }

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
  Widget build(BuildContext context) {
    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final fontFamily = AppTypography.getFontFamilyByScript(fontScript);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: IslamicKatibahAppBar(
        surahName: widget.isTranslationMode
            ? 'مدیریت دانلود ترجمه صوتی'
            : 'مدیریت دانلود صوت',
        fontFamily: fontFamily,
      ),
      body: Column(
        children: [
          DownloadManagerReciterSelector(
            isTranslationMode: widget.isTranslationMode,
          ),
          Expanded(
            child: DownloadManagerSurahList(
              initialSurahId: widget.initialSurahId,
            ),
          ),
          const DownloadManagerActionBar(),
        ],
      ),
    );
  }
}
