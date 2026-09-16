import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
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
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final state = ref.watch(downloadHubControllerProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62.0),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 4,
            left: 8.0,
            right: 8.0,
            bottom: 6.0,
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
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.goNamed(quranHomeRoute);
                  }
                },
              ),
              Expanded(
                child: Text(
                  'مدیریت دانلودها',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balance back button
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        color: colorScheme.primary,
        onRefresh: () async {
          await Future.wait([
            ref.read(downloadHubControllerProvider.notifier).loadSummary(),
            ref.read(downloadedItemsControllerProvider.notifier).loadItems(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: 6.0,
            bottom: MediaQuery.paddingOf(context).bottom + 28.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Storage Info Card
              DownloadStorageInfoCard(state: state),

              const SizedBox(height: 4),

              // 2. Main Categories Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                child: Text(
                  'دسته‌بندی فایل‌های دانلودی',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),

              // 2. Main Categories in ONE Single Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category 1: Quran Audio
                    Expanded(
                      child: DownloadCategoryCard(
                        title: 'صوت قرآن',
                        subtitle: state.activeReciterName.replaceAll('استاد ', ''),
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

              const SizedBox(height: 6),

              // 3. Live Active Queue Section
              const DownloadActiveQueueSection(),

              const SizedBox(height: 6),

              // 4. Downloaded Offline Items Section
              const DownloadedItemsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
