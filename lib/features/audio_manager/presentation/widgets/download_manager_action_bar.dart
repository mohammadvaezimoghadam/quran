import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/app_snackbar.dart';
import '../../application/states/download_manager_state.dart';
import '../../application/states/download_manager_selected_surahs_provider.dart';
import '../../application/controllers/audio_download_controller.dart';

class DownloadManagerActionBar extends ConsumerWidget {
  const DownloadManagerActionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedReciter = ref.watch(downloadManagerSelectedReciterProvider);
    final selectedSurahs = ref.watch(downloadManagerSelectedSurahsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = selectedReciter != null && selectedSurahs.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: colorScheme.surface,
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isEnabled
                ? () {
                    final surahCount = selectedSurahs.length;
                    for (final surahId in selectedSurahs) {
                      ref
                          .read(audioDownloadControllerProvider.notifier)
                          .startDownload(
                            reciter: selectedReciter,
                            surahId: surahId,
                          );
                    }
                    ref
                        .read(downloadManagerSelectedSurahsProvider.notifier)
                        .setSurahs({});

                    AppSnackBar.showSuccess(
                      context,
                      'دانلود $surahCount سوره شروع شد.',
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
              disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              selectedSurahs.isEmpty
                  ? 'لطفاً سوره‌های مورد نظر را انتخاب کنید'
                  : 'دانلود ${selectedSurahs.length} سوره انتخاب شده',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isEnabled 
                        ? Colors.white
                        : colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
