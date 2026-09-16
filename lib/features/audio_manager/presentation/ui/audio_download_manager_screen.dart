import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran_reader/application/controllers/quran_audio_controller.dart';
import '../../../quran_reader/application/controllers/reciter_providers.dart';
import '../../../surah_list/application/controllers/surah_list_controller.dart';
import '../../application/states/download_manager_state.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure search query starts clean
      ref.read(surahListControllerProvider.notifier).searchSurahs('');

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(surahListControllerProvider.notifier).searchSurahs('');
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(116.0),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 4,
              left: 12.0,
              right: 8.0,
              bottom: 8.0,
            ),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              border: Border(
                bottom: BorderSide(
                  color: colors.cardBorder,
                  width: 0.8,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'بازگشت',
                        icon: Icon(
                          CupertinoIcons.chevron_forward,
                          size: 24,
                          color: colorScheme.onSurface,
                        ),
                        splashRadius: 22,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).maybePop();
                        },
                      ),
                      Expanded(
                        child: Text(
                          widget.isTranslationMode
                              ? 'دانلود ترجمه صوتی'
                              : 'دانلود صوت قرآن',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for back button
                    ],
                  ),
                ),
                6.vSpace,
                Container(
                  height: 42,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : const Color(0xFFF1EFEA),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: colors.cardBorder,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      10.hSpace,
                      Icon(
                        CupertinoIcons.search,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      8.hSpace,
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: (query) {
                            ref
                                .read(surahListControllerProvider.notifier)
                                .searchSurahs(query);
                          },
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13.5,
                            color: colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'جستجوی نام سوره...',
                            hintStyle: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12.5,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.55),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8.0),
                          ),
                        ),
                      ),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _searchController,
                        builder: (context, value, _) {
                          if (value.text.isNotEmpty) {
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _searchController.clear();
                                ref
                                    .read(surahListControllerProvider.notifier)
                                    .searchSurahs('');
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(
                                  CupertinoIcons.xmark_circle,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
      ),
    );
  }
}
