import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/settings_switch_tile.dart';
import '../../../../core/theme/app_typography.dart';
import 'translation_dropdown_selector.dart';/// An encapsulated UI section for Translation Settings (Toggle, Font Size, and Manager).
/// This can be injected into any settings drawer/menu across the app.
class TranslationSettingsSection extends StatelessWidget {
  final bool showTranslation;
  final double translationFontSize;
  final String translationFontFamily;
  final bool removeTranslationBrackets;
  final ValueChanged<bool> onToggleTranslation;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<String>? onFontFamilyChanged;
  final ValueChanged<bool>? onToggleRemoveBrackets;
  
  /// Colors injected from the parent (e.g., drawer) to match its theme
  final Color accentColor;
  final Color textPrimary;
  final Color textSecondary;

  const TranslationSettingsSection({
    super.key,
    required this.showTranslation,
    required this.translationFontSize,
    this.translationFontFamily = 'Vazirmatn',
    this.removeTranslationBrackets = true,
    required this.onToggleTranslation,
    required this.onFontSizeChanged,
    this.onFontFamilyChanged,
    this.onToggleRemoveBrackets,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 1. Show Translation Toggle
        SettingsSwitchTile(
          title: 'نمایش ترجمه',
          subtitle: 'نمایش ترجمه فارسی زیر آیه‌ها',
          icon: CupertinoIcons.captions_bubble,
          value: showTranslation,
          accentColor: accentColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          onChanged: onToggleTranslation,
        ),

        // 2. Animated Sub-settings for Translation
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: showTranslation
              ? Column(
                  children: [
                    _buildInnerDivider(colorScheme),

                    // Translation Font Family Selector (وزیر / نازنین)
                    _buildFontFamilyTile(context, colorScheme),

                    _buildInnerDivider(colorScheme),

                    // Translation Font Size
                    _buildSliderTile(
                      context: context,
                      title: 'اندازه متن ترجمه',
                      valueLabel: '${translationFontSize.toInt()} pt',
                      icon: CupertinoIcons.chat_bubble_text,
                      value: translationFontSize,
                      min: 12,
                      max: 26,
                      divisions: 14,
                      accentColor: accentColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onChanged: onFontSizeChanged,
                    ),

                    _buildInnerDivider(colorScheme),

                    // Remove Bracket Explanations Toggle
                    if (onToggleRemoveBrackets case final callback?) ...[
                      SettingsSwitchTile(
                        title: 'حذف توضیحات داخل پرانتز و قلاب',
                        subtitle: 'مخفی کردن عبارات اضافه و تفسیری مترجم از متن ترجمه',
                        icon: CupertinoIcons.textbox,
                        value: removeTranslationBrackets,
                        accentColor: accentColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onChanged: callback,
                      ),
                      _buildInnerDivider(colorScheme),
                    ],

                    // Translation Manager Button
                    _buildManagerButton(context, colorScheme),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildFontFamilyTile(BuildContext context, ColorScheme colorScheme) {
    final fonts = [
      {'name': 'وزیر', 'family': 'Vazirmatn'},
      {'name': 'نازنین', 'family': 'BNazanin'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.textformat_alt, size: 18.0, color: accentColor),
              8.0.hSpace,
              Text(
                'فونت متن ترجمه',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          Container(
            height: 34,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: fonts.map((f) {
                final isSelected = translationFontFamily == f['family'];
                return GestureDetector(
                  onTap: () {
                    if (onFontFamilyChanged != null) {
                      onFontFamilyChanged!(f['family']!);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.surface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        f['name']!,
                        style: TextStyle(
                          fontFamily: f['family'],
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? accentColor : textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerButton(BuildContext context, ColorScheme colorScheme) {
    return TranslationDropdownSelector(
      accentColor: accentColor,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
    );
  }

  Widget _buildInnerDivider(ColorScheme colorScheme) {
    return Divider(
      height: 1,
      thickness: 0.8,
      indent: 14,
      endIndent: 14,
      color: colorScheme.outlineVariant.withValues(alpha: 0.25),
    );
  }

  Widget _buildSliderTile({
    required BuildContext context,
    required String title,
    required String valueLabel,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Color accentColor,
    required Color textPrimary,
    required Color textSecondary,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18.0, color: accentColor),
                  8.0.hSpace,
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  valueLabel,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          4.0.vSpace,
          Row(
            children: [
              Text(
                'کوچک',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10.5,
                  color: textSecondary,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: accentColor,
                    inactiveTrackColor: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.2),
                    thumbColor: Colors.white,
                    overlayColor: accentColor.withValues(alpha: 0.15),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  ),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    divisions: divisions,
                    onChanged: onChanged,
                  ),
                ),
              ),
              Text(
                'بزرگ',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
