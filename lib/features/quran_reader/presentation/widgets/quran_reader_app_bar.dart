import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../core/theme/app_typography.dart';

/// Modern Apple-styled AppBar for QuranReaderScreen.
/// Preserves 100% of functional callbacks while providing an authentic iOS Reader appearance.
class QuranReaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String surahName;
  final int surahNumber;
  final bool isSelectionMode;
  final int selectedCount;
  final bool isBookmarked;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSurahTap;
  final VoidCallback? onBookmarkPressed;
  final ValueChanged<String>? onMenuSelected;
  final PopupMenuItemBuilder<String>? menuItemBuilder;

  // Selection Mode Actions
  final VoidCallback? onClearSelection;
  final VoidCallback? onCopySelected;
  final VoidCallback? onShareSelected;
  final VoidCallback? onDictionarySelected;

  const QuranReaderAppBar({
    super.key,
    required this.surahName,
    required this.surahNumber,
    this.isSelectionMode = false,
    this.selectedCount = 0,
    this.isBookmarked = false,
    this.onBackPressed,
    this.onSurahTap,
    this.onBookmarkPressed,
    this.onMenuSelected,
    this.menuItemBuilder,
    this.onClearSelection,
    this.onCopySelected,
    this.onShareSelected,
    this.onDictionarySelected,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onTap,
    required String tooltip,
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor =
        iconColor ?? (isDark ? Colors.white70 : Colors.black87);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(19),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.08),
                width: 0.8,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 19,
                color: effectiveColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      height: topPadding + kToolbarHeight,
      padding: EdgeInsets.only(
        top: topPadding,
        left: 8.0,
        right: 8.0,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16191C) : const Color(0xFFEBE7CE),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.06),
            width: 0.8,
          ),
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: isSelectionMode
            ? _buildSelectionBar(context, isDark, colorScheme)
            : _buildNormalBar(context, isDark, colorScheme),
      ),
    );
  }

  Widget _buildNormalBar(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Row(
      key: const ValueKey('reader_app_bar_normal'),
      children: [
        // 1. Back Button (Leading in RTL is on the Right)
        _buildIconButton(
          context: context,
          icon: CupertinoIcons.chevron_forward,
          onTap: onBackPressed ?? () => Navigator.of(context).maybePop(),
          tooltip: 'بازگشت',
        ),

        const SizedBox(width: 8),

        // 2. Interactive Surah Title Capsule
        Expanded(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSurahTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.28),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          surahNumber.toPersianDigit(),
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          surahName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1D1D1F),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        CupertinoIcons.chevron_down,
                        size: 11,
                        color: colorScheme.primary.withValues(alpha: 0.75),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // 3. Bookmark Button
        _buildIconButton(
          context: context,
          icon: isBookmarked
              ? CupertinoIcons.bookmark_fill
              : CupertinoIcons.bookmark,
          iconColor: isBookmarked ? colorScheme.primary : null,
          onTap: onBookmarkPressed,
          tooltip: isBookmarked ? 'حذف نشانه' : 'نشانه‌گذاری',
        ),

        const SizedBox(width: 6),

        // 4. Settings Popup Menu
        Theme(
          data: Theme.of(context).copyWith(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: PopupMenuButton<String>(
            tooltip: 'تنظیمات و گزینه‌ها',
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.08),
                width: 0.8,
              ),
            ),
            onSelected: onMenuSelected,
            itemBuilder: menuItemBuilder ?? (_) => const [],
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 0.8,
                ),
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.slider_horizontal_3,
                  size: 19,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionBar(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Row(
      key: const ValueKey('reader_app_bar_selection'),
      children: [
        // 1. Close Selection Button
        _buildIconButton(
          context: context,
          icon: CupertinoIcons.xmark,
          onTap: onClearSelection,
          tooltip: 'لغو انتخاب',
        ),

        const SizedBox(width: 8),

        // 2. Selected Count Badge
        Expanded(
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              child: Text(
                '${selectedCount.toPersianDigit()} آیه انتخاب شد',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // 3. Action Buttons (Bookmark, Dictionary, Share, Copy)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconButton(
              context: context,
              icon: CupertinoIcons.bookmark,
              onTap: onBookmarkPressed,
              tooltip: 'نشانه‌گذاری',
            ),
            const SizedBox(width: 4),
            _buildIconButton(
              context: context,
              icon: CupertinoIcons.book,
              onTap: onDictionarySelected,
              tooltip: 'لغت‌نامه',
            ),
            const SizedBox(width: 4),
            _buildIconButton(
              context: context,
              icon: CupertinoIcons.share,
              onTap: onShareSelected,
              tooltip: 'اشتراک‌گذاری',
            ),
            const SizedBox(width: 4),
            _buildIconButton(
              context: context,
              icon: CupertinoIcons.doc_on_doc,
              onTap: onCopySelected,
              tooltip: 'کپی آیات',
            ),
          ],
        ),
      ],
    );
  }
}
