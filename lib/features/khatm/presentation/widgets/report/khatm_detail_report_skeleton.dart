import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import '../shared/khatm_skeleton.dart';

/// Skeleton loading placeholder matching the Personal Khatm Report Detail Screen.
class KhatmDetailReportSkeleton extends StatelessWidget {
  const KhatmDetailReportSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;
    final hairlineBorder = Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.04),
      width: 0.5,
    );

    return KhatmSkeletonScope(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── ۱. کارت گزارش پیشرفت دونات ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: hairlineBorder,
              ),
              child: const Column(
                children: [
                  KhatmSkeletonBox(width: 150, height: 15, borderRadius: 5),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                KhatmSkeletonBox(
                                  width: 10,
                                  height: 10,
                                  isCircle: true,
                                ),
                                SizedBox(width: 8),
                                KhatmSkeletonBox(width: 120, height: 12),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                KhatmSkeletonBox(
                                  width: 10,
                                  height: 10,
                                  isCircle: true,
                                ),
                                SizedBox(width: 8),
                                KhatmSkeletonBox(width: 110, height: 12),
                              ],
                            ),
                          ],
                        ),
                      ),
                      KhatmSkeletonRing(size: 84, strokeWidth: 7.5),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── ۲. کارت بازه زمانی شروع و پایان ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: hairlineBorder,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KhatmSkeletonBox(width: 56, height: 11),
                      SizedBox(height: 6),
                      KhatmSkeletonBox(width: 84, height: 13),
                    ],
                  ),
                  Container(
                    width: 0.6,
                    height: 28,
                    color: colors.cardBorder.withValues(alpha: 0.5),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      KhatmSkeletonBox(width: 56, height: 11),
                      SizedBox(height: 6),
                      KhatmSkeletonBox(width: 84, height: 13),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── ۳. هدر لیست جلسات ──
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                KhatmSkeletonBox(width: 115, height: 15),
                KhatmSkeletonBox(width: 72, height: 24, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 12),

            // ── ۴. ردیف‌های اسکلتون جلسات ──
            ...List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  height: 62,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: hairlineBorder,
                  ),
                  child: const Row(
                    children: [
                      KhatmSkeletonBox(width: 24, height: 24, isCircle: true),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            KhatmSkeletonBox(width: 130, height: 13),
                            SizedBox(height: 6),
                            KhatmSkeletonBox(width: 88, height: 10),
                          ],
                        ),
                      ),
                      KhatmSkeletonBox(width: 52, height: 22, borderRadius: 8),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
