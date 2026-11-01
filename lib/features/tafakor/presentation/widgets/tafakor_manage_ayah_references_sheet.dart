import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../common/widgets/app_modal_header.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../surah_list/infrastructure/datasources/static_surahs_data.dart';
import '../../../surah_list/infrastructure/dtos/surah_dto.dart';
import '../../domain/entities/tafakor_post.dart';
import '../../domain/entities/tafakor_quran_reference.dart';
import '../../infrastructure/repositories/tafakor_posts_repository_impl.dart';
import '../../infrastructure/services/tafakor_quran_extractor.dart';

/// Clean, self-contained bottom sheet for managing and adding Quran Ayah references
/// directly to a Tafakor post without opening secondary dialogs or navigation sheets.
class TafakorManageAyahReferencesSheet extends ConsumerStatefulWidget {
  final TafakorPost post;
  final ValueChanged<TafakorPost>? onPostUpdated;
  final int? initialSurahNumber;

  const TafakorManageAyahReferencesSheet({
    super.key,
    required this.post,
    this.onPostUpdated,
    this.initialSurahNumber,
  });

  static Future<void> show(
    BuildContext context, {
    required TafakorPost post,
    ValueChanged<TafakorPost>? onPostUpdated,
    int? initialSurahNumber,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TafakorManageAyahReferencesSheet(
        post: post,
        onPostUpdated: onPostUpdated,
        initialSurahNumber: initialSurahNumber,
      ),
    );
  }

  @override
  ConsumerState<TafakorManageAyahReferencesSheet> createState() =>
      _TafakorManageAyahReferencesSheetState();
}

