import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/size_extension.dart';
import 'package:quran/core/routes/route_name.dart';
import 'package:quran/core/theme/app_colors.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/khatm/application/controllers/khatm_list_controller.dart';
import 'package:quran/features/khatm/application/controllers/personal_khatm_sync_controller.dart';
import 'package:quran/features/khatm/domain/entities/khatm_plan.dart';
import 'package:quran/features/khatm/infrastructure/datasources/khatm_mock_data.dart';
import 'khatm_list_card.dart';
import 'khatm_skeleton.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// تست بصری و بررسی تجربه کاربری (Mock Mode Toggle)
/// با تغییر این فلگ به false، ویجت به منطق اصلی هایو (دیتای واقعی) برمی‌گردد.
/// ─────────────────────────────────────────────────────────────────────────────
const bool _showMockActiveKhatms = false;

/// Clean Apple-style Sacred Serenity Home Section for Quran Khatm & Study Plans,
/// incorporating both Group Campaigns and Individual Reading Plans.
class KhatmHomeSection extends ConsumerWidget {
  const KhatmHomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    // Keep personal khatm sync controller active so it auto-syncs with backend
    ref.watch(personalKhatmSyncControllerProvider);

    final state = ref.watch(khatmListControllerProvider);
    final plans = state.plans;
    final isLoading = state.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── ۱. هدر بخش (تراز افقی و حس خلوت مینیمال) ─────────────────────────
        _buildSectionHeader(context, ref, plans, isDark, colorScheme),
        8.vSpace,

