import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/reciter/reciter_avatar_button.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';

/// Clean Apple-Style Navigation Header & Search Bar for Surah List Screen.
/// Designed for zero unnecessary rebuilds and high aesthetic clarity.
class SurahListAppleHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAudioDownloadManagerTap;
  final VoidCallback onSortTap;
  final VoidCallback onToggleFavoritesTap;
  final bool isOnlyFavorites;
  final VoidCallback? onBackPressed;

  const SurahListAppleHeader({
    super.key,
    required this.title,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchChanged,
    required this.onAudioDownloadManagerTap,
    required this.onSortTap,
    required this.onToggleFavoritesTap,
    required this.isOnlyFavorites,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(114.0);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final topPadding = MediaQuery.of(context).padding.top;

    final searchBgColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFF1EEE8);

    final placeholderColor = isDark ? Colors.white38 : Colors.black38;

    return Container(
      height: preferredSize.height + topPadding,
      padding: EdgeInsets.only(
        top: topPadding + 4.0,
        left: 16.0,
        right: 8.0,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Back Button + Title + Action Icons
          SizedBox(
            height: 42,
            child: Row(
              children: [
                // Back Button (Apple-style chevron)
                IconButton(
                  tooltip: 'بازگشت',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    CupertinoIcons.chevron_forward,
                    size: 22,
                    color: colorScheme.onSurface,
                  ),
                  splashRadius: 20,
                  onPressed: onBackPressed ??
                      () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                ),

                2.hSpace,

                // Title (Persian, bold, IRANSans)
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),

                // Reciter Selection Avatar
                const ReciterAvatarButton(
                  radius: 17,
                  showLabel: false,
                ),

                2.hSpace,

                // Download Manager Action
                IconButton(
                  tooltip: 'مدیریت دانلود صوت',
                  icon: Icon(
                    CupertinoIcons.arrow_down_to_line,
                    size: 20,
                    color: colorScheme.onSurface,
                  ),
                  splashRadius: 20,
                  onPressed: onAudioDownloadManagerTap,
                ),

                // Sort & Favorites Menu (iOS Style Ellipsis)
                PopupMenuButton<String>(
                  tooltip: 'گزینه‌ها',
                  icon: Icon(
                    CupertinoIcons.ellipsis_circle,
                    size: 21,
                    color: colorScheme.onSurface,
                  ),
                  splashRadius: 20,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  ),
                  onSelected: (value) {
                    if (value == 'sort') {
                      onSortTap();
                    } else if (value == 'favorites') {
                      onToggleFavoritesTap();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'sort',
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.sort_down,
                            size: 19,
                            color: colors.goldAccent,
                          ),
                          10.hSpace,
                          const Text(
                            'مرتب‌سازی',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'favorites',
                      child: Row(
                        children: [
                          Icon(
                            isOnlyFavorites
                                ? CupertinoIcons.list_bullet
                                : CupertinoIcons.star_fill,
                            size: 19,
                            color: colors.goldAccent,
                          ),
                          10.hSpace,
                          Text(
                            isOnlyFavorites ? 'نمایش همه سوره‌ها' : 'فهرست شخصی',
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          6.vSpace,

          // Row 2: Apple-style Pill Search Box
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: searchBgColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
            ),
            child: Row(
              children: [
                10.hSpace,
                Icon(
                  CupertinoIcons.search,
                  size: 18,
                  color: placeholderColor,
                ),
                8.hSpace,
                Expanded(
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    onChanged: onSearchChanged,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13.5,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'جستجو در نام یا شماره سوره...',
                      hintStyle: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13.0,
                        color: placeholderColor,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                // Clear Button (isolated with ListenableBuilder to avoid rebuilding parent)
                ListenableBuilder(
                  listenable: searchController,
                  builder: (context, _) {
                    if (searchController.text.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return GestureDetector(
                      onTap: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Icon(
                          CupertinoIcons.clear_circled_solid,
                          size: 17,
                          color: placeholderColor,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
