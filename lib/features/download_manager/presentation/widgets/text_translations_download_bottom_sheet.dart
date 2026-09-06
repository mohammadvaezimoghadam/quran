import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../translation_manager/application/controllers/translation_manager_controller.dart';
import '../../../translation_manager/domain/entities/translation_entity.dart';

class TextTranslationsDownloadBottomSheet extends ConsumerStatefulWidget {
  const TextTranslationsDownloadBottomSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TextTranslationsDownloadBottomSheet(),
    );
  }

  @override
  ConsumerState<TextTranslationsDownloadBottomSheet> createState() =>
      _TextTranslationsDownloadBottomSheetState();
}

class _TextTranslationsDownloadBottomSheetState
    extends ConsumerState<TextTranslationsDownloadBottomSheet> {
  String _selectedLanguageFilter = 'all'; // 'all', 'fa', 'en', 'other'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sheetBgColor = isDark ? const Color(0xFF141A19) : Colors.white;

    final translationState = ref.watch(translationManagerControllerProvider);
    final translations = translationState.value?.translations ?? [];
    final activeId = translationState.value?.activeTranslationId;
    final downloadProgress = translationState.value?.downloadProgress ?? {};

    // Filter by language
    final filteredTranslations = translations.where((t) {
      if (_selectedLanguageFilter == 'fa') return t.languageCode == 'fa';
      if (_selectedLanguageFilter == 'en') return t.languageCode == 'en';
      if (_selectedLanguageFilter == 'other') {
        return t.languageCode != 'fa' && t.languageCode != 'en';
      }
      return true;
    }).toList();

    final downloadedCount = translations.where((t) => t.isDownloaded).length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.78,
        decoration: BoxDecoration(
          color: sheetBgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        child: Column(
          children: [
            // Drag Handle
            Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.book_fill,
                    color: Color(0xFF0277BD),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'مدیریت متن ترجمه‌ها',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0277BD).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$downloadedCount از ${translations.length} دانلود شده',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0277BD),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Language Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('all', 'همه زبان‌ها', translations.length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'fa',
                    'فارسی',
                    translations.where((t) => t.languageCode == 'fa').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'en',
                    'انگلیسی',
                    translations.where((t) => t.languageCode == 'en').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'other',
                    'سایر زبان‌ها',
                    translations
                        .where((t) => t.languageCode != 'fa' && t.languageCode != 'en')
                        .length,
                  ),
                ],
              ),
            ),

            const Divider(height: 20),

            // Translations List
            Expanded(
              child: translationState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredTranslations.isEmpty
                      ? const Center(
                          child: Text(
                            'هیچ ترجمه‌ای در این دسته‌بندی یافت نشد',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          itemCount: filteredTranslations.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 16),
                          itemBuilder: (context, index) {
                            final translation = filteredTranslations[index];
                            final isDownloading =
                                downloadProgress.containsKey(translation.id);
                            final progress = downloadProgress[translation.id] ?? 0.0;
                            final isActive = translation.id == activeId;

                            return _TranslationListItem(
                              translation: translation,
                              isDownloading: isDownloading,
                              progress: progress,
                              isActive: isActive,
                              isDark: isDark,
                              onDownload: () {
                                ref
                                    .read(translationManagerControllerProvider.notifier)
                                    .downloadTranslation(translation);
                              },
                              onCancelDownload: () {
                                ref
                                    .read(translationManagerControllerProvider.notifier)
                                    .cancelDownload(translation.id);
                              },
                              onDelete: () => _confirmDelete(context, translation),
                              onSetActive: () {
                                ref
                                    .read(translationManagerControllerProvider.notifier)
                                    .setActiveTranslation(translation.id);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, int count) {
    final isSelected = _selectedLanguageFilter == key;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguageFilter = key;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0277BD)
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFF0ECE6)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : null,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($count)',
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, TranslationEntity translation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'حذف ترجمه',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'آیا از حذف داده‌های ترجمه «${translation.name}» از حافظه اطمینان دارید؟',
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(translationManagerControllerProvider.notifier)
          .deleteTranslation(translation.id);
    }
  }
}

class _TranslationListItem extends StatelessWidget {
  final TranslationEntity translation;
  final bool isDownloading;
  final double progress;
  final bool isActive;
  final bool isDark;
  final VoidCallback onDownload;
  final VoidCallback onCancelDownload;
  final VoidCallback onDelete;
  final VoidCallback onSetActive;

  const _TranslationListItem({
    required this.translation,
    required this.isDownloading,
    required this.progress,
    required this.isActive,
    required this.isDark,
    required this.onDownload,
    required this.onCancelDownload,
    required this.onDelete,
    required this.onSetActive,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toInt();

    return Column(
      children: [
        Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF4F1EA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  translation.isDownloaded
                      ? CupertinoIcons.checkmark_seal_fill
                      : CupertinoIcons.book,
                  color: translation.isDownloaded
                      ? Colors.green
                      : (isDark ? Colors.white60 : Colors.black54),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          translation.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ترجمه فعال',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'مترجم: ${translation.translatorName} (${translation.languageCode.toUpperCase()})',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Actions
            if (isDownloading) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$percent٪',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0277BD),
                    ),
                  ),
                  IconButton(
                    tooltip: 'لغو دانلود',
                    icon: const Icon(
                      CupertinoIcons.xmark_circle,
                      size: 22,
                      color: AppColors.error,
                    ),
                    onPressed: onCancelDownload,
                  ),
                ],
              ),
            ] else if (translation.isDownloaded) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isActive)
                    TextButton(
                      onPressed: onSetActive,
                      child: const Text(
                        'انتخاب',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  if (!translation.isDefault)
                    IconButton(
                      tooltip: 'حذف از حافظه',
                      icon: const Icon(
                        CupertinoIcons.trash,
                        size: 19,
                        color: Colors.redAccent,
                      ),
                      onPressed: onDelete,
                    ),
                ],
              ),
            ] else ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0277BD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(CupertinoIcons.cloud_download, size: 16),
                label: const Text(
                  'دانلود',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: onDownload,
              ),
            ],
          ],
        ),

        // Progress bar when downloading
        if (isDownloading) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF0ECE6),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0277BD)),
            ),
          ),
        ],
      ],
    );
  }
}
