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
  final bool isDeleting;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TafakorAyahChip({
    super.key,
    required this.reference,
    this.isDark = false,
    this.isDeleting = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Neutral colorless styling (subtle translucent gray/white/black)
    final bgColor = isDark
        ? const Color(0xFF232328)
        : const Color(0xFFF3F4F6);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);
    final textColor = isDark
        ? const Color(0xFFE5E7EB)
        : const Color(0xFF374151);
    final iconColor = isDark
        ? Colors.white54
        : Colors.black45;
    final xColor = isDark ? Colors.white60 : Colors.black45;

    final deleteButton = (onDelete != null || isDeleting)
        ? Tooltip(
            message: 'حذف ارجاع آیه',
            textStyle: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11,
              color: Colors.white,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isDeleting
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onDelete?.call();
                      },
                borderRadius: BorderRadius.circular(12),
                splashColor: isDark ? Colors.white12 : Colors.black12,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 7.0,
                    end: 3.0,
                    top: 5.0,
                    bottom: 5.0,
                  ),
                  child: isDeleting
                      ? SizedBox(
                          width: 11.5,
                          height: 11.5,
                          child: CupertinoActivityIndicator(
                            radius: 5.0,
                            color: xColor,
                          ),
                        )
                      : Icon(
                          CupertinoIcons.xmark,
                          size: 11.5,
                          color: xColor,
                        ),
                ),
              ),
            ),
          )
        : null;

    final ayahTapArea = Material(
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
        borderRadius: BorderRadiusDirectional.horizontal(
          start: Radius.circular(onDelete != null ? 5 : 10),
          end: const Radius.circular(10),
        ).resolve(Directionality.of(context)),
        splashColor: isDark ? Colors.white10 : Colors.black12,
        highlightColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: onDelete != null ? 4 : 9,
            end: 9,
            top: 5,
            bottom: 5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
              const SizedBox(width: 4),
              Icon(
                CupertinoIcons.chevron_left,
                size: 11,
                color: iconColor,
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 0.85),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ?deleteButton,
          ayahTapArea,
        ],
      ),
    );
  }
}

/// A horizontal scrollable section that displays all Quran references of a post in a single row.
class TafakorPostAyahBadgesSection extends StatelessWidget {
  final TafakorPost post;
  final bool isDark;
  final bool canModify;
  final bool Function(TafakorQuranReference reference)? isDeletingReference;
  final void Function(TafakorQuranReference reference)? onDeleteReference;

  const TafakorPostAyahBadgesSection({
    super.key,
    required this.post,
    required this.isDark,
    this.canModify = false,
    this.isDeletingReference,
    this.onDeleteReference,
  });

  @override
  Widget build(BuildContext context) {
    final refs = post.quranReferences;
    if (refs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: refs.map((ref) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: TafakorAyahChip(
                reference: ref,
                isDark: isDark,
                isDeleting: isDeletingReference?.call(ref) ?? false,
                onDelete: (canModify && onDeleteReference != null)
                    ? () => onDeleteReference!(ref)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

