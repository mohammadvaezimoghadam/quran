import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../common/utils/arabic_text_helper.dart';
import '../../../../common/widgets/app_modal_header.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../common/widgets/surah_picker_dialog.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../surah_list/application/controllers/surah_list_controller.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import '../../application/controllers/word_by_word_provider.dart';
import '../../domain/entities/word_entity.dart';
import '../widgets/surah_header_title_capsule.dart';
import 'surah_dictionary_screen.dart';

/// Full-screen view displaying the word-by-word vocabulary of a specific Ayah,
/// with previous/next navigation, direct Ayah number picker, Surah switcher,
/// and a shortcut to the full Surah dictionary.
class AyahDictionaryScreen extends ConsumerStatefulWidget {
  final int surahId;
  final String surahName;
  final int ayahNumber;

  const AyahDictionaryScreen({
    super.key,
    required this.surahId,
    required this.surahName,
    required this.ayahNumber,
  });

  /// Static helper to push this screen onto the navigation stack
  static Future<void> open(
    BuildContext context, {
    required int surahId,
    required String surahName,
    required int ayahNumber,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AyahDictionaryScreen(
          surahId: surahId,
          surahName: surahName,
          ayahNumber: ayahNumber,
        ),
      ),
    );
  }

  @override
  ConsumerState<AyahDictionaryScreen> createState() =>
      _AyahDictionaryScreenState();
}

class _AyahDictionaryScreenState extends ConsumerState<AyahDictionaryScreen> {
  late int _currentSurahId;
  late int _currentAyahNumber;

