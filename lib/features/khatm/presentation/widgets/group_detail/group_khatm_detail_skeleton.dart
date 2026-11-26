import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';
import '../shared/khatm_skeleton.dart';

/// Skeleton loading placeholder matching the Group Khatm Detail Screen layout.
class GroupKhatmDetailSkeleton extends StatelessWidget {
  const GroupKhatmDetailSkeleton({super.key});

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
    final pillBg = isDark ? const Color(0xFF222224) : const Color(0xFFF3F1EC);

    return KhatmSkeletonScope(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── ۱. کارت هدر مشخصات و نمودار دایره‌ای ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: hairlineBorder,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const KhatmSkeletonBox(
                          width: 72,
                          height: 20,
                          borderRadius: 20,
                        ),
                        const SizedBox(height: 8),
                        const KhatmSkeletonBox(
                          width: 150,
                          height: 16,
                          borderRadius: 6,
                        ),
                        const SizedBox(height: 6),
                        const KhatmSkeletonBox(
                          width: 130,
                          height: 11,
                          borderRadius: 4,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: pillBg,
                            borderRadius: BorderRadius.circular(12),
                            border: hairlineBorder,
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    KhatmSkeletonBox(width: 36, height: 9),
                                    SizedBox(height: 5),
                                    KhatmSkeletonBox(width: 18, height: 12),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    KhatmSkeletonBox(width: 40, height: 9),
                                    SizedBox(height: 5),
                                    KhatmSkeletonBox(width: 18, height: 12),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    KhatmSkeletonBox(width: 36, height: 9),
                                    SizedBox(height: 5),
                                    KhatmSkeletonBox(width: 18, height: 12),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  const KhatmSkeletonRing(size: 100, strokeWidth: 7.5),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── ۲. کارت گرید ۴ ستونه سهم‌ها ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: hairlineBorder,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      KhatmSkeletonBox(width: 130, height: 16, borderRadius: 6),
                      KhatmSkeletonBox(width: 48, height: 22, borderRadius: 20),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: KhatmSkeletonBox(
                      width: 190,
                      height: 12,
                      borderRadius: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      KhatmSkeletonBox(width: 64, height: 28, borderRadius: 10),
                      SizedBox(width: 8),
                      KhatmSkeletonBox(width: 64, height: 28, borderRadius: 10),
                      SizedBox(width: 8),
                      KhatmSkeletonBox(width: 64, height: 28, borderRadius: 10),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 8,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.12,
                    ),
                    itemBuilder: (_, _) {
                      return Container(
                        decoration: BoxDecoration(
                          color: pillBg,
                          borderRadius: BorderRadius.circular(12),
                          border: hairlineBorder,
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            KhatmSkeletonBox(
                              width: 24,
                              height: 9,
                              borderRadius: 3,
                            ),
                            SizedBox(height: 5),
                            KhatmSkeletonBox(
                              width: 20,
                              height: 13,
                              borderRadius: 4,
                            ),
                            SizedBox(height: 4),
                            KhatmSkeletonBox(
                              width: 26,
                              height: 8,
                              borderRadius: 3,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── ۳. کارت همراهان ──
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(16),
                border: hairlineBorder,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      KhatmSkeletonBox(width: 22, height: 22, isCircle: true),
                      SizedBox(width: 8),
                      KhatmSkeletonBox(width: 145, height: 12),
                    ],
                  ),
                  KhatmSkeletonBox(width: 44, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
