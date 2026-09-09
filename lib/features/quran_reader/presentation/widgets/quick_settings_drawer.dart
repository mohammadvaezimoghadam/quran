import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../../../common/utils/arabic_text_helper.dart';
import '../../../../common/widgets/app_theme_toggle_button.dart';
import '../../../../common/widgets/reciter/horizontal_reciter_selector.dart';
import '../../../../common/widgets/reciter/reciter_selection_bottom_sheet.dart';
import '../../../../common/widgets/settings_switch_tile.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/presentation/theme_controller.dart';
import '../../../translation_manager/presentation/widgets/translation_settings_section.dart';
import '../../application/controllers/quran_audio_controller.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import '../../domain/enums/audio_playback_mode.dart';
import 'ayah_number_marker.dart';
import 'tashkeel_color_selector_tile.dart';

/// Ultra-modern iOS-style Tabbed Settings Bottom Sheet (Display & Audio).
class QuickSettingsDrawer extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<QuickSettingsDrawer> createState() =>
      _QuickSettingsDrawerState();
}

class _QuickSettingsDrawerState extends ConsumerState<QuickSettingsDrawer> {
  int _selectedTabIndex = 0; // 0: Quran Text, 1: Translation, 2: Audio & Recitation

  static const List<String> _fontNames = [
    'عثمان طه',
    'امیری',
    'شهرزاد',
    'نیریزی',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final topPadding = mediaQuery.padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Responsive height calculation: up to 86% of screen or bounded by top status bar
    final maxResponsiveHeight = (screenHeight - topPadding - 24.0)
        .clamp(350.0, screenHeight * 0.86);

    // Notifiers for dispatching actions (does not trigger rebuilds)
    final displayNotifier =
        ref.read(quranDisplaySettingsControllerProvider.notifier);
    final audioController =
        ref.read(quranAudioControllerProvider.notifier);

    final currentThemeMode = ref.watch(themeControllerProvider);
    final activeThemeMode = currentThemeMode == ThemeMode.system
        ? (isDark ? ThemeMode.dark : ThemeMode.light)
        : currentThemeMode;

    final sheetBgColor =
        isDark ? const Color(0xFF14181B) : const Color(0xFFF1EFEA);
    final cardBgColor = isDark ? const Color(0xFF21262B) : Colors.white;
    final textPrimary = colorScheme.onSurface;
    final textSecondary = colorScheme.onSurfaceVariant;
    final accentColor = colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: maxResponsiveHeight,
          ),
          decoration: BoxDecoration(
            color: sheetBgColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24.0),
            ),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 12.0),
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

              // 2. Header Title & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  Text(
                    'تنظیمات',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.6),
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

              14.0.vSpace,

              // 3. Tab Switcher (3 Tabs: متن قرآن / ترجمه / صوت و تلاوت)
              Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildTabButton(
                      index: 0,
                      title: 'متن قرآن',
                      cardBgColor: cardBgColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    _buildTabButton(
                      index: 1,
                      title: 'ترجمه',
                      cardBgColor: cardBgColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    _buildTabButton(
                      index: 2,
                      title: 'صوت و تلاوت',
                      cardBgColor: cardBgColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),

              14.0.vSpace,

              // 4. Tab Content (Optimized: Isolated Subtree Watches to avoid unneeded rebuilds)
              Expanded(
                child: _selectedTabIndex == 0
                    ? _buildQuranTab(
                        context: context,
                        ref: ref,
                        displayNotifier: displayNotifier,
                        activeThemeMode: activeThemeMode,
                        cardBgColor: cardBgColor,
                        accentColor: accentColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        colorScheme: colorScheme,
                      )
                    : _selectedTabIndex == 1
                        ? _buildTranslationTab(
                            context: context,
                            ref: ref,
                            displayNotifier: displayNotifier,
                            cardBgColor: cardBgColor,
                            accentColor: accentColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            colorScheme: colorScheme,
                          )
                        : _buildAudioTab(
                            context: context,
                            ref: ref,
                            displayNotifier: displayNotifier,
                            audioController: audioController,
                            cardBgColor: cardBgColor,
                            accentColor: accentColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            colorScheme: colorScheme,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String title,
    required Color cardBgColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected ? cardBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? textPrimary : textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- TAB 0: QURAN TEXT & SCRIPT ---
  Widget _buildQuranTab({
    required BuildContext context,
    required WidgetRef ref,
    required dynamic displayNotifier,
    required ThemeMode activeThemeMode,
    required Color cardBgColor,
    required Color accentColor,
    required Color textPrimary,
    required Color textSecondary,
    required ColorScheme colorScheme,
  }) {
    final settings = ref.watch(quranDisplaySettingsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Compact Pinned Quran Live Preview
        _buildQuranLivePreviewCard(
          context: context,
          settings: settings,
          cardBgColor: cardBgColor,
          accentColor: accentColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          colorScheme: colorScheme,
        ),

        12.0.vSpace,

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // GROUP 1: QURAN SCRIPT & CALLIGRAPHY
                _buildSectionTitle('قلم و نگارش قرآن', textSecondary),
                6.0.vSpace,
                _buildCardGroup(
                  cardBgColor: cardBgColor,
                  children: [
                    _buildFontScriptTile(
                      context: context,
                      settings: settings,
                      notifier: displayNotifier,
                      accentColor: accentColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      colorScheme: colorScheme,
                    ),
                    _buildInnerDivider(colorScheme),
                    TashkeelColorSelectorTile(
                      selectedColorHex: settings.harakatColor,
                      accentColor: accentColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      colorScheme: colorScheme,
                      onColorSelected: (colorHex) =>
                          displayNotifier.updateHarakatColor(colorHex),
                    ),
                    _buildInnerDivider(colorScheme),
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
                      onChanged: (val) =>
                          displayNotifier.updateArabicFontSize(val),
                    ),
                    _buildInnerDivider(colorScheme),
                    _buildSliderTile(
                      context: context,
                      title: 'فاصله خطوط متن عربی',
                      valueLabel: settings.arabicLineHeight.toStringAsFixed(1),
                      icon: CupertinoIcons.arrow_up_down,
                      value: settings.arabicLineHeight,
                      min: 1.6,
                      max: 3.2,
                      divisions: 16,
                      accentColor: accentColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onChanged: (val) =>
                          displayNotifier.updateArabicLineHeight(val),
                    ),
                  ],
                ),

                16.0.vSpace,

                // GROUP 2: DISPLAY OPTIONS & THEME
                _buildSectionTitle('نمایش و صفحه', textSecondary),
                6.0.vSpace,
                _buildCardGroup(
                  cardBgColor: cardBgColor,
                  children: [
                    SettingsSwitchTile(
                      title: 'نمایش متن عربی',
                      subtitle: 'نمایش آیات به زبان عربی',
                      icon: CupertinoIcons.text_quote,
                      value: settings.showArabicText,
                      accentColor: accentColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onChanged: (val) => displayNotifier.toggleArabicText(val),
                    ),
                    _buildInnerDivider(colorScheme),
                    SettingsSwitchTile(
                      title: 'نمایش شماره آیه‌ها',
                      subtitle: 'نمایش نشانگر شماره در پایان هر آیه',
                      icon: CupertinoIcons.number,
                      value: settings.showAyahNumbers,
                      accentColor: accentColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onChanged: (val) =>
                          displayNotifier.toggleAyahNumbers(val),
                    ),
                    _buildInnerDivider(colorScheme),
                    _buildThemeTile(
                      context: context,
                      activeThemeMode: activeThemeMode,
                      accentColor: accentColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),

                16.0.vSpace,

                // RESET BUTTON
                Center(
                  child: TextButton.icon(
                    onPressed: () => displayNotifier.resetToDefaults(),
                    icon: Icon(
                      CupertinoIcons.refresh,
                      size: 16,
                      color: textSecondary,
                    ),
                    label: Text(
                      'بازنشانی تنظیمات متن و نگارش',
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
    );
  }

  // --- TAB 1: TRANSLATION SETTINGS ---
  Widget _buildTranslationTab({
    required BuildContext context,
    required WidgetRef ref,
    required dynamic displayNotifier,
    required Color cardBgColor,
    required Color accentColor,
    required Color textPrimary,
    required Color textSecondary,
    required ColorScheme colorScheme,
  }) {
    final settings = ref.watch(quranDisplaySettingsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Compact Pinned Translation Live Preview
        _buildTranslationLivePreviewCard(
          context: context,
          settings: settings,
          cardBgColor: cardBgColor,
          accentColor: accentColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          colorScheme: colorScheme,
        ),

        12.0.vSpace,

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('تنظیمات ترجمه فارسی', textSecondary),
                6.0.vSpace,
                _buildCardGroup(
                  cardBgColor: cardBgColor,
                  children: [
                    TranslationSettingsSection(
                      showTranslation: settings.showTranslation,
                      translationFontSize: settings.translationFontSize,
                      translationFontFamily: settings.translationFontFamily,
                      removeTranslationBrackets:
                          settings.removeTranslationBrackets,
                      onToggleTranslation: (val) =>
                          displayNotifier.toggleTranslation(val),
                      onFontSizeChanged: (val) =>
                          displayNotifier.updateTranslationFontSize(val),
                      onFontFamilyChanged: (val) =>
                          displayNotifier.updateTranslationFontFamily(val),
                      onToggleRemoveBrackets: (val) =>
                          displayNotifier.toggleRemoveTranslationBrackets(val),
                      accentColor: accentColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),

                16.0.vSpace,

                // RESET TRANSLATION BUTTON
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      displayNotifier.updateTranslationFontSize(16.0);
                      displayNotifier.updateTranslationFontFamily('BNazanin');
                      displayNotifier.toggleRemoveTranslationBrackets(true);
                      displayNotifier.toggleTranslation(true);
                    },
                    icon: Icon(
                      CupertinoIcons.refresh,
                      size: 16,
                      color: textSecondary,
                    ),
                    label: Text(
                      'بازنشانی تنظیمات ترجمه',
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
    );
  }

  // --- PINNED QURAN LIVE PREVIEW CARD ---
  Widget _buildQuranLivePreviewCard({
    required BuildContext context,
    required dynamic settings,
    required Color cardBgColor,
    required Color accentColor,
    required Color textPrimary,
    required Color textSecondary,
    required ColorScheme colorScheme,
  }) {
    final fontFamily =
        AppTypography.getFontFamilyByScript(settings.fontScript);
    final harakatColor =
        ArabicTextHelper.parseHexColor(settings.harakatColor);
    const sampleArabicText = 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَالَمِينَ';

    final baseArabicStyle = AppTypography.displayQuranReader.copyWith(
      fontFamily: fontFamily,
      fontSize: settings.arabicFontSize,
      height: settings.arabicLineHeight,
      color: textPrimary,
    );

    final bool useCustomHarakat =
        harakatColor != null && harakatColor != textPrimary;

    final List<InlineSpan> textChildren = [];

    if (settings.showArabicText) {
      if (useCustomHarakat) {
        textChildren.addAll(
          ArabicTextHelper.buildColoredSpans(
            text: sampleArabicText,
            baseStyle: baseArabicStyle,
            baseColor: textPrimary,
            harakatColor: harakatColor,
          ),
        );
      } else {
        textChildren.add(const TextSpan(text: sampleArabicText));
      }

      if (settings.showAyahNumbers) {
        textChildren.add(const TextSpan(text: '\u200F'));
        textChildren.add(
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: AyahNumberMarker(
              number: 2,
              isActive: false,
            ),
          ),
        );
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: settings.showArabicText
          ? RichText(
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              text: TextSpan(
                style: baseArabicStyle,
                children: textChildren,
              ),
            )
          : Center(
              child: Text(
                'نمایش متن عربی غیرفعال است',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  color: textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
    );
  }

  // --- PINNED TRANSLATION LIVE PREVIEW CARD ---
  Widget _buildTranslationLivePreviewCard({
    required BuildContext context,
    required dynamic settings,
    required Color cardBgColor,
    required Color accentColor,
    required Color textPrimary,
    required Color textSecondary,
    required ColorScheme colorScheme,
  }) {
    const rawSampleTranslationText =
        '(خداوندی که) ستایش مخصوص اوست [که] پروردگار جهانیان است.';
    final sampleTranslationText = settings.removeTranslationBrackets
        ? rawSampleTranslationText.removeTranslatorExplanations()
        : rawSampleTranslationText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: settings.showTranslation
          ? Text(
              sampleTranslationText,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: settings.translationFontFamily,
                fontSize: settings.translationFontSize,
                color: textSecondary,
                height: 1.35,
              ),
            )
          : Center(
              child: Text(
                'نمایش ترجمه غیرفعال است',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  color: textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
    );
  }

  // --- TAB 2: AUDIO & RECITATION (Optimized with targeted select watchers) ---
  Widget _buildAudioTab({
    required BuildContext context,
    required WidgetRef ref,
    required dynamic displayNotifier,
    required dynamic audioController,
    required Color cardBgColor,
    required Color accentColor,
    required Color textPrimary,
    required Color textSecondary,
    required ColorScheme colorScheme,
  }) {
    // Targeted selectors: Audio ticks/duration updates do NOT trigger rebuilds here
    final playbackMode = ref.watch(
      quranAudioControllerProvider.select((s) => s.playbackMode),
    );
    final isAutoPlayNext = ref.watch(
      quranAudioControllerProvider.select((s) => s.isAutoPlayNext),
    );
    final isSingleAyahMode = ref.watch(
      quranAudioControllerProvider.select((s) => s.isSingleAyahMode),
    );
    final autoHighlight = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.autoHighlight),
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // GROUP 0: PLAYBACK MODE SELECTION
          _buildSectionTitle('نحوه پخش صوت', textSecondary),
          6.0.vSpace,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
            children: AudioPlaybackMode.values.map((mode) {
              final isSelected = playbackMode == mode;
              
              String shortTitle;
              switch (mode) {
                case AudioPlaybackMode.onlyQuran:
                  shortTitle = 'تلاوت';
                  break;
                case AudioPlaybackMode.onlyTranslation:
                  shortTitle = 'ترجمه';
                  break;
                case AudioPlaybackMode.quranThenTranslation:
                  shortTitle = 'تلاوت+ترجمه';
                  break;
                case AudioPlaybackMode.translationThenQuran:
                  shortTitle = 'ترجمه+تلاوت';
                  break;
              }

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: InkWell(
                    onTap: () {
                      ref
                          .read(quranAudioControllerProvider.notifier)
                          .setPlaybackMode(mode);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentColor.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(color: accentColor, width: 1.2)
                            : Border.all(color: Colors.transparent, width: 1.2),
                      ),
                      child: Center(
                        child: Text(
                          shortTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 10.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? accentColor : textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        16.0.vSpace,

        // GROUP 1: ARABIC RECITER SELECTION
        if (playbackMode.includesQuran) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('قاری تلاوت قرآن', textSecondary),
              InkWell(
                onTap: () => ReciterSelectionBottomSheet.show(context,
                    checkDownloadStatus: true),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        'لیست کامل',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      4.0.hSpace,
                      Icon(
                        CupertinoIcons.chevron_left,
                        size: 13,
                        color: accentColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          6.0.vSpace,
          const HorizontalReciterSelector(
              isTranslationMode: false, checkDownloadStatus: true),
          16.0.vSpace,
        ],

        // GROUP 2: AUDIO TRANSLATION SELECTION
        if (playbackMode.includesTranslation) ...[
          _buildSectionTitle('گوینده ترجمه گویا', textSecondary),
          6.0.vSpace,
          const HorizontalReciterSelector(
              isTranslationMode: true, checkDownloadStatus: true),
          16.0.vSpace,
        ],

        // GROUP 2: AUDIO PLAYBACK OPTIONS
        _buildSectionTitle('گزینه‌های پخش صوت', textSecondary),
        6.0.vSpace,
        _buildCardGroup(
          cardBgColor: cardBgColor,
          children: [
            SettingsSwitchTile(
              title: 'پخش خودکار آیه بعدی',
              subtitle: 'ادامه تلاوت خودکار آیه‌ها پس از پایان هر آیه',
              icon: CupertinoIcons.play_circle,
              value: isAutoPlayNext,
              accentColor: accentColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              onChanged: (val) => audioController.toggleAutoPlayNext(),
            ),
            _buildInnerDivider(colorScheme),
            SettingsSwitchTile(
              title: 'حالت تک آیه‌ای (تکرار)',
              subtitle: 'پخش مجدد همان آیه و توقف پس از پایان آن',
              icon: CupertinoIcons.repeat,
              value: isSingleAyahMode,
              accentColor: accentColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              onChanged: (val) => audioController.toggleSingleAyahMode(),
            ),
            _buildInnerDivider(colorScheme),
            SettingsSwitchTile(
              title: 'هایلایت خودکار آیه در حال پخش',
              subtitle: 'هایلایت رنگی و اسکرول همگام آیه در حال تلاوت',
              icon: CupertinoIcons.sparkles,
              value: autoHighlight,
              accentColor: accentColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              onChanged: (val) => displayNotifier.toggleAutoHighlight(val),
            ),
          ],
        ),

        16.0.vSpace,
        ],
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
      width: double.infinity,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 7),
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
                    backgroundColor: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
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
                isDark
                    ? CupertinoIcons.moon_fill
                    : CupertinoIcons.sun_max_fill,
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
