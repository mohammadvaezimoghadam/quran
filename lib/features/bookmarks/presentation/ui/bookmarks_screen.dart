import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_modal_header.dart';
import '../../../../common/widgets/app_segmented_tab_bar.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/bookmarks_controller.dart';
import '../../domain/entities/bookmark_item.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';

/// Full-screen Apple-styled Bookmarks screen designed for the Main Navigation Shell.
class BookmarksScreen extends ConsumerStatefulWidget {
  final bool showBackButton;
  final VoidCallback? onExploreSurahs;

  const BookmarksScreen({
    super.key,
    this.showBackButton = false,
    this.onExploreSurahs,
  });

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  int _selectedTabIndex = 0; // 0: All, 1: Ayahs only
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAyah(BookmarkItem item) {
    ref.read(quranDisplaySettingsControllerProvider.notifier).toggleArabicText(true);

    context.pushNamed(
      quranReaderRoute,
      pathParameters: {'id': item.surahId.toString()},
      queryParameters: {
        'name': item.surahName,
        'ayah': item.ayahNumber.toString(),
      },
    );
  }

  Future<void> _confirmClearAll() async {
    final colors = context.colors;
    final isDark = context.isDark;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: colors.dialogSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppModalHeader(
                title: 'حذف همه نشانه‌ها',
                onClose: () => Navigator.of(dialogCtx).pop(false),
                bottomSpacing: 12,
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: isDark ? 0.20 : 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  CupertinoIcons.trash,
                  size: 24,
                  color: Colors.redAccent,
                ),
              ),
              12.vSpace,
              Text(
                'آیا مطمئن هستید که می‌خواهید تمام نشانه‌های ذخیره‌شده را حذف کنید؟ این عمل غیرقابل بازگشت است.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13.5,
                  height: 1.5,
                  color: textSecondary,
                ),
              ),
              20.vSpace,
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(false),
                      child: Text(
                        'انصراف',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ),
                  12.hSpace,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        'حذف همه',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await ref.read(bookmarksControllerProvider.notifier).clearAll();
    }
  }

  String _formatTimeAgo(int timestamp) {
    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'همین الان';
    if (diff.inHours < 1) return '${diff.inMinutes.toPersianDigit()} دقیقه پیش';
    if (diff.inDays < 1) return '${diff.inHours.toPersianDigit()} ساعت پیش';
    if (diff.inDays == 1) return 'دیروز';
    if (diff.inDays < 7) return '${diff.inDays.toPersianDigit()} روز پیش';
    if (diff.inDays < 30) return '${(diff.inDays ~/ 7).toPersianDigit()} هفته پیش';
    return '${date.year.toPersianDigit()}/${date.month.toPersianDigit()}/${date.day.toPersianDigit()}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;
    final allBookmarks = ref.watch(bookmarksControllerProvider);

    final tabFiltered = _selectedTabIndex == 0
        ? allBookmarks
        : allBookmarks.where((b) => b.isAyahBookmark).toList();

    final filtered = _searchQuery.trim().isEmpty
        ? tabFiltered
        : tabFiltered.where((b) {
            final query = _searchQuery.trim();
            final matchesSurah = b.surahName.contains(query);
            final matchesAyah = b.ayahNumber.toString().contains(query);
            final matchesArabic = b.arabicText?.contains(query) ?? false;
            return matchesSurah || matchesAyah || matchesArabic;
          }).toList();

    final topPadding = MediaQuery.paddingOf(context).top;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            padding: EdgeInsets.only(
              top: topPadding + 4.0,
              left: 12.0,
              right: 6.0,
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
            child: Row(
              children: [
                if (widget.showBackButton)
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
                      }
                    },
                  )
                else
                  const SizedBox(width: 48),

                Expanded(
                  child: Text(
                    'نشانه‌ها و برگزیده‌ها',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),

                if (allBookmarks.isNotEmpty)
                  IconButton(
                    tooltip: 'حذف همه نشانه‌ها',
                    icon: Icon(
                      CupertinoIcons.trash,
                      size: 20,
                      color: textSecondary,
                    ),
                    splashRadius: 22,
                    onPressed: _confirmClearAll,
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            12.vSpace,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.marginPage),
              child: AppSegmentedTabBar(
                items: const [
                  AppSegmentedTabItem(title: 'همه نشانه‌ها'),
                  AppSegmentedTabItem(title: 'نشانه‌های آیه'),
                ],
                selectedIndex: _selectedTabIndex,
                onTabSelected: (index) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedTabIndex = index);
                },
              ),
            ),

            if (allBookmarks.length > 5) ...[
              10.vSpace,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.marginPage),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.cardBorder,
                      width: 0.8,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'جستجو در نشانه‌ها...',
                      hintStyle: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12.5,
                        color: textSecondary.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(
                        CupertinoIcons.search,
                        size: 16,
                        color: textSecondary,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(CupertinoIcons.clear_circled_solid, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
            ],

            12.vSpace,

            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState(context, isDark, allBookmarks.isEmpty, textSecondary)
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        left: AppDimens.marginPage,
                        right: AppDimens.marginPage,
                        bottom: 90,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => 8.vSpace,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _buildBookmarkCard(context, item, isDark, textSecondary);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarkCard(
    BuildContext context,
    BookmarkItem item,
    bool isDark,
    Color textSecondary,
  ) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.cardBorder,
          width: 0.8,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _navigateToAyah(item),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      item.isAyahBookmark
                          ? CupertinoIcons.bookmark_fill
                          : CupertinoIcons.book,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                12.hSpace,

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.surahName,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          8.hSpace,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'آیه ${item.ayahNumber.toPersianDigit()}',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (item.arabicText != null && item.arabicText!.isNotEmpty) ...[
                        4.vSpace,
                        Text(
                          item.arabicText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'UthmanicHafs',
                            fontSize: 14,
                            color: textSecondary,
                          ),
                        ),
                      ],
                      4.vSpace,
                      Text(
                        _formatTimeAgo(item.createdAt),
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          color: textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  tooltip: 'حذف نشانک',
                  icon: Icon(
                    CupertinoIcons.trash,
                    size: 18,
                    color: Colors.redAccent.withValues(alpha: 0.75),
                  ),
                  splashRadius: 20,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.read(bookmarksControllerProvider.notifier).removeBookmark(
                          item.surahId,
                          item.ayahNumber,
                        );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    bool isCompletelyEmpty,
    Color textSecondary,
  ) {
    final colorScheme = context.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: isDark ? 0.12 : 0.08),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.20),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.bookmark,
                  size: 38,
                  color: colorScheme.primary,
                ),
              ),
            ),
            16.vSpace,
            Text(
              isCompletelyEmpty
                  ? 'هنوز نشانه‌ای ثبت نشده است'
                  : 'موردی با این عبارت یافت نشد',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            8.vSpace,
            Text(
              isCompletelyEmpty
                  ? 'هنگام تلاوت قرآن، می‌توانید با لمس آیکون نشانه‌گذاری در بالای صفحه، آیه یا سوره مورد نظر خود را ذخیره کنید.'
                  : 'لطفاً عبارت دیگری را جستجو کنید.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                height: 1.5,
                color: textSecondary,
              ),
            ),
            if (isCompletelyEmpty && widget.onExploreSurahs != null) ...[
              20.vSpace,
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onExploreSurahs!();
                },
                icon: const Icon(CupertinoIcons.book, size: 18),
                label: const Text('مشاهده فهرست سوره‌ها'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
