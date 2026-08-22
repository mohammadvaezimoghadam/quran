import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_constants.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/presentation/theme_controller.dart';

/// Reusable Theme Toggle Button Widget for AppBars and Headers.
class AppThemeToggleButton extends ConsumerWidget {
  final double iconSize;
  final Color? color;

  const AppThemeToggleButton({
    super.key,
    this.iconSize = AppDimens.iconMd,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      onPressed: () {
        final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
        ref.read(themeControllerProvider.notifier).toggleTheme(newMode);
      },
      tooltip: isDark ? AppConstants.lightThemeTooltip : AppConstants.darkThemeTooltip,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: SvgPicture.asset(
          isDark ? 'assets/icons/ic_sun.svg' : 'assets/icons/ic_crescent_moon.svg',
          key: ValueKey<bool>(isDark),
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(
            color ?? (isDark ? const Color(0xFFC5A059) : const Color(0xFF005C55)),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
