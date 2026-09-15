import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/data/local/sqflite/sqflite_service_provider.dart';
import '../../../../core/services/quran_navigation/domain/entities/ayah_target.dart';
import '../../../../core/services/quran_navigation/quran_navigation_service_provider.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../surah_list/application/controllers/surah_list_controller.dart';
import '../../../surah_list/domain/entities/surah_entity.dart';
import '../../application/controllers/quran_reader_controller.dart';
import '../../domain/entities/ayah_entity.dart';

enum QuickJumpTab { surah, juz, hizb, page }

/// Live Interconnected Single-View Sheet for Quran Quick Jump.
/// Replaces multiple disconnected tabs with a unified, synchronized card
/// where Surah, Ayah, Page, and Juz stay in continuous bidirectional sync.
class QuranQuickJumpBottomSheet extends ConsumerStatefulWidget {
  final QuickJumpTab initialTab;

  const QuranQuickJumpBottomSheet({
    super.key,
    this.initialTab = QuickJumpTab.surah,
  });

  static Future<AyahTarget?> show(
    BuildContext context, {
    QuickJumpTab initialTab = QuickJumpTab.surah,
  }) {
    return showModalBottomSheet<AyahTarget>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: QuranQuickJumpBottomSheet(initialTab: initialTab),
      ),
    );
  }

  @override
  ConsumerState<QuranQuickJumpBottomSheet> createState() =>
      _QuranQuickJumpBottomSheetState();
}

