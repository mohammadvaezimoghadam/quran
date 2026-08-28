import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../common/widgets/islamic_katibah_app_bar.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../application/states/download_manager_selected_surahs_provider.dart';
import '../widgets/download_manager_reciter_selector.dart';
import '../widgets/download_manager_surah_list.dart';
import '../widgets/download_manager_action_bar.dart';

class AudioDownloadManagerScreen extends ConsumerStatefulWidget {
  final int? initialSurahId;

  const AudioDownloadManagerScreen({
    super.key,
    this.initialSurahId,
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
    // Ensure no Surah is pre-selected upon entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(downloadManagerSelectedSurahsProvider.notifier).setSurahs({});
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
        surahName: 'مدیریت دانلود صوت',
        fontFamily: fontFamily,
      ),
      body: const Column(
        children: [
          DownloadManagerReciterSelector(),
          Expanded(
            child: DownloadManagerSurahList(),
          ),
          DownloadManagerActionBar(),
        ],
      ),
    );
  }
}
