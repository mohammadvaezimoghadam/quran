import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/string_extension.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../../surah_list/application/controllers/surah_list_controller.dart';
import '../../../surah_list/domain/entities/surah_entity.dart';
import '../../application/controllers/pinned_surah_controller.dart';
import '../../application/controllers/quick_access_controller.dart';

/// Bottom sheet for selecting a pinned surah for quick access or dictionary
class PinnedSurahPickerBottomSheet extends ConsumerStatefulWidget {
  final int? slotIndex;
  final String? title;
  final String? subtitle;
  final IconData? iconData;
  final bool autoSavePinned;

  const PinnedSurahPickerBottomSheet({
    super.key,
    this.slotIndex,
    this.title,
    this.subtitle,
    this.iconData,
    this.autoSavePinned = true,
  });

  static Future<SurahEntity?> show(
    BuildContext context, {
    int? slotIndex,
    String? title,
    String? subtitle,
    IconData? iconData,
    bool autoSavePinned = true,
  }) {
    return showModalBottomSheet<SurahEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: PinnedSurahPickerBottomSheet(
          slotIndex: slotIndex,
          title: title,
          subtitle: subtitle,
          iconData: iconData,
          autoSavePinned: autoSavePinned,
        ),
      ),
    );
  }

  @override
  ConsumerState<PinnedSurahPickerBottomSheet> createState() =>
      _PinnedSurahPickerBottomSheetState();
}

class _PinnedSurahPickerBottomSheetState
    extends ConsumerState<PinnedSurahPickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final arabicFontFamily = AppTypography.getFontFamilyByScript(fontScript);

    final surahs = ref.watch(surahListControllerProvider.select((s) => s.surahs));
    final currentPinnedId = widget.slotIndex != null
        ? ref.watch(quickAccessControllerProvider).slots[widget.slotIndex!]?.surahId
        : ref.watch(pinnedSurahIdProvider);

    final normalizedQuery = _searchQuery.normalizeForSearch();

    final filteredSurahs = surahs.where((surah) {
      if (normalizedQuery.isEmpty) return true;
      final normalizedName = surah.name.normalizeForSearch();
      final normalizedEnglish = surah.englishName.normalizeForSearch();
      final numberStr = surah.number.toString();
      final persianNumberStr = numberStr.toPersianDigit();

      return normalizedName.contains(normalizedQuery) ||
          normalizedEnglish.contains(normalizedQuery) ||
          numberStr.contains(normalizedQuery) ||
          persianNumberStr.contains(normalizedQuery);
    }).toList();

    final sheetBgColor = isDark ? const Color(0xFF16201E) : Colors.white;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.80,
      ),
      decoration: BoxDecoration(
        color: sheetBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header Title & Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.goldAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.iconData ?? CupertinoIcons.star_fill,
                      color: AppColors.goldAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title ?? 'انتخاب سوره منتخب',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle ??
                              'برای دسترسی سریع و قرائت مستقیم از صفحه اصلی',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'جستجوی نام، ترجمه یا شماره سوره...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    CupertinoIcons.search,
                    size: 18,
                    color: isDark ? Colors.white60 : Colors.black45,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFF5F3EF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),

            // Surah List
            Expanded(
              child: filteredSurahs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.search,
                            size: 40,
                            color: isDark ? Colors.white24 : Colors.black26,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'سوره‌ای با مشخصات جستجو یافت نشد.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      itemCount: filteredSurahs.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, indent: 56),
                      itemBuilder: (context, index) {
                        final surah = filteredSurahs[index];
                        final isSelected = widget.autoSavePinned
                            ? (currentPinnedId == surah.number)
                            : false;

                        return Material(
                          color: isSelected
                              ? (isDark
                                  ? AppColors.goldAccent.withValues(alpha: 0.12)
                                  : AppColors.primary.withValues(alpha: 0.08))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: ListTile(
                            dense: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            leading: Container(
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark
                                        ? AppColors.goldAccent
                                        : AppColors.primary)
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : const Color(0xFFEEEBE3)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                surah.number.toString().toPersianDigit(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white70
                                          : const Color(0xFF4A463F)),
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  'سوره ',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 13.5,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? (isDark
                                            ? AppColors.goldAccent
                                            : AppColors.primary)
                                        : (isDark
                                            ? Colors.white70
                                            : const Color(0xFF6E685F)),
                                  ),
                                ),
                                Text(
                                  surah.name,
                                  style: TextStyle(
                                    fontFamily: arabicFontFamily,
                                    fontSize: 18,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? (isDark
                                            ? AppColors.goldAccent
                                            : AppColors.primary)
                                        : (isDark
                                            ? Colors.white
                                            : const Color(0xFF2C2A29)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${surah.englishName})',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                '${surah.numberOfAyahs.toString().toPersianDigit()} آیه • ${surah.revelationTypeFa} • صفحه ${surah.startPage.toString().toPersianDigit()}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color:
                                      isDark ? Colors.white54 : Colors.black54,
                                ),
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: isDark
                                        ? AppColors.goldAccent
                                        : AppColors.primary,
                                    size: 22,
                                  )
                                : const Icon(
                                    CupertinoIcons.chevron_left,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                            onTap: () async {
                              HapticFeedback.lightImpact();
                              if (widget.slotIndex != null) {
                                await ref
                                    .read(quickAccessControllerProvider.notifier)
                                    .assignSurahToSlot(
                                      widget.slotIndex!,
                                      surah.number,
                                    );
                                if (context.mounted) {
                                  Navigator.pop(context, surah);
                                  AppSnackBar.showSuccess(
                                    context,
                                    'سوره ${surah.name} به عنوان سوره منتخب تنظیم شد.',
                                  );
                                }
                              } else if (widget.autoSavePinned) {
                                await ref
                                    .read(pinnedSurahIdProvider.notifier)
                                    .setPinnedSurah(surah.number);
                                if (context.mounted) {
                                  Navigator.pop(context, surah);
                                  AppSnackBar.showSuccess(
                                    context,
                                    'سوره ${surah.name} به عنوان سوره منتخب تنظیم شد.',
                                  );
                                }
                              } else {
                                Navigator.pop(context, surah);
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
