import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/prayer_times_controller.dart';
import '../widgets/city_selection_bottom_sheet.dart';
import '../widgets/prayer_times_card.dart';

/// Full screen view for Prayer Times & Calendar Details
class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerTimesControllerProvider);
    final controller = ref.read(prayerTimesControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اوقات شرعی و تقویم',
          style: AppTypography.appBarTitle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.location_solid),
            tooltip: 'تغییر شهر',
            onPressed: () => CitySelectionBottomSheet.show(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.marginPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Home Card Representation
            const PrayerTimesCard(),
            AppDimens.stackLg.vSpace,

            // Calendar Hijri Adjustment Settings Section
            Card(
              elevation: 0,
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                side: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.gutterGrid),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          color: AppColors.primary,
                          size: AppDimens.iconSm,
                        ),
                        SizedBox(width: AppDimens.stackXs),
                        Text(
                          'تعدیل تقویم قمری',
                          style: AppTypography.cardHeader,
                        ),
                      ],
                    ),
                    8.vSpace,
                    Text(
                      'در صورت اختلاف یک یا دو روزه روئیت هلال ماه، انحراف تقویم را تنظیم کنید:',
                      style: AppTypography.captionText,
                    ),
                    12.vSpace,

                    // Segmented Selector for Hijri adjustment (-2 to +2 days)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [-2, -1, 0, 1, 2].map((days) {
                        final isSelected = state.hijriAdjustment == days;
                        final label = days == 0
                            ? 'بدون تغییر'
                            : (days > 0
                                ? '+${days.toString().toPersianDigit()} روز'
                                : '${days.toString().toPersianDigit()} روز');

                        return ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontSize: 12,
                          ),
                          onSelected: (_) {
                            controller.setHijriAdjustment(days);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
