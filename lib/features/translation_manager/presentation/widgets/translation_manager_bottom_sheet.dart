import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/constants/app_constants.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../application/controllers/translation_manager_controller.dart';
import '../../../surah_list/application/controllers/surah_list_controller.dart';

/// Bottom sheet for selecting a Surah and a Translator using scrollable wheels (CupertinoPicker).
class TranslationManagerBottomSheet extends ConsumerStatefulWidget {
  const TranslationManagerBottomSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TranslationManagerBottomSheet(),
    );
  }

  @override
  ConsumerState<TranslationManagerBottomSheet> createState() =>
      _TranslationManagerBottomSheetState();
}

class _TranslationManagerBottomSheetState
    extends ConsumerState<TranslationManagerBottomSheet> {
  int _selectedSurahIndex = 0;
  int _selectedTranslatorIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  bool _isCurrentlyDownloading(List<dynamic> translations) {
    if (translations.isEmpty) return false;
    final state = ref.read(translationManagerControllerProvider).value;
    if (state == null) return false;
    final selectedTranslation = translations[_selectedTranslatorIndex];
    return state.downloadProgress.containsKey(selectedTranslation.id);
  }

  Future<void> _handleStartReading(
      BuildContext context, dynamic surah, dynamic translation) async {
    final controller = ref.read(translationManagerControllerProvider.notifier);

    // If it's not downloaded, ask for permission
    if (!translation.isDownloaded) {
      final shouldDownload = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            'دانلود ترجمه',
            style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          content: Text(
            'شما باید ترجمه «${translation.name}» را دانلود کنید. مایل به دانلود هستید؟',
            style: TextStyle(
                fontFamily: AppTypography.fontFamily, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'انصراف',
                style: TextStyle(fontFamily: AppTypography.fontFamily),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                'دانلود',
                style: TextStyle(fontFamily: AppTypography.fontFamily),
              ),
            ),
          ],
        ),
      );

      if (shouldDownload != true) return;

      // Await the download
      await controller.downloadTranslation(translation);
      
      // Stop execution here so it doesn't automatically jump to the reader page.
      // The user can press "Start Reading" again once the download is complete.
      return;
    }

    // Update settings (turn off Arabic text since we want Translation view)
    ref.read(quranDisplaySettingsControllerProvider.notifier).toggleArabicText(false);

    if (!context.mounted) return;
    
    // Close bottom sheet
    Navigator.of(context).pop();

    // Navigate to reader page with the selected translation ID
    context.pushNamed(
      quranReaderRoute,
      pathParameters: {'id': surah.number.toString()},
      queryParameters: {
        'name': surah.name,
        'translationId': translation.id,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBgColor = isDark
        ? const Color(0xFF14181B)
        : const Color(0xFFF1EFEA);

    final surahState = ref.watch(surahListControllerProvider);
    final translationState = ref.watch(translationManagerControllerProvider);
    
    final surahs = surahState.surahs;
    final translations = translationState.value?.translations ?? [];

    // Get the user's selected Arabic font for Surah names
    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final fontFamily = AppTypography.getFontFamilyByScript(fontScript);

    return ScaffoldMessenger(
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.48,
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
                ),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 16,
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

            if (surahState.isLoading || translationState.isLoading || translations.isEmpty)
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
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                              scrollController: FixedExtentScrollController(
                                initialItem: _selectedTranslatorIndex,
                              ),
                              onSelectedItemChanged: (index) {
                                _selectedTranslatorIndex = index;
                              },
                              childCount: translations.length,
                              itemBuilder: (context, index) {
                                final translation = translations[index];
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                      Flexible(
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              WidgetSpan(
                                                alignment: PlaceholderAlignment.middle,
                                                child: _TranslationStatusIcon(translation: translation),
                                              ),
                                              TextSpan(text: translation.name),
                                            ],
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.bottomSheetItemLabel
                                              .copyWith(color: colorScheme.onSurface, fontSize: 11, height: 1.2),
                                        ),
                                      ),
                                      ],
                                    ),
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
                onPressed: _isCurrentlyDownloading(translations)
                    ? null
                    : () {
                        if (surahs.isEmpty || translations.isEmpty) return;
                        
                        final selectedSurah = surahs[_selectedSurahIndex];
                        final selectedTranslation = translations[_selectedTranslatorIndex];
                        
                        _handleStartReading(context, selectedSurah, selectedTranslation);
                      },
                child: const Text(
                  AppConstants.startReadingButtonLabel,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
}

class _TranslationStatusIcon extends ConsumerWidget {
  final dynamic translation;

  const _TranslationStatusIcon({required this.translation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(translationManagerControllerProvider).value;
    
    // Check if downloading
    final progress = state?.downloadProgress[translation.id];
    final isDownloading = progress != null;

    if (translation.isDownloaded) {
      return Padding(
        padding: const EdgeInsets.only(left: 6.0),
        child: Icon(
          CupertinoIcons.check_mark_circled_solid, 
          size: 14, 
          color: Colors.green.shade600,
        ),
      );
    }

    if (isDownloading) {
      return Padding(
        padding: const EdgeInsets.only(left: 6.0),
        child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 2,
            backgroundColor: colorScheme.primary.withOpacity(0.2),
            color: colorScheme.primary,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Icon(
        CupertinoIcons.cloud_download, 
        size: 14, 
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
