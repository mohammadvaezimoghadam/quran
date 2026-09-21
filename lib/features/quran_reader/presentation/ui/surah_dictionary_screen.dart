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
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../common/widgets/surah_picker_dialog.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../surah_list/application/controllers/surah_list_controller.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import '../../application/controllers/word_by_word_provider.dart';
import '../../domain/entities/word_entity.dart';
import '../widgets/surah_header_title_capsule.dart';

/// Clean Apple-style screen displaying the entire word-by-word vocabulary of a Surah.
/// Features real-time search, instant Surah switching, and high-contrast typography.
class SurahDictionaryScreen extends ConsumerStatefulWidget {
  final int surahId;
  final String surahName;

  const SurahDictionaryScreen({
    super.key,
    required this.surahId,
    required this.surahName,
  });

  @override
  ConsumerState<SurahDictionaryScreen> createState() =>
      _SurahDictionaryScreenState();
}

class _SurahDictionaryScreenState extends ConsumerState<SurahDictionaryScreen> {
  late int _currentSurahId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentSurahId = widget.surahId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    final surahs = ref.watch(surahListControllerProvider.select((s) => s.surahs));
    final currentSurah = surahs.where((s) => s.number == _currentSurahId).firstOrNull;

    // Load pre-grouped words for the active Surah
    final groupedWordsAsync = ref.watch(surahDictionaryGroupedProvider(_currentSurahId));

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
      fontSize: 20,
      height: 1.4,
      fontWeight: FontWeight.bold,
      color: baseArabicColor,
    );
    final bool useCustomColor =
        harakatColor != null && harakatColor != baseArabicColor;

    final topPadding = MediaQuery.of(context).padding.top;
    final surahDisplayName = currentSurah?.nameFa ?? _currentSurahId.surahNameFa;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(118.0),
        child: Container(
          padding: EdgeInsets.only(
            top: topPadding + 4.0,
            left: 14.0,
            right: 8.0,
            bottom: 8.0,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row 1: Back Button + Surah Selector + Surah Switcher Pill
              SizedBox(
                height: 48,
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
                              activeSurah: currentSurah,
                              surahs: surahs,
                            );
                            if (selected != null && mounted) {
                              setState(() {
                                _currentSurahId = selected.number;
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    // Balance spacer so capsule is centered (48px like back button)
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              6.vSpace,

              // Row 2: Search Bar
              CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'جستجوی کلمه عربی یا ترجمه فارسی...',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                placeholderStyle: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12.5,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: groupedWordsAsync.when(
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
                    'خطا در دریافت اطلاعات لغت‌نامه:\n$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(
                      surahDictionaryGroupedProvider(_currentSurahId),
                    ),
                    child: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            ),
          ),
          data: (ayahGroups) {
            if (ayahGroups.isEmpty) {
              return const Center(
                child: Text(
                  'هیچ لغتی برای این سوره یافت نشد.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              );
            }

            // Real-time search filtering
            final query = _searchQuery.normalizeForSearch();
            final filteredGroups = query.isEmpty
                ? ayahGroups
                : ayahGroups
                    .map((group) {
                      final matches = group.words.where((w) {
                        return w.arabicText.normalizeForSearch().contains(query) ||
                            w.translation.normalizeForSearch().contains(query) ||
                            group.ayahNumber.toString() == query ||
                            group.ayahNumber.toPersianDigit() == query;
                      }).toList();
                      return SurahAyahWords(
                        ayahNumber: group.ayahNumber,
                        words: matches,
                      );
                    })
                    .where((group) => group.words.isNotEmpty)
                    .toList();

            if (filteredGroups.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.search,
                      size: 42,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                    12.vSpace,
                    Text(
                      'کلمه‌ای با مشخصات جستجو یافت نشد.',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13.5,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                    8.vSpace,
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: Text(
                        'پاک کردن جستجو',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredGroups.length,
              itemBuilder: (context, index) {
                final group = filteredGroups[index];
                final ayahWords = group.words;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.cardBorder,
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Ayah Header Banner
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(
                            alpha: isDark ? 0.12 : 0.07,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                              ),
                              child: Text(
                                'آیه ${group.ayahNumber.toPersianDigit()}',
                                style: const TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${ayahWords.length.toPersianDigit()} کلمه',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 11.5,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Words List
                      Column(
                        children: [
                          for (int i = 0; i < ayahWords.length; i++) ...[
                            if (i > 0)
                              Divider(
                                height: 1,
                                thickness: 0.6,
                                color: colors.cardBorder,
                              ),
                            _WordRow(
                              word: ayahWords[i],
                              isEven: i % 2 == 0,
                              baseArabicStyle: baseArabicStyle,
                              baseArabicColor: baseArabicColor,
                              harakatColor: harakatColor,
                              useCustomColor: useCustomColor,
                              isDark: isDark,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Clean, responsive vocabulary row widget
class _WordRow extends StatelessWidget {
  final WordEntity word;
  final bool isEven;
  final TextStyle baseArabicStyle;
  final Color baseArabicColor;
  final Color? harakatColor;
  final bool useCustomColor;
  final bool isDark;

  const _WordRow({
    required this.word,
    required this.isEven,
    required this.baseArabicStyle,
    required this.baseArabicColor,
    required this.harakatColor,
    required this.useCustomColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isEven
          ? Colors.transparent
          : (isDark
              ? Colors.white.withValues(alpha: 0.02)
              : Colors.black.withValues(alpha: 0.015)),
      child: InkWell(
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
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Arabic Word (Right side)
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

              const SizedBox(width: 8),

              // Subtle arrow icon
              Icon(
                CupertinoIcons.arrow_left,
                size: 12,
                color: isDark ? Colors.white24 : Colors.black26,
              ),

              const SizedBox(width: 8),

              // Persian Translation (Left side)
              Expanded(
                flex: 6,
                child: Text(
                  word.translation,
                  textAlign: TextAlign.left,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13.5,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.88)
                        : const Color(0xFF3E3B38),
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
