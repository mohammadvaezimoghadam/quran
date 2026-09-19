import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/int_extension.dart';
import 'app_modal_header.dart';
import '../extensions/string_extension.dart';
import '../extensions/surah_name_extension.dart';
import '../../core/theme/app_typography.dart';
import '../../features/surah_list/application/controllers/surah_list_controller.dart';
import '../../features/surah_list/domain/entities/surah_entity.dart';

/// Reusable Apple-style Centered Dialog for selecting a Surah.
/// Features instant search and scrollable Surah list without nested bottom sheets.
class SurahPickerDialog extends ConsumerStatefulWidget {
  final String title;
  final SurahEntity? activeSurah;
  final List<SurahEntity>? surahs;

  const SurahPickerDialog({
    super.key,
    this.title = 'انتخاب سوره',
    this.activeSurah,
    this.surahs,
  });

  /// Opens the center dialog and returns the selected [SurahEntity], or null if dismissed.
  static Future<SurahEntity?> show(
    BuildContext context, {
    String title = 'انتخاب سوره',
    SurahEntity? activeSurah,
    List<SurahEntity>? surahs,
  }) {
    HapticFeedback.selectionClick();
    return showDialog<SurahEntity>(
      context: context,
      builder: (ctx) => SurahPickerDialog(
        title: title,
        activeSurah: activeSurah,
        surahs: surahs,
      ),
    );
  }

  @override
  ConsumerState<SurahPickerDialog> createState() => _SurahPickerDialogState();
}

class _SurahPickerDialogState extends ConsumerState<SurahPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  bool _hasAutoScrolled = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveSurah(List<SurahEntity> allSurahs) {
    if (!mounted || !_scrollController.hasClients) return;
    if (!_scrollController.position.hasContentDimensions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveSurah(allSurahs);
      });
      return;
    }
    final active = widget.activeSurah;
    if (active == null) return;

    final targetIndex = allSurahs.indexWhere((s) => s.number == active.number);
    if (targetIndex == -1) return;

    const double itemHeight = 50.0;
    const double itemExtent = 51.0; // 50.0 item + 1.0 divider
    const double listPaddingTop = 6.0;

    final itemCenter = listPaddingTop + (targetIndex * itemExtent) + (itemHeight / 2);
    final viewportHeight = _scrollController.position.viewportDimension;
    final maxScroll = _scrollController.position.maxScrollExtent;

    final targetOffset = (itemCenter - (viewportHeight / 2)).clamp(0.0, maxScroll);

    _scrollController.jumpTo(targetOffset);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final allSurahs = widget.surahs ??
        ref.watch(surahListControllerProvider.select((s) => s.surahs)) ??
        <SurahEntity>[];

    if (!_hasAutoScrolled && widget.activeSurah != null && allSurahs.isNotEmpty) {
      _hasAutoScrolled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveSurah(allSurahs);
      });
    }

    final normalized = _searchQuery.normalizeForSearch();
    final filtered = allSurahs.where((s) {
      if (normalized.isEmpty) return true;
      return s.name.normalizeForSearch().contains(normalized) ||
          s.nameFa.normalizeForSearch().contains(normalized) ||
          s.englishName.normalizeForSearch().contains(normalized) ||
          s.number.toString() == normalized;
    }).toList();

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.72,
          maxWidth: 420,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            AppModalHeader(
              title: widget.title,
              bottomSpacing: 8,
            ),

            // Search Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: CupertinoSearchTextField(
                controller: _searchController,
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
                    _searchQuery = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            Divider(
              height: 1,
              thickness: 0.6,
              color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E5DF),
            ),

            // Surah List
            Flexible(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'سوره‌ای یافت نشد',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ),
                    )
                  : RawScrollbar(
                      controller: _scrollController,
                      thumbColor: colorScheme.primary.withValues(alpha: 0.4),
                      radius: const Radius.circular(4),
                      thickness: 3,
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 0.5,
                          indent: 44,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.04),
                        ),
                        itemBuilder: (context, index) {
                          final s = filtered[index];
                          final isSelected =
                              widget.activeSurah?.number == s.number;

                          return Material(
                            color: isSelected
                                ? colorScheme.primary.withValues(
                                    alpha: isDark ? 0.16 : 0.08,
                                  )
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.pop(context, s);
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? colorScheme.primary
                                              : (isDark
                                                  ? Colors.white.withValues(
                                                      alpha: 0.07,
                                                    )
                                                  : Colors.black.withValues(
                                                      alpha: 0.05,
                                                    )),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          s.number.toPersianDigit(),
                                          style: TextStyle(
                                            fontFamily:
                                                AppTypography.fontFamily,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : (isDark
                                                    ? Colors.white70
                                                    : Colors.black87),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'سوره ${s.nameFa}',
                                          style: TextStyle(
                                            fontFamily:
                                                AppTypography.fontFamily,
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? colorScheme.primary
                                                : (isDark
                                                    ? Colors.white
                                                    : const Color(0xFF1C1B1B)),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${s.numberOfAyahs.toPersianDigit()} آیه • ص ${s.startPage.toPersianDigit()}',
                                        style: TextStyle(
                                          fontFamily:
                                              AppTypography.fontFamily,
                                          fontSize: 11.5,
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.black45,
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 8),
                                        Icon(
                                          CupertinoIcons.checkmark_alt,
                                          color: colorScheme.primary,
                                          size: 17,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
