import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../common/extensions/context_extension.dart';
import '../../../../../common/extensions/size_extension.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_typography.dart';

/// Modern Apple-Style Quran Search Bar Widget
/// Designed to be integrated directly as Row 2 of the Home Screen Header.
class HomeSearchBarWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const HomeSearchBarWidget({
    super.key,
    this.onTap,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final colorScheme = context.colorScheme;

    final searchBgColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFF1EEE8);
    final placeholderColor = isDark ? Colors.white38 : Colors.black38;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: searchBgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.search,
                  size: 19,
                  color: colorScheme.primary,
                ),
                8.hSpace,
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    onTap: onTap,
                    readOnly: onTap != null && controller == null,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13.5,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'جستجو در متن قرآن، نام سوره یا آیه...',
                      hintStyle: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: placeholderColor,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

