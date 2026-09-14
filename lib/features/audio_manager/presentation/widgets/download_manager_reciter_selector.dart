import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/app_cached_network_image.dart';
import '../../../../common/widgets/reciter/reciter_selection_bottom_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran_reader/application/controllers/quran_audio_controller.dart';
import '../../../quran_reader/application/controllers/reciter_providers.dart';
import '../../../quran_reader/domain/entities/reciter_entity.dart';
import '../../application/states/download_manager_state.dart';

class DownloadManagerReciterSelector extends ConsumerWidget {
  final bool isTranslationMode;

  const DownloadManagerReciterSelector({
    super.key,
    this.isTranslationMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedReciter = ref.watch(downloadManagerSelectedReciterProvider);
    final recitersResult = ref.watch(
      isTranslationMode ? translationRecitersListProvider : recitersListProvider,
    );

    List<ReciterEntity> reciters = [];
    if (recitersResult.value != null && recitersResult.value!.isSuccess()) {
      reciters = recitersResult.value!.tryGetSuccess() ?? [];
    }

    if (selectedReciter == null && reciters.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final audioState = ref.read(quranAudioControllerProvider);
        final defaultReciter = isTranslationMode
            ? (audioState.selectedTranslationReciter ?? reciters.first)
            : (audioState.selectedReciter ?? reciters.first);
        ref.read(downloadManagerSelectedReciterProvider.notifier).setReciter(defaultReciter);
      });
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final cardBgColor = isDark ? const Color(0xFF162321) : const Color(0xFFFAF7F2);
    final cardBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.primary.withValues(alpha: 0.12);

    final imageUrl = selectedReciter?.imageUrl;
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Guide / Purpose Text
          Text(
            isTranslationMode
                ? 'برای استفاده آفلاین و بدون اینترنت ترجمه صوتی، سوره و گوینده مورد نظر خود را انتخاب و دانلود کنید.'
                : 'برای استفاده آفلاین و بدون اینترنت صوت قرآن، سوره و قاری مورد نظر خود را انتخاب و دانلود کنید.',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.5,
              height: 1.5,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 12),

          // Reciter Selector Hero Card with photo background & gradient
          InkWell(
            onTap: () {
              ReciterSelectionBottomSheet.show(
                context,
                isDownloadMode: true,
                isTranslationMode: isTranslationMode,
                onReciterSelected: (ReciterEntity reciter) {
                  ref.read(downloadManagerSelectedReciterProvider.notifier).setReciter(reciter);
                  if (isTranslationMode) {
                    ref.read(quranAudioControllerProvider.notifier).selectTranslationReciter(reciter);
                  } else {
                    ref.read(quranAudioControllerProvider.notifier).selectReciter(reciter);
                  }
                },
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorderColor, width: 1.2),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Stack(
                children: [
                  // 1. Reciter photo background on the RIGHT with zoom & gradient fade to transparent
                  if (hasImage)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 210,
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              Colors.black.withValues(alpha: isDark ? 0.40 : 0.55),
                              Colors.black.withValues(alpha: isDark ? 0.18 : 0.25),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
                        child: Transform.scale(
                          scale: 1.45,
                          alignment: Alignment.centerRight,
                          child: AppCachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                  // 2. Foreground Card Content (No microphone icon)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        // Texts on Start (Right in RTL)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    isTranslationMode ? 'گوینده ترجمه' : 'قاری منتخب',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 11.5,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (selectedReciter?.styleName != null &&
                                      selectedReciter!.styleName!.isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                            alpha: isDark ? 0.25 : 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        selectedReciter.styleName!,
                                        style: TextStyle(
                                          fontFamily: AppTypography.fontFamily,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? AppColors.inversePrimary
                                              : AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedReciter?.name ??
                                    (isTranslationMode
                                        ? 'انتخاب گوینده'
                                        : 'انتخاب قاری'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Change button / chevron (no background, flipped icon direction)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'تغییر',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
