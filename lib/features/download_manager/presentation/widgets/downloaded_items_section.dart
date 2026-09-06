import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/data/local/preferences/preferences_keys.dart';
import '../../../../core/data/local/preferences/preferences_service_provider.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran_reader/application/controllers/quran_audio_controller.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../../quran_reader/application/controllers/reciter_providers.dart';
import '../../../quran_reader/domain/enums/audio_playback_mode.dart';
import '../../../translation_manager/application/controllers/translation_manager_controller.dart';
import '../../application/controllers/downloaded_items_controller.dart';
import '../../domain/entities/downloaded_item_entity.dart';

class DownloadedItemsSection extends ConsumerStatefulWidget {
  const DownloadedItemsSection({super.key});

  @override
  ConsumerState<DownloadedItemsSection> createState() =>
      _DownloadedItemsSectionState();
}

class _DownloadedItemsSectionState extends ConsumerState<DownloadedItemsSection> {
  String _selectedFilter = 'all'; // 'all', 'quran', 'trans_audio', 'trans_text'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final asyncItems = ref.watch(downloadedItemsControllerProvider);

    final cardBgColor = isDark ? const Color(0xFF192220) : Colors.white;
    final cardBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFEAE7E3);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: cardBorderColor, width: 1),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12.0,
                  offset: const Offset(0, 3.0),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: asyncItems.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'خطا در بارگیری دانلودها: $err',
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
          ),
          data: (items) {
            final quranAudioItems = items
                .where((i) => i.type == DownloadedItemType.quranAudio)
                .toList();
            final audioTransItems = items
                .where((i) => i.type == DownloadedItemType.audioTranslation)
                .toList();
            final textTransItems = items
                .where((i) => i.type == DownloadedItemType.textTranslation)
                .toList();

            final filteredItems = items.where((item) {
              if (_selectedFilter == 'quran') {
                return item.type == DownloadedItemType.quranAudio;
              }
              if (_selectedFilter == 'trans_audio') {
                return item.type == DownloadedItemType.audioTranslation;
              }
              if (_selectedFilter == 'trans_text') {
                return item.type == DownloadedItemType.textTranslation;
              }
              return true;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.tray_full_fill,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'فایل‌های دانلود شده',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${items.length} فایل ذخیره',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 2. Filter Tabs
                if (items.isNotEmpty) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'همه', items.length),
                        const SizedBox(width: 8),
                        _buildFilterChip('quran', 'صوت قرآن', quranAudioItems.length),
                        const SizedBox(width: 8),
                        _buildFilterChip('trans_audio', 'ترجمه گویا', audioTransItems.length),
                        const SizedBox(width: 8),
                        _buildFilterChip('trans_text', 'متن ترجمه', textTransItems.length),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 3. Content: Empty or List
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            CupertinoIcons.tray,
                            size: 44,
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'هنوز فایلی در حافظه دستگاه دانلود نشده است.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'با استفاده از گزینه‌های بالا می‌توانید صوت و ترجمه‌ها را برای استفاده آفلاین دانلود کنید.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else if (filteredItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Text(
                        'موردی در این دسته‌بندی وجود ندارد.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredItems.length,
                    separatorBuilder: (context, index) => const Divider(height: 18),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _DownloadedItemRow(
                        item: item,
                        isDark: isDark,
                        onOpen: () => _openItem(item),
                        onDelete: () => _confirmDelete(item),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, int count) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = key;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFF0ECE6)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : null,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($count)',
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openItem(DownloadedItemEntity item) async {
    switch (item.type) {
      case DownloadedItemType.quranAudio:
        if (item.reciterId != null) {
          final allReciters = await ref.read(allRecitersListProvider.future);
          final reciter = allReciters
              .tryGetSuccess()
              ?.where((r) => r.id == item.reciterId)
              .firstOrNull;
          if (reciter != null) {
            await ref
                .read(quranAudioControllerProvider.notifier)
                .selectReciter(reciter);
          }
        }
        // Set playback mode to only Quran recitation and persist
        ref
            .read(quranAudioControllerProvider.notifier)
            .setPlaybackMode(AudioPlaybackMode.onlyQuran);

        if (mounted && item.surahId != null) {
          context.pushNamed(
            quranReaderRoute,
            pathParameters: {'id': item.surahId.toString()},
          );
        }
        break;

      case DownloadedItemType.audioTranslation:
        if (item.reciterId != null) {
          final allReciters = await ref.read(allRecitersListProvider.future);
          final reciter = allReciters
              .tryGetSuccess()
              ?.where((r) => r.id == item.reciterId)
              .firstOrNull;
          if (reciter != null) {
            await ref
                .read(quranAudioControllerProvider.notifier)
                .selectTranslationReciter(reciter);
          }
        }
        // Set playback mode to only Translation and persist
        ref
            .read(quranAudioControllerProvider.notifier)
            .setPlaybackMode(AudioPlaybackMode.onlyTranslation);

        if (mounted && item.surahId != null) {
          context.pushNamed(
            quranReaderRoute,
            pathParameters: {'id': item.surahId.toString()},
          );
        }
        break;

      case DownloadedItemType.textTranslation:
        if (item.translationId != null) {
          // Set as active translation and persist in preferences
          await ref
              .read(translationManagerControllerProvider.notifier)
              .setActiveTranslation(item.translationId!);
        }
        // Ensure translation display is turned on and persisted
        ref
            .read(quranDisplaySettingsControllerProvider.notifier)
            .toggleTranslation(true);
        ref
            .read(preferencesServiceProvider)
            .setBool(PreferencesKeys.showTranslation, true);

        if (mounted) {
          context.pushNamed(
            quranReaderRoute,
            pathParameters: {'id': '1'},
            queryParameters: {'translationId': item.translationId},
          );
        }
        break;
    }
  }

  Future<void> _confirmDelete(DownloadedItemEntity item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'حذف فایل دانلود شده',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'آیا از حذف «${item.title}» (${item.subtitle}) از حافظه دستگاه اطمینان دارید؟',
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف فایل', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (item.reciterId != null && item.surahId != null) {
        await ref.read(downloadedItemsControllerProvider.notifier).deleteAudioItem(
              reciterId: item.reciterId!,
              surahId: item.surahId!,
            );
      } else if (item.translationId != null) {
        await ref
            .read(downloadedItemsControllerProvider.notifier)
            .deleteTextTranslation(item.translationId!);
      }
      if (mounted) {
        AppSnackBar.showSuccess(context, '«${item.title}» از حافظه حذف شد');
      }
    }
  }
}

