import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Lightweight, zero-dependency Markdown Viewer tailored for Persian Quranic AI responses.
/// Elegantly formats headers (###), bold text (**bold**), bullet points (* or -),
/// blockquotes (>), and dividers (---).
class QuranMarkdownView extends StatelessWidget {
  final String text;
  final bool isDark;
  final TextStyle? baseStyle;

  const QuranMarkdownView({
    super.key,
    required this.text,
    required this.isDark,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    final defaultBaseStyle = baseStyle ??
        TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 13.5,
          height: 1.75,
          color: isDark
              ? Colors.white.withValues(alpha: 0.9)
              : const Color(0xFF24221F),
        );

    final goldColor =
        isDark ? AppColors.goldAccent : const Color(0xFFB5872A);

    for (int i = 0; i < lines.length; i++) {
      final rawLine = lines[i].trim();

      if (rawLine.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // 1. Horizontal Divider: ---
      if (rawLine == '---' || rawLine == '***' || rawLine == '___') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(
              height: 1,
              thickness: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE8E3D8),
            ),
          ),
        );
        continue;
      }

      // 2. Headings: ### Header or ## Header
      if (rawLine.startsWith('### ')) {
        final headingText = rawLine.substring(4).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 3.5,
                  height: 16,
                  decoration: BoxDecoration(
                    color: goldColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _cleanFormatting(headingText),
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: goldColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      if (rawLine.startsWith('## ')) {
        final headingText = rawLine.substring(3).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Text(
              _cleanFormatting(headingText),
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        );
        continue;
      }

      // 3. Blockquote: > Quote text
      if (rawLine.startsWith('> ')) {
        final quoteContent = rawLine.substring(2).trim();
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.goldAccent.withValues(alpha: 0.07)
                  : const Color(0xFFF7F3EB),
              borderRadius: BorderRadius.circular(12),
              border: Border(
                right: BorderSide(color: goldColor, width: 3.5),
              ),
            ),
            child: _buildFormattedRichText(quoteContent, defaultBaseStyle.copyWith(
              fontStyle: FontStyle.italic,
              color: isDark ? const Color(0xFFE4D5B7) : const Color(0xFF5A4418),
            )),
          ),
        );
        continue;
      }

      // 4. Bullet Points: * or -
      if (rawLine.startsWith('* ') || rawLine.startsWith('- ')) {
        final bulletText = rawLine.substring(2).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(right: 6.0, top: 4.0, bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: goldColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildFormattedRichText(bulletText, defaultBaseStyle),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // 5. Standard Paragraph
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: _buildFormattedRichText(rawLine, defaultBaseStyle),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  /// Removes bold/italic markdown characters from headings for pure display
  String _cleanFormatting(String text) {
    return text.replaceAll('**', '').replaceAll('*', '').trim();
  }

  /// Parses **bold text** inside regular sentences into RichText TextSpans
  Widget _buildFormattedRichText(String text, TextStyle baseStyle) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      final boldContent = match.group(1) ?? '';
      spans.add(
        TextSpan(
          text: boldContent,
          style: baseStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: baseStyle,
        ),
      );
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.justify,
    );
  }
}
