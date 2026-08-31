import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../../../common/widgets/app_loading_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/prayer_times_controller.dart';
import '../../application/services/prayer_times_calculator_service.dart';
import '../../domain/entities/prayer_times_entity.dart';
import 'city_selection_bottom_sheet.dart';

/// Bade Saba Style Premium Calendar & Prayer Times Card
class PrayerTimesCard extends ConsumerStatefulWidget {
  const PrayerTimesCard({super.key});

  @override
  ConsumerState<PrayerTimesCard> createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends ConsumerState<PrayerTimesCard> {
  bool _isMonthExpanded = false;
  static const int _initialPage = 10000;
  late final PageController _weeklyPageController;
  late final PageController _monthlyPageController;

  @override
  void initState() {
    super.initState();
    _weeklyPageController = PageController(initialPage: _initialPage);
    _monthlyPageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _weeklyPageController.dispose();
    _monthlyPageController.dispose();
    super.dispose();
  }

  Jalali _addJalaliMonths(Jalali base, int monthsToAdd) {
    int totalMonths = (base.year * 12 + base.month - 1) + monthsToAdd;
    int newYear = totalMonths ~/ 12;
    int newMonth = (totalMonths % 12) + 1;
    int daysInNewMonth = Jalali(newYear, newMonth, 1).monthLength;
    int newDay = base.day.clamp(1, daysInNewMonth);
    return Jalali(newYear, newMonth, newDay);
  }

  final List<String> _weekDaysFa = [
    'شنبه',
    'یک‌شنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'جمعه'
  ];

  /// Persian weekday index (0 = Saturday ... 6 = Friday)
  int _persianWeekdayIndex(DateTime dt) {
    return (dt.weekday % 7 + 1) % 7;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prayerTimesControllerProvider);
    final controller = ref.read(prayerTimesControllerProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    if (state.isLoading) {
      return const _CardWrapper(
        height: 240,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppLoadingIndicator(),
              SizedBox(height: AppDimens.stackSm),
              Text(
                'در حال دریافت اطلاعات تقویم و اوقات شرعی...',
                style: AppTypography.statusMessage,
              ),
            ],
          ),
        ),
      );
    }

    if (state.errorMessage != null) {
      return _CardWrapper(
        height: 200,
        isError: true,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_triangle,
                color: AppColors.error,
                size: AppDimens.iconMd,
              ),
              6.vSpace,
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTypography.statusMessage
                    .copyWith(color: AppColors.error),
              ),
              8.vSpace,
              SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: () => controller.loadInitialData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.gutterGrid,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                    ),
                  ),
                  icon:
                      const Icon(CupertinoIcons.refresh, size: AppDimens.iconXs),
                  label: const Text(
                    AppConstants.retryButtonLabel,
                    style: AppTypography.buttonLabel,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final prayerTimes = state.prayerTimes;
    final selectedCity = state.selectedCity;
    if (prayerTimes == null || selectedCity == null) {
      return const SizedBox.shrink();
    }

    final selectedDate = state.selectedDate ?? DateTime.now();
    final today = DateTime.now();
    final jalali = Jalali.fromDateTime(selectedDate);
    final gregorianStr = DateFormat('d MMMM yyyy').format(selectedDate);
    final dayOfWeekFa = _getPersianDayOfWeekName(selectedDate);

    final nextPrayerType = prayerTimes.getNextPrayerType();
    final isTodaySelected = _isSameDay(selectedDate, today);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Calendar Card (Top Box)
        _CardWrapper(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bade Saba Top Calendar Header (Clean Shamsi Month/Year without directional buttons)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Side: Shamsi Month/Year + Gregorian Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getShamsiMonthName(jalali.month)} ${jalali.year.toString().toPersianDigit()}',
                          style: AppTypography.cardHeader.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        2.vSpace,
                        Text(
                          gregorianStr,
                          style: AppTypography.captionText.copyWith(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center Circle: Large Shamsi Day Number
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondaryContainer.withValues(alpha: 0.9),
                          AppColors.goldMetallic,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColors.goldMetallic.withValues(alpha: 0.35),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        jalali.day.toString().toPersianDigit(),
                        style: AppTypography.cardHeader.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  // Right Side: Day of Week + Hijri Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          dayOfWeekFa,
                          style: AppTypography.cardHeader.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        2.vSpace,
                        Text(
                          prayerTimes.hijriDate,
                          textAlign: TextAlign.right,
                          style: AppTypography.captionText.copyWith(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              14.vSpace,

              // Weekly Day Strip / Expandable Month Grid Box (Fixed height grid on month changes)
              // Weekly Day Strip / Expandable Month Grid Box with Interactive PageView
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusDefault),
                    ),
                    child: Column(
                      children: [
                        // Weekday Titles Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _weekDaysFa.map((dayName) {
                            return Expanded(
                              child: Text(
                                dayName,
                                textAlign: TextAlign.center,
                                style: AppTypography.captionText.copyWith(
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        6.vSpace,

                        // Interactive Smooth PageView for Calendar Paging
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: _isMonthExpanded ? 210 : 36,
                          child: PageView.builder(
                            controller: _isMonthExpanded
                                ? _monthlyPageController
                                : _weeklyPageController,
                            physics: const BouncingScrollPhysics(),
                            onPageChanged: (pageIndex) {
                              final offset = pageIndex - _initialPage;
                              if (_isMonthExpanded) {
                                final targetJalali = _addJalaliMonths(
                                    Jalali.fromDateTime(today), offset);
                                controller.changeDate(targetJalali.toDateTime());
                              } else {
                                final targetDate =
                                    today.add(Duration(days: offset * 7));
                                controller.changeDate(targetDate);
                              }
                            },
                            itemBuilder: (context, index) {
                              final offset = index - _initialPage;
                              if (_isMonthExpanded) {
                                final targetJalali = _addJalaliMonths(
                                    Jalali.fromDateTime(today), offset);
                                return _buildMonthlyCalendarGrid(
                                    targetJalali, selectedDate, today, controller);
                              } else {
                                final targetDate =
                                    today.add(Duration(days: offset * 7));
                                return _buildWeeklyDayStrip(
                                    targetDate, today, controller);
                              }
                            },
                          ),
                        ),
                        2.vSpace,

                        // Center Chevron Expand/Collapse Button
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isMonthExpanded = !_isMonthExpanded;
                            });
                          },
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusSm),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 16.0),
                            child: Icon(
                              _isMonthExpanded
                                  ? CupertinoIcons.chevron_up
                                  : CupertinoIcons.chevron_down,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Compact Cupertino Today Button positioned at bottom-left corner of calendar box
                  if (!isTodaySelected)
                    Positioned(
                      left: 6,
                      bottom: 4,
                      child: Tooltip(
                        message: 'بازگشت به امروز',
                        child: InkWell(
                          onTap: () {
                            controller.changeDate(today);
                            if (_isMonthExpanded) {
                              _monthlyPageController.animateToPage(
                                _initialPage,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _weeklyPageController.animateToPage(
                                _initialPage,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(13),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Icon(
                              CupertinoIcons.arrow_counterclockwise,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        12.vSpace,

        // 2. Separate Standalone Prayer Times Card (Pure Theme Green Background, Horizon Header + Prayer Row)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.gutterGrid,
            vertical: AppDimens.cardPaddingVertical,
          ),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.primaryContainer : AppColors.primary,
            borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 16.0,
                      spreadRadius: -4.0,
                      offset: const Offset(0, 8.0),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Horizon Header ("افق [شهر] >")
              InkWell(
                onTap: () => CitySelectionBottomSheet.show(context),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.sun_max_fill,
                        color: AppColors.goldMetallic,
                        size: 16,
                      ),
                      6.hSpace,
                      Text(
                        'افق ${selectedCity.namePersian}',
                        style: AppTypography.cardHeader.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      4.hSpace,
                      const Icon(
                        CupertinoIcons.chevron_left,
                        color: Colors.white70,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
              8.vSpace,

              // Single-Row Grid of 8 Prayer Times (Direct Row without inner container wrapper)
              Row(
                children: PrayerType.values.map((type) {
                  final isNext = type == nextPrayerType && isTodaySelected;
                  final time = prayerTimes.getTimeForType(type);
                  final timeStr =
                      PrayerTimesCalculatorService.formatTimeString(time);

                  return Expanded(
                    child: _BadeSabaPrayerColumn(
                      title: type.titleFa,
                      timeStr: timeStr,
                      isNext: isNext,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds 7-day horizontal weekly strip
  Widget _buildWeeklyDayStrip(
    DateTime selectedDate,
    DateTime today,
    PrayerTimesController controller,
  ) {
    final dayOffset = _persianWeekdayIndex(selectedDate);
    final saturday = selectedDate.subtract(Duration(days: dayOffset));

    final weekDays = List.generate(7, (i) => saturday.add(Duration(days: i)));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((dt) {
        final j = Jalali.fromDateTime(dt);
        final isSelected = _isSameDay(dt, selectedDate);
        final isToday = _isSameDay(dt, today);

        return Expanded(
          child: InkWell(
            onTap: () => controller.changeDate(dt),
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isToday
                    ? Colors.redAccent.withValues(alpha: 0.9)
                    : (isSelected
                        ? AppColors.goldMetallic
                        : Colors.transparent),
              ),
              child: Center(
                child: Text(
                  j.day.toString().toPersianDigit(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: (isToday || isSelected)
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: (isToday || isSelected)
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Builds 42-cell (6 rows x 7 days) fixed-size monthly calendar grid matching Bade Saba layout
  Widget _buildMonthlyCalendarGrid(
    Jalali jalali,
    DateTime selectedDate,
    DateTime today,
    PrayerTimesController controller,
  ) {
    final firstDayOfMonthJalali = Jalali(jalali.year, jalali.month, 1);
    final firstDayOfMonthDt = firstDayOfMonthJalali.toDateTime();
    final startPadding = _persianWeekdayIndex(firstDayOfMonthDt);
    final daysInMonth = jalali.monthLength;

    // Always 42 cells (6 rows x 7 days) so the container height stays 100% fixed on month changes
    const totalCells = 42;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        if (index < startPadding || index >= startPadding + daysInMonth) {
          return const SizedBox.shrink();
        }

        final dayNum = index - startPadding + 1;
        final cellJalali = Jalali(jalali.year, jalali.month, dayNum);
        final cellDt = cellJalali.toDateTime();

        final isSelected = _isSameDay(cellDt, selectedDate);
        final isToday = _isSameDay(cellDt, today);

        return InkWell(
          onTap: () => controller.changeDate(cellDt),
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isToday
                  ? Colors.redAccent.withValues(alpha: 0.9)
                  : (isSelected ? AppColors.goldMetallic : Colors.transparent),
            ),
            child: Text(
              dayNum.toString().toPersianDigit(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: (isToday || isSelected)
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: (isToday || isSelected)
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getPersianDayOfWeekName(DateTime dt) {
    const days = [
      'دوشنبه',
      'سه‌شنبه',
      'چهارشنبه',
      'پنج‌شنبه',
      'جمعه',
      'شنبه',
      'یک‌شنبه'
    ];
    return days[dt.weekday - 1];
  }

  String _getShamsiMonthName(int month) {
    const months = [
      'فروردین',
      'اردیبهشت',
      'خرداد',
      'تیر',
      'مرداد',
      'شهریور',
      'مهر',
      'آبان',
      'آذر',
      'دی',
      'بهمن',
      'اسفند'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}

/// Single Prayer Column Item matching Bade Saba row layout
class _BadeSabaPrayerColumn extends StatelessWidget {
  final String title;
  final String timeStr;
  final bool isNext;

  const _BadeSabaPrayerColumn({
    required this.title,
    required this.timeStr,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      decoration: BoxDecoration(
        color: isNext
            ? AppColors.goldMetallic.withValues(alpha: 0.25)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: isNext
            ? Border.all(color: AppColors.goldMetallic, width: 1)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.captionText.copyWith(
                fontSize: 11,
                color: isNext ? AppColors.softGoldText : Colors.white70,
                fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          4.vSpace,
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              timeStr.toPersianDigit(),
              textAlign: TextAlign.center,
              style: AppTypography.sectionHeader.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color:
                    isNext ? Colors.white : Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Private Card Container Wrapper with theme-aware gradient & Islamic pattern
class _CardWrapper extends StatelessWidget {
  final Widget child;
  final double? height;
  final bool isError;

  const _CardWrapper({
    required this.child,
    this.height,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final gradientColors = isError
        ? [colorScheme.errorContainer, colorScheme.errorContainer]
        : (isDark
            ? [colorScheme.primaryContainer, const Color(0xFF0D2B22)]
            : [AppColors.primary, AppColors.primaryContainer]);

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: (isError ? colorScheme.error : AppColors.primary)
                      .withValues(alpha: 0.14),
                  blurRadius: 24.0,
                  spreadRadius: -8.0,
                  offset: const Offset(0, 12.0),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        child: Stack(
          children: [
            if (!isError)
              Positioned.fill(
                child: Opacity(
                  opacity: isDark ? 0.35 : 0.55,
                  child: const Image(
                    image: AssetImage(AppConstants.ayahCardBgAsset),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.gutterGrid,
                vertical: AppDimens.cardPaddingVertical,
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
