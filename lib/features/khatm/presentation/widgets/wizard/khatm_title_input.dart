import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/core/theme/app_typography.dart';

/// Text input field for Khatm title («عنوان ختم»).
/// Borderless design with soft filled background and outside label.
class KhatmTitleInput extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String? errorText;

  const KhatmTitleInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final inputBg = isDark ? const Color(0xFF242426) : const Color(0xFFEEEBE4);
    final inputBorderSide = BorderSide(
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.06),
      width: 0.8,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'عنوان ختم',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'عنوان را وارد کنید',
            errorText: errorText,
            filled: true,
            fillColor: inputBg,
            hintStyle: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: inputBorderSide,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: inputBorderSide,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.error, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          ),
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
