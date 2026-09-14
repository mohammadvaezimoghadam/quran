import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../common/extensions/context_extension.dart';
import '../../../../../common/extensions/size_extension.dart';
import '../../../../../core/theme/app_dimens.dart';

/// Modern Minimalist Quran Search Bar Widget
/// Placed at the top of the Quran Home screen.
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
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        border: Border.all(
          color: colors.cardBorder,
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10.0,
                  offset: const Offset(0, 2.0),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              children: [
                // Search Icon
                Icon(
                  CupertinoIcons.search,
                  size: 20,
                  color: isDark ? colors.goldAccent : colorScheme.primary,
                ),
                12.hSpace,

                // Search Input Field or Placeholder
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    onTap: onTap,
                    readOnly: onTap != null && controller == null,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'جستجو در متن قرآن، سوره یا آیه...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
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
