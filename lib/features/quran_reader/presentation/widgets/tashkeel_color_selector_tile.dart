import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/utils/arabic_text_helper.dart';
import '../../../../core/theme/app_typography.dart';
import 'inline_tashkeel_color_picker.dart';

/// Premium tile widget for customizing Quranic Tashkeel (Arabic diacritics & harakat) colors.
/// Features a single circular color button that toggles an inline dropdown spectrum picker.
class TashkeelColorSelectorTile extends StatefulWidget {
  final String selectedColorHex;
  final Color accentColor;
  final Color textPrimary;
  final Color textSecondary;
  final ColorScheme colorScheme;
  final ValueChanged<String> onColorSelected;

  const TashkeelColorSelectorTile({
    super.key,
    required this.selectedColorHex,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.colorScheme,
    required this.onColorSelected,
  });

  @override
  State<TashkeelColorSelectorTile> createState() =>
      _TashkeelColorSelectorTileState();
}

class _TashkeelColorSelectorTileState extends State<TashkeelColorSelectorTile> {
  bool _isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    final currentColor =
        ArabicTextHelper.parseHexColor(widget.selectedColorHex) ??
            const Color(0xFFFF4444);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Tile Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title & Icon
              Row(
                children: [
                  Icon(
                    Icons.color_lens_outlined,
                    size: 18.0,
                    color: widget.accentColor,
                  ),
                  8.0.hSpace,
                  Text(
                    'رنگ‌بندی اعراب و علامات (تشکیل)',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: widget.textPrimary,
                    ),
                  ),
                ],
              ),

              // Circular Colored Button with Palette Icon
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isDropdownOpen = !_isDropdownOpen;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Tooltip(
                  message: 'انتخاب طیف رنگی اعراب',
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: currentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        _isDropdownOpen
                            ? CupertinoIcons.chevron_up
                            : CupertinoIcons.paintbrush,
                        size: 16,
                        color: currentColor.computeLuminance() > 0.5
                            ? Colors.black87
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Dropdown Spectrum Picker Box
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _isDropdownOpen
                ? InlineTashkeelColorPicker(
                    initialColorHex: widget.selectedColorHex,
                    accentColor: widget.accentColor,
                    textPrimary: widget.textPrimary,
                    textSecondary: widget.textSecondary,
                    colorScheme: widget.colorScheme,
                    onColorChanged: widget.onColorSelected,
                    onClose: () {
                      setState(() {
                        _isDropdownOpen = false;
                      });
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
