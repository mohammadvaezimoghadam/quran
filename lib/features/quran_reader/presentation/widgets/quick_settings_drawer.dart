import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_theme_toggle_button.dart';
import '../../../../common/widgets/settings_switch_tile.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/presentation/theme_controller.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import 'tashkeel_color_selector_tile.dart';
import '../../../translation_manager/presentation/widgets/translation_settings_section.dart';

/// Ultra-modern iOS-style Grouped Settings Bottom Sheet.
class QuickSettingsDrawer extends ConsumerWidget {
  const QuickSettingsDrawer({super.key});

  /// Helper method to display settings in iOS-style Grouped Bottom Sheet.
  static Future<void> show(BuildContext context) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final notifier =
        container.read(quranDisplaySettingsControllerProvider.notifier);

    // Record baseline state before user makes changes in settings
    notifier.recordInitialState();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      elevation: 0,
      builder: (context) => const QuickSettingsDrawer(),
    );

    // Save ONLY if changes were made upon closing
    notifier.saveSettingsIfChanged();
  }

  static const List<String> _fontNames = [
    'عثمان طه',
    'امیری',
    'شهرزاد',
    'نیریزی',
  ];


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Display Settings State & Notifier
    final settings = ref.watch(quranDisplaySettingsControllerProvider);
    final notifier = ref.read(quranDisplaySettingsControllerProvider.notifier);
    final currentThemeMode = ref.watch(themeControllerProvider);
    final activeThemeMode = currentThemeMode == ThemeMode.system
        ? (isDark ? ThemeMode.dark : ThemeMode.light)
        : currentThemeMode;

    // Explicit high-contrast theme-aware color tokens for crisp iOS Grouped Layout
    final sheetBgColor = isDark
        ? const Color(0xFF14181B)
        : const Color(0xFFF1EFEA);
    final cardBgColor = isDark
        ? const Color(0xFF21262B)
        : Colors.white;
    final textPrimary = colorScheme.onSurface;
    final textSecondary = colorScheme.onSurfaceVariant;
    final accentColor = colorScheme.primary;

    return ScaffoldMessenger(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.55,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Builder(
            builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: SafeArea(
              top: false,
              child: Container(
                decoration: BoxDecoration(
            color: sheetBgColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24.0),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  decoration: BoxDecoration(
                    color: textSecondary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // 2. iOS-style Top Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  Text(
                    'تنظیمات',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.xmark,
                        color: textSecondary,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),

              10.0.vSpace,

              // 3. Scrollable Grouped Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- GROUP 1: READING & TEXT SETTINGS (COMBINED) ---
                      _buildSectionTitle('تنظیمات متن و قرائت', textSecondary),
                      6.0.vSpace,
                      _buildCardGroup(
                        cardBgColor: cardBgColor,
                        children: [
                          // 1.1 Arabic Font Size (Always Visible)
                          _buildSliderTile(
                            context: context,
                            title: 'اندازه متن عربی',
                            valueLabel: '${settings.arabicFontSize.toInt()} pt',
                            icon: CupertinoIcons.textformat_size,
                            value: settings.arabicFontSize,
                            min: 18,
                            max: 42,
                            divisions: 24,
                            accentColor: accentColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            onChanged: (val) => notifier.updateArabicFontSize(val),
                          ),

                          _buildInnerDivider(colorScheme),

                          // 1.2 Font Script (Always Visible)
                          _buildFontScriptTile(
                            context: context,
                            settings: settings,
                            notifier: notifier,
                            accentColor: accentColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            colorScheme: colorScheme,
                          ),

                          _buildInnerDivider(colorScheme),

                          // 1.3 Tashkeel Color Selector Tile (Always Visible)
                          TashkeelColorSelectorTile(
                            selectedColorHex: settings.harakatColor,
                            accentColor: accentColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            colorScheme: colorScheme,
                            onColorSelected: (colorHex) =>
                                notifier.updateHarakatColor(colorHex),
                          ),

                          _buildInnerDivider(colorScheme),

                          // 1.4 Show Arabic Text Toggle
                          SettingsSwitchTile(
                            title: 'نمایش متن عربی',
                            subtitle: 'نمایش آیات به زبان عربی',
                            icon: CupertinoIcons.text_quote,
                            value: settings.showArabicText,
                            accentColor: accentColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            onChanged: (val) => notifier.toggleArabicText(val),
                          ),

                          _buildInnerDivider(colorScheme),

                          // 1.5 Translation Settings (Extracted to translation_manager feature)
                          TranslationSettingsSection(
                            showTranslation: settings.showTranslation,
                            translationFontSize: settings.translationFontSize,
                            onToggleTranslation: (val) => notifier.toggleTranslation(val),
                            onFontSizeChanged: (val) => notifier.updateTranslationFontSize(val),
                            accentColor: accentColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                        ],
                      ),

                      16.0.vSpace,

                      // --- GROUP 2: DISPLAY & PLAYBACK OPTIONS ---
                      _buildSectionTitle('گزینه‌های نمایش و پخش', textSecondary),
                      6.0.vSpace,
                      _buildCardGroup(
                        cardBgColor: cardBgColor,
                        children: [
                          // 2.1 Theme Selection (AppThemeToggleButton)
                          _buildThemeTile(
                            context: context,
                            ref: ref,
                            activeThemeMode: activeThemeMode,
                            accentColor: accentColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            colorScheme: colorScheme,
                          ),

                          _buildInnerDivider(colorScheme),

                          // 2.2 Show Ayah Numbers
                          SettingsSwitchTile(
                            title: 'نمایش شماره آیه‌ها',
                            subtitle: 'نمایش نشانگر شماره در پایان هر آیه',
                            icon: CupertinoIcons.number,
                            value: settings.showAyahNumbers,
                            accentColor: accentColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            onChanged: (val) => notifier.toggleAyahNumbers(val),
                          ),

                          _buildInnerDivider(colorScheme),

                          // 2.3 Auto Highlight
                          SettingsSwitchTile(
                            title: 'هایلایت خودکار پخش',
                            subtitle: 'هایلایت رنگی آیه در حال تلاوت',
                            icon: CupertinoIcons.sparkles,
                            value: settings.autoHighlight,
                            accentColor: accentColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            onChanged: (val) => notifier.toggleAutoHighlight(val),
                          ),
                        ],
                      ),

                      16.0.vSpace,

                      // --- RESET SETTINGS BUTTON ---
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            notifier.resetToDefaults();
                          },
                          icon: Icon(
                            CupertinoIcons.refresh,
                            size: 16,
                            color: textSecondary,
                          ),
                          label: Text(
                            'بازنشانی تنظیمات به حالت اولیه',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: textSecondary,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                          ),
                        ),
                      ),

                      8.0.vSpace,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
        ),
        ),
      ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionTitle(String title, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: textSecondary,
        ),
      ),
    );
  }

  Widget _buildCardGroup({
    required Color cardBgColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
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
                    inactiveTrackColor:
                        Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
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

  Widget _buildFontScriptTile({
    required BuildContext context,
    required dynamic settings,
    required dynamic notifier,
    required Color accentColor,
    required Color textPrimary,
    required Color textSecondary,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.textformat, size: 18.0, color: accentColor),
              8.0.hSpace,
              Text(
                'نوع خط عربی',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          8.0.vSpace,
          Row(
            children: List.generate(_fontNames.length, (index) {
              final fontName = _fontNames[index];
              final isSelected = settings.fontScript == fontName;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: ChoiceChip(
                    labelPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    backgroundColor:
                        colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    selectedColor: accentColor.withValues(alpha: 0.25),
                    side: BorderSide(
                      color: isSelected
                          ? accentColor
                          : colorScheme.outline.withValues(alpha: 0.15),
                    ),
                    label: Center(
                      child: Text(
                        fontName,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          color: isSelected ? accentColor : textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        notifier.updateFontScript(fontName);
                      }
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeMode activeThemeMode,
    required Color accentColor,
    required Color textPrimary,
    required Color textSecondary,
    required ColorScheme colorScheme,
  }) {
    final isDark = activeThemeMode == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isDark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                size: 18.0,
                color: accentColor,
              ),
              8.0.hSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حالت صفحه (تم)',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    isDark ? 'تم تیره (حالت شب)' : 'تم روشن (حالت روز)',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const AppThemeToggleButton(
            iconSize: 22,
          ),
        ],
      ),
    );
  }




}
