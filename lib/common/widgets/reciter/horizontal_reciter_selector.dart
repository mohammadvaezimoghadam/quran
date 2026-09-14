import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_constants.dart';
import '../../extensions/size_extension.dart';
import '../../widgets/app_cached_network_image.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/quran_reader/application/controllers/quran_audio_controller.dart';
import '../../../features/quran_reader/application/controllers/reciter_providers.dart';
import '../../../features/quran_reader/domain/entities/reciter_entity.dart';
import '../../../features/quran_reader/presentation/utils/reciter_download_helper.dart';
import '../../../features/subscription/application/vip_subscription_controller.dart';
import '../../../features/subscription/domain/policy/audio_vip_policy.dart';
import 'reciter_selection_bottom_sheet.dart';

/// Horizontal scrollable list of reciter avatar cards for settings drawer.
class HorizontalReciterSelector extends ConsumerStatefulWidget {
  final bool isTranslationMode;
  final bool checkDownloadStatus;

  const HorizontalReciterSelector({
    super.key,
    this.isTranslationMode = false,
    this.checkDownloadStatus = false,
  });

  @override
  ConsumerState<HorizontalReciterSelector> createState() =>
      _HorizontalReciterSelectorState();
}

class _HorizontalReciterSelectorState
    extends ConsumerState<HorizontalReciterSelector> {
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
    final audioState = ref.watch(quranAudioControllerProvider);
    final recitersAsync = ref.watch(
      widget.isTranslationMode
          ? translationRecitersListProvider
          : arabicRecitersListProvider,
    );
    final currentSelectedId = widget.isTranslationMode
        ? audioState.selectedTranslationReciter?.id
        : audioState.selectedReciter?.id;

    return SizedBox(
      height: 126.0,
      child: recitersAsync.when(
        data: (result) => result.when(
          (reciters) {
            if (reciters.isEmpty) {
              return const Center(child: Text(AppConstants.noReciterFound));
            }

            final groupedReciters = _groupReciters(reciters);

            return ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 2.0,
              ),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: groupedReciters.length,
              separatorBuilder: (context, index) => 12.hSpace,
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

                final isVip = ref.watch(hasVipAccessProvider);
                final isLocked = !isVip &&
                    (widget.isTranslationMode
                        ? true
                        : !AudioVipPolicy.isDefaultReciter(
                            activeVariant.identifier));
                

                return SizedBox(
                  width: 86.0,
                  child: InkWell(
                    onTap: () async {
                      if (widget.isTranslationMode) {
                        ref
                            .read(quranAudioControllerProvider.notifier)
                            .selectTranslationReciter(activeVariant);
                      } else {
                        ref
                            .read(quranAudioControllerProvider.notifier)
                            .selectReciter(activeVariant);
                      }
                      if (widget.checkDownloadStatus) {
                        await ReciterDownloadHelper.checkAndPromptSurahDownload(
                          context: context,
                          ref: ref,
                          reciter: activeVariant,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(14.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar Circle with ring indicator and status badges
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
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: AppCachedNetworkImage.circle(
                                imageUrl: group.imageUrl,
                                size: 48.0,
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
                                      colors: [
                                        Color(0xFF0F766E),
                                        Color(0xFF005C55),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.lock_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                           ],
                         ),
                         6.vSpace,

                        // Reciter Name
                        Text(
                          group.baseName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11.5,
                            fontWeight: isGroupSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isGroupSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                        3.vSpace,

                        // Style Dropdown or Label
                        if (group.variants.length > 1)
                          Theme(
                            data: Theme.of(context).copyWith(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            ),
                            child: PopupMenuButton<ReciterEntity>(
                              initialValue: activeVariant,
                              elevation: 8.0,
                              shadowColor:
                                  Colors.black.withValues(alpha: 0.45),
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
                                setState(() {
                                  _selectedVariantsMap[group.baseName] =
                                      variant;
                                });
                                if (widget.isTranslationMode) {
                                  ref
                                      .read(quranAudioControllerProvider.notifier)
                                      .selectTranslationReciter(variant);
                                } else {
                                  ref
                                      .read(quranAudioControllerProvider.notifier)
                                      .selectReciter(variant);
                                }
                                if (widget.checkDownloadStatus) {
                                  await ReciterDownloadHelper.checkAndPromptSurahDownload(
                                    context: context,
                                    ref: ref,
                                    reciter: variant,
                                  );
                                }
                              },
                              itemBuilder: (popupContext) => group.variants.map((v) {
                                final vStyle = _getTranslatedVariant(
                                    v.name, v.styleName);
                                final vQuality = _formatQuality(v.bitrate);
                                final isVSelected = activeVariant.id == v.id;

                                return PopupMenuItem<ReciterEntity>(
                                  value: v,
                                  height: 36,
                                  child: Row(
                                    children: [
                                      Icon(
                                        isVSelected
                                            ? CupertinoIcons.checkmark_circle_fill
                                            : CupertinoIcons.circle,
                                        size: 15,
                                        color: isVSelected
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant
                                                .withValues(alpha: 0.8),
                                      ),
                                      6.hSpace,
                                      Text(
                                        '$vStyle ($vQuality)',
                                        style: TextStyle(
                                          fontFamily:
                                              AppTypography.fontFamily,
                                          fontSize: 11.5,
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
                                  horizontal: 5.0,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: isGroupSelected
                                      ? colorScheme.primary
                                          .withValues(alpha: 0.15)
                                      : colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(6.0),
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
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 8.5,
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
                                      size: 11.0,
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
                              fontSize: 9.0,
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
        loading: () => const Center(
          child: CupertinoActivityIndicator(),
        ),
        error: (err, stack) => Center(child: Text(err.toString())),
      ),
    );
  }
}
