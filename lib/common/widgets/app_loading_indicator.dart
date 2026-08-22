import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

/// Reusable Standard Circular Loading Indicator Widget for the entire app.
/// Uses AppDimens.iconMd as the default size token.
class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const AppLoadingIndicator({
    super.key,
    this.size = AppDimens.iconMd,
    this.color = AppColors.secondaryContainer,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}
