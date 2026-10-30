import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/widgets/app_snackbar.dart';
import 'package:quran/core/routes/route_name.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/khatm/application/controllers/khatm_detail_controller.dart';
import 'package:quran/features/khatm/application/controllers/khatm_list_controller.dart';
import 'package:quran/features/khatm/domain/entities/khatm_plan.dart';
import 'package:quran/features/khatm/domain/entities/khatm_session_item.dart';
import 'package:quran/features/khatm/domain/services/khatm_quran_resolver.dart';
import '../widgets/report/khatm_continue_button.dart';
import '../widgets/report/khatm_date_range_card.dart';
import '../widgets/report/khatm_progress_donut_chart.dart';
import '../widgets/report/khatm_session_tile.dart';
import '../widgets/report/khatm_session_timeline_header.dart';

/// Screen presenting the detailed Khatm Report & Sessions Timeline
/// styled cleanly to match the app's minimal Apple design system without decorative icons.
class KhatmDetailReportScreen extends ConsumerStatefulWidget {
  final String planId;

  const KhatmDetailReportScreen({
    super.key,
    required this.planId,
  });

  @override
  ConsumerState<KhatmDetailReportScreen> createState() =>
      _KhatmDetailReportScreenState();
}

class _KhatmDetailReportScreenState
    extends ConsumerState<KhatmDetailReportScreen> {
  late final ScrollController _scrollController = ScrollController();
  final GlobalKey _topCardsKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _findTargetIndex(KhatmPlan plan) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Check for session whose scheduled date is today
    final todayIdx = plan.sessions.indexWhere((s) {
      final d = DateTime(
        s.scheduledDate.year,
        s.scheduledDate.month,
        s.scheduledDate.day,
      );
      return d.isAtSameMomentAs(today);
    });
    if (todayIdx != -1) return todayIdx;

    // 2. Otherwise find the first uncompleted session
    final pendingIdx = plan.sessions.indexWhere((s) => !s.isCompleted);
    if (pendingIdx != -1) return pendingIdx;

    return 0;
  }

  void _scrollToSession(int index, int totalSessions) {
    if (!_scrollController.hasClients) return;
    HapticFeedback.lightImpact();

    // 1. Determine exact height of top cards dynamically (fallback 248.0)
    double topCardsHeight = 248.0;
    final renderBox =
        _topCardsKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      // 14 top padding + measured column height + 12 bottom padding
      topCardsHeight = 14.0 + renderBox.size.height + 12.0;
    }

    // 2. Each session tile has minHeight of 52.0px.
    const tileEstimatedHeight = 52.0;

    // To position the item completely below the sticky header without being obscured,
    // we scroll topCardsHeight + item offset, with a comfortable 14px margin so it's
    // clearly visible below the header divider.
    final targetOffset =
        (topCardsHeight + (index * tileEstimatedHeight) - 14.0)
            .clamp(0.0, _scrollController.position.maxScrollExtent);

    final currentOffset = _scrollController.offset;
    final distance = (targetOffset - currentOffset).abs();

    // For long distances, jump near the target to prevent intermediate widget build lag
    if (distance > 700) {
      final preOffset = targetOffset > currentOffset
          ? targetOffset - 250
          : targetOffset + 250;
      _scrollController.jumpTo(
        preOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      );
    }

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    HapticFeedback.lightImpact();
    final colors = context.colors;
    final isDark = context.isDark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          'حذف ختم',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: Theme.of(ctx).colorScheme.onSurface,
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            'آیا از حذف این برنامه ختم اطمینان دارید؟',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'انصراف',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13.5,
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? Colors.white12 : Colors.black87,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'حذف',
              style: TextStyle(
                color: Colors.white,
                fontFamily: AppTypography.fontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(khatmDetailControllerProvider(widget.planId).notifier)
          .deletePlan();
      if (success && context.mounted) {
        AppSnackBar.showSuccess(context, 'برنامه ختم حذف شد.');
        context.pop();
      }
    }
  }

  void _onContinueKhatm(BuildContext context) {
    HapticFeedback.lightImpact();
    final state = ref.read(khatmDetailControllerProvider(widget.planId));
    final plan = state.plan;
    if (plan == null) return;

    final nextSession = plan.nextPendingSession;
    if (nextSession == null) {
      AppSnackBar.showInfo(context, 'تمام جلسات این ختم به پایان رسیده است.');
      return;
    }

    final unitToNavigate = (nextSession.lastReadUnit != null &&
            nextSession.lastReadUnit! >= nextSession.fromUnit &&
            nextSession.lastReadUnit! <= nextSession.toUnit)
        ? nextSession.lastReadUnit!
        : nextSession.fromUnit;

    final target = KhatmQuranResolver.resolveUnit(
      unitType: plan.unitType,
      unitNumber: unitToNavigate,
    );

    context.pushNamed(
      quranReaderRoute,
      pathParameters: {'id': target.surahId.toString()},
      queryParameters: {
        'ayah': target.ayahNumber.toString(),
        'khatmId': plan.id,
        'khatmSession': nextSession.sessionIndex.toString(),
      },
    ).then((_) {
      if (!mounted) return;
      ref.read(khatmDetailControllerProvider(widget.planId).notifier).loadPlan();
      ref.read(khatmListControllerProvider.notifier).loadPlans();
    });
  }

  void _onSessionTap(KhatmPlan plan, KhatmSessionItem session) {
    final unitToNavigate = (!session.isCompleted &&
            session.lastReadUnit != null &&
            session.lastReadUnit! >= session.fromUnit &&
            session.lastReadUnit! <= session.toUnit)
        ? session.lastReadUnit!
        : session.fromUnit;

    final target = KhatmQuranResolver.resolveUnit(
      unitType: plan.unitType,
      unitNumber: unitToNavigate,
    );

    context.pushNamed(
      quranReaderRoute,
      pathParameters: {'id': target.surahId.toString()},
      queryParameters: {
        'ayah': target.ayahNumber.toString(),
        if (!session.isCompleted) ...{
          'khatmId': plan.id,
          'khatmSession': session.sessionIndex.toString(),
        },
      },
    ).then((_) {
      if (!mounted) return;
      ref
          .read(khatmDetailControllerProvider(widget.planId).notifier)
          .loadPlan();
      ref
          .read(khatmListControllerProvider.notifier)
          .loadPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    final state = ref.watch(khatmDetailControllerProvider(widget.planId));
    final controller =
        ref.read(khatmDetailControllerProvider(widget.planId).notifier);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final plan = state.plan;
    if (plan == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'گزارش ختم',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: colors.cardBackground,
          leading: IconButton(
            tooltip: 'بازگشت',
            icon: Icon(
              CupertinoIcons.chevron_forward,
              size: 24,
              color: colorScheme.onSurface,
            ),
            splashRadius: 22,
            onPressed: () {
              HapticFeedback.lightImpact();
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.pop();
              }
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.8),
            child: Container(
              color: colors.cardBorder,
              height: 0.8,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage ?? 'ختم یافت نشد',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'بازگشت',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'گزارش ختم',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colors.cardBackground,
        leading: IconButton(
          tooltip: 'بازگشت',
          icon: Icon(
            CupertinoIcons.chevron_forward,
            size: 24,
            color: colorScheme.onSurface,
          ),
          splashRadius: 22,
          onPressed: () {
            HapticFeedback.lightImpact();
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.pop();
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.8),
          child: Container(
            color: colors.cardBorder,
            height: 0.8,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextButton(
              onPressed: () => _confirmDelete(context),
              child: Text(
                'حذف',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: themeErrorColor(context),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Top Header Section (Donut Chart & Date Range) ────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        key: _topCardsKey,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Card 1: Donut Progress Chart ─────────────────
                          KhatmProgressDonutChart(
                            title: plan.title,
                            totalUnits: plan.totalUnits,
                            completedUnits: plan.completedUnits,
                            unitLabel: plan.unitLabel,
                          ),
                          const SizedBox(height: 12),

                          // ── Card 2: Date Range (Zero icons) ──────────────
                          KhatmDateRangeCard(
                            startDateFa: plan.startDateFa,
                            endDateFa: plan.endDateFa,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Pinned Sticky Header (Title, Today Jump Chip, Column Headers) ─
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _KhatmTimelineStickyHeaderDelegate(
                      plan: plan,
                      onJumpToToday: !plan.isCompleted && plan.sessions.isNotEmpty
                          ? () {
                              final targetIdx = _findTargetIndex(plan);
                              _scrollToSession(
                                targetIdx,
                                plan.sessions.length,
                              );
                            }
                          : null,
                    ),
                  ),

                  // ── Virtualized Timeline Sessions List (SliverList) ───────
                  if (plan.sessions.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: Text('جلسه‌ای تعریف نشده است')),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverList.builder(
                        itemCount: plan.sessions.length,
                        itemBuilder: (context, index) {
                          final session = plan.sessions[index];
                          return KhatmSessionTile(
                            session: session,
                            unitType: plan.unitType,
                            isFirst: index == 0,
                            isLast: index == plan.sessions.length - 1,
                            onToggle: (val) {
                              controller.toggleSession(
                                session.sessionIndex,
                                val,
                              );
                            },
                            onSessionTap: () {
                              _onSessionTap(plan, session);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // ── Docked Bottom Continue Khatm Button ────────────────────────
            KhatmContinueButton(
              isEnabled: !plan.isCompleted,
              label: plan.isCompleted ? 'ختم تکمیل شده است' : 'ادامه ختم',
              onPressed: () => _onContinueKhatm(context),
            ),
          ],
        ),
      ),
    );
  }

  Color themeErrorColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }
}

/// Pinned persistent sticky header for the sessions timeline.
/// Holds the section title, "نوبت امروز" jump chip, and table column headers.
class _KhatmTimelineStickyHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final KhatmPlan plan;
  final VoidCallback? onJumpToToday;

  _KhatmTimelineStickyHeaderDelegate({
    required this.plan,
    this.onJumpToToday,
  });

  @override
  double get minExtent => 74.0;

  @override
  double get maxExtent => 74.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    return Container(
      height: 74.0,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Section Title & Jump to Today Button ─────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'گزارش تلاوت براساس تاریخ',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : const Color(0xFF5A554E),
                  ),
                ),
                if (!plan.isCompleted &&
                    plan.sessions.isNotEmpty &&
                    onJumpToToday != null)
                  GestureDetector(
                    onTap: onJumpToToday,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.cardBorder,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.arrow_down_to_line,
                            size: 12,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'نوبت امروز',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // ── Table Column Headers (ردیف | عنوان | تاریخ) ───
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: KhatmSessionTimelineHeader(),
          ),

          // ── Divider ──────────────────────────────────────
          Container(
            height: 0.8,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: colors.cardBorder,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(
      covariant _KhatmTimelineStickyHeaderDelegate oldDelegate) {
    return oldDelegate.plan != plan ||
        oldDelegate.onJumpToToday != onJumpToToday;
  }
}
