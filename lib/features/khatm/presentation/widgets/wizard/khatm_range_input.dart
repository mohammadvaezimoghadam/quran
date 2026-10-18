import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/extensions/string_extension.dart';
import 'package:quran/core/theme/app_typography.dart';

/// Row containing "از [واحد]" and "تا [واحد]" side-by-side inputs.
/// Borderless design with soft filled background and outside labels.
class KhatmRangeInput extends StatefulWidget {
  final int fromValue;
  final int toValue;
  final int maxValue;
  final String unitLabel;
  final void Function(int from, int to) onRangeChanged;

  const KhatmRangeInput({
    super.key,
    required this.fromValue,
    required this.toValue,
    required this.maxValue,
    required this.unitLabel,
    required this.onRangeChanged,
  });

  @override
  State<KhatmRangeInput> createState() => _KhatmRangeInputState();
}

class _KhatmRangeInputState extends State<KhatmRangeInput> {
  late TextEditingController _fromController;
  late TextEditingController _toController;
  late FocusNode _fromFocusNode;
  late FocusNode _toFocusNode;

  @override
  void initState() {
    super.initState();
    _fromController =
        TextEditingController(text: widget.fromValue.toPersianDigit());
    _toController =
        TextEditingController(text: widget.toValue.toPersianDigit());
    _fromFocusNode = FocusNode();
    _toFocusNode = FocusNode();

    _fromFocusNode.addListener(_onFromFocusChanged);
    _toFocusNode.addListener(_onToFocusChanged);
  }

  void _onFromFocusChanged() {
    if (!_fromFocusNode.hasFocus) {
      final parsed = int.tryParse(_fromController.text.toEnglishDigit());
      if (parsed == null || parsed < 1 || parsed > widget.maxValue) {
        _fromController.text = widget.fromValue.toPersianDigit();
      } else if (parsed > widget.toValue) {
        _toController.text = parsed.toPersianDigit();
        widget.onRangeChanged(parsed, parsed);
      }
    }
  }

  void _onToFocusChanged() {
    if (!_toFocusNode.hasFocus) {
      final parsed = int.tryParse(_toController.text.toEnglishDigit());
      if (parsed == null || parsed < 1 || parsed > widget.maxValue) {
        _toController.text = widget.toValue.toPersianDigit();
      } else if (parsed < widget.fromValue) {
        _toController.text = widget.fromValue.toPersianDigit();
        widget.onRangeChanged(widget.fromValue, widget.fromValue);
      }
    }
  }

  @override
  void didUpdateWidget(covariant KhatmRangeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fromValue != widget.fromValue) {
      final currentFrom = int.tryParse(_fromController.text.toEnglishDigit());
      if (currentFrom != widget.fromValue) {
        _fromController.text = widget.fromValue.toPersianDigit();
      }
    }
    if (oldWidget.toValue != widget.toValue) {
      final currentTo = int.tryParse(_toController.text.toEnglishDigit());
      if (currentTo != widget.toValue) {
        _toController.text = widget.toValue.toPersianDigit();
      }
    }
  }

  @override
  void dispose() {
    _fromFocusNode.removeListener(_onFromFocusChanged);
    _toFocusNode.removeListener(_onToFocusChanged);
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _onFromChanged(String val) {
    if (val.trim().isEmpty) return;
    final parsed = int.tryParse(val.toEnglishDigit());
    if (parsed != null && parsed >= 1 && parsed <= widget.maxValue) {
      final validTo = widget.toValue < parsed ? parsed : widget.toValue;
      widget.onRangeChanged(parsed, validTo);
    }
  }

  void _onToChanged(String val) {
    if (val.trim().isEmpty) return;
    final parsed = int.tryParse(val.toEnglishDigit());
    if (parsed != null && parsed >= 1 && parsed <= widget.maxValue) {
      widget.onRangeChanged(widget.fromValue, parsed);
    }
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

    return Row(
      children: [
        // از [واحد]
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'از ${widget.unitLabel}',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fromController,
                focusNode: _fromFocusNode,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
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
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                ),
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                onChanged: _onFromChanged,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // تا [واحد]
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تا ${widget.unitLabel}',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _toController,
                focusNode: _toFocusNode,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
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
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                ),
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                onChanged: _onToChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