class _DownloadedItemRow extends StatelessWidget {
  final DownloadedItemEntity item;
  final bool isDark;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _DownloadedItemRow({
    required this.item,
    required this.isDark,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String badgeLabel;
    IconData iconData;

    switch (item.type) {
      case DownloadedItemType.quranAudio:
        badgeColor = AppColors.primary;
        badgeLabel = 'صوت قرآن';
        iconData = CupertinoIcons.waveform;
        break;
      case DownloadedItemType.audioTranslation:
        badgeColor = Colors.deepPurple;
        badgeLabel = 'ترجمه گویا';
        iconData = CupertinoIcons.speaker_2_fill;
        break;
      case DownloadedItemType.textTranslation:
        badgeColor = const Color(0xFF0277BD);
        badgeLabel = 'متن ترجمه';
        iconData = CupertinoIcons.book_fill;
        break;
    }

    return Row(
      children: [
        // Type Badge Icon
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(iconData, size: 18, color: badgeColor),
          ),
        ),
        const SizedBox(width: 12),

        // Title and Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeLabel,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '• ${item.formattedSize}',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Action Buttons: Open & Delete
        IconButton(
          tooltip: 'مشاهده / پخش',
          icon: const Icon(
            CupertinoIcons.play_arrow_solid,
            size: 18,
            color: AppColors.primary,
          ),
          onPressed: onOpen,
        ),
        IconButton(
          tooltip: 'حذف از حافظه',
          icon: const Icon(
            CupertinoIcons.trash,
            size: 17,
            color: Colors.redAccent,
          ),
          onPressed: onDelete,
        ),
      ],
    );
  }
}
