import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../core/theme/app_typography.dart';

/// Reusable Quill-powered block editor for topic and contemplation blocks.
/// Replaces Flutter's native [TextField] to eliminate BiDi / RTL cursor jumping bugs
/// on parenthesized Arabic/Persian numbers like (۲۹) and multiline text.
class QuillBlockField extends StatefulWidget {
  final String initialText;
  final String hintText;
  final TextStyle? style;
  final ValueChanged<String> onChanged;
  final int? minLines;

  const QuillBlockField({
    super.key,
    required this.initialText,
    required this.hintText,
    this.style,
    required this.onChanged,
    this.minLines,
  });

  @override
  State<QuillBlockField> createState() => _QuillBlockFieldState();
}

class _QuillBlockFieldState extends State<QuillBlockField> {
  late final QuillController _quillController;
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final text = widget.initialText;
    final doc = text.isEmpty
        ? Document()
        : (Document()..insert(0, text.endsWith('\n') ? text : '$text\n'));

    _quillController = QuillController(
      document: doc,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _focusNode = FocusNode();
    _scrollController = ScrollController();

    _focusNode.addListener(_onFocusChanged);
    _quillController.addListener(_onTextChanged);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _flush();
    }
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        _flush();
      }
    });
  }

  void _flush() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    final raw = _quillController.document.toPlainText();
    final text = raw.endsWith('\n') ? raw.substring(0, raw.length - 1) : raw;
    if (text != widget.initialText) {
      widget.onChanged(text);
    }
  }

  @override
  void didUpdateWidget(covariant QuillBlockField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialText != widget.initialText && !_focusNode.hasFocus) {
      final raw = _quillController.document.toPlainText();
      final current = raw.endsWith('\n') ? raw.substring(0, raw.length - 1) : raw;
      if (current != widget.initialText) {
        final replaceLen = _quillController.document.length > 1
            ? _quillController.document.length - 1
            : 0;
        _quillController.replaceText(
          0,
          replaceLen,
          widget.initialText,
          null,
        );
      }
    }
  }

  @override
  void dispose() {
    _flush();
    _focusNode.removeListener(_onFocusChanged);
    _quillController.removeListener(_onTextChanged);
    _focusNode.dispose();
    _quillController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultStyle = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 14.0,
      height: 1.6,
      color: isDark ? Colors.white : Colors.black87,
    );

    final effectiveStyle = widget.style ?? defaultStyle;
    final placeholderStyle = effectiveStyle.copyWith(
      color: isDark
          ? Colors.white.withValues(alpha: 0.35)
          : const Color(0xFF8E8E93),
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
          final textLen = _quillController.document.length - 1;
          _quillController.updateSelection(
            TextSelection.collapsed(offset: textLen > 0 ? textLen : 0),
            ChangeSource.local,
          );
        }
      },
      child: QuillEditor.basic(
        controller: _quillController,
        focusNode: _focusNode,
        scrollController: _scrollController,
        config: QuillEditorConfig(
          placeholder: widget.hintText,
          padding: EdgeInsets.zero,
          autoFocus: false,
          expands: false,
          scrollable: false,
          customStyles: DefaultStyles(
            paragraph: DefaultTextBlockStyle(
              effectiveStyle,
              HorizontalSpacing.zero,
              VerticalSpacing.zero,
              VerticalSpacing.zero,
              null,
            ),
            placeHolder: DefaultTextBlockStyle(
              placeholderStyle,
              HorizontalSpacing.zero,
              VerticalSpacing.zero,
              VerticalSpacing.zero,
              null,
            ),
          ),
        ),
      ),
    );
  }
}
