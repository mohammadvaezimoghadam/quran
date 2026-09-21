import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../core/theme/app_typography.dart';
import 'surah_header_title_capsule.dart';

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
  Size get preferredSize => const Size.fromHeight(60.0);

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onTap,
    required String tooltip,
    Color? iconColor,
    double size = 22,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = iconColor ?? colorScheme.onSurface;

    return IconButton(
      tooltip: tooltip,
      icon: Icon(
        icon,
        size: size,
        color: effectiveColor,
      ),
      splashRadius: 22,
      onPressed: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final colorScheme = Theme.of(context).colorScheme;
    final colors = context.colors;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      height: topPadding + 60.0,
      padding: EdgeInsets.only(
        top: topPadding + 2.0,
        left: 8.0,
        right: 8.0,
        bottom: 2.0,
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
        // 1. Back Button (Standard Apple-style chevron across all screens)
        _buildIconButton(
          context: context,
          icon: CupertinoIcons.chevron_forward,
          size: 24,
          onTap: onBackPressed ?? () => Navigator.of(context).maybePop(),
          tooltip: 'بازگشت',
        ),

        const SizedBox(width: 8),

        // 2. Interactive Surah Title Capsule
        Expanded(
          child: Center(
            child: SurahHeaderTitleCapsule(
              surahNumber: surahNumber,
              surahName: surahName,
              onTap: onSurahTap,
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

        const SizedBox(width: 4),

        // 4. Settings Popup Menu (Standard icon button with no artificial circle wrapper)
        PopupMenuButton<String>(
          tooltip: 'تنظیمات و گزینه‌ها',
          icon: Icon(
            CupertinoIcons.slider_horizontal_3,
            size: 22,
            color: colorScheme.onSurface,
          ),
          splashRadius: 22,
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: context.colors.cardBorder,
              width: 0.8,
            ),
          ),
          onSelected: onMenuSelected,
          itemBuilder: menuItemBuilder ?? (_) => const [],
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

        // 2. Selected Count Text (Clean & simple, no green box)
        Expanded(
          child: Center(
            child: Text(
              '${selectedCount.toPersianDigit()} آیه انتخاب شد',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
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
