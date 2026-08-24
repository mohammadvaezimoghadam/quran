import 'package:flutter/material.dart';

import '../../../../common/extensions/size_extension.dart';
import '../../../../core/theme/app_dimens.dart';

/// Skeleton loading placeholder for Ayah translation text.
class TranslationSkeleton extends StatelessWidget {
  const TranslationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white10 : Colors.black12;

    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.stackMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          4.vSpace,
          Container(
            height: 16,
            width: MediaQuery.sizeOf(context).width * 0.6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
