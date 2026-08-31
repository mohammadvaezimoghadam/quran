import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/extensions/size_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/prayer_times_controller.dart';

/// Modern City Selection Bottom Sheet with GPS Auto-Detection & Province Filter
class CitySelectionBottomSheet extends ConsumerStatefulWidget {
  const CitySelectionBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CitySelectionBottomSheet(),
    );
  }

  @override
  ConsumerState<CitySelectionBottomSheet> createState() =>
      _CitySelectionBottomSheetState();
}

class _CitySelectionBottomSheetState
    extends ConsumerState<CitySelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prayerTimesControllerProvider);
    final allCities = state.cities;

    // Filter cities based on search query
    final filteredCities = allCities.where((city) {
      return _searchQuery.isEmpty ||
          city.namePersian.contains(_searchQuery) ||
          city.province.contains(_searchQuery) ||
          city.nameEnglish.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final navBarPadding = MediaQuery.viewPaddingOf(context).bottom;
    final bottomSpacing = keyboardInset > 0
        ? keyboardInset + 16.0
        : (navBarPadding > 0 ? navBarPadding + 16.0 : 24.0);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(28),
          elevation: 8,
          shadowColor: Colors.black26,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              top: 20,
              bottom: bottomSpacing,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // Top Drag Handle & Header Title
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            14.vSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'انتخاب شهر و موقعیت',
                      style: AppTypography.sectionHeader.copyWith(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    4.vSpace,
                    Text(
                      'موقعیت خود را برای محاسبه دقیق اوقات شرعی انتخاب کنید',
                      style: AppTypography.captionText.copyWith(
                        color: AppColors.outline,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    if (context.canPop()) context.pop();
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            16.vSpace,

            // Search Field & Compact Circular GPS Button Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'جستجوی نام شهر یا استان...',
                      hintStyle: AppTypography.searchHint.copyWith(
                        color: AppColors.outline,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.primary, size: 22),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                ),
                10.hSpace,
                // Circular GPS Button
                Tooltip(
                  message: 'شناسایی خودکار موقعیت با GPS',
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: state.isLoading
                            ? null
                            : () async {
                                await ref
                                    .read(prayerTimesControllerProvider.notifier)
                                    .detectCurrentLocation();
                                if (context.mounted && context.canPop()) {
                                  context.pop();
                                }
                              },
                        child: Center(
                          child: state.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.my_location_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            14.vSpace,

            // 3. Cities List View
            Expanded(
              child: filteredCities.isEmpty
                  ? Center(
                      child: Text(
                        'شهری با این مشخصات یافت نشد.',
                        style: AppTypography.captionText.copyWith(
                          color: AppColors.outline,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredCities.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withValues(alpha: 0.3),
                      ),
                      itemBuilder: (context, index) {
                        final city = filteredCities[index];
                        final isSelected =
                            city.id == state.selectedCity?.id;

                        return ListTile(
                          onTap: () {
                            ref
                                .read(prayerTimesControllerProvider.notifier)
                                .selectCity(city);
                            if (context.canPop()) {
                              context.pop();
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.grey.shade100),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSelected
                                  ? Icons.location_on_rounded
                                  : Icons.location_city_rounded,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.outline,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            city.namePersian,
                            style: AppTypography.buttonLabel.copyWith(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            'استان ${city.province}',
                            style: AppTypography.captionText.copyWith(
                              fontSize: 11,
                              color: AppColors.outline,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                  size: 22,
                                )
                              : null,
                        );
                      },
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