class _QuranQuickJumpBottomSheetState
    extends ConsumerState<QuranQuickJumpBottomSheet> {
  bool _isInitialized = false;
  bool _isCalculating = false;
  bool _isSurahDropdownOpen = false;
  final TextEditingController _surahSearchController = TextEditingController();
  String _surahSearchQuery = '';

  // Interconnected Live State
  SurahEntity? _selectedSurah;
  int _currentAyahNumber = 1;
  int _currentPageNumber = 1;
  int _currentJuzNumber = 1;

  @override
  void dispose() {
    _surahSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = context.colorScheme;
    final surahs = ref.watch(surahListControllerProvider.select((s) => s.surahs));

    // Initialize from currently visible Ayah in reader or first surah
    if (!_isInitialized && surahs.isNotEmpty) {
      _isInitialized = true;
      _initFromReader(surahs);
    }

    final activeSurah = _selectedSurah ?? (surahs.isNotEmpty ? surahs.first : null);
    final maxAyahs = activeSurah?.numberOfAyahs ?? 7;

    // Card styling inspired by Hayat/Tafakor modular system
    final cardBg = isDark
        ? const Color(0xFF181717)
        : const Color(0xFFF7F5F0);

    final cardBorder = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE2DDD5);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: context.colors.dialogSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // 1. Drag Handle
              10.vSpace,
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              12.vSpace,

              // 2. Header Bar
              Row(
                children: [
                  const SizedBox(width: 44),
                  Expanded(
                    child: Text(
                      'پرش سریع در قرآن',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1C1B1B),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'بستن',
                    icon: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      size: 24,
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              14.vSpace,

              // 3. The Live Interconnected Trio Card
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cardBorder, width: 0.8),
                ),
                child: Column(
                  children: [
                    // ROW 1: Surah Selector
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _isSurahDropdownOpen = !_isSurahDropdownOpen;
                            if (!_isSurahDropdownOpen) {
                              _surahSearchController.clear();
                              _surahSearchQuery = '';
                            }
                          });
                        },
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.book,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              12.hSpace,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'سوره',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 11.5,
                                        color: isDark
                                            ? const Color(0xFF9E9E9E)
                                            : const Color(0xFF6E6D68),
                                      ),
                                    ),
                                    2.vSpace,
                                    Text(
                                      activeSurah != null
                                          ? '${activeSurah.number.toPersianDigit()}. سوره ${activeSurah.nameFa}'
                                          : 'انتخاب سوره...',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1C1B1B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: isDark ? 0.18 : 0.10,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${maxAyahs.toPersianDigit()} آیه',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                              8.hSpace,
                              AnimatedRotation(
                                turns: _isSurahDropdownOpen ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  CupertinoIcons.chevron_down,
                                  size: 16,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Inline Surah Dropdown
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: _buildInlineSurahDropdown(
                        context: context,
                        surahs: surahs,
                        activeSurah: activeSurah,
                        isDark: isDark,
                        cardBorder: cardBorder,
                        colorScheme: colorScheme,
                      ),
                      crossFadeState: _isSurahDropdownOpen
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 240),
                    ),

                    // Hairline Divider
                    Divider(
                      height: 1,
                      thickness: 0.6,
                      indent: 16,
                      endIndent: 16,
                      color: cardBorder,
                    ),

                    // ROW 2: Ayah Stepper
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.text_quote,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          12.hSpace,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'شماره آیه',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 11.5,
                                    color: isDark
                                        ? const Color(0xFF9E9E9E)
                                        : const Color(0xFF6E6D68),
                                  ),
                                ),
                                2.vSpace,
                                Text(
                                  'آیه ${_currentAyahNumber.toPersianDigit()}',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1C1B1B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildStepper(
                            currentVal: _currentAyahNumber,
                            minVal: 1,
                            maxVal: maxAyahs,
                            isDark: isDark,
                            primaryColor: colorScheme.primary,
                            onChanged: (newVal) => _updateAyah(newVal),
                            onTapDirectEdit: () => _promptDirectNumber(
                              context: context,
                              title: 'شماره آیه سوره ${activeSurah?.nameFa ?? ""}',
                              currentVal: _currentAyahNumber,
                              minVal: 1,
                              maxVal: maxAyahs,
                              onSubmitted: (val) => _updateAyah(val),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Hairline Divider
                    Divider(
                      height: 1,
                      thickness: 0.6,
                      indent: 16,
                      endIndent: 16,
                      color: cardBorder,
                    ),

                    // ROW 3: Page & Juz Interconnected Row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 12.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Page Card
                              Expanded(
                                child: _buildPageCard(
                                  currentPage: _currentPageNumber,
                                  isDark: isDark,
                                  primaryColor: colorScheme.primary,
                                  onTapEdit: () => _promptDirectNumber(
                                    context: context,
                                    title: 'شماره صفحه قرآن',
                                    currentVal: _currentPageNumber,
                                    minVal: 1,
                                    maxVal: 604,
                                    onSubmitted: (val) => _onPageChanged(val, surahs),
                                  ),
                                ),
                              ),
                              10.hSpace,

                              // Juz Card
                              Expanded(
                                child: _buildJuzCard(
                                  currentJuz: _currentJuzNumber,
                                  isDark: isDark,
                                  primaryColor: colorScheme.primary,
                                  onChanged: (newVal) => _onJuzChanged(newVal, surahs),
                                  onTapEdit: () => _promptDirectNumber(
                                    context: context,
                                    title: 'شماره جزء قرآن',
                                    currentVal: _currentJuzNumber,
                                    minVal: 1,
                                    maxVal: 30,
                                    onSubmitted: (val) => _onJuzChanged(val, surahs),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          10.vSpace,

                          // Page Scrubber Slider (۱ تا ۶۰۴)
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: colorScheme.primary,
                              inactiveTrackColor: colorScheme.primary.withValues(
                                alpha: isDark ? 0.20 : 0.15,
                              ),
                              thumbColor: colorScheme.primary,
                              overlayColor: colorScheme.primary.withValues(alpha: 0.18),
                              trackHeight: 3.5,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                            ),
                            child: Slider(
                              value: _currentPageNumber.toDouble().clamp(1.0, 604.0),
                              min: 1.0,
                              max: 604.0,
                              onChanged: (val) {
                                final page = val.round();
                                if (page != _currentPageNumber) {
                                  _onPageChanged(page, surahs);
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'صفحه ۱ (آغاز)',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 10,
                                    color: isDark ? Colors.white38 : Colors.black38,
                                  ),
                                ),
                                Text(
                                  'صفحه ۶۰۴ (پایان)',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 10,
                                    color: isDark ? Colors.white38 : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              20.vSpace,

              // 4. Primary Action Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isCalculating || activeSurah == null
                      ? null
                      : () => _handleConfirm(activeSurah),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                    ),
                    elevation: 0,
                  ),
                  icon: _isCalculating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(CupertinoIcons.paperplane_fill, size: 17),
                  label: Text(
                    _isCalculating
                        ? 'در حال انتقال...'
                        : 'انتقال به سوره ${activeSurah?.nameFa ?? ""}، آیه ${_currentAyahNumber.toPersianDigit()}',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                ),
              ),
              18.vSpace,
            ],
          ),
        ),
      ),
    ),
  );
}

  // --- Sub-widgets & Steppers ---

  Widget _buildStepper({
    required int currentVal,
    required int minVal,
    required int maxVal,
    required bool isDark,
    required Color primaryColor,
    required ValueChanged<int> onChanged,
    required VoidCallback onTapDirectEdit,
  }) {
    final canMinus = currentVal > minVal;
    final canPlus = currentVal < maxVal;

    final btnBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepperButton(
          icon: CupertinoIcons.minus,
          isEnabled: canMinus,
          btnBg: btnBg,
          isDark: isDark,
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(currentVal - 1);
          },
        ),
        8.hSpace,
        Material(
          color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTapDirectEdit,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: primaryColor.withValues(alpha: isDark ? 0.40 : 0.30),
                  width: 0.9,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.pencil,
                    size: 11.5,
                    color: primaryColor,
                  ),
                  4.hSpace,
                  Text(
                    currentVal.toPersianDigit(),
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        8.hSpace,
        _stepperButton(
          icon: CupertinoIcons.plus,
          isEnabled: canPlus,
          btnBg: btnBg,
          isDark: isDark,
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(currentVal + 1);
          },
        ),
      ],
    );
  }

  Widget _buildPageCard({
    required int currentPage,
    required bool isDark,
    required Color primaryColor,
    required VoidCallback onTapEdit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E5DF),
          width: 0.7,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'صفحه',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  color: isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6E6D68),
                ),
              ),
              Text(
                'از ۶۰۴',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
          6.vSpace,
          Material(
            color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onTapEdit,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: isDark ? 0.40 : 0.30),
                    width: 0.9,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.pencil,
                      size: 12,
                      color: primaryColor,
                    ),
                    4.hSpace,
                    Text(
                      'صفحه ${currentPage.toPersianDigit()}',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1C1B1B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          4.vSpace,
          Center(
            child: Text(
              'لمس جهت تایپ',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJuzCard({
    required int currentJuz,
    required bool isDark,
    required Color primaryColor,
    required ValueChanged<int> onChanged,
    required VoidCallback onTapEdit,
  }) {
    final canMinus = currentJuz > 1;
    final canPlus = currentJuz < 30;
    final btnBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E5DF),
          width: 0.7,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'جزء',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  color: isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6E6D68),
                ),
              ),
              Text(
                'از ۳۰',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
          6.vSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStepperButton(
                icon: CupertinoIcons.minus,
                isEnabled: canMinus,
                btnBg: btnBg,
                isDark: isDark,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(currentJuz - 1);
                },
              ),
              Material(
                color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: onTapEdit,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: isDark ? 0.40 : 0.30),
                        width: 0.9,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.pencil,
                          size: 11,
                          color: primaryColor,
                        ),
                        3.hSpace,
                        Text(
                          'جزء ${currentJuz.toPersianDigit()}',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1C1B1B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _miniStepperButton(
                icon: CupertinoIcons.plus,
                isEnabled: canPlus,
                btnBg: btnBg,
                isDark: isDark,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(currentJuz + 1);
                },
              ),
            ],
          ),
          4.vSpace,
          Center(
            child: Text(
              'پرش ۲۰ صفحه‌ای',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9.5,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepperButton({
    required IconData icon,
    required bool isEnabled,
    required Color btnBg,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isEnabled ? btnBg : btnBg.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            icon,
            size: 16,
            color: isEnabled
                ? (isDark ? Colors.white : Colors.black87)
                : (isDark ? Colors.white24 : Colors.black26),
          ),
        ),
      ),
    );
  }

  Widget _miniStepperButton({
    required IconData icon,
    required bool isEnabled,
    required Color btnBg,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isEnabled ? btnBg : btnBg.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 26,
          height: 26,
          child: Icon(
            icon,
            size: 13,
            color: isEnabled
                ? (isDark ? Colors.white : Colors.black87)
                : (isDark ? Colors.white24 : Colors.black26),
          ),
        ),
      ),
    );
  }

  // --- Logic & Synchronization ---

  void _initFromReader(List<SurahEntity> surahs) {
    final ayahs = ref.read(quranReaderControllerProvider.select((s) => s.ayahs));
    final itemPositionsListener = ref.read(activeItemPositionsListenerProvider);

    AyahEntity? currentAyah;
    if (ayahs.isNotEmpty) {
      int currentIndex = 0;
      if (itemPositionsListener != null) {
        final positions = itemPositionsListener.itemPositions.value;
        if (positions.isNotEmpty) {
          final visiblePositions = positions.where((p) => p.itemTrailingEdge > 0);
          if (visiblePositions.isNotEmpty) {
            currentIndex = visiblePositions
                .reduce((min, current) => current.index < min.index ? current : min)
                .index;
          }
        }
      }
      if (currentIndex >= 0 && currentIndex < ayahs.length) {
        currentAyah = ayahs[currentIndex];
      }
    }

    if (currentAyah != null) {
      final surahId = currentAyah.surahId;
      _selectedSurah = surahs.firstWhere(
        (s) => s.number == surahId,
        orElse: () => surahs.first,
      );
      _currentAyahNumber = currentAyah.ayahNumber;
      _currentPageNumber = currentAyah.page ?? _selectedSurah!.startPage;
      _currentJuzNumber = currentAyah.juz ?? _selectedSurah!.startJuz;
    } else {
      _selectedSurah = surahs.first;
      _currentAyahNumber = 1;
      _currentPageNumber = _selectedSurah!.startPage;
      _currentJuzNumber = _selectedSurah!.startJuz;
    }
  }

  Future<void> _updateAyah(int newAyah) async {
    setState(() {
      _currentAyahNumber = newAyah;
    });

    final surah = _selectedSurah;
    if (surah == null) return;

    // Fast path: check loaded ayahs in reader
    final ayahs = ref.read(quranReaderControllerProvider).ayahs;
    final match = ayahs.where((a) => a.surahId == surah.number && a.ayahNumber == newAyah).firstOrNull;
    if (match != null && match.page != null) {
      final page = match.page!;
      final calculatedJuz = page <= 1 ? 1 : (((page - 2) ~/ 20) + 1).clamp(1, 30);
      if (mounted) {
        setState(() {
          _currentPageNumber = page;
          _currentJuzNumber = match.juz ?? calculatedJuz;
        });
      }
      return;
    }

    // Database lookup
    try {
      final sqflite = ref.read(sqfliteServiceProvider);
      final res = await sqflite.rawQuery(
        'SELECT page, juz FROM ayahs WHERE surah_number = ? AND number_in_surah = ? LIMIT 1',
        [surah.number, newAyah],
      );
      if (res.isNotEmpty && mounted) {
        final page = res.first['page'] as int?;
        final juz = res.first['juz'] as int?;
        if (page != null) {
          final calculatedJuz = page <= 1 ? 1 : (((page - 2) ~/ 20) + 1).clamp(1, 30);
          setState(() {
            _currentPageNumber = page;
            _currentJuzNumber = juz ?? calculatedJuz;
          });
        }
      }
    } catch (_) {}
  }

  void _onSurahSelected(SurahEntity newSurah) {
    final calculatedJuz = newSurah.startPage <= 1
        ? 1
        : (((newSurah.startPage - 2) ~/ 20) + 1).clamp(1, 30);
    setState(() {
      _selectedSurah = newSurah;
      _currentAyahNumber = 1;
      _currentPageNumber = newSurah.startPage;
      _currentJuzNumber = newSurah.startJuz > 0 ? newSurah.startJuz : calculatedJuz;
    });
  }

  Future<void> _onPageChanged(int page, List<SurahEntity> surahs) async {
    final navService = ref.read(quranNavigationServiceProvider);
    final target = await navService.getTargetByPage(page);
    final calculatedJuz = page <= 1 ? 1 : (((page - 2) ~/ 20) + 1).clamp(1, 30);

    if (target != null && mounted) {
      final matchedSurah = surahs.firstWhere(
        (s) => s.number == target.surahId,
        orElse: () => _selectedSurah ?? surahs.first,
      );
      setState(() {
        _currentPageNumber = page;
        _selectedSurah = matchedSurah;
        _currentAyahNumber = target.ayahNumber;
        _currentJuzNumber = calculatedJuz;
      });
    } else if (mounted) {
      setState(() {
        _currentPageNumber = page;
        _currentJuzNumber = calculatedJuz;
      });
    }
  }

  Future<void> _onJuzChanged(int juz, List<SurahEntity> surahs) async {
    final navService = ref.read(quranNavigationServiceProvider);
    final target = await navService.getTargetByJuz(juz);
    final juzStartPage = juz <= 1 ? 1 : (juz - 1) * 20 + 2;

    if (target != null && mounted) {
      final matchedSurah = surahs.firstWhere(
        (s) => s.number == target.surahId,
        orElse: () => _selectedSurah ?? surahs.first,
      );
      setState(() {
        _currentJuzNumber = juz;
        _selectedSurah = matchedSurah;
        _currentAyahNumber = target.ayahNumber;
        _currentPageNumber = juzStartPage;
      });
    } else if (mounted) {
      setState(() {
        _currentJuzNumber = juz;
        _currentPageNumber = juzStartPage;
      });
    }
  }

  Future<void> _handleConfirm(SurahEntity surah) async {
    final navService = ref.read(quranNavigationServiceProvider);
    setState(() => _isCalculating = true);

    try {
      final target = await navService.getTargetBySurah(
        surah.number,
        ayahNumber: _currentAyahNumber,
      );

      if (mounted && target != null) {
        Navigator.pop(context, target);
      } else if (mounted) {
        AppSnackBar.showError(context, 'موقعیت مورد نظر یافت نشد.');
      }
    } finally {
      if (mounted) {
        setState(() => _isCalculating = false);
      }
    }
  }

  // --- Modals & Pickers ---

  Widget _buildInlineSurahDropdown({
    required BuildContext context,
    required List<SurahEntity> surahs,
    required SurahEntity? activeSurah,
    required bool isDark,
    required Color cardBorder,
    required ColorScheme colorScheme,
  }) {
    final normalized = _surahSearchQuery.normalizeForSearch();
    final filtered = surahs.where((s) {
      if (normalized.isEmpty) return true;
      return s.name.normalizeForSearch().contains(normalized) ||
          s.nameFa.normalizeForSearch().contains(normalized) ||
          s.englishName.normalizeForSearch().contains(normalized) ||
          s.number.toString() == normalized;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.22)
            : Colors.black.withValues(alpha: 0.025),
        border: Border(
          top: BorderSide(color: cardBorder, width: 0.6),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: CupertinoSearchTextField(
              controller: _surahSearchController,
              placeholder: 'جستجوی نام یا شماره سوره...',
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
                  _surahSearchQuery = val;
                });
              },
            ),
          ),

          // Scrollable Surah list
          SizedBox(
            height: 220,
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'سوره‌ای یافت نشد',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12.5,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  )
                : RawScrollbar(
                    thumbColor: colorScheme.primary.withValues(alpha: 0.4),
                    radius: const Radius.circular(4),
                    thickness: 3,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 40,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.black.withValues(alpha: 0.04),
                      ),
                      itemBuilder: (context, index) {
                        final s = filtered[index];
                        final isSelected = activeSurah?.number == s.number;

                        return Material(
                          color: isSelected
                              ? colorScheme.primary.withValues(alpha: isDark ? 0.16 : 0.08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _onSurahSelected(s);
                              setState(() {
                                _isSurahDropdownOpen = false;
                                _surahSearchController.clear();
                                _surahSearchQuery = '';
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? colorScheme.primary
                                          : (isDark
                                              ? Colors.white.withValues(alpha: 0.07)
                                              : Colors.black.withValues(alpha: 0.05)),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Text(
                                      s.number.toPersianDigit(),
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark ? Colors.white70 : Colors.black87),
                                      ),
                                    ),
                                  ),
                                  10.hSpace,
                                  Expanded(
                                    child: Text(
                                      'سوره ${s.nameFa}',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 13.5,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected
                                            ? colorScheme.primary
                                            : (isDark ? Colors.white : const Color(0xFF1C1B1B)),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${s.numberOfAyahs.toPersianDigit()} آیه • ص ${s.startPage.toPersianDigit()}',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 11,
                                      color: isDark ? Colors.white38 : Colors.black45,
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    8.hSpace,
                                    Icon(
                                      CupertinoIcons.checkmark_alt,
                                      color: colorScheme.primary,
                                      size: 16,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          6.vSpace,
        ],
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
    final textController = TextEditingController(text: currentVal.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            autofocus: true,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '$minVal تا $maxVal',
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : const Color(0xFFF2EFEB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                final raw = textController.text.trim().toEnglishDigit();
                final val = int.tryParse(raw);
                if (val != null && val >= minVal && val <= maxVal) {
                  Navigator.pop(ctx);
                  onSubmitted(val);
                } else {
                  AppSnackBar.showError(
                    ctx,
                    'عدد باید بین ${minVal.toPersianDigit()} تا ${maxVal.toPersianDigit()} باشد.',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('تأیید'),
            ),
          ],
        );
      },
    );
  }
}
