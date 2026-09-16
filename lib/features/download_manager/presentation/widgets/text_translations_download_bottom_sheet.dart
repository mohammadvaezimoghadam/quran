import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../subscription/application/vip_subscription_controller.dart';
import '../../../subscription/domain/policy/translation_vip_policy.dart';
import '../../../subscription/presentation/widgets/vip_required_dialog.dart';
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
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    final translationState = ref.watch(translationManagerControllerProvider);
    final translations = translationState.value?.translations ?? [];
    final activeId = translationState.value?.activeTranslationId;
    final downloadProgress = translationState.value?.downloadProgress ?? {};
    final hasVip = ref.watch(hasVipAccessProvider);

    // Filter by language
    final filteredTranslations = translations.where((t) {
      if (_selectedLanguageFilter == 'all') return true;
      if (_selectedLanguageFilter == 'other') {
        return t.languageCode != 'fa' && t.languageCode != 'en';
      }
      return t.languageCode == _selectedLanguageFilter;
    }).toList();

    final downloadedCount = translations.where((t) => t.isDownloaded).length;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.78,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Top Drag Handle
          Center(
            child: Container(
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Header Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'دانلود ترجمه‌های متنی',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${downloadedCount.toPersianDigit()} از ${translations.length.toPersianDigit()} دانلود شده',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'بستن',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    CupertinoIcons.chevron_down,
                    size: 22,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Language Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  'English',
                  translations.where((t) => t.languageCode == 'en').length,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'other',
                  'سایر زبان‌ها',
                  translations
                      .where((t) =>
                          t.languageCode != 'fa' && t.languageCode != 'en')
                      .length,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Divider(
            height: 1,
            thickness: 0.6,
            color: colors.cardBorder,
          ),

          // Translations List
          Expanded(
            child: translationState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTranslations.isEmpty
                    ? Center(
                        child: Text(
                          'ترجمه‌ای یافت نشد',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        itemCount: filteredTranslations.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 0.5,
                          color: colors.cardBorder.withValues(alpha: 0.6),
                        ),
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
                            hasVip: hasVip,
                            onDownload: () {
                              if (!TranslationVipPolicy.canAccessTranslation(
                                  translationId: translation.id, hasVip: hasVip)) {
                                VipRequiredDialog.show(context: context);
                                return;
                              }
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
                              if (!TranslationVipPolicy.canAccessTranslation(
                                  translationId: translation.id, hasVip: hasVip)) {
                                VipRequiredDialog.show(context: context);
                                return;
                              }
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
    );
  }

  Widget _buildFilterChip(String key, String label, int count) {
    final isSelected = _selectedLanguageFilter == key;
    final colorScheme = context.colorScheme;
    final colors = context.colors;
    final isDark = context.isDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedLanguageFilter = key;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(
                    alpha: isDark ? 0.20 : 0.12,
                  )
                : colors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(
                      alpha: isDark ? 0.50 : 0.35,
                    )
                  : colors.cardBorder,
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.primary
                      : (isDark ? Colors.white70 : const Color(0xFF5A5852)),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${count.toPersianDigit()})',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.8)
                      : (isDark ? Colors.white38 : Colors.black38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TranslationEntity translation,
  ) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text('حذف ترجمه'),
        content: Text('آیا از حذف داده‌های ترجمه «${translation.name}» از حافظه اطمینان دارید؟'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('حذف'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('انصراف'),
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
  final bool hasVip;
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
    required this.hasVip,
    required this.onDownload,
    required this.onCancelDownload,
    required this.onDelete,
    required this.onSetActive,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final percent = (progress * 100).toInt();
    final isFree = TranslationVipPolicy.isTranslationFree(translation.id);
    final isLocked = !hasVip && !isFree;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        children: [
          Row(
            children: [
              // Clean Icon Badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: translation.isDownloaded
                      ? colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.10)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFF2EFE9)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    translation.isDownloaded
                        ? CupertinoIcons.checkmark_seal_fill
                        : CupertinoIcons.book,
                    color: translation.isDownloaded
                        ? colorScheme.primary
                        : (isDark ? Colors.white54 : Colors.black45),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Title
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        translation.name,
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      Text(
                        '• ترجمه فعال',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.greenAccent : Colors.green.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Actions (Unboxed, clean plain text)
              if (isDownloading) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${percent.toPersianDigit()}٪',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onCancelDownload();
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Text(
                          'لغو',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (translation.isDownloaded) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isActive)
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onSetActive();
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Text(
                            'انتخاب',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    if (!translation.isDefault) ...[
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onDelete();
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Text(
                            'حذف',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ] else if (isLocked) ...[
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onDownload();
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Text(
                      'اشتراک ویژه',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onDownload();
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Text(
                      'دانلود',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Progress bar when downloading
          if (isDownloading) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 2.5,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFF0ECE6),
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
