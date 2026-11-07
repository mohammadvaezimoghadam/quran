import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/quran_reader/application/controllers/quran_reader_controller.dart';
import '../../../../features/tafakor/presentation/widgets/ayah_notes_bottom_sheet.dart';
import '../../domain/entities/ayah_teaser_item.dart';

/// Floating teaser card (speech bubble tooltip) that notifies users about latest community notes on an Ayah.
/// Features a compact size and a sharp downward pointer (beak) at the bottom-right corner.
class AyahTeaserCard extends ConsumerWidget {
  final AyahTeaserItem item;
  final int surahId;
  final String? surahName;
  final VoidCallback? onDismiss;

  static const double beakHeight = 6.5;
  static const double beakWidth = 10.0;
  static const double beakRightOffset = 16.0;
  static const double cornerRadius = 12.0;

  const AyahTeaserCard({
    super.key,
    required this.item,
    required this.surahId,
    this.surahName,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF1E2328) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFE5E5EA);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.08);

    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark
        ? const Color(0xFFB0B0B0)
        : const Color(0xFF4A4A4A);

    return CustomPaint(
      painter: BubbleCalloutPainter(
        color: bgColor,
        borderColor: borderColor,
        borderWidth: 0.8,
        radius: cornerRadius,
        beakWidth: beakWidth,
        beakHeight: beakHeight,
        beakRightOffset: beakRightOffset,
        shadowColor: shadowColor,
      ),
      child: ClipPath(
        clipper: BubbleCalloutClipper(
          radius: cornerRadius,
          beakWidth: beakWidth,
          beakHeight: beakHeight,
          beakRightOffset: beakRightOffset,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              final allAyahs = ref.read(quranReaderControllerProvider).ayahs;
              final ayahEntity =
                  allAyahs.where((a) => a.ayahNumber == item.ayah).firstOrNull;

              AyahNotesBottomSheet.show(
                context,
                surahNumber: surahId,
                ayahNumber: item.ayah,
                surahName: surahName ?? 'سوره $surahId',
                ayahArabicText: ayahEntity?.arabicText ?? '',
                translationText: ayahEntity?.translationText,
                ayahEntity: ayahEntity,
              );
            },
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 215,
                minWidth: 150,
              ),
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8 + beakHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Row 1: Author Avatar + Name + Dismiss Button
                  Row(
                    children: [
                      _buildAvatar(item.author.avatar, isDark),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.author.name,
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onDismiss != null)
                        GestureDetector(
                          onTap: onDismiss,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                              CupertinoIcons.xmark,
                              size: 11,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Row 2: Note Content Preview
                  Text(
                    item.contentPreview,
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w400,
                      color: subtitleColor,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl, bool isDark) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          avatarUrl,
          width: 22,
          height: 22,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildFallbackAvatar(isDark),
        ),
      );
    }
    return _buildFallbackAvatar(isDark);
  }

  Widget _buildFallbackAvatar(bool isDark) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF2C3238) : const Color(0xFFE8EEF5),
      ),
      child: Icon(
        CupertinoIcons.person_fill,
        size: 12,
        color: isDark ? Colors.white70 : const Color(0xFF4A6572),
      ),
    );
  }
}

