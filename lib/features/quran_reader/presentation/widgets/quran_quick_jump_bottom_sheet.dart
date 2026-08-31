import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/services/quran_navigation/domain/entities/ayah_target.dart';
import '../../../../core/services/quran_navigation/quran_navigation_service_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../surah_list/application/controllers/surah_list_controller.dart';
import '../../../surah_list/domain/entities/surah_entity.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import '../../application/controllers/quran_reader_controller.dart';
import '../../domain/entities/ayah_entity.dart';

enum QuickJumpTab { surah, juz, hizb, page }

/// Modern single Tabbed Bottom Sheet for Quran Quick Jump
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
  late QuickJumpTab _activeTab;
  bool _isInitialized = false;

  // Surah & Ayah Tab State
  SurahEntity? _selectedSurah;
  final TextEditingController _surahSearchController = TextEditingController();
  final TextEditingController _ayahNumberController = TextEditingController(text: '1');
  String _surahSearchQuery = '';

  // Numeric Tabs State
  final TextEditingController _juzController = TextEditingController(text: '1');
  final TextEditingController _hizbController = TextEditingController(text: '1');
  final TextEditingController _pageController = TextEditingController(text: '1');

  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  @override
  void dispose() {
    _surahSearchController.dispose();
    _ayahNumberController.dispose();
    _juzController.dispose();
    _hizbController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final navService = ref.read(quranNavigationServiceProvider);
    setState(() => _isCalculating = true);

    try {
      AyahTarget? target;

      switch (_activeTab) {
        case QuickJumpTab.surah:
          if (_selectedSurah == null) {
            AppSnackBar.showError(context, 'لطفاً یک سوره انتخاب کنید.');
            return;
          }
          final ayahNum = int.tryParse(_ayahNumberController.text.trim()) ?? 1;
          final maxAyahs = _selectedSurah!.numberOfAyahs;
          if (ayahNum < 1 || ayahNum > maxAyahs) {
            AppSnackBar.showError(
                context, 'شماره آیه سوره ${_selectedSurah!.name} باید بین ۱ تا $maxAyahs باشد.');
            return;
          }
          target = await navService.getTargetBySurah(_selectedSurah!.number,
              ayahNumber: ayahNum);
          break;

        case QuickJumpTab.juz:
          final juzNum = int.tryParse(_juzController.text.trim()) ?? 1;
          if (juzNum < 1 || juzNum > 30) {
            AppSnackBar.showError(context, 'شماره جزء باید بین ۱ تا ۳۰ باشد.');
            return;
          }
          target = await navService.getTargetByJuz(juzNum);
          break;

        case QuickJumpTab.hizb:
          final hizbNum = int.tryParse(_hizbController.text.trim()) ?? 1;
          if (hizbNum < 1 || hizbNum > 120) {
            AppSnackBar.showError(context, 'شماره حزب باید بین ۱ تا ۱۲۰ باشد.');
            return;
          }
          target = await navService.getTargetByHizb(hizbNum);
          break;

        case QuickJumpTab.page:
          final pageNum = int.tryParse(_pageController.text.trim()) ?? 1;
          if (pageNum < 1 || pageNum > 604) {
            AppSnackBar.showError(context, 'شماره صفحه باید بین ۱ تا ۶۰۴ باشد.');
            return;
          }
          target = await navService.getTargetByPage(pageNum);
          break;
      }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surahs = ref.watch(surahListControllerProvider.select((s) => s.surahs));

    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final selectedFontFamily = AppTypography.getFontFamilyByScript(fontScript);

    // Initialize values from currently visible ayah in reader
    if (!_isInitialized && surahs.isNotEmpty) {
      _isInitialized = true;
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
        _ayahNumberController.text = currentAyah.ayahNumber.toString();
        if (currentAyah.juz != null) _juzController.text = currentAyah.juz.toString();
        if (currentAyah.hizb != null) _hizbController.text = currentAyah.hizb.toString();
        if (currentAyah.page != null) _pageController.text = currentAyah.page.toString();
      } else {
        _selectedSurah = surahs.first;
      }
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E262C) : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
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

          // Header Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.arrow_up_left_square,
                  color: AppColors.primary,
                  size: 20,
                ),
                8.hSpace,
                Text(
                  'پرش سریع در قرآن',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 22),
                  color: isDark ? Colors.white54 : Colors.black38,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          8.vSpace,

          // Tab Bar Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTabButton(QuickJumpTab.surah, 'سوره و آیه'),
                  _buildTabButton(QuickJumpTab.juz, 'جزء'),
                  _buildTabButton(QuickJumpTab.hizb, 'حزب'),
                  _buildTabButton(QuickJumpTab.page, 'صفحه'),
                ],
              ),
            ),
          ),
          16.vSpace,

          // Active Tab Content Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildActiveTabBody(surahs, isDark, selectedFontFamily),
            ),
          ),

          16.vSpace,

          // Submit Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isCalculating ? null : _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
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
                    : const Icon(CupertinoIcons.paperplane_fill, size: 18),
                label: Text(
                  _isCalculating ? 'در حال محاسبه...' : 'انتقال به آیه',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(QuickJumpTab tab, String label) {
    final isSelected = _activeTab == tab;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _activeTab = tab;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabBody(
      List<SurahEntity> surahs, bool isDark, String selectedFontFamily) {
    switch (_activeTab) {
      case QuickJumpTab.surah:
        return _buildSurahTab(surahs, isDark, selectedFontFamily);
      case QuickJumpTab.juz:
        return _buildNumericInputTab(
          title: 'شماره جزء (۱ تا ۳۰)',
          controller: _juzController,
          maxVal: 30,
          isDark: isDark,
        );
      case QuickJumpTab.hizb:
        return _buildNumericInputTab(
          title: 'شماره حزب (۱ تا ۱۲۰)',
          controller: _hizbController,
          maxVal: 120,
          isDark: isDark,
        );
      case QuickJumpTab.page:
        return _buildNumericInputTab(
          title: 'شماره صفحه (۱ تا ۶۰۴)',
          controller: _pageController,
          maxVal: 604,
          isDark: isDark,
        );
    }
  }

  Widget _buildSurahTab(
      List<SurahEntity> surahs, bool isDark, String selectedFontFamily) {
    final query = _surahSearchQuery.normalizeForSearch();

    final filteredSurahs = surahs.where((s) {
      if (query.isEmpty) return true;
      final normalizedName = s.name.normalizeForSearch();
      final normalizedEnglishName = s.englishName.normalizeForSearch();
      return normalizedName.contains(query) ||
          normalizedEnglishName.contains(query) ||
          s.number.toString() == query;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Field for Surahs
        TextField(
          controller: _surahSearchController,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontFamily: AppTypography.fontFamily,
            fontSize: 14,
          ),
          onChanged: (val) {
            setState(() {
              _surahSearchQuery = val;
            });
          },
          decoration: InputDecoration(
            hintText: 'جستجوی نام یا شماره سوره...',
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 13,
            ),
            prefixIcon: Icon(
              CupertinoIcons.search,
              size: 18,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        8.vSpace,

        // Scrollable List of Filtered Surahs
        Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
          ),
          child: Material(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            clipBehavior: Clip.antiAlias,
            child: filteredSurahs.isEmpty
              ? const Center(child: Text('سوره‌ای یافت نشد'))
              : ListView.builder(
                  itemCount: filteredSurahs.length,
                  itemBuilder: (context, index) {
                    final surah = filteredSurahs[index];
                    final isSelected = _selectedSurah?.number == surah.number;

                    return ListTile(
                      dense: true,
                      selected: isSelected,
                      selectedTileColor: AppColors.primary.withValues(alpha: 0.15),
                      title: Text(
                        '${surah.number.toPersianDigit()}. سوره ${surah.name}',
                        style: TextStyle(
                          fontFamily: selectedFontFamily,
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      subtitle: Text(
                        'تعداد آیه: ${surah.numberOfAyahs.toPersianDigit()} | صفحه ${surah.startPage.toPersianDigit()}',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedSurah = surah;
                        });
                      },
                    );
                  },
                ),
          ),
        ),
        14.vSpace,

        // Ayah Number Input Field with Validation
        if (_selectedSurah != null) ...[
          Row(
            children: [
              Text(
                'شماره آیه:',
                style: AppTypography.captionText.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'تعداد کل آیه: ${_selectedSurah!.numberOfAyahs.toPersianDigit()}',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          6.vSpace,
          TextField(
            controller: _ayahNumberController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onChanged: (val) {
              setState(() {}); // Trigger rebuild for live validation message
            },
            decoration: InputDecoration(
              hintText: '۱',
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              errorText: _getAyahValidationError(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String? _getAyahValidationError() {
    if (_selectedSurah == null) return null;
    final valStr = _ayahNumberController.text.trim();
    if (valStr.isEmpty) return 'شماره آیه را وارد کنید';
    final val = int.tryParse(valStr);
    if (val == null) return 'شماره نامعتبر است';
    if (val < 1 || val > _selectedSurah!.numberOfAyahs) {
      return 'باید بین ۱ تا ${_selectedSurah!.numberOfAyahs.toPersianDigit()} باشد';
    }
    return null;
  }

  Widget _buildNumericInputTab({
    required String title,
    required TextEditingController controller,
    required int maxVal,
    required bool isDark,
  }) {
    final valStr = controller.text.trim();
    final val = int.tryParse(valStr);
    final bool isInvalid = val == null || val < 1 || val > maxVal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.captionText.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        12.vSpace,

        // Centered Text Field
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: isDark ? Colors.white : AppColors.primary,
          ),
          onChanged: (val) {
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: '۱',
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            errorText: isInvalid ? 'باید عددی بین ۱ تا ${maxVal.toPersianDigit()} باشد' : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
        16.vSpace,
      ],
    );
  }
}