class _TafakorManageAyahReferencesSheetState
    extends ConsumerState<TafakorManageAyahReferencesSheet> {
  late List<TafakorQuranReference> _references;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _ayahController = TextEditingController(
    text: '1',
  );

  SurahDto? _selectedSurah;
  int _selectedAyahNumber = 1;
  String _searchQuery = '';
  bool _isSaving = false;
  TafakorQuranReference? _deletingReference;

  @override
  void initState() {
    super.initState();
    _references = List.from(widget.post.quranReferences);

    if (widget.initialSurahNumber != null &&
        widget.initialSurahNumber! >= 1 &&
        widget.initialSurahNumber! <= 114) {
      _selectedSurah = kStaticQuranSurahs[widget.initialSurahNumber! - 1];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _ayahController.dispose();
    super.dispose();
  }

  List<SurahDto> get _filteredSurahs {
    if (_searchQuery.trim().isEmpty) return kStaticQuranSurahs;
    final q = _searchQuery.trim().toLowerCase();
    return kStaticQuranSurahs.where((s) {
      final fa = s.number.surahNameFa.toLowerCase();
      final ar = s.name.toLowerCase();
      final numStr = s.number.toString();
      final faNumStr = s.number.toPersianDigit();
      return fa.contains(q) ||
          ar.contains(q) ||
          numStr.contains(q) ||
          faNumStr.contains(q);
    }).toList();
  }

  Future<void> _confirmRemoveReference(TafakorQuranReference refToRemove) async {
    HapticFeedback.lightImpact();
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: CupertinoAlertDialog(
          title: const Text(
            'حذف ارجاع آیه',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'آیا از حذف ارجاع «سوره ${refToRemove.surahName}، آیه ${refToRemove.ayahNumber.toPersianDigit()}» از این پست اطمینان دارید؟',
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                'انصراف',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              onPressed: () => Navigator.pop(dialogCtx, false),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text(
                'حذف',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.pop(dialogCtx, true),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      await _removeReference(refToRemove);
    }
  }

  Future<void> _removeReference(TafakorQuranReference refToRemove) async {
    HapticFeedback.lightImpact();
    final remaining = _references
        .where(
          (r) =>
              !(r.surahNumber == refToRemove.surahNumber &&
                  r.ayahNumber == refToRemove.ayahNumber),
        )
        .toList();

    setState(() {
      _deletingReference = refToRemove;
      _isSaving = true;
    });

    final payload = remaining
        .map(
          (r) => {
            'plugin': 'quran',
            'resource_type': 'ayah',
            'external_id': 'surah:${r.surahNumber},ayah:${r.ayahNumber}',
            'metadata': {
              'surah_number': r.surahNumber,
              'ayah_number': r.ayahNumber,
              'surah_name': r.surahName,
            },
          },
        )
        .toList();

    final repo = ref.read(tafakorPostsRepositoryProvider);
    final result = await repo.updatePostReferences(
      postId: widget.post.id,
      pluginReferences: payload,
    );

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _deletingReference = null;
    });

    result.when(
      (updatedPost) {
        setState(() {
          _references = remaining;
        });
        TafakorQuranRegistry.register(widget.post.id, remaining);
        widget.onPostUpdated?.call(updatedPost);
        AppSnackBar.showSuccess(context, 'ارجاع آیه با موفقیت حذف شد');
      },
      (failure) {
        AppSnackBar.showError(
          context,
          'خطا در حذف ارجاع آیه: ${failure.message}',
        );
      },
    );
  }

  Future<void> _addAndSaveReference() async {
    if (_selectedSurah == null) {
      AppSnackBar.showError(context, 'لطفاً ابتدا یک سوره را انتخاب کنید');
      return;
    }

    final raw = _ayahController.text.trim().toEnglishDigit();
    final ayahNum = int.tryParse(raw) ?? _selectedAyahNumber;

    if (ayahNum < 1 || ayahNum > _selectedSurah!.numberOfAyahs) {
      AppSnackBar.showError(
        context,
        'شماره آیه باید بین ۱ تا ${_selectedSurah!.numberOfAyahs.toPersianDigit()} باشد',
      );
      return;
    }

    final exists = _references.any(
      (r) => r.surahNumber == _selectedSurah!.number && r.ayahNumber == ayahNum,
    );
    if (exists) {
      AppSnackBar.showError(context, 'این آیه قبلاً به این پست اضافه شده است');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    final newRef = TafakorQuranReference(
      surahNumber: _selectedSurah!.number,
      ayahNumber: ayahNum,
      surahName: _selectedSurah!.number.surahNameFa,
    );

    final updatedList = [..._references, newRef];
    final payload = updatedList
        .map(
          (r) => {
            'plugin': 'quran',
            'resource_type': 'ayah',
            'external_id': 'surah:${r.surahNumber},ayah:${r.ayahNumber}',
            'metadata': {
              'surah_number': r.surahNumber,
              'ayah_number': r.ayahNumber,
              'surah_name': r.surahName,
            },
          },
        )
        .toList();

    final repo = ref.read(tafakorPostsRepositoryProvider);
    final result = await repo.updatePostReferences(
      postId: widget.post.id,
      pluginReferences: payload,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.when(
      (updatedPost) {
        TafakorQuranRegistry.register(widget.post.id, updatedList);
        widget.onPostUpdated?.call(updatedPost);
        Navigator.of(context).pop();
        AppSnackBar.showSuccess(context, 'آیه با موفقیت به پست اضافه شد');
      },
      (failure) {
        AppSnackBar.showError(context, 'خطا در ثبت آیه: ${failure.message}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF1E1E22) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);
    final primaryTextColor = isDark
        ? const Color(0xFFEEEEEE)
        : const Color(0xFF1E1E22);
    final secondaryTextColor = isDark ? Colors.white54 : Colors.black45;
    final chipBg = isDark ? const Color(0xFF28282D) : const Color(0xFFF3F4F6);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppModalHeader(
                  title: 'مدیریت و افزودن آیه',
                  showDragHandle: true,
                  showDivider: false,
                  bottomSpacing: 14.0,
                  onClose: () => Navigator.of(context).pop(),
                ),

                // 1. Current Attached Verses
                if (_references.isNotEmpty) ...[
                  Text(
                    'آیات متصل به این پست:',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: secondaryTextColor,
                    ),
                  ),
                  8.vSpace,
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _references.map((r) {
                        final isDeleting = _deletingReference != null &&
                            _deletingReference!.surahNumber == r.surahNumber &&
                            _deletingReference!.ayahNumber == r.ayahNumber;

                        return Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: chipBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: borderColor, width: 0.7),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'سوره ${r.surahName} • آیه ${r.ayahNumber.toPersianDigit()}',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: primaryTextColor,
                                  ),
                                ),
                                6.hSpace,
                                GestureDetector(
                                  onTap: isDeleting || _isSaving
                                      ? null
                                      : () => _confirmRemoveReference(r),
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: isDeleting
                                        ? SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CupertinoActivityIndicator(
                                              radius: 5.5,
                                              color: secondaryTextColor,
                                            ),
                                          )
                                        : Icon(
                                            CupertinoIcons.xmark,
                                            size: 12,
                                            color: secondaryTextColor,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  16.vSpace,
                ],

                // 2. Add New Ayah Section
                Text(
                  'افزودن آیه جدید',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: primaryTextColor,
                  ),
                ),
                10.vSpace,

                // Surah Selection: When no surah selected, show search input and list
                if (_selectedSurah == null) ...[
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF28282D)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor, width: 0.7),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        color: primaryTextColor,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'جستجوی نام یا شماره سوره...',
                        hintStyle: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12.5,
                          color: secondaryTextColor,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  8.vSpace,
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 180),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filteredSurahs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 2),
                      itemBuilder: (context, index) {
                        final s = _filteredSurahs[index];
                        return InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedSurah = s;
                              _selectedAyahNumber = 1;
                              _ayahController.text = '1';
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${s.number.toPersianDigit()}.',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 12,
                                    color: secondaryTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                8.hSpace,
                                Expanded(
                                  child: Text(
                                    'سوره ${s.number.surahNameFa} (${s.name})',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 13,
                                      color: primaryTextColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${s.numberOfAyahs.toPersianDigit()} آیه',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 11.5,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  // Selected Surah Display Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 0.7),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'سوره انتخاب‌شده',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 11,
                                  color: secondaryTextColor,
                                ),
                              ),
                              3.vSpace,
                              Text(
                                '${_selectedSurah!.number.toPersianDigit()}. سوره ${_selectedSurah!.number.surahNameFa} (${_selectedSurah!.numberOfAyahs.toPersianDigit()} آیه)',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedSurah = null;
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'تغییر سوره',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  14.vSpace,

                  // Ayah Number Stepper & Input
                  Text(
                    'شماره آیه (از ۱ تا ${_selectedSurah!.numberOfAyahs.toPersianDigit()}):',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: secondaryTextColor,
                    ),
                  ),
                  8.vSpace,
                  Row(
                    children: [
                      // Minus Button
                      _buildStepButton(
                        label: '-',
                        onTap: () {
                          final cur =
                              int.tryParse(
                                _ayahController.text.toEnglishDigit(),
                              ) ??
                              _selectedAyahNumber;
                          if (cur > 1) {
                            final next = cur - 1;
                            _ayahController.text = next.toString();
                            setState(() => _selectedAyahNumber = next);
                          }
                        },
                        isDark: isDark,
                        borderColor: borderColor,
                        primaryTextColor: primaryTextColor,
                      ),
                      10.hSpace,

                      // Center Ayah TextField
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF28282D)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderColor, width: 0.8),
                          ),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: _ayahController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: primaryTextColor,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (val) {
                              final parsed = int.tryParse(val.toEnglishDigit());
                              if (parsed != null &&
                                  parsed >= 1 &&
                                  parsed <= _selectedSurah!.numberOfAyahs) {
                                _selectedAyahNumber = parsed;
                              }
                            },
                          ),
                        ),
                      ),
                      10.hSpace,

                      // Plus Button
                      _buildStepButton(
                        label: '+',
                        onTap: () {
                          final cur =
                              int.tryParse(
                                _ayahController.text.toEnglishDigit(),
                              ) ??
                              _selectedAyahNumber;
                          if (cur < _selectedSurah!.numberOfAyahs) {
                            final next = cur + 1;
                            _ayahController.text = next.toString();
                            setState(() => _selectedAyahNumber = next);
                          }
                        },
                        isDark: isDark,
                        borderColor: borderColor,
                        primaryTextColor: primaryTextColor,
                      ),
                    ],
                  ),

                  18.vSpace,

                  // Green Submit Button (Without extra icons)
                  ElevatedButton(
                    onPressed: _isSaving ? null : _addAndSaveReference,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A884),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(
                        0xFF00A884,
                      ).withValues(alpha: 0.6),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'ثبت آیه',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepButton({
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    required Color borderColor,
    required Color primaryTextColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF28282D) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
