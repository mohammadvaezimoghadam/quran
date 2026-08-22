import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_cached_network_image.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/quran_audio_controller.dart';
import '../../application/controllers/reciter_providers.dart';
import '../../domain/entities/reciter_entity.dart';

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
  const ReciterSelectionBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => const ReciterSelectionBottomSheet(),
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

  List<ReciterGroup> _groupReciters(List<ReciterEntity> rawReciters) {
    final Map<String, List<ReciterEntity>> groupedMap = {};

    for (final r in rawReciters) {
      final baseName = _cleanReciterName(r.name);
      if (!groupedMap.containsKey(baseName)) {
        groupedMap[baseName] = [];
      }
      groupedMap[baseName]!.add(r);
    }

    return groupedMap.entries.map((entry) {
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
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final audioState = ref.watch(quranAudioControllerProvider);
    final selectedStyleId = ref.watch(selectedReciterStyleIdProvider);

    final stylesAsync = ref.watch(recitationStylesProvider);
    final recitersAsync = ref.watch(recitersListProvider);
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.75;

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
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.mic_fill,
                      color: colorScheme.primary,
                      size: 20.0,
                    ),
                  ),
                  12.hSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.selectReciterTitle,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        2.vSpace,
                        Text(
                          'قاری مورد نظر خود را جهت پخش صوتی انتخاب کنید',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11.5,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      CupertinoIcons.xmark,
                      color: colorScheme.onSurfaceVariant,
                      size: 18.0,
                    ),
                  ),
                ],
              ),
            ),
            12.vSpace,

            // Styles Filter Chips
            stylesAsync.when(
              data: (result) => result.when(
                (styles) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('همه سبک‌ها'),
                        selected: selectedStyleId == null,
                        onSelected: (_) {
                          ref
                              .read(selectedReciterStyleIdProvider.notifier)
                              .setStyleId(null);
                        },
                      ),
                      ...styles.map((style) {
                        final isSelected = selectedStyleId == style.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(style.name),
                            selected: isSelected,
                            onSelected: (_) {
                              ref
                                  .read(selectedReciterStyleIdProvider.notifier)
                                  .setStyleId(style.id);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                (error) => const SizedBox.shrink(),
              ),
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
            ),

            12.vSpace,

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
                      itemCount: groupedReciters.length,
                      itemBuilder: (context, index) {
                        final group = groupedReciters[index];

                        final isGroupSelected = group.variants.any(
                          (v) => v.id == currentSelectedId,
                        );

                        final activeVariant = _selectedVariantsMap[group.baseName] ??
                            group.variants.firstWhere(
                              (v) => v.id == currentSelectedId,
                              orElse: () => group.variants.first,
                            );
                        final styleLabel = _getTranslatedVariant(
                            activeVariant.name, activeVariant.styleName);
                        final qualityLabel = _formatQuality(activeVariant.bitrate);
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              ref
                                  .read(quranAudioControllerProvider.notifier)
                                  .selectReciter(activeVariant);
                              Navigator.of(context).pop();
                            },
                            borderRadius: BorderRadius.circular(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Reciter Avatar with active ring
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
                                      onSelected: (variant) {
                                        setState(() {
                                          _selectedVariantsMap[group.baseName] =
                                              variant;
                                        });
                                        ref
                                            .read(quranAudioControllerProvider
                                                .notifier)
                                            .selectReciter(variant);
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
    );
  }
}
