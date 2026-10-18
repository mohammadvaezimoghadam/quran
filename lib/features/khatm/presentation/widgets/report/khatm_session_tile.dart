import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/extensions/string_extension.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';
import 'package:quran/features/khatm/domain/entities/khatm_session_item.dart';

/// Single row item in the Khatm sessions timeline.
class KhatmSessionTile extends StatelessWidget {
  final KhatmSessionItem session;
  final KhatmUnitType unitType;
  final bool isFirst;
  final bool isLast;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onSessionTap;

  const KhatmSessionTile({
    super.key,
    required this.session,
    required this.unitType,
    this.isFirst = false,
    this.isLast = false,
    this.onToggle,
    this.onSessionTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final primary = colorScheme.primary;
    final isCompleted = session.isCompleted;

    final dateColor = isDark ? Colors.white54 : const Color(0xFF7A756D);
    final rowBorder = Border(
      bottom: BorderSide(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : colors.cardBorder.withValues(alpha: 0.5),
        width: 0.7,
      ),
    );

    final status = session.computeStatus();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(border: isLast ? null : rowBorder),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── ردیف: Timeline Node with checkbox toggle (Right in RTL) ──
            SizedBox(
              width: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Vertical dotted connector line
                  CustomPaint(
                    size: const Size(2, double.infinity),
                    painter: _DottedLinePainter(
                      color: primary.withValues(alpha: 0.35),
                      isFirst: isFirst,
                      isLast: isLast,
                    ),
                  ),
                  // Circled node badge (tap to toggle completion)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onToggle?.call(!isCompleted);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? primary : colors.cardBackground,
                        border: Border.all(
                          color: isCompleted
                              ? primary
                              : primary.withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                CupertinoIcons.checkmark,
                                size: 14,
                                color: Colors.white,
                              )
                            : Text(
                                (session.sessionIndex + 1).toPersianDigit(),
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                  fontSize: 11.5,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── عنوان جلسه (Middle in RTL) ──
            Expanded(
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (onSessionTap != null) {
                    onSessionTap!();
                  } else {
                    onToggle?.call(!isCompleted);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          session.computeTitle(unitType),
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            fontWeight: isCompleted
                                ? FontWeight.normal
                                : FontWeight.w600,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted
                                ? (isDark ? Colors.white38 : Colors.black38)
                                : colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (!isCompleted && status == KhatmSessionStatus.current) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'امروز',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                      ] else if (!isCompleted &&
                          status == KhatmSessionStatus.missed) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'معوقه',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ── تاریخ (Left in RTL) ──
            SizedBox(
              width: 85,
              child: Center(
                child: Text(
                  session.scheduledDateFa.toPersianDigit(),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11.5,
                    color: dateColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws vertical dotted line connecting timeline nodes.
class _DottedLinePainter extends CustomPainter {
  final Color color;
  final bool isFirst;
  final bool isLast;

  _DottedLinePainter({
    required this.color,
    required this.isFirst,
    required this.isLast,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final startY = isFirst ? size.height / 2 : 0.0;
    final endY = isLast ? size.height / 2 : size.height;
    final x = size.width / 2;

    const dashHeight = 4.0;
    const dashSpace = 3.5;

    double currentY = startY;
    while (currentY < endY) {
      canvas.drawLine(
        Offset(x, currentY),
        Offset(x, (currentY + dashHeight).clamp(0.0, endY)),
        paint,
      );
      currentY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isFirst != isFirst ||
        oldDelegate.isLast != isLast;
  }
}
