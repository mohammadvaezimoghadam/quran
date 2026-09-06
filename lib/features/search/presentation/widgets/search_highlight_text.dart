import 'package:flutter/material.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../../../core/theme/app_colors.dart';

/// Renders a text with highlighted search query matches.
/// Works with both plain text and Arabic/Persian diacritic-normalized texts.
class SearchHighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle baseStyle;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;

  const SearchHighlightText({
    super.key,
    required this.text,
    required this.query,
    required this.baseStyle,
    this.highlightStyle,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty || text.isEmpty) {
      return Text(
        text,
        style: baseStyle,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    final effectiveHighlightStyle = highlightStyle ??
        baseStyle.copyWith(
          color: AppColors.goldAccent,
          backgroundColor: AppColors.goldAccent.withValues(alpha: 0.15),
          fontWeight: FontWeight.bold,
        );

    // 1. Direct case-insensitive match check
    final lowerText = text.toLowerCase();
    final lowerQuery = cleanQuery.toLowerCase();

    if (lowerText.contains(lowerQuery)) {
      final spans = <TextSpan>[];
      int start = 0;
      int indexOfMatch;

      while ((indexOfMatch = lowerText.indexOf(lowerQuery, start)) != -1) {
        if (indexOfMatch > start) {
          spans.add(TextSpan(
            text: text.substring(start, indexOfMatch),
            style: baseStyle,
          ));
        }

        final matchEnd = indexOfMatch + lowerQuery.length;
        spans.add(TextSpan(
          text: text.substring(indexOfMatch, matchEnd),
          style: effectiveHighlightStyle,
        ));

        start = matchEnd;
      }

      if (start < text.length) {
        spans.add(TextSpan(
          text: text.substring(start),
          style: baseStyle,
        ));
      }

      return Text.rich(
        TextSpan(children: spans),
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    // 2. Normalized word-by-word match fallback (for Arabic text with diacritics)
    final words = text.split(' ');
    final normQuery = cleanQuery.normalizeForSearch();
    final spans = <TextSpan>[];

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final normWord = word.normalizeForSearch();

      final isMatch = normWord.isNotEmpty &&
          (normWord.contains(normQuery) || normQuery.contains(normWord));

      spans.add(TextSpan(
        text: word + (i < words.length - 1 ? ' ' : ''),
        style: isMatch ? effectiveHighlightStyle : baseStyle,
      ));
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
