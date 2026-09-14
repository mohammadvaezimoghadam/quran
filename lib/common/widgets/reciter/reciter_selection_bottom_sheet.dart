import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_cached_network_image.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../features/quran_reader/application/controllers/quran_audio_controller.dart';
import '../../../features/quran_reader/application/controllers/reciter_providers.dart';
import '../../../features/quran_reader/domain/entities/reciter_entity.dart';
import '../../../features/quran_reader/presentation/utils/reciter_download_helper.dart';
import '../../../features/subscription/domain/policy/audio_vip_policy.dart';
import '../../../features/subscription/application/vip_subscription_controller.dart';
import '../../../features/subscription/presentation/ui/vip_subscription_sheet.dart';

/// Model representing a unique Reciter person with all their recitation variants.
class ReciterGroup {
  final String baseName;
  final String? imageUrl;
  final List<ReciterEntity> variants;

  ReciterGroup({
    required this.baseName,
    required this.imageUrl,
    required this.variants,
  });
}

/// Modal Bottom Sheet for selecting reciters with high contrast inline variant popup menu.
class ReciterSelectionBottomSheet extends ConsumerStatefulWidget {
  final bool isDownloadMode;
  final bool checkDownloadStatus;
  final bool isTranslationMode;
  final Function(ReciterEntity)? onReciterSelected;

  const ReciterSelectionBottomSheet({
    super.key,
    this.isDownloadMode = false,
    this.checkDownloadStatus = false,
    this.isTranslationMode = false,
    this.onReciterSelected,
  });

  static Future<void> show(
    BuildContext context, {
    bool isDownloadMode = false,
    bool checkDownloadStatus = false,
    bool isTranslationMode = false,
    Function(ReciterEntity)? onReciterSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => ReciterSelectionBottomSheet(
        isDownloadMode: isDownloadMode,
        checkDownloadStatus: checkDownloadStatus,
        isTranslationMode: isTranslationMode,
        onReciterSelected: onReciterSelected,
      ),
    );
  }

  @override
  ConsumerState<ReciterSelectionBottomSheet> createState() =>
      _ReciterSelectionBottomSheetState();
}

