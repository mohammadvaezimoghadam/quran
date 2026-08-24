import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../common/constants/app_constants.dart';
import '../../../../../core/routes/route_name.dart';
import '../../../../../common/extensions/size_extension.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../../../quran_reader/application/controllers/translation_controller.dart';
import '../../../../surah_list/application/controllers/surah_list_controller.dart';

/// Bottom sheet for selecting a Surah and a Translator using scrollable wheels (CupertinoPicker).
class TranslationSelectionBottomSheet extends ConsumerStatefulWidget {
  const TranslationSelectionBottomSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TranslationSelectionBottomSheet(),
    );
  }

  @override
  ConsumerState<TranslationSelectionBottomSheet> createState() =>
      _TranslationSelectionBottomSheetState();
}

class _TranslationSelectionBottomSheetState
    extends ConsumerState<TranslationSelectionBottomSheet> {
  int _selectedSurahIndex = 0;
  int _selectedTranslatorIndex = 0;

  late final List<String> _translators;
  FixedExtentScrollController? _translatorScrollController;

  @override
  void initState() {
    super.initState();
    _translators = translatorNameToIdMap.keys.toList();

    // Read the initially saved translator from settings to pre-select it synchronously
    final settings = ref.read(quranDisplaySettingsControllerProvider);
    final index = _translators.indexOf(settings.translatorName);
    
    if (index != -1) {
      _selectedTranslatorIndex = index;
    }
    
    _translatorScrollController = FixedExtentScrollController(
      initialItem: _selectedTranslatorIndex,
    );
  }

  @override
  void dispose() {
    _translatorScrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBgColor = isDark
        ? const Color(0xFF14181B)
        : const Color(0xFFF1EFEA);

    final surahState = ref.watch(surahListControllerProvider);
    final surahs = surahState.surahs;

    // Get the user's selected Arabic font for Surah names
    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final fontFamily = AppTypography.getFontFamilyByScript(fontScript);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.45,
        decoration: BoxDecoration(
          color: sheetBgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 20,
          left: 16,
          right: 16,
        ),
        child: Column(
          children: [
            // Top Drag Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Text(
              AppConstants.selectSurahAndTranslatorTitle,
              style: AppTypography.sectionHeader.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            16.vSpace,

            if (surahState.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: Row(
                  children: [
                    // --- Surahs Picker ---
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          const Text(
                            AppConstants.surahLabel,
                            style: AppTypography.bottomSheetSubtitle,
                          ),
                          8.vSpace,
                          Expanded(
                            child: CupertinoPicker.builder(
                              itemExtent: 45,
                              useMagnifier: true,
                              magnification: 1.15,
                              scrollController: FixedExtentScrollController(
                                initialItem: _selectedSurahIndex,
                              ),
                              onSelectedItemChanged: (index) {
                                _selectedSurahIndex = index;
                              },
                              childCount: surahs.length,
                              itemBuilder: (context, index) {
                                final surah = surahs[index];
                                return Center(
                                  child: Text(
                                    surah.name, // Arabic name
                                    style: AppTypography.bottomSheetItemLabel
                                        .copyWith(
                                          fontFamily:
                                              fontFamily, // User selected font!
                                          fontSize: 18,
                                          color: colorScheme.onSurface,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    16.hSpace,

                    // --- Translators Picker ---
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          const Text(
                            AppConstants.translatorLabel,
                            style: AppTypography.bottomSheetSubtitle,
                          ),
                          8.vSpace,
                          Expanded(
                            child: CupertinoPicker.builder(
                              itemExtent: 45,
                              useMagnifier: true,
                              magnification: 1.15,
                              scrollController: _translatorScrollController,
                              onSelectedItemChanged: (index) {
                                _selectedTranslatorIndex = index;
                              },
                              childCount: _translators.length,
                              itemBuilder: (context, index) {
                                return Center(
                                  child: Text(
                                    _translators[index],
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: AppTypography.bottomSheetItemLabel
                                        .copyWith(color: colorScheme.onSurface),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            16.vSpace,

            // --- Action Button ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  if (surahs.isEmpty) return;

                  final selectedSurah = surahs[_selectedSurahIndex];
                  final selectedTranslator =
                      _translators[_selectedTranslatorIndex];

                  // 1. Save chosen translator and turn off Arabic text
                  final settingsNotifier = ref.read(quranDisplaySettingsControllerProvider.notifier);
                  settingsNotifier.updateTranslator(selectedTranslator);
                  settingsNotifier.toggleArabicText(false);

                  // 2. Close bottom sheet
                  Navigator.of(context).pop();

                  // 3. Navigate to reader page
                  Future.microtask(() {
                    if (context.mounted) {
                      context.pushNamed(
                        quranReaderRoute,
                        pathParameters: {'id': selectedSurah.number.toString()},
                        queryParameters: {'name': selectedSurah.name},
                      );
                    }
                  });
                },
                child: const Text(
                  AppConstants.startReadingButtonLabel,
                  style: AppTypography.bottomSheetActionLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