  @override
  void initState() {
    super.initState();
    _currentSurahId = widget.surahId;
    _currentAyahNumber = widget.ayahNumber;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    final surahs = ref.watch(
      surahListControllerProvider.select((s) => s.surahs),
    );
    final surah = surahs.where((s) => s.number == _currentSurahId).firstOrNull;
    final totalAyahs = surah?.numberOfAyahs ?? 286;

    final wordsAsync = ref.watch(
      ayahWordsProvider((
        surahId: _currentSurahId,
        ayahNumber: _currentAyahNumber,
      )),
    );

    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final harakatColorHex = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.harakatColor),
    );
    final fontFamily = AppTypography.getFontFamilyByScript(fontScript);
    final harakatColor = ArabicTextHelper.parseHexColor(harakatColorHex);

    final baseArabicColor = colorScheme.onSurface;
    final baseArabicStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      height: 1.5,
      fontWeight: FontWeight.bold,
      color: baseArabicColor,
    );
    final bool useCustomColor =
        harakatColor != null && harakatColor != baseArabicColor;

    final surahDisplayName = surah?.nameFa ?? _currentSurahId.surahNameFa;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62.0),
        child: Container(
          padding: EdgeInsets.only(
            top: topPadding + 4.0,
            left: 10.0,
            right: 8.0,
            bottom: 6.0,
          ),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            border: Border(
              bottom: BorderSide(
                color: colors.cardBorder,
                width: 0.8,
              ),
            ),
          ),
          child: Row(
            children: [
              // Back Button (Apple-style chevron)
              IconButton(
                tooltip: 'بازگشت',
                icon: Icon(
                  CupertinoIcons.chevron_forward,
                  size: 24,
                  color: colorScheme.onSurface,
                ),
                splashRadius: 22,
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),

              const SizedBox(width: 8),

              // Interactive Surah Title Capsule (Unified with QuranReaderAppBar)
              Expanded(
                child: Center(
                  child: SurahHeaderTitleCapsule(
                    surahNumber: _currentSurahId,
                    surahName: 'سوره $surahDisplayName',
                    onTap: () async {
                      final selected = await SurahPickerDialog.show(
                        context,
                        title: 'انتخاب سوره لغت‌نامه',
                        activeSurah: surah,
                        surahs: surahs,
                      );
                      if (selected != null && mounted) {
                        setState(() {
                          _currentSurahId = selected.number;
                          _currentAyahNumber = 1;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Button to jump to full Surah Dictionary
              Tooltip(
                message: 'لغت‌نامه کامل سوره',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  splashRadius: 22,
                  icon: Icon(
                    CupertinoIcons.book,
                    size: 21,
                    color: colorScheme.primary,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SurahDictionaryScreen(
                          surahId: _currentSurahId,
                          surahName: surahDisplayName,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: wordsAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 12),
                Text(
                  'لغات این آیه هنوز در دیتابیس ثبت نشده است.\n$error',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(
                    ayahWordsProvider((
                      surahId: _currentSurahId,
                      ayahNumber: _currentAyahNumber,
                    )),
                  ),
                  child: const Text('تلاش مجدد'),
                ),
              ],
            ),
          ),
        ),
        data: (words) {
          if (words.isEmpty) {
            return Center(
              child: Text(
                'هیچ لغتی برای این آیه یافت نشد.',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            physics: const BouncingScrollPhysics(),
            itemCount: words.length,
            itemBuilder: (context, index) {
              return _AyahWordCard(
                word: words[index],
                baseArabicStyle: baseArabicStyle,
                baseArabicColor: baseArabicColor,
                harakatColor: harakatColor,
                useCustomColor: useCustomColor,
                isDark: isDark,
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          border: Border(
            top: BorderSide(
              color: colors.cardBorder,
              width: 0.8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Next Ayah Button (In RTL, Next is to the left / forward)
                TextButton.icon(
                  onPressed: _currentAyahNumber < totalAyahs
                      ? () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _currentAyahNumber++;
                          });
                        }
                      : null,
                  icon: const Icon(CupertinoIcons.chevron_forward, size: 16),
                  label: const Text(
                    'آیه بعدی',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                  ),
                ),

                // Center indicator with direct Ayah edit
                Material(
                  color: colorScheme.primary.withValues(
                    alpha: isDark ? 0.12 : 0.08,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => _promptDirectNumber(
                      context: context,
                      title: 'شماره آیه سوره $surahDisplayName',
                      currentVal: _currentAyahNumber,
                      minVal: 1,
                      maxVal: totalAyahs,
                      onSubmitted: (newAyah) {
                        setState(() {
                          _currentAyahNumber = newAyah;
                        });
                      },
                    ),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colorScheme.primary.withValues(
                            alpha: isDark ? 0.35 : 0.25,
                          ),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'آیه ${_currentAyahNumber.toPersianDigit()} از ${totalAyahs.toPersianDigit()}',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),

                // Previous Ayah Button (In RTL, Previous is to the right / back)
                TextButton.icon(
                  onPressed: _currentAyahNumber > 1
                      ? () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _currentAyahNumber--;
                          });
                        }
                      : null,
                  icon: const Icon(CupertinoIcons.chevron_back, size: 16),
                  label: const Text(
                    'آیه قبلی',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _promptDirectNumber({
    required BuildContext context,
    required String title,
    required int currentVal,
    required int minVal,
    required int maxVal,
    required ValueChanged<int> onSubmitted,
  }) {
    final textController = TextEditingController(text: currentVal.toPersianDigit());
    textController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: textController.text.length,
    );

    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        final primaryColor = theme.colorScheme.primary;
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            void submit() {
              final raw = textController.text.trim().toEnglishDigit();
              if (raw.isEmpty) {
                setDialogState(() {
                  errorMessage = 'لطفاً یک عدد وارد کنید';
                });
                HapticFeedback.heavyImpact();
                return;
              }
              final val = int.tryParse(raw);
              if (val == null) {
                setDialogState(() {
                  errorMessage = 'لطفاً یک عدد معتبر وارد کنید';
                });
                HapticFeedback.heavyImpact();
                return;
              }
              if (val < minVal || val > maxVal) {
                setDialogState(() {
                  errorMessage =
                      'عدد باید بین ${minVal.toPersianDigit()} تا ${maxVal.toPersianDigit()} باشد.';
                });
                HapticFeedback.heavyImpact();
                return;
              }

              Navigator.pop(ctx);
              onSubmitted(val);
            }

            return Dialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppModalHeader(
                        title: title,
                        onClose: () => Navigator.pop(ctx),
                        bottomSpacing: 12,
                      ),
                      TextField(
                        controller: textController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final converted = newValue.text.toPersianDigit();
                            return newValue.copyWith(
                              text: converted,
                              selection: newValue.selection,
                            );
                          }),
                        ],
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1C1B1B),
                        ),
                        onChanged: (text) {
                          final clean = text.trim().toEnglishDigit();
                          if (clean.isEmpty) {
                            if (errorMessage != null) {
                              setDialogState(() {
                                errorMessage = null;
                              });
                            }
                            return;
                          }
                          final val = int.tryParse(clean);
                          String? newError;
                          if (val == null) {
                            newError = 'لطفاً یک عدد معتبر وارد کنید';
                          } else if (val < minVal || val > maxVal) {
                            newError =
                                'عدد باید بین ${minVal.toPersianDigit()} تا ${maxVal.toPersianDigit()} باشد.';
                          }

                          if (newError != errorMessage) {
                            setDialogState(() {
                              errorMessage = newError;
                            });
                          }
                        },
                        onSubmitted: (_) => submit(),
                        decoration: InputDecoration(
                          hintText: '${minVal.toPersianDigit()} تا ${maxVal.toPersianDigit()}',
                          helperText: errorMessage == null
                              ? 'عدد بین ${minVal.toPersianDigit()} تا ${maxVal.toPersianDigit()} را وارد کنید'
                              : null,
                          helperStyle: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                          errorText: errorMessage,
                          errorMaxLines: 2,
                          errorStyle: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withValues(alpha: 0.07)
                              : const Color(0xFFF5F3EE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: errorMessage != null
                                  ? Colors.redAccent
                                  : (isDark ? Colors.white12 : Colors.black12),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: errorMessage != null
                                  ? Colors.redAccent
                                  : primaryColor,
                              width: 1.8,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                              width: 1.5,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      16.vSpace,
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(
                                'انصراف',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 14,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          12.hSpace,
                          Expanded(
                            child: ElevatedButton(
                              onPressed: submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 11,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'تأیید',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Detailed Word Card for Ayah Dictionary
class _AyahWordCard extends StatelessWidget {
  final WordEntity word;
  final TextStyle baseArabicStyle;
  final Color baseArabicColor;
  final Color? harakatColor;
  final bool useCustomColor;
  final bool isDark;

  const _AyahWordCard({
    required this.word,
    required this.baseArabicStyle,
    required this.baseArabicColor,
    required this.harakatColor,
    required this.useCustomColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.cardBorder,
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            HapticFeedback.selectionClick();
            Clipboard.setData(
              ClipboardData(text: '${word.arabicText} : ${word.translation}'),
            );
            AppSnackBar.showSuccess(
              context,
              '«${word.arabicText}» در حافظه کپی شد.',
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Word position indicator
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(
                      alpha: isDark ? 0.14 : 0.09,
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    word.position.toPersianDigit(),
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),

                12.hSpace,

                // Arabic Text (Right side)
                Expanded(
                  flex: 5,
                  child: useCustomColor
                      ? RichText(
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          text: TextSpan(
                            style: baseArabicStyle,
                            children: ArabicTextHelper.buildColoredSpans(
                              text: word.arabicText,
                              baseStyle: baseArabicStyle,
                              baseColor: baseArabicColor,
                              harakatColor: harakatColor!,
                            ),
                          ),
                        )
                      : Text(
                          word.arabicText,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: baseArabicStyle,
                        ),
                ),

                10.hSpace,

                // Separator arrow
                Icon(
                  CupertinoIcons.arrow_left,
                  size: 13,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),

                10.hSpace,

                // Persian Translation (Left side)
                Expanded(
                  flex: 6,
                  child: Text(
                    word.translation,
                    textAlign: TextAlign.left,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.88)
                          : const Color(0xFF2C3238),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