        // ── ۲. ردیف کارت‌های فعال (دیتای ماک جهت ارزیابی بصری vs دیتای واقعی) ──
        if (_showMockActiveKhatms)
          _buildMockActiveKhatmList(
            context,
            ref,
            plans,
            colors,
            colorScheme,
            isDark,
          )
        else if (isLoading && plans.isEmpty)
          KhatmSkeletonScope(
            child: Container(
              height: 110,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: colors.cardBackgroundSubtle,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        KhatmSkeletonBox(width: 130, height: 15),
                        SizedBox(height: 10),
                        KhatmSkeletonBox(width: 90, height: 11),
                      ],
                    ),
                  ),
                  KhatmSkeletonRing(size: 40, strokeWidth: 3.5),
                ],
              ),
            ),
          )
        else if (plans.isEmpty)
          _buildEmptyKhatmCard(context, ref, colors, colorScheme, isDark)
        else if (plans.length == 1)
          KhatmListCard(
            key: ValueKey(plans.first.id),
            plan: plans.first,
            margin: EdgeInsets.zero,
          )
        else
          _buildHorizontalKhatmList(
            context,
            ref,
            plans,
            colors: colors,
            colorScheme: colorScheme,
            isDark: isDark,
          ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ۱. هدر بخش: هماهنگ با هدر بخش دسترسی سریع
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(
    BuildContext context,
    WidgetRef ref,
    List<KhatmPlan> plans,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: SizedBox(
        height: 32,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // سمت راست: عنوان اصلی بخش (+ دکمه بعلاوه فقط زمانی که لیست خالی نیست)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'برنامه ختم',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : const Color(0xFF5A554E),
                  ),
                ),
                if (_showMockActiveKhatms || plans.isNotEmpty) ...[
                  6.hSpace,
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showCreateKhatmBottomSheet(context, ref);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colors.cardBackgroundSubtle,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.cardBorder,
                          width: 0.8,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        CupertinoIcons.plus,
                        size: 12,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const Spacer(),

            // سمت چپ: لینک «همه» با آیکون chevron_left جهت مشاهده همه ختم‌ها
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.pushNamed(khatmListRoute).then((_) {
                  ref.read(khatmListControllerProvider.notifier).loadPlans();
                });
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'همه',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF6E6860),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      CupertinoIcons.chevron_left,
                      size: 11,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ۲. کارت خالی برای ایجاد ختم جدید (در صورت عدم وجود ختم فعال)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildEmptyKhatmCard(
    BuildContext context,
    WidgetRef ref,
    dynamic colors,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final primaryMint = colorScheme.primary;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showCreateKhatmBottomSheet(context, ref);
      },
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        painter: _DottedBorderPainter(
          color: isDark
              ? Colors.white.withValues(alpha: 0.20)
              : primaryMint.withValues(alpha: 0.25),
          strokeWidth: 1.0,
          dash: 5.0,
          gap: 4.0,
          radius: 16.0,
        ),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.02)
                : Colors.black.withValues(alpha: 0.015),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.plus, size: 17, color: primaryMint),
              6.hSpace,
              Text(
                'ایجاد برنامه ختم جدید',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: primaryMint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ۳. ردیف کارت‌های فعال (دیتای ماک تستی با عرض ۸۲٪)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildMockActiveKhatmList(
    BuildContext context,
    WidgetRef ref,
    List<KhatmPlan> plans,
    dynamic colors,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final cardWidth = (MediaQuery.of(context).size.width * 0.82).clamp(
      275.0,
      325.0,
    );

    final displayPlans = plans.isNotEmpty
        ? plans
        : [KhatmTestData.samplePersonalPlan];

    return SizedBox(
      height: 126,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        children: [
          // ── ۱. کارت‌های ختم شخصی (با باز شدن مستقیم صفحه جزئیات KhatmDetailReportScreen) ──
          for (final plan in displayPlans) ...[
            KhatmListCard(
              key: ValueKey(plan.id),
              plan: plan,
              cardWidth: cardWidth,
              margin: EdgeInsets.zero,
            ),
            const SizedBox(width: 10),
          ],

          // ── ۲. کارت ختم گروهی (تستی / متصل به صفحه جزئیات GroupKhatmDetailScreen) ──
          _buildMockGroupCard(
            context,
            colors: colors,
            colorScheme: colorScheme,
            isDark: isDark,
            width: cardWidth,
          ),
        ],
      ),
    );
  }

  /// کارت ختم گروهی با تگ طلایی و اتصال مستقیم به جزئیات و تلاوت
  Widget _buildMockGroupCard(
    BuildContext context, {
    required dynamic colors,
    required ColorScheme colorScheme,
    required bool isDark,
    required double width,
  }) {
    const goldColor = AppColors.goldAccent; // 0xFFC5A059

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            context.pushNamed(
              groupKhatmDetailRoute,
              pathParameters: {'code': 'test-khatm'},
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ردیف بالا: تگ کپسولی طلایی + درصد پیشرفت
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7.5,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: goldColor.withValues(
                          alpha: isDark ? 0.20 : 0.14,
                        ),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: goldColor.withValues(alpha: 0.35),
                          width: 0.6,
                        ),
                      ),
                      child: Text(
                        'ختم گروهی • ۳۶ ساعت مهلت',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFFF4E0A5)
                              : const Color(0xFF8A6C18),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '۴۰٪ تکمیل',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),

                // ردیف وسط: عنوان ختم و شماره جزء
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ختم قرآن هدیه به امام رضا (ع)',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          2.vSpace,
                          Text(
                            'سهم من: جزء ۷ • سوره اعراف',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // دکمه کپسولی سبز تلاوت
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.pushNamed(
                          quranReaderRoute,
                          pathParameters: {'id': '7'},
                          queryParameters: {
                            'ayah': '1',
                            'groupKhatmCode': 'test-khatm',
                            'groupSlotUnit': '7',
                            'groupSlotId': '7',
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 29,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'تلاوت',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ۴. باتم‌شیت انتخاب نوع ختم (فردی vs گروهی)
  // ───────────────────────────────────────────────────────────────────────────
  void _showCreateKhatmBottomSheet(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = context.isDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomCtx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border(
                top: BorderSide(
                  color: colors.cardBorder.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // دستگیره iOS
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white24
                            : Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  10.vSpace,

                  // عنوان هدر (بدون توضیحات اضافه)
                  Text(
                    'ایجاد ختم جدید',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  16.vSpace,

                  // گزینه ۱: ختم فردی (بدون آیکون، فقط عنوان)
                  _buildOptionRow(
                    context: bottomCtx,
                    title: 'ختم فردی',
                    theme: theme,
                    colors: colors,
                    colorScheme: colorScheme,
                    onTap: () {
                      Navigator.pop(bottomCtx);
                      context.pushNamed(createKhatmWizardRoute).then((_) {
                        ref
                            .read(khatmListControllerProvider.notifier)
                            .loadPlans();
                      });
                    },
                  ),
                  8.vSpace,

                  // گزینه ۲: ختم گروهی (بدون آیکون، فقط عنوان)
                  _buildOptionRow(
                    context: bottomCtx,
                    title: 'ختم گروهی',
                    theme: theme,
                    colors: colors,
                    colorScheme: colorScheme,
                    onTap: () {
                      Navigator.pop(bottomCtx);
                      context.pushNamed(createGroupKhatmRoute);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ردیف ساده و تمیز بدون آیکون و توضیحات اضافه
  Widget _buildOptionRow({
    required BuildContext context,
    required String title,
    required ThemeData theme,
    required dynamic colors,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackgroundSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.cardBorder.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Icon(
                  CupertinoIcons.chevron_left,
                  size: 14,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // لیست افقی واقعی (دست‌نخورده از کدهای قبلی جهت پایداری سیستم)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildHorizontalKhatmList(
    BuildContext context,
    WidgetRef ref,
    List<KhatmPlan> plans, {
    required dynamic colors,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final cardWidth = (MediaQuery.of(context).size.width * 0.78).clamp(
      260.0,
      310.0,
    );

    return SizedBox(
      height: 126,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        itemCount: plans.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final plan = plans[index];
          return KhatmListCard(
            key: ValueKey(plan.id),
            plan: plan,
            cardWidth: cardWidth,
            margin: EdgeInsets.zero,
          );
        },
      ),
    );
  }
}

/// Custom painter for rounded rectangle dashed/dotted border
class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double radius;

  const _DottedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dash = 5.0,
    this.gap = 4.0,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len = (distance + dash < metric.length)
            ? dash
            : metric.length - distance;
        final extractPath = metric.extractPath(distance, distance + len);
        canvas.drawPath(extractPath, paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dash != dash ||
      oldDelegate.gap != gap ||
      oldDelegate.radius != radius;
}
