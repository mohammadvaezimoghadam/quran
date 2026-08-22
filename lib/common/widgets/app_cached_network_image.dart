import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A reusable, cached network image component wrapping [CachedNetworkImage]
/// with standardized loading shimmer/indicator and graceful error/placeholder icon fallback states.
class AppCachedNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BoxShape shape;
  final BorderRadiusGeometry? borderRadius;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;
  final String? fallbackText;
  final IconData? fallbackIcon;
  final Color? backgroundColor;

  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.fallbackText,
    this.fallbackIcon,
    this.backgroundColor,
  });

  /// Specialized factory for circular avatars
  const factory AppCachedNetworkImage.circle({
    Key? key,
    required String? imageUrl,
    required double size,
    BoxFit fit,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
    String? fallbackText,
    IconData? fallbackIcon,
    Color? backgroundColor,
  }) = _AppCircleCachedNetworkImage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = backgroundColor ?? colorScheme.surfaceContainerHighest;
    final isPrimaryBg = backgroundColor == colorScheme.primary;
    final fallbackColor =
        isPrimaryBg ? colorScheme.onPrimary : colorScheme.primary;

    final hasUrl = imageUrl != null && imageUrl!.trim().isNotEmpty;

    Widget buildErrorFallback() {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          shape: shape,
          borderRadius: shape == BoxShape.circle ? null : borderRadius,
        ),
        alignment: Alignment.center,
        child: fallbackIcon != null
            ? Icon(
                fallbackIcon,
                color: fallbackColor,
                size: (height != null) ? height! * 0.48 : 22.0,
              )
            : Text(
                (fallbackText != null && fallbackText!.isNotEmpty)
                    ? fallbackText![0].toUpperCase()
                    : '؟',
                style: TextStyle(
                  color: fallbackColor,
                  fontWeight: FontWeight.bold,
                  fontSize: (height != null) ? height! * 0.4 : 14.0,
                ),
              ),
      );
    }

    if (!hasUrl) {
      return buildErrorFallback();
    }

    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder ??
          (context, url) => Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: shape,
                  borderRadius: shape == BoxShape.circle ? null : borderRadius,
                ),
                child: Center(
                  child: SizedBox(
                    width: (height != null) ? height! * 0.35 : 16.0,
                    height: (height != null) ? height! * 0.35 : 16.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: fallbackColor,
                    ),
                  ),
                ),
              ),
      errorWidget: errorWidget ??
          (context, url, error) => buildErrorFallback(),
    );

    if (shape == BoxShape.circle) {
      return ClipOval(child: imageWidget);
    } else if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

class _AppCircleCachedNetworkImage extends AppCachedNetworkImage {
  const _AppCircleCachedNetworkImage({
    super.key,
    required super.imageUrl,
    required double size,
    super.fit = BoxFit.cover,
    super.placeholder,
    super.errorWidget,
    super.fallbackText,
    super.fallbackIcon = CupertinoIcons.person_fill,
    super.backgroundColor,
  }) : super(
          width: size,
          height: size,
          shape: BoxShape.circle,
        );
}
