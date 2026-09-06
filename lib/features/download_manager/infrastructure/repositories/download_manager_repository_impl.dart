import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../common/constants/surah_constants.dart';
import '../../../../common/exceptions/failure.dart';
import '../../../../core/data/local/preferences/preferences_service_provider.dart';
import '../../../audio_manager/application/states/download_manager_state.dart';
import '../../../quran_reader/application/controllers/quran_audio_controller.dart';
import '../../../quran_reader/application/controllers/reciter_providers.dart';
import '../../../translation_manager/infrastructure/repositories/translation_repository_impl.dart';
import '../../domain/entities/download_hub_summary_entity.dart';
import '../../domain/entities/downloaded_item_entity.dart';
import '../../domain/repositories/download_manager_repository.dart';
import '../datasources/download_manager_local_datasource.dart';

final downloadManagerRepositoryProvider =
    Provider<IDownloadManagerRepository>((ref) {
  final localDataSource = ref.watch(downloadManagerLocalDataSourceProvider);
  return DownloadManagerRepositoryImpl(
    localDataSource,
    ref,
  );
});

class DownloadManagerRepositoryImpl implements IDownloadManagerRepository {
  final IDownloadManagerLocalDataSource _localDataSource;
  final Ref _ref;

  DownloadManagerRepositoryImpl(this._localDataSource, this._ref);

