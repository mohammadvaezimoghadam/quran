import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/widgets/islamic_katibah_app_bar.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/download_hub_controller.dart';
import '../../application/controllers/downloaded_items_controller.dart';
import '../widgets/download_active_queue_section.dart';
import '../widgets/download_category_card.dart';
import '../widgets/download_storage_info_card.dart';
import '../widgets/downloaded_items_section.dart';
import '../widgets/text_translations_download_bottom_sheet.dart';

class DownloadHubScreen extends ConsumerWidget {
  const DownloadHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(downloadHubControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const IslamicKatibahAppBar(
        surahName: 'مدیریت دانلودها',
        fontFamily: AppTypography.fontFamily,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(downloadHubControllerProvider.notifier).loadSummary(),
            ref.read(downloadedItemsControllerProvider.notifier).loadItems(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Storage Info Card
              DownloadStorageInfoCard(state: state),

              const SizedBox(height: 12),

              // 2. Main Categories Grid
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                child: Text(
                  'دسته‌بندی فایل‌های آفلاین',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 2. Main Categories in ONE Single Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category 1: Quran Audio
                    Expanded(
                      child: DownloadCategoryCard(
                        title: 'صوت قرآن',
                        subtitle: state.activeReciterName.replaceAll('استاد ', ''),
                        icon: CupertinoIcons.waveform,
                        badgeText: '${state.downloadedQuranSurahs.toPersianDigit()} / ${state.totalQuranSurahs.toPersianDigit()}',
                        progress: state.totalQuranSurahs > 0
                            ? state.downloadedQuranSurahs / state.totalQuranSurahs
                            : 0.0,
                        onTap: () async {
                          await context.pushNamed(
                            audioDownloadManagerRoute,
                            queryParameters: {'isTranslation': 'false'},
                          );
                          ref.read(downloadHubControllerProvider.notifier).loadSummary();
                          ref.read(downloadedItemsControllerProvider.notifier).loadItems();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Category 2: Audio Translation
                    Expanded(
                      child: DownloadCategoryCard(
                        title: 'ترجمه گویا',
                        subtitle: state.activeTranslationReciterName,
                        icon: CupertinoIcons.speaker_2_fill,
                        badgeText: '${state.downloadedTranslationSurahs.toPersianDigit()} / ${state.totalTranslationSurahs.toPersianDigit()}',
                        progress: state.totalTranslationSurahs > 0
                            ? state.downloadedTranslationSurahs / state.totalTranslationSurahs
                            : 0.0,
                        onTap: () async {
                          await context.pushNamed(
                            audioDownloadManagerRoute,
                            queryParameters: {'isTranslation': 'true'},
                          );
                          ref.read(downloadHubControllerProvider.notifier).loadSummary();
                          ref.read(downloadedItemsControllerProvider.notifier).loadItems();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Category 3: Text Translations
                    Expanded(
                      child: DownloadCategoryCard(
                        title: 'متن ترجمه',
                        subtitle: 'ترجمه‌ها',
                        icon: CupertinoIcons.book_fill,
                        badgeText: '${state.downloadedTextTranslations.toPersianDigit()} / ${state.totalTextTranslations.toPersianDigit()}',
                        progress: state.totalTextTranslations > 0
                            ? state.downloadedTextTranslations / state.totalTextTranslations
                            : 0.0,
                        onTap: () async {
                          await TextTranslationsDownloadBottomSheet.show(context);
                          ref.read(downloadHubControllerProvider.notifier).loadSummary();
                          ref.read(downloadedItemsControllerProvider.notifier).loadItems();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 3. Live Active Queue Section
              const DownloadActiveQueueSection(),

              const SizedBox(height: 12),

              // 4. Downloaded Offline Items Section
              const DownloadedItemsSection(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
