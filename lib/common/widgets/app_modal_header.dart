import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';

/// Standard Apple-grade header component for all Bottom Sheets and Dialogs.
/// Guarantees:
/// 1. Exactly centered title with balanced spacers on both edges.
/// 2. Uniform Cupertino xmark_circle_fill close button on the left (in RTL).
/// 3. Optional top drag handle for bottom sheets.
/// 4. Optional custom title widget or leading action button.
class AppModalHeader extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final VoidCallback? onClose;
  final Widget? leadingAction;
  final bool showDragHandle;
  final double bottomSpacing;
  final bool showDivider;
  final Color? dividerColor;

  const AppModalHeader({
    super.key,
    this.title,
    this.titleWidget,
    this.onClose,
    this.leadingAction,
    this.showDragHandle = false,
    this.bottomSpacing = 12.0,
    this.showDivider = false,
    this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    const actionSize = 44.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDragHandle) ...[
          Center(
            child: Container(
              width: 38,
              height: 4.5,
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
          child: Row(
            children: [
              // 1. Right side (in RTL): Leading action or balanced spacer for 100% centering
              SizedBox(
                width: actionSize,
                height: actionSize,
                child: leadingAction != null
                    ? Center(child: leadingAction)
                    : null,
              ),

              // 2. Center: Title
              Expanded(
                child: titleWidget ??
                    Text(
                      title ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
              ),

              // 3. Left side (in RTL): Uniform close button (ضربدر)
              SizedBox(
                width: actionSize,
                height: actionSize,
                child: IconButton(
                  tooltip: 'بستن',
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 24,
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) ...[
          const SizedBox(height: 4),
          Divider(
            height: 1,
            thickness: 0.8,
            color: dividerColor ??
                (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06)),
          ),
        ],
        SizedBox(height: bottomSpacing),
      ],
    );
  }
}