  @override
  Future<Result<DownloadHubSummaryEntity, Failure>> getDownloadHubSummary() async {
    try {
      // 1. Storage metrics
      final totalBytes = await _localDataSource.getTotalAudioStorageSizeInBytes();
      final storagePath = await _localDataSource.getRootAudioStorageDirectory();

      // 2. Wi-Fi Preference
      final isWifiOnly = _localDataSource.getWifiOnlyPreference();

      // 3. Quran Reciter stats
      final audioState = _ref.read(quranAudioControllerProvider);
      var activeReciter = _ref.read(downloadManagerSelectedReciterProvider) ??
          audioState.selectedReciter;

      final allReciters = await _ref.read(arabicRecitersListProvider.future);
      final recitersList = allReciters.tryGetSuccess() ?? [];

      if (activeReciter == null) {
        final prefs = _ref.read(sharedPreferencesInstanceProvider);
        final savedId = prefs.getInt('selected_reciter_id');
        if (savedId != null) {
          activeReciter = recitersList.where((r) => r.id == savedId).firstOrNull;
        }
        activeReciter ??= recitersList
                .where((r) => r.identifier.contains('parhizgar'))
                .firstOrNull ??
            recitersList.firstOrNull;
      }

      var activeReciterId = activeReciter?.id ?? 91;
      var activeReciterName = activeReciter?.name ?? 'شهریار پرهیزگار';
      var quranDownloadedList =
          _localDataSource.getDownloadedSurahsForReciter(activeReciterId);

      // If current active reciter has 0 downloads, check if another reciter (e.g. Parhizgar) has downloads
      if (quranDownloadedList.isEmpty) {
        for (final r in recitersList) {
          final downloads = _localDataSource.getDownloadedSurahsForReciter(r.id);
          if (downloads.isNotEmpty) {
            activeReciter = r;
            activeReciterId = r.id;
            activeReciterName = r.name;
            quranDownloadedList = downloads;
            break;
          }
        }
      }

      // 4. Audio Translation Reciter stats
      final allTransReciters =
          await _ref.read(translationRecitersListProvider.future);
      final transList = allTransReciters.tryGetSuccess() ?? [];

      var activeTransReciter = audioState.selectedTranslationReciter;
      if (activeTransReciter == null) {
        final prefs = _ref.read(sharedPreferencesInstanceProvider);
        final savedTransId = prefs.getInt('selected_translation_reciter_id');
        if (savedTransId != null) {
          activeTransReciter =
              transList.where((r) => r.id == savedTransId).firstOrNull;
        }
        activeTransReciter ??= transList.firstOrNull;
      }

      var activeTransId = activeTransReciter?.id ?? 53;
      var activeTransName = activeTransReciter?.name ?? 'ترجمه صوتی گویا';
      var transDownloadedList =
          _localDataSource.getDownloadedSurahsForReciter(activeTransId);

      // If current active translation reciter has 0 downloads, check if another speaker has downloads
      if (transDownloadedList.isEmpty) {
        for (final r in transList) {
          final downloads = _localDataSource.getDownloadedSurahsForReciter(r.id);
          if (downloads.isNotEmpty) {
            activeTransReciter = r;
            activeTransId = r.id;
            activeTransName = r.name;
            transDownloadedList = downloads;
            break;
          }
        }
      }

      // 5. Text Translations stats
      final translationRepo = _ref.read(translationRepositoryProvider);
      final translationsResult = await translationRepo.getAllTranslations();
      final translationsList = translationsResult.tryGetSuccess() ?? [];
      final downloadedTextCount =
          translationsList.where((t) => t.isDownloaded).length;
      final totalTextCount = translationsList.length;

      final entity = DownloadHubSummaryEntity(
        totalAudioStorageBytes: totalBytes,
        storagePath: storagePath,
        downloadedQuranSurahs: quranDownloadedList.length,
        totalQuranSurahs: 114,
        activeReciterName: activeReciterName,
        activeReciterId: activeReciterId,
        downloadedTranslationSurahs: transDownloadedList.length,
        totalTranslationSurahs: 114,
        activeTranslationReciterName: activeTransName,
        activeTranslationReciterId: activeTransId,
        downloadedTextTranslations: downloadedTextCount,
        totalTextTranslations: totalTextCount > 0 ? totalTextCount : 1,
        isWifiOnly: isWifiOnly,
      );

      return Success(entity);
    } catch (e, stack) {
      return Error(
        Failure(
          message: 'خطا در بارگذاری خلاصه وضعیت دانلودها: $e',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<void, Failure>> setWifiOnlyPreference(bool isWifiOnly) async {
    try {
      await _localDataSource.setWifiOnlyPreference(isWifiOnly);
      return const Success(null);
    } catch (e, stack) {
      return Error(
        Failure(
          message: 'خطا در ذخیره تنظیمات وای‌فای: $e',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<void, Failure>> clearAllAudioCache() async {
    try {
      await _localDataSource.clearAllAudioCache();
      return const Success(null);
    } catch (e, stack) {
      return Error(
        Failure(
          message: 'خطا در پاک‌سازی حافظه صوتی: $e',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<void, Failure>> clearAllDownloads() async {
    try {
      // 1. Clear all physical audio cache and audio Hive database
      await _localDataSource.clearAllAudioCache();

      // 2. Clear all downloaded text translations (except preserving default preloaded)
      final translationRepo = _ref.read(translationRepositoryProvider);
      final translationsResult = await translationRepo.getAllTranslations();
      final translationsList = translationsResult.tryGetSuccess() ?? [];
      final downloadedTexts = translationsList.where((t) => t.isDownloaded && t.id != 'fa.makarem');

      for (final t in downloadedTexts) {
        await translationRepo.deleteTranslation(t.id);
      }

      return const Success(null);
    } catch (e, stack) {
      return Error(
        Failure(
          message: 'خطا در پاک‌سازی کلی فایل‌های دانلودی: $e',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<void, Failure>> deleteSurahAudio({
    required int reciterId,
    required int surahId,
  }) async {
    try {
      await _localDataSource.deleteSurahAudio(
        reciterId: reciterId,
        surahId: surahId,
      );
      return const Success(null);
    } catch (e, stack) {
      return Error(
        Failure(
          message: 'خطا در حذف صوت سوره: $e',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<List<DownloadedItemEntity>, Failure>> getAllDownloadedItems() async {
    try {
      final List<DownloadedItemEntity> items = [];

      // 1. Get all reciters to resolve reciter names and types
      final allRecitersResult = await _ref.read(allRecitersListProvider.future);
      final allReciters = allRecitersResult.tryGetSuccess() ?? [];

      // 2. Scan downloaded audio Surahs
      final audioSurahs = _localDataSource.getAllDownloadedAudioSurahs();
      for (final item in audioSurahs) {
        final reciter = allReciters.where((r) => r.id == item.reciterId).firstOrNull;
        final isAudioTranslation = reciter?.styleId == 4;
        final surahName = SurahConstants.getSurahName(item.surahId);
        final sizeBytes = await _localDataSource.getSurahDirectorySize(
          reciterId: item.reciterId,
          surahId: item.surahId,
        );
        final lastModified = await _localDataSource.getSurahLastModified(
          reciterId: item.reciterId,
          surahId: item.surahId,
        );

        final mb = sizeBytes / (1024 * 1024);
        final formattedSize = mb >= 0.1
            ? '${mb.toStringAsFixed(1)} مگابایت'
            : (sizeBytes > 0
                ? '${(sizeBytes / 1024).toStringAsFixed(0)} کیلوبایت'
                : 'کمتر از ۱ کیلوبایت');

        items.add(
          DownloadedItemEntity(
            id: 'audio_r${item.reciterId}_s${item.surahId}',
            type: isAudioTranslation
                ? DownloadedItemType.audioTranslation
                : DownloadedItemType.quranAudio,
            title: 'سوره $surahName',
            subtitle: isAudioTranslation
                ? 'گوینده: ${reciter?.name ?? 'گوینده ناشناس'}'
                : 'قاری: ${reciter?.name ?? 'قاری ناشناس'}',
            surahId: item.surahId,
            reciterId: item.reciterId,
            sizeBytes: sizeBytes,
            formattedSize: formattedSize,
            downloadedAt: lastModified,
          ),
        );
      }

      // 3. Scan downloaded text translations
      final translationRepo = _ref.read(translationRepositoryProvider);
      final translationsResult = await translationRepo.getAllTranslations();
      final translationsList = translationsResult.tryGetSuccess() ?? [];
      final downloadedTexts = translationsList.where((t) => t.isDownloaded);

      final prefs = _ref.read(sharedPreferencesInstanceProvider);
      for (final t in downloadedTexts) {
        const approxBytes = 1500000;
        final savedTimeStr = prefs.getString('trans_downloaded_at_${t.id}');
        final downloadedAt = savedTimeStr != null
            ? DateTime.tryParse(savedTimeStr)
            : null;

        items.add(
          DownloadedItemEntity(
            id: 'text_${t.id}',
            type: DownloadedItemType.textTranslation,
            title: 'ترجمه ${t.name}',
            subtitle: 'مترجم: ${t.translatorName}',
            translationId: t.id,
            sizeBytes: approxBytes,
            formattedSize: '~1.5 مگابایت',
            downloadedAt: downloadedAt,
          ),
        );
      }

      // 4. Sort: Newest downloaded first at the top of the list
      items.sort((a, b) {
        final aTime = a.downloadedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.downloadedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      return Success(items);
    } catch (e, stack) {
      return Error(
        Failure(
          message: 'خطا در واکشی فهرست فایل‌های دانلود شده: $e',
          stackTrace: stack,
        ),
      );
    }
  }
}