class _ReciterSelectionBottomSheetState
    extends ConsumerState<ReciterSelectionBottomSheet> {
  // Local state to keep track of selected variant per reciter group (baseName -> ReciterEntity)
  final Map<String, ReciterEntity> _selectedVariantsMap = {};
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll('ي', 'ی')
        .replaceAll('ك', 'ک')
        .replaceAll('ة', 'ه')
        .replaceAll('آ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('ء', '')
        .replaceAll(RegExp(r'[\u064B-\u065F]'), '') // remove Arabic diacritics
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _cleanReciterName(String rawName) {
    var cleaned =
        rawName.replaceAll(RegExp(r'\s*[\(\[\{].*?[\)\]\}]'), '').trim();
    cleaned =
        cleaned.replaceAll(RegExp(r'\d+kbps', caseSensitive: false), '').trim();
    cleaned = cleaned.replaceAll(RegExp(r'^استاد\s*'), '').trim();
    return cleaned;
  }



  String _getTranslatedVariant(String rawName, String? styleName) {
    final lower = rawName.toLowerCase();

    if (lower.contains('mujawwad') ||
        lower.contains('مجود') ||
        lower.contains('تجوید')) {
      return 'مجوّد';
    }
    if (lower.contains('warsh') || lower.contains('ورش')) {
      return 'ورش';
    }
    if (lower.contains('khalaf') || lower.contains('خلف')) {
      return 'خلف';
    }
    if (lower.contains('qaloon') || lower.contains('قالون')) {
      return 'قالون';
    }
    if (lower.contains('doori') || lower.contains('دوري')) {
      return 'الدوري';
    }
    if (lower.contains('al-bazzi') || lower.contains('بزي')) {
      return 'البزي';
    }
    if (lower.contains('muallim') || lower.contains('معلم')) {
      return 'معلم';
    }

    if (styleName != null && styleName.isNotEmpty) {
      final sLower = styleName.toLowerCase();
      if (sLower.contains('mujawwad') || sLower.contains('مجود')) return 'مجوّد';
      if (sLower.contains('warsh') || sLower.contains('ورش')) return 'ورش';
    }

    return 'ترتیل';
  }

  String _formatQuality(String? bitrate) {
    if (bitrate == null || bitrate.isEmpty) return 'HQ';
    final cleaned =
        bitrate.replaceAll(RegExp(r'kbps', caseSensitive: false), '').trim();
    if (cleaned == '128' ||
        cleaned == '64' ||
        cleaned == '192' ||
        cleaned == '320') {
      return '${cleaned}K';
    }
    return cleaned.toUpperCase();
  }

  int _getReciterPriority(ReciterGroup group) {
    // 1. Ostad Parhizgar is top priority (0)
    final isParhizgar = group.variants.any((v) =>
        AudioVipPolicy.isDefaultReciter(v.identifier) ||
        v.name.contains('پرهیزگار') ||
        v.name.contains('پرهیزکار') ||
        group.baseName.contains('پرهیزگار') ||
        group.baseName.contains('پرهیزکار'));
    if (isParhizgar) return 0;

    // 2. Persian translations (if in translation mode)
    final isPersianTranslation = group.variants.any((v) =>
        v.identifier.startsWith('fa_') ||
        v.name.contains('فارسی') ||
        v.name.contains('فولادوند') ||
        v.name.contains('مکارم'));
    if (isPersianTranslation) return 1;

    // 3. Other Iranian Reciters (Priority 2)
    final isIranian = group.variants.any((v) {
      final id = v.identifier.toLowerCase();
      final name = v.name;
      return id.contains('mansoori') ||
          id.contains('shakernejad') ||
          id.contains('pourzargari') ||
          id.contains('emam_jomeh') ||
          id.contains('aghaei') ||
          id.contains('panahi') ||
          id.contains('sabzali') ||
          id.contains('saeedian') ||
          id.contains('abbasi') ||
          id.contains('misbahi') ||
          name.contains('منصوری') ||
          name.contains('شاکرنژاد') ||
          name.contains('پورزرگری') ||
          name.contains('امام جمعه') ||
          name.contains('آقایی') ||
          name.contains('پناهی') ||
          name.contains('سبزعلی') ||
          name.contains('سعیدیان') ||
          name.contains('عباسی') ||
          name.contains('مصباحی');
    }) ||
        group.baseName.contains('منصوری') ||
        group.baseName.contains('شاکرنژاد') ||
        group.baseName.contains('پورزرگری');
    if (isIranian) return 2;

    return 10;
  }

  List<ReciterGroup> _groupReciters(List<ReciterEntity> rawReciters) {
    final Map<String, List<ReciterEntity>> groupedMap = {};
    final Map<String, int> firstSeenOrder = {};
    int index = 0;

    for (final r in rawReciters) {
      // Do not strip or merge different audio translations
      final baseName = r.styleId == 4 ? r.name : _cleanReciterName(r.name);
      if (!groupedMap.containsKey(baseName)) {
        groupedMap[baseName] = [];
        firstSeenOrder[baseName] = index++;
      }
      groupedMap[baseName]!.add(r);
    }

    final groups = groupedMap.entries.map((entry) {
      final variants = entry.value;
      final image = variants.firstWhere(
        (v) => v.imageUrl != null && v.imageUrl!.isNotEmpty,
        orElse: () => variants.first,
      ).imageUrl;

      return ReciterGroup(
        baseName: entry.key,
        imageUrl: image,
        variants: variants,
      );
    }).toList();

    groups.sort((a, b) {
      final pA = _getReciterPriority(a);
      final pB = _getReciterPriority(b);
      if (pA != pB) return pA.compareTo(pB);
      final orderA = firstSeenOrder[a.baseName] ?? 0;
      final orderB = firstSeenOrder[b.baseName] ?? 0;
      return orderA.compareTo(orderB);
    });

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final softGreenColor = (isDark ? const Color(0xFF1B6B58) : const Color(0xFF267D69))
        .withValues(alpha: 0.70);
    final audioState = ref.watch(quranAudioControllerProvider);
    final selectedStyleId = ref.watch(selectedReciterStyleIdProvider);

    final stylesAsync = ref.watch(recitationStylesProvider);
    final recitersAsync = widget.isTranslationMode
        ? ref.watch(translationRecitersListProvider)
        : ref.watch(recitersListProvider);
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final sheetHeight = keyboardHeight > 0
        ? MediaQuery.sizeOf(context).height * 0.88
        : MediaQuery.sizeOf(context).height * 0.78;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: Column(
            children: [
              12.vSpace,
              // Drag Handle
              Center(
                child: Container(
                  width: 38.0,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                ),
              ),
              14.vSpace,

              // Header Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.isTranslationMode
                            ? 'انتخاب گوینده ترجمه'
                            : AppConstants.selectReciterTitle,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'بستن',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white38
                            : Colors.black26,
                        size: 24.0,
                      ),
                    ),
                  ],
                ),
              ),
              12.vSpace,

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  height: 42.0,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.15),
                      width: 1.0,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    textInputAction: TextInputAction.search,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13.0,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: widget.isTranslationMode
                          ? 'جستجوی گوینده یا مترجم...'
                          : 'جستجوی نام قاری...',
                      hintStyle: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12.0,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
                      ),
                      prefixIcon: Icon(
                        CupertinoIcons.search,
                        size: 17.0,
                        color: colorScheme.primary.withValues(alpha: 0.8),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: Icon(
                                CupertinoIcons.clear_circled_solid,
                                size: 17.0,
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 10.0,
                      ),
                    ),
                  ),
                ),
              ),
              10.vSpace,

              // Styles Filter Tabs
              if (!widget.isTranslationMode) ...[
                stylesAsync.when(
                  data: (result) => result.when(
                    (styles) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.25)
                              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildStyleTabItem(
                                label: 'همه سبک‌ها',
                                isSelected: selectedStyleId == null,
                                softGreenColor: softGreenColor,
                                colorScheme: colorScheme,
                                onTap: () {
                                  ref
                                      .read(selectedReciterStyleIdProvider.notifier)
                                      .setStyleId(null);
                                },
                              ),
                              ...styles.map((style) {
                                final isSelected = selectedStyleId == style.id;
                                return _buildStyleTabItem(
                                  label: style.name,
                                  isSelected: isSelected,
                                  softGreenColor: softGreenColor,
                                  colorScheme: colorScheme,
                                  onTap: () {
                                    ref
                                        .read(selectedReciterStyleIdProvider.notifier)
                                        .setStyleId(style.id);
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                    (error) => const SizedBox.shrink(),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (err, stack) => const SizedBox.shrink(),
                ),
                10.vSpace,
              ],

              // Clean 3-Column Grid with High Contrast Inline Variant Selector
              Expanded(
                child: recitersAsync.when(
                  data: (result) => result.when(
                    (reciters) {
                      if (reciters.isEmpty) {
                        return const Center(
                            child: Text(AppConstants.noReciterFound));
                      }

                      final groupedReciters = _groupReciters(reciters);
                      final queryTrimmed = _searchQuery.trim();
                      final filteredReciters = queryTrimmed.isEmpty
                          ? groupedReciters
                          : groupedReciters.where((group) {
                              final q = _normalizeText(queryTrimmed);
                              if (_normalizeText(group.baseName).contains(q)) {
                                return true;
                              }
                              return group.variants.any((v) =>
                                  _normalizeText(v.name).contains(q) ||
                                  _normalizeText(v.englishName).contains(q) ||
                                  _normalizeText(v.arabicName).contains(q));
                            }).toList();

                      if (filteredReciters.isEmpty) {
                        return Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 16.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    CupertinoIcons.search,
                                    size: 36.0,
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                16.vSpace,
                                Text(
                                  widget.isTranslationMode
                                      ? 'گوینده‌ای مطابق جستجو یافت نشد'
                                      : 'قاری‌ای با نام «$_searchQuery» یافت نشد',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                8.vSpace,
                                Text(
                                  'نام قاری را به صورت فارسی یا انگلیسی جستجو کنید',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 11.5,
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                16.vSpace,
                                TextButton.icon(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  icon: Icon(
                                    CupertinoIcons.clear,
                                    size: 14.0,
                                    color: colorScheme.primary,
                                  ),
                                  label: Text(
                                    'پاک کردن جستجو',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final currentSelectedId = audioState.selectedReciter?.id;

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: filteredReciters.length,
                        itemBuilder: (context, index) {
                          final group = filteredReciters[index];

                        final isGroupSelected = group.variants.any(
                          (v) => v.id == currentSelectedId,
                        );

                        final activeVariant = _selectedVariantsMap[group.baseName] ??
                            group.variants.firstWhere(
                              (v) => v.id == currentSelectedId,
                              orElse: () => group.variants.first,
                            );
                        final isVip = ref.watch(hasVipAccessProvider);
                        final isLocked = !isVip &&
                            (widget.isTranslationMode
                                ? true
                                : !AudioVipPolicy.isDefaultReciter(
                                    activeVariant.identifier));
                        final styleLabel = _getTranslatedVariant(
                            activeVariant.name, activeVariant.styleName);
                        final qualityLabel = _formatQuality(activeVariant.bitrate);
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              if (isLocked) {
                                VipSubscriptionSheet.show(context);
                                return;
                              }
                              if (widget.isDownloadMode) {
                                widget.onReciterSelected?.call(activeVariant);
                                Navigator.of(context).pop();
                              } else {
                                if (widget.isTranslationMode) {
                                  ref
                                      .read(quranAudioControllerProvider.notifier)
                                      .selectTranslationReciter(activeVariant);
                                } else {
                                  ref
                                      .read(quranAudioControllerProvider.notifier)
                                      .selectReciter(activeVariant);
                                }
                                Navigator.of(context).pop();
                                if (widget.checkDownloadStatus) {
                                  await ReciterDownloadHelper.checkAndPromptSurahDownload(
                                    context: context,
                                    ref: ref,
                                    reciter: activeVariant,
                                  );
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Reciter Avatar with active ring and VIP badge
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      padding: const EdgeInsets.all(2.5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isGroupSelected
                                              ? colorScheme.primary
                                              : colorScheme.outline
                                                  .withValues(alpha: 0.15),
                                          width: isGroupSelected ? 2.2 : 1.0,
                                        ),
                                        boxShadow: isGroupSelected
                                            ? [
                                                BoxShadow(
                                                  color: colorScheme.primary
                                                      .withValues(alpha: 0.35),
                                                  blurRadius: 12,
                                                  spreadRadius: 2,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: AppCachedNetworkImage.circle(
                                        imageUrl: group.imageUrl,
                                        size: 52.0,
                                        fallbackIcon: CupertinoIcons.person_fill,
                                        backgroundColor: isGroupSelected
                                            ? colorScheme.primary
                                            : colorScheme.surfaceContainerHigh,
                                      ),
                                    ),
                                    if (isLocked)
                                      Positioned(
                                        top: -3,
                                        right: -3,
                                        child: Container(
                                          padding: const EdgeInsets.all(3.5),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF0F766E), Color(0xFF005C55)],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.lock_rounded,
                                            color: Colors.white,
                                            size: 13,
                                          ),
                                        ),
                                      ),
                                   ],
                                 ),
                                 8.vSpace,

                                // Reciter Base Name
                                Text(
                                  group.baseName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 12.0,
                                    fontWeight: isGroupSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: isGroupSelected
                                        ? colorScheme.primary
                                        : colorScheme.onSurface,
                                  ),
                                ),
                                4.vSpace,

                                // Inline Style Dropdown with Enhanced Contrast & Floating Elevation
                                if (group.variants.length > 1)
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                    ),
                                    child: PopupMenuButton<ReciterEntity>(
                                      initialValue: activeVariant,
                                      elevation: 8.0,
                                      shadowColor: Colors.black.withValues(alpha: 0.45),
                                      color: colorScheme.surfaceContainerHigh,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14.0),
                                        side: BorderSide(
                                          color: colorScheme.outlineVariant
                                              .withValues(alpha: 0.35),
                                          width: 1.0,
                                        ),
                                      ),
                                      tooltip: 'تغییر سبک تلاوت',
                                      onSelected: (variant) async {
                                        final variantIsLocked = !isVip &&
                                            (widget.isTranslationMode
                                                ? true
                                                : !AudioVipPolicy.isDefaultReciter(
                                                    variant.identifier));
                                        if (variantIsLocked) {
                                          VipSubscriptionSheet.show(context);
                                          return;
                                        }
                                        setState(() {
                                          _selectedVariantsMap[group.baseName] =
                                              variant;
                                        });
                                        
                                         if (widget.isDownloadMode) {
                                           widget.onReciterSelected?.call(variant);
                                           Navigator.of(context).pop();
                                         } else {
                                           if (widget.isTranslationMode) {
                                             ref
                                                 .read(quranAudioControllerProvider
                                                     .notifier)
                                                 .selectTranslationReciter(variant);
                                           } else {
                                             ref
                                                 .read(quranAudioControllerProvider
                                                     .notifier)
                                                 .selectReciter(variant);
                                           }
                                           if (widget.checkDownloadStatus) {
                                             await ReciterDownloadHelper.checkAndPromptSurahDownload(
                                               context: context,
                                               ref: ref,
                                               reciter: variant,
                                             );
                                           }
                                         }
                                      },
                                      itemBuilder: (popupContext) =>
                                          group.variants.map((v) {
                                        final vStyle = _getTranslatedVariant(
                                            v.name, v.styleName);
                                        final vQuality =
                                            _formatQuality(v.bitrate);
                                        final isVSelected =
                                            activeVariant.id == v.id;

                                        return PopupMenuItem<ReciterEntity>(
                                          value: v,
                                          height: 38,
                                          child: Row(
                                            children: [
                                              Icon(
                                                isVSelected
                                                    ? CupertinoIcons.checkmark_circle_fill
                                                    : CupertinoIcons.circle,
                                                size: 16,
                                                color: isVSelected
                                                    ? colorScheme.primary
                                                    : colorScheme.onSurfaceVariant
                                                        .withValues(alpha: 0.8),
                                              ),
                                              8.hSpace,
                                              Text(
                                                '$vStyle ($vQuality)',
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppTypography.fontFamily,
                                                  fontSize: 12.0,
                                                  fontWeight: isVSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: isVSelected
                                                      ? colorScheme.primary
                                                      : colorScheme.onSurface
                                                          .withValues(alpha: 0.95),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0,
                                          vertical: 2.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isGroupSelected
                                              ? colorScheme.primary
                                                  .withValues(alpha: 0.15)
                                              : colorScheme
                                                  .surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                          border: Border.all(
                                            color: isGroupSelected
                                                ? colorScheme.primary
                                                    .withValues(alpha: 0.3)
                                                : colorScheme.outline
                                                    .withValues(alpha: 0.2),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '$styleLabel • $qualityLabel',
                                              style: TextStyle(
                                                fontFamily:
                                                    AppTypography.fontFamily,
                                                fontSize: 9.0,
                                                fontWeight: FontWeight.bold,
                                                color: isGroupSelected
                                                    ? colorScheme.primary
                                                    : colorScheme.primary
                                                        .withValues(alpha: 0.85),
                                              ),
                                            ),
                                            2.hSpace,
                                            Icon(
                                              CupertinoIcons.chevron_down,
                                              size: 12.0,
                                              color: isGroupSelected
                                                  ? colorScheme.primary
                                                  : colorScheme.primary
                                                      .withValues(alpha: 0.85),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    '$styleLabel • $qualityLabel',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 9.5,
                                      color: isGroupSelected
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.65),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  (error) => Center(child: Text(error.message)),
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text(err.toString())),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildStyleTabItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color softGreenColor,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
            decoration: BoxDecoration(
              color: isSelected ? softGreenColor : Colors.transparent,
              borderRadius: BorderRadius.circular(24.0),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: isSelected ? 12.5 : 12.0,
                color: isSelected
                    ? Colors.white
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
