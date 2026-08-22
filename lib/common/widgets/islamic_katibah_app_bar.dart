import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';

/// Clean Theme-Aware Islamic Katibah AppBar with Vazirmatn typography & UI Search TextField.
class IslamicKatibahAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String surahName;
  final int? surahNumber;
  final String? fontFamily;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final ValueChanged<String>? onSearchChanged;
  final bool showSearchField;

  const IslamicKatibahAppBar({
    super.key,
    required this.surahName,
    this.surahNumber,
    this.fontFamily,
    this.onBackPressed,
    this.actions,
    this.onSearchChanged,
    this.showSearchField = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(showSearchField ? 130.0 : 76.0);

  @override
  State<IslamicKatibahAppBar> createState() => _IslamicKatibahAppBarState();
}

class _IslamicKatibahAppBarState extends State<IslamicKatibahAppBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    // Dynamic App Theme Colors (Deep Emerald & Gold)
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF062320), Color(0xFF0B3834)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [AppColors.primary, Color(0xFF09726A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    const softGoldText = Color(0xFFF4E0A5);

    return Container(
      height: widget.preferredSize.height + topPadding,
      padding: EdgeInsets.only(top: topPadding),
      decoration: BoxDecoration(
        gradient: bgGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRect(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Islamic Arabesque Background Pattern (پترن اسلیمی)
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.12 : 0.16,
                child: Image.asset(
                  AppConstants.ayahCardBgAsset,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Column for Main Title Row + Prominent UI Search Bar
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Back button, Surah Title, Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      // Back Button (If pop available)
                      if (Navigator.of(context).canPop())
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.chevron_forward,
                            size: 20,
                            color: softGoldText,
                          ),
                          tooltip: 'بازگشت',
                          onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
                        )
                      else
                        const SizedBox(width: 40),

                      // Center Surah Title with custom or default Typography
                      Expanded(
                        child: Text(
                          widget.surahName,
                          textAlign: TextAlign.center,
                          style: AppTypography.katibahTitle.copyWith(
                            fontFamily: widget.fontFamily ?? AppTypography.fontFamily,
                            shadows: const [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Right Actions Slot (if any)
                      if (widget.actions != null && widget.actions!.isNotEmpty)
                        Row(mainAxisSize: MainAxisSize.min, children: widget.actions!)
                      else
                        const SizedBox(width: 40),
                    ],
                  ),
                ),

                // Prominent Always-Visible Search Bar ("همیشه تو چشم")
                if (widget.showSearchField) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.marginPage,
                    ),
                    child: _buildSearchTextField(softGoldText),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a prominent, perfectly aligned UI Search TextField
  Widget _buildSearchTextField(Color textGold) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        border: Border.all(
          color: textGold.withValues(alpha: 0.45),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: _searchController,
          onChanged: (text) {
            widget.onSearchChanged?.call(text);
            setState(() {});
          },
          textAlignVertical: TextAlignVertical.center,
          style: AppTypography.searchInput,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            isDense: true,
            hintText: AppConstants.searchHintText,
            hintStyle: AppTypography.searchHint,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                CupertinoIcons.search,
                color: textGold.withValues(alpha: 0.85),
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    icon: const Icon(
                      CupertinoIcons.xmark_circle_fill,
                      size: 18,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      widget.onSearchChanged?.call('');
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 8,
            ),
          ),
        ),
      ),
    );
  }
}
