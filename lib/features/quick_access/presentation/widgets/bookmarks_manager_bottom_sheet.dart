import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../bookmarks/application/controllers/bookmarks_controller.dart';
import '../../../bookmarks/domain/entities/bookmark_item.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';

/// Luxury bottom sheet for managing saved bookmarks with tabs for All Bookmarks and Saved Ayahs.
class BookmarksManagerBottomSheet extends ConsumerStatefulWidget {
  const BookmarksManagerBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BookmarksManagerBottomSheet(),
    );
  }

  @override
  ConsumerState<BookmarksManagerBottomSheet> createState() =>
      _BookmarksManagerBottomSheetState();
}

class _BookmarksManagerBottomSheetState
    extends ConsumerState<BookmarksManagerBottomSheet> {
  int _selectedTabIndex = 0; // 0: All, 1: Ayahs

  void _navigateToAyah(BookmarkItem item) {
    Navigator.of(context).pop();
    ref.read(quranDisplaySettingsControllerProvider.notifier).toggleArabicText(true);

    Future.microtask(() {
      if (mounted) {
        context.pushNamed(
          quranReaderRoute,
          pathParameters: {'id': item.surahId.toString()},
          queryParameters: {
            'name': item.surahName,
            'ayah': item.ayahNumber.toString(),
          },
        );
      }
    });
  }

  Future<void> _confirmClearAll() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E2825) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'حذف همه نشانه‌ها',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید تمام نشانه‌های ذخیره‌شده را حذف کنید؟',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(
              'انصراف',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text(
              'حذف همه',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(bookmarksControllerProvider.notifier).clearAll();
      HapticFeedback.mediumImpact();
      if (mounted) {
        AppSnackBar.showInfo(context, 'تمام نشانه‌ها پاک شدند.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookmarks = ref.watch(bookmarksControllerProvider);
    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final arabicFontFamily = AppTypography.getFontFamilyByScript(fontScript);

    // Separate page/reading bookmarks from individual ayah bookmarks
    final readingBookmarks = bookmarks.where((b) => !b.isAyahBookmark).toList();
    final ayahBookmarks = bookmarks.where((b) => b.isAyahBookmark).toList();

    final currentDisplayList = _selectedTabIndex == 0 ? readingBookmarks : ayahBookmarks;

    final sheetBg = isDark ? const Color(0xFF151D1B) : const Color(0xFFF9F8F6);
    final cardBg = isDark ? const Color(0xFF1E2825) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE8E5DF);
    final primaryColor = isDark ? const Color(0xFF52C498) : AppColors.primary;
    final goldColor = isDark ? const Color(0xFFF4E0A5) : const Color(0xFF947124);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Drag Handle
            10.vSpace,
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            12.vSpace,

            // 2. Luxury Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  // Bookmarks Icon Container
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      CupertinoIcons.bookmark_fill,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  12.hSpace,

                  // Title & Count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'نشانه‌های ذخیره‌شده',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        2.vSpace,
                        Text(
                          bookmarks.isEmpty
                              ? 'هیچ نشانه‌ای ذخیره نشده'
                              : '${bookmarks.length.toPersianDigit()} نشانه در دسترس',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Clear All Button (Visible if has bookmarks)
                  if (bookmarks.isNotEmpty)
                    IconButton(
                      tooltip: 'حذف همه',
                      icon: const Icon(
                        CupertinoIcons.trash,
                        size: 20,
                        color: Colors.redAccent,
                      ),
                      onPressed: _confirmClearAll,
                    ),

                  // Close Button
                  IconButton(
                    tooltip: 'بستن',
                    icon: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      size: 24,
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            12.vSpace,

            // 3. Segmented Tab Bar for Switching between "Page Bookmarks" and "Saved Ayahs"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: 40,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFEFECE6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        title: 'نشانک صفحه (${readingBookmarks.length.toPersianDigit()})',
                        isSelected: _selectedTabIndex == 0,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        onTap: () => setState(() => _selectedTabIndex = 0),
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        title: 'آیات نشان‌شده (${ayahBookmarks.length.toPersianDigit()})',
                        isSelected: _selectedTabIndex == 1,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        onTap: () => setState(() => _selectedTabIndex = 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            12.vSpace,
            Divider(
              height: 1,
              thickness: 1,
              color: borderColor,
            ),

            // 4. Content: Empty State OR List of Bookmarks
            Flexible(
              child: currentDisplayList.isEmpty
                  ? _buildEmptyState(
                      context,
                      isDark,
                      primaryColor,
                      isAyahTab: _selectedTabIndex == 1,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                      itemCount: currentDisplayList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = currentDisplayList[index];
                        final isLatest = _selectedTabIndex == 0 && index == 0;

                        return _buildBookmarkCard(
                          item: item,
                          index: index,
                          isLatest: isLatest,
                          isDark: isDark,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          primaryColor: primaryColor,
                          goldColor: goldColor,
                          arabicFontFamily: arabicFontFamily,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required bool isDark,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF24302C) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? (isDark ? primaryColor : const Color(0xFF1E2421))
                  : (isDark ? Colors.white54 : Colors.black45),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    Color primaryColor, {
    bool isAyahTab = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              isAyahTab ? CupertinoIcons.bookmark : CupertinoIcons.bookmark,
              size: 36,
              color: primaryColor.withValues(alpha: 0.8),
            ),
          ),
          16.vSpace,
          Text(
            isAyahTab
                ? 'هنوز هیچ آیه‌ای نشانه‌گذاری نشده است'
                : 'هنوز هیچ نشانه‌ای ثبت نشده است',
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          8.vSpace,
          Text(
            isAyahTab
                ? 'در صفحه قرائت قرآن با نگه‌داشتن انگشت روی هر آیه و انتخاب گزینه «نشانه‌گذاری»، می‌توانید آیات منتخب را در این تب ذخیره کنید.'
                : 'هنگام قرائت قرآن با لمس آیکون نشانه در هدر بالای صفحه، می‌توانید محل مطالعه و صفحه را برای ادامه خواندن ذخیره نمایید.',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black54,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          24.vSpace,
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              context.pushNamed(surahListRoute);
            },
            icon: const Icon(CupertinoIcons.book, size: 18),
            label: const Text(
              'مشاهده فهرست سوره‌ها',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkCard({
    required BookmarkItem item,
    required int index,
    required bool isLatest,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color primaryColor,
    required Color goldColor,
    required String arabicFontFamily,
  }) {
    final cleanSurahName = item.surahName
        .replaceFirst(RegExp(r'^(سورة|سوره)\s+'), '')
        .trim();

    final hasArabicSnippet = item.arabicText != null && item.arabicText!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToAyah(item),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isLatest
                  ? primaryColor.withValues(alpha: 0.4)
                  : borderColor,
              width: isLatest ? 1.4 : 1.0,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Index & Badge Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isLatest
                        ? primaryColor.withValues(alpha: isDark ? 0.25 : 0.12)
                        : (isDark ? Colors.white10 : const Color(0xFFF3F0EB)),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isLatest
                          ? primaryColor.withValues(alpha: 0.5)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (index + 1).toPersianDigit(),
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isLatest ? primaryColor : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ),
                12.hSpace,

                // 2. Surah & Ayah Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              cleanSurahName,
                              style: TextStyle(
                                fontFamily: arabicFontFamily,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: goldColor,
                                height: 1.1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isLatest) ...[
                            8.hSpace,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'آخرین نشانک',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ] else if (item.isAyahBookmark) ...[
                            8.hSpace,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: goldColor.withValues(alpha: isDark ? 0.2 : 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'آیه نشان‌شده',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: goldColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      4.vSpace,
                      Text(
                        item.totalAyahs > 0
                            ? 'آیه ${item.ayahNumber.toPersianDigit()} از ${item.totalAyahs.toPersianDigit()}'
                            : 'آیه ${item.ayahNumber.toPersianDigit()}',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),

                      // Optional Arabic Text Preview for Ayah Bookmarks
                      if (hasArabicSnippet) ...[
                        6.vSpace,
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            item.arabicText!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: arabicFontFamily,
                              fontSize: 14,
                              height: 1.6,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.75)
                                  : const Color(0xFF2C322E),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 3. Delete Bookmark Button
                IconButton(
                  tooltip: 'حذف این نشانک',
                  icon: Icon(
                    CupertinoIcons.delete,
                    size: 18,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    await ref
                        .read(bookmarksControllerProvider.notifier)
                        .removeBookmark(item.surahId, item.ayahNumber);
                    if (mounted) {
                      AppSnackBar.showInfo(
                        context,
                        'نشانک سوره $cleanSurahName حذف شد.',
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
