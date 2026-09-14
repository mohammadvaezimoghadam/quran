import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../common/constants/app_constants.dart';
import '../../../../../common/extensions/context_extension.dart';
import '../../../../../common/extensions/int_extension.dart';
import '../../../../../common/extensions/size_extension.dart';
import '../../../../../common/extensions/surah_name_extension.dart';
import '../../../../../common/widgets/app_loading_indicator.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../application/controllers/home_controller.dart';

/// Premium Ayah of the Day Widget.
class AyahOfTheDayCard extends ConsumerStatefulWidget {
  const AyahOfTheDayCard({super.key});

  @override
  ConsumerState<AyahOfTheDayCard> createState() => _AyahOfTheDayCardState();
}

class _AyahOfTheDayCardState extends ConsumerState<AyahOfTheDayCard> {
  bool _isExpanded = false;

  static const Duration animationDuration = Duration(milliseconds: 500);
  static const Curve animationCurve = Curves.easeInOutCubic;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ayahOfTheDayControllerProvider);
    final controller = ref.read(ayahOfTheDayControllerProvider.notifier);
    final colorScheme = context.colorScheme;
    final colors = context.colors;

    // 1. Loading State
    if (state.isLoading) {
      return const _CardWrapper(
        height: AppDimens.cardBaseHeight,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppLoadingIndicator(),
              SizedBox(height: AppDimens.stackSm),
              Text(
                AppConstants.loadingAyahOfTheDay,
                style: AppTypography.statusMessage,
              ),
            ],
          ),
        ),
      );
    }

    // 2. Error State
    if (state.errorMessage != null) {
      return _CardWrapper(
        height: AppDimens.cardBaseHeight,
        isError: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.wifi_slash,
              color: colorScheme.error,
              size: AppDimens.iconMd,
            ),
            6.vSpace,
            Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: AppTypography.statusMessage.copyWith(color: colorScheme.error),
            ),
            8.vSpace,
            SizedBox(
              height: 30,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.fetchAyahOfTheDay();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.gutterGrid),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  ),
                ),
                icon: const Icon(CupertinoIcons.refresh, size: AppDimens.iconXs),
                label: const Text(
                  AppConstants.retryButtonLabel,
                  style: AppTypography.buttonLabel,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 3. Success State: Smoothly Animated Ayah Card
    final ayah = state.ayah;
    if (ayah == null) return const SizedBox.shrink();

    return _CardWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed Header: Title + Reusable Audio Play Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.stackSm,
                  vertical: AppDimens.stackXxSm,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.sparkles,
                      color: Colors.white.withValues(alpha: 0.80),
                      size: AppDimens.iconSm,
                    ),
                    6.hSpace,
                    const Text(
                      AppConstants.ayahOfTheDayTitle,
                      style: AppTypography.cardHeader,
                    ),
                  ],
                ),
              ),
            ],
          ),
          6.vSpace,

          // Isolated Paragraph Text Area (Smooth 500ms AnimatedSize)
          AnimatedSize(
            duration: animationDuration,
            curve: animationCurve,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Arabic Text
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    ayah.arabicText,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLines: _isExpanded ? null : 2,
                    overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: AppTypography.displayQuranCompact,
                  ),
                ),
                4.vSpace,

                // Persian Translation
                Text(
                  ayah.translationText,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  maxLines: _isExpanded ? null : 1,
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: AppTypography.translationTextSm.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          6.vSpace,

          // Toggle Button ("مشاهده بیشتر / بستن")
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.stackXs,
                  vertical: AppDimens.stackXxSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isExpanded
                          ? AppConstants.collapseButtonLabel
                          : AppConstants.readMoreButtonLabel,
                      style: AppTypography.actionButtonLabel,
                    ),
                    const SizedBox(width: AppDimens.stackXxSm),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: animationDuration,
                      curve: animationCurve,
                      child: Icon(
                        CupertinoIcons.chevron_down,
                        color: colors.goldAccent,
                        size: AppDimens.iconXs,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          8.vSpace,

          // Fixed Footer: Surah & Ayah Info
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'سوره ${ayah.surahNumber.surahNameFa} • ${AppConstants.ayahLabel} ${ayah.ayahNumber.toPersianDigit()}',
                style: AppTypography.badgeLabelSm.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Private Card Container Wrapper with theme-aware gradient, downward shadow & Islamic pattern
class _CardWrapper extends StatelessWidget {
  final Widget child;
  final double? height;
  final bool isError;

  const _CardWrapper({
    required this.child,
    this.height,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final gradientColors = isError
        ? [colorScheme.errorContainer, colorScheme.errorContainer]
        : (isDark
            ? [colorScheme.primaryContainer, colorScheme.surfaceContainerHigh]
            : [colorScheme.primary, colorScheme.primaryContainer]);

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: isDark
            ? null // در حالت تاریک شدو نداریم - عمق با رنگ سطح نشان داده میشه
            : [
                BoxShadow(
                  color: (isError ? colorScheme.error : colorScheme.primary)
                      .withValues(alpha: 0.14),
                  blurRadius: 24.0,
                  spreadRadius: -8.0,
                  offset: const Offset(0, 12.0),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        child: Stack(
          children: [
            if (!isError)
              Positioned.fill(
                child: Opacity(
                  opacity: isDark ? 0.35 : 0.55,
                  child: const Image(
                    image: AssetImage(AppConstants.ayahCardBgAsset),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.gutterGrid,
                vertical: AppDimens.cardPaddingVertical,
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
