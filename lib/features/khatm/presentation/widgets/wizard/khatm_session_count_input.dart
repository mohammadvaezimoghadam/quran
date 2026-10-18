import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/extensions/string_extension.dart';
import 'package:quran/core/theme/app_typography.dart';

/// Numeric text input for total sessions or units per session.
/// Borderless design with soft filled background and outside label.
class KhatmSessionCountInput extends StatefulWidget {
  final int value;
  final String label;
  final int max;
  final ValueChanged<int> onChanged;

  const KhatmSessionCountInput({
    super.key,
    required this.value,
    required this.label,
    required this.max,
    required this.onChanged,
  });

  @override
  State<KhatmSessionCountInput> createState() => _KhatmSessionCountInputState();
}

class _KhatmSessionCountInputState extends State<KhatmSessionCountInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toPersianDigit());
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      final parsed = int.tryParse(_controller.text.toEnglishDigit());
      if (parsed == null || parsed < 1 || parsed > widget.max) {
        _controller.text = widget.value.toPersianDigit();
      }
    }
  }

  @override
  void didUpdateWidget(covariant KhatmSessionCountInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final currentParsed = int.tryParse(_controller.text.toEnglishDigit());
      if (currentParsed != widget.value) {
        _controller.text = widget.value.toPersianDigit();
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

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
          widget.label,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.right,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            filled: true,
            fillColor: inputBg,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          ),
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          onChanged: (val) {
            if (val.trim().isEmpty) return;
            final parsed = int.tryParse(val.toEnglishDigit());
            if (parsed != null && parsed >= 1 && parsed <= widget.max) {
              widget.onChanged(parsed);
            }
          },
        ),
      ],
    );
  }
}
