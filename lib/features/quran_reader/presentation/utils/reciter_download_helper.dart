import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_name.dart';
import '../../../../core/services/audio_storage/audio_storage_providers.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../surah_list/application/controllers/surah_list_controller.dart';
import '../../../surah_list/domain/entities/surah_entity.dart';
import '../../../surah_list/presentation/widgets/surah_action_dialog.dart';
import '../../application/controllers/quran_audio_controller.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import '../../application/controllers/quran_reader_controller.dart';
import '../../domain/entities/reciter_entity.dart';
import '../../domain/enums/audio_playback_mode.dart';

abstract class ReciterDownloadHelper {
  /// Mode-aware download check.
  /// Based on the current [AudioPlaybackMode], checks whether all required
  /// audio sources (quran reciter and/or translation reader) are downloaded.
  /// Shows [SurahActionDialog] for the first missing source.
  /// Returns `true` only if ALL required sources are downloaded.
  static Future<bool> checkAndPromptForPlayback({
    required BuildContext context,
    required WidgetRef ref,
    int? surahId,
  }) async {
    final audioState = ref.read(quranAudioControllerProvider);
    final mode = audioState.playbackMode;
    final quranReciter = audioState.selectedReciter;
    final translationReciter = audioState.selectedTranslationReciter;

    final activeSurahId = surahId ??
        audioState.currentSurahId ??
        ref.read(quranReaderControllerProvider).currentSurahId;

    // Determine which sources need to be checked
    final needsQuran = mode.includesQuran;
    final needsTranslation = mode.includesTranslation;

    // Check Quran reciter first (if needed)
    if (needsQuran && quranReciter != null) {
      final isQuranReady = await _isReciterSurahDownloaded(
        ref: ref,
        reciterId: quranReciter.id,
        surahId: activeSurahId,
      );
      if (!isQuranReady) {
        if (!context.mounted) return false;
        await _showDownloadDialog(
          context: context,
          ref: ref,
          surahId: activeSurahId,
          message: 'صوت تلاوت قاری «${quranReciter.name}» برای این سوره دانلود نشده است.',
          isTranslation: false,
        );
        return false;
      }
    }

    // Check Translation reader (if needed)
    if (needsTranslation && translationReciter != null) {
      final isTranslationReady = await _isReciterSurahDownloaded(
        ref: ref,
        reciterId: translationReciter.id,
        surahId: activeSurahId,
      );
      if (!isTranslationReady) {
        if (!context.mounted) return false;
        await _showDownloadDialog(
          context: context,
          ref: ref,
          surahId: activeSurahId,
          message: 'صوت ترجمه گویای «${translationReciter.name}» برای این سوره دانلود نشده است.',
          isTranslation: true,
        );
        return false;
      }
    }

    return true;
  }

  /// Legacy single-reciter check (used by SurahListScreen and HorizontalReciterSelector).
  /// Does NOT consider playback mode — just checks one specific reciter.
  static Future<bool> checkAndPromptSurahDownload({
    required BuildContext context,
    required WidgetRef ref,
    required ReciterEntity reciter,
    int? surahId,
  }) async {
    final activeSurahId = surahId ??
        ref.read(quranAudioControllerProvider).currentSurahId ??
        ref.read(quranReaderControllerProvider).currentSurahId;

    final isReady = await _isReciterSurahDownloaded(
      ref: ref,
      reciterId: reciter.id,
      surahId: activeSurahId,
    );

    if (!isReady) {
      if (!context.mounted) return false;
      final isTranslation = reciter.styleId == 4;
      await _showDownloadDialog(
        context: context,
        ref: ref,
        surahId: activeSurahId,
        message: isTranslation
            ? 'صوت ترجمه گویای «${reciter.name}» برای این سوره دانلود نشده است.'
            : 'صوت تلاوت قاری «${reciter.name}» برای این سوره دانلود نشده است.',
        isTranslation: isTranslation,
      );
      return false;
    }
    return true;
  }

  // ── Private helpers ──

  static Future<bool> _isReciterSurahDownloaded({
    required WidgetRef ref,
    required int reciterId,
    required int surahId,
  }) async {
    final storageService = ref.read(audioStorageServiceProvider);
    final isSurahMarked = storageService.isSurahDownloaded(reciterId, surahId);
    if (isSurahMarked) return true;

    final firstAyahPath = await storageService.getLocalAyahAudioPath(
      reciterId: reciterId,
      surahId: surahId,
      ayahNumber: 1,
    );
    return firstAyahPath != null;
  }

  static Future<void> _showDownloadDialog({
    required BuildContext context,
    required WidgetRef ref,
    required int surahId,
    required String message,
    required bool isTranslation,
  }) async {
    final surahList = ref.read(surahListControllerProvider).surahs;
    final surah = surahList.firstWhere(
      (s) => s.number == surahId,
      orElse: () => SurahEntity(
        number: surahId,
        name: 'سوره $surahId',
        englishName: 'Surah $surahId',
        englishNameTranslation: '',
        numberOfAyahs: 7,
        revelationType: 'Meccan',
        startPage: 1,
        startJuz: 1,
      ),
    );

    final fontScript = ref.read(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final surahFontFamily = AppTypography.getFontFamilyByScript(fontScript);

    if (!context.mounted) return;

    await SurahActionDialog.show(
      context: context,
      surah: surah,
      surahFontFamily: surahFontFamily,
      message: message,
      onReadSurah: () {},
      onDownloadAudio: () {
        GoRouter.of(context).pushNamed(
          audioDownloadManagerRoute,
          queryParameters: {
            'surahId': surahId.toString(),
            if (isTranslation) 'isTranslation': 'true',
          },
        );
      },
    );
  }
}
