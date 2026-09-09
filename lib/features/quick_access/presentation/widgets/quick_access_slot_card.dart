import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/string_extension.dart';
import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/quick_access_tool_entity.dart';

class QuickAccessSlotCard extends ConsumerStatefulWidget {
  final QuickAccessToolEntity? tool;
  final String? subtitle;
  final bool isEditMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;

  const QuickAccessSlotCard({
    super.key,
    required this.tool,
    this.subtitle,
    required this.isEditMode,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  @override
  ConsumerState<QuickAccessSlotCard> createState() =>
      _QuickAccessSlotCardState();
}

class _QuickAccessSlotCardState extends ConsumerState<QuickAccessSlotCard>
    with TickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  late final AnimationController _badgeController;
  late final Animation<double> _badgeScale;

  @override
  void initState() {
    super.initState();

    // 1. Gentle initial wiggle/shake animation on entering edit mode
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -0.005)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.005, end: 0.005)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.005, end: -0.0035)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.0035, end: 0.002)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.002, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 1,
      ),
    ]).animate(_shakeController);

    // 2. Smooth scale animation for the delete 'X' badge
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.isEditMode ? 1.0 : 0.0,
    );

    _badgeScale = CurvedAnimation(
      parent: _badgeController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );

    if (widget.isEditMode) {
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(QuickAccessSlotCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isEditMode && !oldWidget.isEditMode) {
      // Trigger subtle shake and scale in the badge
      _shakeController.forward(from: 0.0);
      _badgeController.forward();
    } else if (!widget.isEditMode && oldWidget.isEditMode) {
      _badgeController.reverse();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isEmpty = widget.tool == null;

    final cardBgColor = isDark
        ? (isEmpty ? Colors.white.withValues(alpha: 0.025) : const Color(0xFF192220))
        : (isEmpty ? const Color(0xFFFBF9F5) : Colors.white);

    final cardBorderColor = isDark
        ? (isEmpty
            ? Colors.white.withValues(alpha: 0.06)
            : (widget.isEditMode
                ? AppColors.goldAccent.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.08)))
        : (isEmpty
            ? const Color(0xFFEAE7DF)
            : (widget.isEditMode
                ? AppColors.goldAccent.withValues(alpha: 0.45)
                : const Color(0xFFEBE7E1)));

    return RotationTransition(
      turns: _shakeAnimation,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Base Slot Card Container
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 84,
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: cardBorderColor,
                width: 1.0,
              ),
              boxShadow: (!isDark && !isEmpty)
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10.0,
                        offset: const Offset(0, 2.0),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16.0),
              child: InkWell(
                onTap: widget.isEditMode ? null : widget.onTap,
                onLongPress: widget.onLongPress,
                borderRadius: BorderRadius.circular(16.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isEmpty) ...[
                          Icon(
                            CupertinoIcons.plus,
                            color: isDark
                                ? Colors.white38
                                : const Color(0xFF9E998F),
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'افزودن',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white38
                                  : const Color(0xFF9E998F),
                            ),
                          ),
                        ] else if (widget.tool!.isSurah) ...[
                          // Clean Surah-Only Card: NO ICON, beautiful Surah typography
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.goldAccent.withValues(alpha: 0.14)
                                  : AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              'سوره ${widget.tool!.surahId.toString().toPersianDigit()}',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.goldAccent
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.tool!.surahId != null
                                    ? widget.tool!.surahId!.surahNameFa
                                    : (widget.tool!.surahName ?? widget.tool!.title)
                                        .replaceAll('سورة', '')
                                        .replaceAll('سوره', '')
                                        .trim(),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF2C2A29),
                                ),
                              ),
                            ),
                          ),
                          if (widget.tool!.ayahCount != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${widget.tool!.ayahCount.toString().toPersianDigit()} آیه',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9.5,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                          ],
                        ] else ...[
                          Icon(
                            widget.tool!.iconData ?? CupertinoIcons.star_fill,
                            color: isDark
                                ? AppColors.goldAccent
                                : AppColors.primary,
                            size: widget.subtitle != null ? 22 : 26,
                          ),
                          SizedBox(height: widget.subtitle != null ? 3 : 8),
                          if (widget.subtitle != null) ...[
                            Text(
                              widget.tool!.title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.white54
                                    : const Color(0xFF6E685F),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle!,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.goldAccent
                                    : AppColors.primary,
                              ),
                            ),
                          ] else ...[
                            Text(
                              widget.tool!.title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : const Color(0xFF2C2A29),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Clean Overlaid Delete Badge (×) Placed Directly On The Card Corner
          if (!isEmpty)
            Positioned(
              top: 6,
              right: 6,
              child: ScaleTransition(
                scale: _badgeScale,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