/// Custom painter for rounded speech bubble with sharp downward beak on bottom-right
class BubbleCalloutPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final double radius;
  final double beakWidth;
  final double beakHeight;
  final double beakRightOffset;
  final Color shadowColor;

  const BubbleCalloutPainter({
    required this.color,
    required this.borderColor,
    this.borderWidth = 0.8,
    required this.radius,
    required this.beakWidth,
    required this.beakHeight,
    required this.beakRightOffset,
    required this.shadowColor,
  });

  Path _getBubblePath(Rect rect) {
    final path = Path();
    final bodyBottom = rect.bottom - beakHeight;

    // 1. Start top-left after radius
    path.moveTo(rect.left + radius, rect.top);

    // 2. Top edge -> top-right corner
    path.lineTo(rect.right - radius, rect.top);
    path.arcToPoint(
      Offset(rect.right, rect.top + radius),
      radius: Radius.circular(radius),
    );

    // 3. Right edge -> bottom-right corner
    path.lineTo(rect.right, bodyBottom - radius);
    path.arcToPoint(
      Offset(rect.right - radius, bodyBottom),
      radius: Radius.circular(radius),
    );

    // 4. Bottom edge with sharp downward beak on right side
    final beakStart = rect.right - beakRightOffset;
    final beakTipX = rect.right - beakRightOffset - (beakWidth / 2);
    final beakTipY = rect.bottom;
    final beakEndX = rect.right - beakRightOffset - beakWidth;

    path.lineTo(beakStart, bodyBottom);
    path.lineTo(beakTipX, beakTipY);
    path.lineTo(beakEndX, bodyBottom);

    // 5. Remaining bottom edge -> bottom-left corner
    path.lineTo(rect.left + radius, bodyBottom);
    path.arcToPoint(
      Offset(rect.left, bodyBottom - radius),
      radius: Radius.circular(radius),
    );

    // 6. Left edge -> top-left corner
    path.lineTo(rect.left, rect.top + radius);
    path.arcToPoint(
      Offset(rect.left + radius, rect.top),
      radius: Radius.circular(radius),
    );

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = _getBubblePath(rect);

    // 1. Soft custom shadow
    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);

    // 2. Background fill
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 3. Crisp vector border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant BubbleCalloutPainter oldDelegate) {
    return color != oldDelegate.color ||
        borderColor != oldDelegate.borderColor ||
        borderWidth != oldDelegate.borderWidth ||
        radius != oldDelegate.radius ||
        beakWidth != oldDelegate.beakWidth ||
        beakHeight != oldDelegate.beakHeight ||
        beakRightOffset != oldDelegate.beakRightOffset ||
        shadowColor != oldDelegate.shadowColor;
  }
}

/// Custom clipper to ensure ink splash stays inside the bubble + beak path
class BubbleCalloutClipper extends CustomClipper<Path> {
  final double radius;
  final double beakWidth;
  final double beakHeight;
  final double beakRightOffset;

  const BubbleCalloutClipper({
    required this.radius,
    required this.beakWidth,
    required this.beakHeight,
    required this.beakRightOffset,
  });

  @override
  Path getClip(Size size) {
    final rect = Offset.zero & size;
    final path = Path();
    final bodyBottom = rect.bottom - beakHeight;

    path.moveTo(rect.left + radius, rect.top);
    path.lineTo(rect.right - radius, rect.top);
    path.arcToPoint(
      Offset(rect.right, rect.top + radius),
      radius: Radius.circular(radius),
    );

    path.lineTo(rect.right, bodyBottom - radius);
    path.arcToPoint(
      Offset(rect.right - radius, bodyBottom),
      radius: Radius.circular(radius),
    );

    final beakStart = rect.right - beakRightOffset;
    final beakTipX = rect.right - beakRightOffset - (beakWidth / 2);
    final beakTipY = rect.bottom;
    final beakEndX = rect.right - beakRightOffset - beakWidth;

    path.lineTo(beakStart, bodyBottom);
    path.lineTo(beakTipX, beakTipY);
    path.lineTo(beakEndX, bodyBottom);

    path.lineTo(rect.left + radius, bodyBottom);
    path.arcToPoint(
      Offset(rect.left, bodyBottom - radius),
      radius: Radius.circular(radius),
    );

    path.lineTo(rect.left, rect.top + radius);
    path.arcToPoint(
      Offset(rect.left + radius, rect.top),
      radius: Radius.circular(radius),
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant BubbleCalloutClipper oldClipper) {
    return radius != oldClipper.radius ||
        beakWidth != oldClipper.beakWidth ||
        beakHeight != oldClipper.beakHeight ||
        beakRightOffset != oldClipper.beakRightOffset;
  }
}
