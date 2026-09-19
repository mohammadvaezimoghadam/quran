import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/reciter/reciter_avatar_button.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';

/// Clean Apple-Style Navigation Header & Search Bar for Surah List Screen.
/// Fully styled to match the unified icon system across all app headers.
class SurahListAppleHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAudioDownloadManagerTap;
  final VoidCallback onSortTap;
  final VoidCallback onToggleFavoritesTap;
  final bool isOnlyFavorites;
  final VoidCallback? onBackPressed;
  final bool showBackButton;

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
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(126.0);

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
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
    );
  }

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Back Button + Title + Standard Apple-styled Action Icons
          SizedBox(
            height: 50,
            child: Row(
              children: [
                // Back Button (Apple-style chevron, conditional)
                if (showBackButton)
                  _buildIconButton(
                    context: context,
                    icon: CupertinoIcons.chevron_forward,
                    size: 24,
                    tooltip: 'بازگشت',
                    onTap: onBackPressed ??
                        () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                  )
                else
                  8.hSpace,

                2.hSpace,

                // Title (Persian, bold, IRANSans)
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 19,
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

                // Download Manager Action (Unified icon button)
                _buildIconButton(
                  context: context,
                  icon: CupertinoIcons.arrow_down_to_line,
                  size: 22,
                  tooltip: 'مدیریت دانلود صوت',
                  onTap: onAudioDownloadManagerTap,
                ),

                2.hSpace,

                // Sort & Favorites Menu (Unified Apple-style PopupMenuButton)
                PopupMenuButton<String>(
                  tooltip: 'گزینه‌ها',
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
                      color: colors.cardBorder,
                      width: 0.8,
                    ),
                  ),
                  onSelected: (value) {
                    HapticFeedback.lightImpact();
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
                            color: colorScheme.primary,
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
                            color: colorScheme.primary,
                          ),
                          10.hSpace,
                          Text(
                            isOnlyFavorites
                                ? 'نمایش همه سوره‌ها'
                                : 'فهرست شخصی',
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

          8.vSpace,

          // Row 2: Apple-style Pill Search Box (Unified search icon with primary green)
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: searchBgColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
            ),
            child: Row(
              children: [
                12.hSpace,
                Icon(
                  CupertinoIcons.search,
                  size: 19,
                  color: colorScheme.primary,
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

                // Clear Button
                ListenableBuilder(
                  listenable: searchController,
                  builder: (context, _) {
                    if (searchController.text.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
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
