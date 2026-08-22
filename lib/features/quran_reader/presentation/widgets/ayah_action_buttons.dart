import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';

/// Context action buttons displayed when an Ayah is focused (Play, Copy, Bookmark, Share).
/// Features a smooth slide animation emerging from behind the primary Play button.
class AyahActionButtons extends StatefulWidget {
  final VoidCallback? onPlayTap;
  final VoidCallback? onCopyTap;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onShareTap;
  final bool isPlaying;
  final bool isBookmarked;
  final bool isVisible;

  const AyahActionButtons({
    super.key,
    this.onPlayTap,
    this.onCopyTap,
    this.onBookmarkTap,
    this.onShareTap,
    this.isPlaying = false,
    this.isBookmarked = false,
    this.isVisible = true,
  });

  @override
  State<AyahActionButtons> createState() => _AyahActionButtonsState();
}

class _AyahActionButtonsState extends State<AyahActionButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    if (widget.isVisible) {
      _animController.forward();
    }
  }

  @override
  void didUpdateWidget(AyahActionButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const double buttonSize = 36.0;
    const double buttonSpacing = 8.0;
    const double step = buttonSize + buttonSpacing;

    final List<_ActionItem> secondaryItems = [];
    if (widget.onCopyTap != null) {
      secondaryItems.add(_ActionItem(
        icon: Icons.copy_rounded,
        onTap: widget.onCopyTap,
        tooltip: 'کپی آیه',
      ));
    }
    if (widget.onBookmarkTap != null) {
      secondaryItems.add(_ActionItem(
        icon: widget.isBookmarked
            ? Icons.bookmark_rounded
            : Icons.bookmark_add_outlined,
        onTap: widget.onBookmarkTap,
        tooltip: 'نشانک',
      ));
    }
    if (widget.onShareTap != null) {
      secondaryItems.add(_ActionItem(
        icon: Icons.share_outlined,
        onTap: widget.onShareTap,
        tooltip: 'اشتراک‌گذاری',
      ));
    }

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final animVal = _expandAnimation.value;
        if (!_animController.isAnimating && animVal == 0.0 && !widget.isVisible) {
          return const SizedBox.shrink();
        }

        final double totalWidth =
            buttonSize + (secondaryItems.length * step * animVal.clamp(0.0, 1.0));

        return SizedBox(
          width: totalWidth,
          height: buttonSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerRight,
            children: [
              // Secondary Action Buttons: Slide out smoothly to the left from behind Play button
              for (int i = 0; i < secondaryItems.length; i++) ...[
                Positioned(
                  right: (i + 1) * step * animVal,
                  child: Opacity(
                    opacity: animVal.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: (0.5 + 0.5 * animVal).clamp(0.0, 1.0),
                      child: _buildActionButton(
                        context: context,
                        icon: secondaryItems[i].icon,
                        onTap: secondaryItems[i].onTap,
                        colorScheme: colorScheme,
                        tooltip: secondaryItems[i].tooltip,
                        buttonSize: buttonSize,
                        isPrimary: false,
                      ),
                    ),
                  ),
                ),
              ],

              // Primary Action Button (Play): Fixed at front on far right
              Positioned(
                right: 0,
                child: _buildActionButton(
                  context: context,
                  icon: widget.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  onTap: widget.onPlayTap,
                  colorScheme: colorScheme,
                  tooltip: 'پخش آیه',
                  buttonSize: buttonSize,
                  isPrimary: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onTap,
    required ColorScheme colorScheme,
    required String tooltip,
    required double buttonSize,
    bool isPrimary = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isPrimary ? colorScheme.primary : colorScheme.surfaceContainerHigh,
        shape: const CircleBorder(),
        elevation: isPrimary ? 3 : 1,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: Icon(
              icon,
              size: AppDimens.iconSm,
              color: isPrimary ? Colors.white : colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  const _ActionItem({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });
}
