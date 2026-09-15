import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../quran_reader/application/controllers/quran_display_settings_controller.dart';

import '../../../../../common/extensions/context_extension.dart';
import '../../../../../common/extensions/int_extension.dart';
import '../../../../../common/extensions/size_extension.dart';
import '../../../../../common/extensions/surah_name_extension.dart';
import '../../../../../core/routes/route_name.dart';
import '../../../../../core/theme/app_typography.dart';

import '../../../application/states/continue_reading_state.dart';

/// Sacred Minimalist "Continue Reading" Widget (ویجت ادامه خواندن)
/// Pixel-perfect implementation matching the reference UI design.
class ContinueReadingCard extends ConsumerStatefulWidget {
  final ContinueReadingState? autoState;
  final ContinueReadingState? bookmarkState;

  const ContinueReadingCard({super.key, this.autoState, this.bookmarkState});

  @override
  ConsumerState<ContinueReadingCard> createState() =>
      _ContinueReadingCardState();
}

class _ContinueReadingCardState extends ConsumerState<ContinueReadingCard> {
  late final ValueNotifier<int> _selectedTabNotifier;

  @override
  void initState() {
    super.initState();
    int initial = 0;
    if (widget.autoState == null && widget.bookmarkState != null) {
      initial = 1;
    }
    _selectedTabNotifier = ValueNotifier<int>(initial);
  }

  @override
  void didUpdateWidget(ContinueReadingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasBoth = widget.autoState != null && widget.bookmarkState != null;
    if (!hasBoth) {
      if (widget.autoState != null) {
        _selectedTabNotifier.value = 0;
      } else if (widget.bookmarkState != null) {
        _selectedTabNotifier.value = 1;
      }
    }
  }

  @override
  void dispose() {
    _selectedTabNotifier.dispose();
    super.dispose();
  }

  void _onCardTap() {
    final state = _selectedTabNotifier.value == 0
        ? widget.autoState
        : widget.bookmarkState;
    if (state != null) {
      ref
          .read(quranDisplaySettingsControllerProvider.notifier)
          .toggleArabicText(true);
      Future.microtask(() {
        if (mounted) {
          context.pushNamed(
            quranReaderRoute,
            pathParameters: {'id': state.surahId.toString()},
            queryParameters: {
              'name': state.surahName,
              'ayah': state.ayahNumber.toString(),
            },
          );
        }
      });
    } else {
      if (_selectedTabNotifier.value == 0) {
        // Start reading from Surah Al-Fatihah
        ref
            .read(quranDisplaySettingsControllerProvider.notifier)
            .toggleArabicText(true);
        context.pushNamed(
          quranReaderRoute,
          pathParameters: {'id': '1'},
          queryParameters: {'name': 'الفاتحة', 'ayah': '1'},
        );
      } else {
        // Go to Surah List
        context.pushNamed(surahListRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    // Theme-Aware Colors (Apple Minimalist & Tafakor Mint Green)
    final cardBgColor = colors.cardBackground;
    final cardBorderColor = colors.cardBorder;

    final primaryColor = colorScheme.primary;
    final titleColor = colorScheme.onSurface;
    final subtitleColor = colorScheme.onSurfaceVariant;

    final buttonBgColor = colorScheme.primary;
    final buttonTextColor = Colors.white;
    final gaugeColor = colorScheme.primary;

    return ValueListenableBuilder<int>(
      valueListenable: _selectedTabNotifier,
      builder: (context, selectedTab, child) {
        final state = selectedTab == 0
            ? widget.autoState
            : widget.bookmarkState;
        final isEmpty = state == null;

        final double progress = (state != null && state.totalAyahs > 0)
            ? (state.ayahNumber / state.totalAyahs).clamp(0.0, 1.0)
            : 0.0;
        final String ayahInfoText = state != null
            ? 'آیه ${state.ayahNumber.toPersianDigit()} از ${state.totalAyahs.toPersianDigit()}'
            : (selectedTab == 0
                  ? 'هنوز مطالعه‌ای ثبت نشده است'
                  : 'هنوز نشانکی ثبت نشده است');

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Compact Cupertino-style Tabs at the top
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : colorScheme.surfaceContainerHigh.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(3.5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSegmentTab(
                      title: 'آخرین مطالعه',
                      icon: CupertinoIcons.clock,
                      isSelected: selectedTab == 0,
                      onTap: () => _selectedTabNotifier.value = 0,
                      activeColor: primaryColor,
                      inactiveColor: subtitleColor,
                      isDark: isDark,
                    ),
                    _buildSegmentTab(
                      title: 'آخرین نشانک',
                      icon: CupertinoIcons.bookmark,
                      isSelected: selectedTab == 1,
                      onTap: () => _selectedTabNotifier.value = 1,
                      activeColor: primaryColor,
                      inactiveColor: subtitleColor,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
            12.vSpace,

            // The Slim Card
            Container(
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: cardBorderColor, width: 0.8),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8.0,
                          offset: const Offset(0, 2.0),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16.0),
                child: InkWell(
                  onTap: _onCardTap,
                  borderRadius: BorderRadius.circular(16.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 1. Right Side (RTL): Progress or Empty Icon
                        if (!isEmpty)
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(end: progress),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            builder: (context, animatedProgress, child) {
                              final int animatedPercent =
                                  (animatedProgress * 100).toInt();
                              final String animatedPercentText =
                                  '${animatedPercent.toPersianDigit()}%';

                              return SizedBox(
                                width: 54,
                                height: 54,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: CircularProgressIndicator(
                                        value: animatedProgress,
                                        strokeWidth: 4.5,
                                        backgroundColor: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.10,
                                              )
                                            : cardBorderColor,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              gaugeColor,
                                            ),
                                        strokeCap: StrokeCap.round,
                                      ),
                                    ),
                                    Text(
                                      animatedPercentText,
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: gaugeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        else
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: gaugeColor.withValues(
                                alpha: isDark ? 0.15 : 0.08,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: gaugeColor.withValues(alpha: 0.25),
                                width: 1.2,
                              ),
                            ),
                            child: Icon(
                              selectedTab == 0
                                  ? CupertinoIcons.book
                                  : CupertinoIcons.bookmark,
                              color: gaugeColor,
                              size: 22,
                            ),
                          ),
                        14.hSpace,

                        // 2. Middle: Texts
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                !isEmpty
                                    ? 'سوره ${state.surahId.surahNameFa}'
                                    : (selectedTab == 0
                                          ? 'شروع قرائت قرآن'
                                          : 'افزودن نشانک'),
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: titleColor,
                                  height: 1.2,
                                ),
                              ),
                              4.vSpace,
                              Text(
                                ayahInfoText,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: subtitleColor,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 3. Left Side: Action Button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: buttonBgColor,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: buttonBgColor.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                !isEmpty
                                    ? 'ادامه'
                                    : (selectedTab == 0 ? 'شروع' : 'سوره‌ها'),
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: buttonTextColor,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                CupertinoIcons.chevron_back,
                                size: 14,
                                color: buttonTextColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSegmentTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
    required Color inactiveColor,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? activeColor
                  : inactiveColor.withValues(alpha: 0.6),
            ),
            5.hSpace,
            Text(
              title,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? activeColor
                    : inactiveColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
