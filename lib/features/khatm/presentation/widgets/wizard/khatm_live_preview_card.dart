import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/string_extension.dart';
import 'package:quran/core/theme/app_typography.dart';

/// Preview card showing computed session quota («تعداد حزب در هر جلسه = X»).
/// Styled with a soft gradient surface, refined typography, and zero borders.
class KhatmLivePreviewCard extends StatelessWidget {
  final String previewText;

  const KhatmLivePreviewCard({
    super.key,
    required this.previewText,
  });

  @override
  Widget build(BuildContext context) {
    if (previewText.trim().isEmpty) return const SizedBox.shrink();

    final colorScheme = context.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.12),
            colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'برآورد برنامه ختم',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            previewText.toPersianDigit(),
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
