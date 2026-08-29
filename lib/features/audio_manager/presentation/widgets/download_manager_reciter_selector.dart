import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../common/widgets/reciter/reciter_selection_bottom_sheet.dart';
import '../../../quran_reader/domain/entities/reciter_entity.dart';
import '../../../quran_reader/application/controllers/reciter_providers.dart';
import '../../../quran_reader/application/controllers/quran_audio_controller.dart';
import '../../application/states/download_manager_state.dart';

class DownloadManagerReciterSelector extends ConsumerWidget {
  final bool isTranslationMode;

  const DownloadManagerReciterSelector({
    super.key,
    this.isTranslationMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedReciter = ref.watch(downloadManagerSelectedReciterProvider);
    final recitersResult = ref.watch(
      isTranslationMode ? translationRecitersListProvider : recitersListProvider,
    );
    
    List<ReciterEntity> reciters = [];
    if (recitersResult.value != null && recitersResult.value!.isSuccess()) {
      reciters = recitersResult.value!.tryGetSuccess() ?? [];
    }

    if (selectedReciter == null && reciters.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final audioState = ref.read(quranAudioControllerProvider);
        final defaultReciter = isTranslationMode
            ? (audioState.selectedTranslationReciter ?? reciters.first)
            : (audioState.selectedReciter ?? reciters.first);
        ref.read(downloadManagerSelectedReciterProvider.notifier).setReciter(defaultReciter);
      });
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isTranslationMode ? 'گوینده ترجمه:' : 'قاری:',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () {
                ReciterSelectionBottomSheet.show(
                  context,
                  isDownloadMode: true,
                  isTranslationMode: isTranslationMode,
                  onReciterSelected: (ReciterEntity reciter) {
                    ref.read(downloadManagerSelectedReciterProvider.notifier).setReciter(reciter);
                  },
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        selectedReciter?.name ?? (isTranslationMode ? 'انتخاب گوینده' : 'انتخاب قاری'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontFamily: AppTypography.fontFamily,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
