import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran_reader/presentation/ui/quran_reader_screen.dart';
import '../../domain/entities/tafakor_post.dart';
import '../../domain/entities/tafakor_quran_reference.dart';

/// Islamic Quran Ayah Chip for Reverse Linkage.
/// When tapped, smoothly navigates directly to `QuranReaderScreen` jumping to the specific Surah and Ayah.
class TafakorAyahChip extends StatelessWidget {
  final TafakorQuranReference reference;
  final bool isDark;
  final VoidCallback? onTap;

  const TafakorAyahChip({
    super.key,
    required this.reference,
    this.isDark = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Theme colors tailored for Islamic aesthetics (subtle emerald tones)
    final bgColor = isDark
        ? const Color(0xFF10261E)
        : const Color(0xFFF0FDF4);
    final borderColor = isDark
        ? const Color(0xFF1D4D39)
        : const Color(0xFFBBEFCA);
    final primaryEmerald = isDark
        ? const Color(0xFF34D399)
        : const Color(0xFF047857);
    final textColor = isDark
        ? const Color(0xFFA7F3D0)
        : const Color(0xFF065F46);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          if (onTap != null) {
            onTap!();
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => QuranReaderScreen(
                surahId: reference.surahNumber,
                surahName: reference.surahName,
                initialAyahNumber: reference.ayahNumber,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: primaryEmerald.withValues(alpha: 0.15),
        highlightColor: primaryEmerald.withValues(alpha: 0.08),
        child: Ink(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 0.85),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.book_fill,
                size: 13.5,
                color: primaryEmerald,
              ),
              const SizedBox(width: 6),
              Text(
                'سوره ${reference.surahName} • آیه ${reference.ayahNumber.toPersianDigit()}',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                CupertinoIcons.chevron_left,
                size: 10.5,
                color: primaryEmerald.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A wrap section that displays all Quran references of a post.
class TafakorPostAyahBadgesSection extends StatelessWidget {
  final TafakorPost post;
  final bool isDark;

  const TafakorPostAyahBadgesSection({
    super.key,
    required this.post,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final refs = post.quranReferences;
    if (refs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 6.0,
        children: refs.map((ref) => TafakorAyahChip(reference: ref, isDark: isDark)).toList(),
      ),
    );
  }
}

