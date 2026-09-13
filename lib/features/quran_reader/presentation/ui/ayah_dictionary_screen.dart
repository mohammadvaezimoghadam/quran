import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../common/utils/arabic_text_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../surah_list/application/controllers/surah_list_controller.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import '../../application/controllers/word_by_word_provider.dart';
import '../../domain/entities/word_entity.dart';
import 'surah_dictionary_screen.dart';

/// Full-screen view displaying the word-by-word vocabulary of a specific Ayah,
/// with previous/next navigation and a shortcut to the full Surah dictionary.
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
  late int _currentAyahNumber;

  @override
  void initState() {
    super.initState();
    _currentAyahNumber = widget.ayahNumber;
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final surahs = ref.watch(
      surahListControllerProvider.select((s) => s.surahs),
    );
    final surah = surahs.where((s) => s.number == widget.surahId).firstOrNull;
    final totalAyahs = surah?.numberOfAyahs ?? 286;

    final wordsAsync = ref.watch(
      ayahWordsProvider((
        surahId: widget.surahId,
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

    final baseArabicColor =
        isDark ? AppColors.goldAccent : const Color(0xFF1E262C);
    final baseArabicStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      height: 1.5,
      fontWeight: FontWeight.bold,
      color: baseArabicColor,
    );
    final bool useCustomColor =
        harakatColor != null && harakatColor != baseArabicColor;

    final surahDisplayName = widget.surahName.isNotEmpty
        ? widget.surahName
        : widget.surahId.surahNameFa;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF141C1A) : const Color(0xFFF9F7F2),
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF192220) : Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: 10.0),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                customBorder: const CircleBorder(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : AppColors.primary.withValues(alpha: 0.08),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFFF4E0A5).withValues(alpha: 0.3)
                          : AppColors.primary.withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                  ),
                  child: Tooltip(
                    message: 'بازگشت',
                    child: Center(
                      child: Icon(
                        CupertinoIcons.chevron_forward,
                        size: 19,
                        color: isDark
                            ? const Color(0xFFF4E0A5)
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'لغت‌نامه آیه ${_currentAyahNumber.toPersianDigit()} $surahDisplayName',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF2C2A29),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SurahDictionaryScreen(
                      surahId: widget.surahId,
                      surahName: widget.surahName,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.book,
                      size: 20,
                      color: isDark ? AppColors.goldAccent : AppColors.primary,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'لغت‌نامه سوره',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.goldAccent : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: wordsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
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
                            surahId: widget.surahId,
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
          ),

          // Bottom Ayah Navigation Bar (Previous / Next Ayah)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF192220) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Next Ayah Button (In RTL, Next is to the left / forward)
                  TextButton.icon(
                    onPressed: _currentAyahNumber < totalAyahs
                        ? () {
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
                  ),

                  // Center indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentAyahNumber.toPersianDigit()} / ${totalAyahs.toPersianDigit()}',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),

                  // Previous Ayah Button
                  TextButton.icon(
                    onPressed: _currentAyahNumber > 1
                        ? () {
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2523) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFEBE7DF),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Clipboard.setData(
            ClipboardData(text: '${word.arabicText} : ${word.translation}'),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '«${word.arabicText}» در حافظه کپی شد',
                textDirection: TextDirection.rtl,
              ),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
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
                  color: isDark
                      ? AppColors.goldAccent.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  word.position.toPersianDigit(),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.goldAccent
                        : AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(width: 12),

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

              const SizedBox(width: 10),

              // Separator arrow
              Icon(
                CupertinoIcons.arrow_left,
                size: 14,
                color: isDark ? Colors.white24 : Colors.black26,
              ),

              const SizedBox(width: 10),

              // Persian Translation (Left side)
              Expanded(
                flex: 6,
                child: Text(
                  word.translation,
                  textAlign: TextAlign.left,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFDFE2E0) : const Color(0xFF2C3238),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
