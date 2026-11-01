import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../surah_list/infrastructure/datasources/static_surahs_data.dart';
import '../../../surah_list/infrastructure/dtos/surah_dto.dart';
import '../../domain/entities/tafakor_quran_reference.dart';

/// Minimalist, monochromatic picker for selecting a Quran Surah and Ayah.
/// Strict neutral dark/light aesthetic with small outlined icons and zero loud colors.
class TafakorAyahPickerBottomSheet extends StatefulWidget {
  final int? initialSurahNumber;

  const TafakorAyahPickerBottomSheet({
    super.key,
    this.initialSurahNumber,
  });

  static Future<TafakorQuranReference?> show(
    BuildContext context, {
    int? initialSurahNumber,
  }) {
    return showModalBottomSheet<TafakorQuranReference>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TafakorAyahPickerBottomSheet(
        initialSurahNumber: initialSurahNumber,
      ),
    );
  }

  @override
  State<TafakorAyahPickerBottomSheet> createState() => _TafakorAyahPickerBottomSheetState();
}

class _TafakorAyahPickerBottomSheetState extends State<TafakorAyahPickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  SurahDto? _selectedSurah;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialSurahNumber != null &&
        widget.initialSurahNumber! >= 1 &&
        widget.initialSurahNumber! <= 114) {
      _selectedSurah = kStaticQuranSurahs[widget.initialSurahNumber! - 1];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SurahDto> get _filteredSurahs {
    if (_searchQuery.trim().isEmpty) return kStaticQuranSurahs;
    final q = _searchQuery.trim().toLowerCase();
    return kStaticQuranSurahs.where((s) {
      final fa = s.number.surahNameFa.toLowerCase();
      final ar = s.name.toLowerCase();
      final numStr = s.number.toString();
      return fa.contains(q) || ar.contains(q) || numStr.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF1A1A1D) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.08);
    final primaryTextColor = isDark ? const Color(0xFFEEEEEE) : const Color(0xFF1E1E22);
    final secondaryTextColor = isDark ? Colors.white54 : Colors.black45;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border.all(color: borderColor, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            10.vSpace,
            // Drag handle
            Center(
              child: Container(
                width: 32,
                height: 3.5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            8.vSpace,

            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  if (_selectedSurah != null)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedSurah = null);
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8.0),
                        child: Icon(
                          CupertinoIcons.chevron_right,
                          size: 16,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      _selectedSurah == null
                          ? 'انتخاب سوره'
                          : 'انتخاب آیه (${_selectedSurah!.number.surahNameFa})',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.xmark,
                        size: 13,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 12, thickness: 0.6),

            // Content: Step 1 (Surah List) or Step 2 (Ayah Grid)
            Expanded(
              child: _selectedSurah == null
                  ? _buildSurahListView(isDark, borderColor, primaryTextColor, secondaryTextColor)
                  : _buildAyahGridView(isDark, borderColor, primaryTextColor, secondaryTextColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahListView(
    bool isDark,
    Color borderColor,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return Column(
      children: [
        // Minimal Search Input
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF232327) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 0.7),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12.5,
                color: primaryTextColor,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                hintText: 'نام یا شماره سوره...',
                hintStyle: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  size: 14,
                  color: secondaryTextColor,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: _filteredSurahs.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final surah = _filteredSurahs[index];
              final surahFaName = surah.number.surahNameFa;
              return InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedSurah = surah);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.04),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          surah.number.toPersianDigit(),
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                      10.hSpace,
                      Expanded(
                        child: Text(
                          surahFaName,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                      Text(
                        '${surah.numberOfAyahs.toPersianDigit()} آیه',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11.5,
                          color: secondaryTextColor,
                        ),
                      ),
                      6.hSpace,
                      Icon(
                        CupertinoIcons.chevron_left,
                        size: 13,
                        color: secondaryTextColor,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAyahGridView(
    bool isDark,
    Color borderColor,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final surah = _selectedSurah!;
    final totalAyahs = surah.numberOfAyahs;

    return GridView.builder(
      padding: const EdgeInsets.all(14),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.15,
      ),
      itemCount: totalAyahs,
      itemBuilder: (context, index) {
        final ayahNumber = index + 1;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              final result = TafakorQuranReference(
                surahNumber: surah.number,
                ayahNumber: ayahNumber,
                surahName: surah.number.surahNameFa,
              );
              Navigator.of(context).pop(result);
            },
            borderRadius: BorderRadius.circular(8),
            child: Ink(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF242429) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor, width: 0.7),
              ),
              child: Center(
                child: Text(
                  ayahNumber.toPersianDigit(),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: primaryTextColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

