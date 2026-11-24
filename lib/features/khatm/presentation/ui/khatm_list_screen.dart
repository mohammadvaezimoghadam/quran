import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/extensions/string_extension.dart';
import 'package:quran/common/utils/jalali_date.dart';
import 'package:quran/common/widgets/app_segmented_tab_bar.dart';
import 'package:quran/core/theme/app_typography.dart';
import '../../../../core/routes/route_name.dart';
import '../../../tafakor/application/controllers/tafakor_auth_controller.dart';
import '../../application/controllers/group_khatm_list_controller.dart';
import '../../application/controllers/khatm_list_controller.dart';
import '../../application/controllers/personal_khatm_sync_controller.dart';
import '../../domain/entities/group_khatm_campaign.dart';
import '../widgets/shared/group_khatm_card.dart';
import '../widgets/shared/khatm_list_card.dart';

/// Screen listing all personal and group Khatm plans with unified segmented tabs.
class KhatmListScreen extends ConsumerStatefulWidget {
  const KhatmListScreen({super.key});

  @override
  ConsumerState<KhatmListScreen> createState() => _KhatmListScreenState();
}

class _KhatmListScreenState extends ConsumerState<KhatmListScreen> {
  /// 0: ختم‌های شخصی | 1: ختم‌های گروهی
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    // Keep sync controller alive on the Personal Khatm list screen
    ref.watch(personalKhatmSyncControllerProvider);
    final state = ref.watch(khatmListControllerProvider);
    final theme = Theme.of(context);
    final colors = context.colors;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'ختم‌های قرآن',
          style: theme.textTheme.titleMedium?.copyWith(
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
            size: 22,
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
          preferredSize: const Size.fromHeight(52.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 6.0,
                ),
                child: AppSegmentedTabBar(
                  height: 38,
                  items: const [
                    AppSegmentedTabItem(
                      title: 'شخصی',
                      icon: CupertinoIcons.person,
                    ),
                    AppSegmentedTabItem(
                      title: 'گروهی',
                      icon: CupertinoIcons.person_2,
                    ),
                  ],
                  selectedIndex: _selectedTab,
                  onTabSelected: (index) {
                    setState(() => _selectedTab = index);
                  },
                ),
              ),
              Container(color: colors.cardBorder, height: 0.8),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_selectedTab == 0) {
            context.pushNamed(createKhatmWizardRoute).then((_) {
              ref.read(khatmListControllerProvider.notifier).loadPlans();
            });
          } else {
            context.pushNamed(createGroupKhatmRoute);
          }
        },
        backgroundColor: colorScheme.primary,
        elevation: 1.5,
        icon: const Icon(CupertinoIcons.plus, size: 18, color: Colors.white),
        label: Text(
          _selectedTab == 0 ? 'ایجاد ختم شخصی' : 'ایجاد ختم گروهی',
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: _selectedTab == 0
            ? RefreshIndicator(
                onRefresh: () async {
                  if (ref.read(isTafakorAuthenticatedProvider)) {
                    await ref
                        .read(personalKhatmSyncControllerProvider.notifier)
                        .syncWithBackend();
                  }
                  await ref
                      .read(khatmListControllerProvider.notifier)
                      .loadPlans();
                },
                child: _buildPersonalTab(context, ref, state, theme),
              )
            : _buildGroupTab(context, theme, colors, colorScheme),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // تب ۱: ختم‌های شخصی (واقعی)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildPersonalTab(
    BuildContext context,
    WidgetRef ref,
    KhatmListState state,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;

    if (state.isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (state.plans.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'هنوز ختم شخصی ایجاد نکرده‌اید',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'می‌توانید برای جزء، حزب، سوره یا صفحه ختم‌های شخصی تعریف کنید.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.pushNamed(createKhatmWizardRoute).then((_) {
                          ref
                              .read(khatmListControllerProvider.notifier)
                              .loadPlans();
                        });
                      },
                      icon: const Icon(CupertinoIcons.plus, size: 16),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      label: Text(
                        'ایجاد برنامه ختم شخصی',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: state.plans.length,
      itemBuilder: (context, index) {
        final plan = state.plans[index];
        return KhatmListCard(
          plan: plan,
          onTap: () {
            context
                .pushNamed(khatmDetailRoute, pathParameters: {'id': plan.id})
                .then((_) {
                  ref.read(khatmListControllerProvider.notifier).loadPlans();
                });
          },
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // تب ۲: ختم‌های گروهی (اتصال زنده به سرور تفکر)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildGroupTab(
    BuildContext context,
    ThemeData theme,
    dynamic colors,
    ColorScheme colorScheme,
  ) {
    final groupState = ref.watch(groupKhatmListControllerProvider);
    final isDark = context.isDark;

    if (groupState.isLoadingPublic && groupState.publicCampaigns.isEmpty) {
      return const Center(child: CupertinoActivityIndicator());
    }

    final myCampaigns = groupState.myCampaigns;
    final publicCampaigns = groupState.publicCampaigns;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(groupKhatmListControllerProvider.notifier).refreshAll(),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          // ── ۱. هدر بخش ختم‌های گروهی من + دکمه مشاهده همه ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'ختم‌های گروهی من',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showMyCampaignsBottomSheet(
                    context,
                    myCampaigns,
                    isDark,
                    colorScheme,
                  );
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  myCampaigns.isNotEmpty
                      ? 'مشاهده همه (${myCampaigns.length.toPersianDigit()})'
                      : 'مشاهده همه',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── ۲. لیست افقی حداکثر ۳ تایی از ختم‌های کاربر یا وضعیت خالی ──
          if (myCampaigns.isEmpty)
            _buildMyCampaignsEmptyState(colorScheme, isDark)
          else
            SizedBox(
              height: 126,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: myCampaigns.take(3).length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final campaign = myCampaigns[index];
                  return _buildMyCampaignHorizontalCard(
                    campaign,
                    colors,
                    colorScheme,
                    isDark,
                  );
                },
              ),
            ),
          const SizedBox(height: 22),

          // ── ۳. بخش لیست عمومی ختم‌های فعال ──
          Row(
            children: [
              Text(
                'ختم‌های فعال قرآن (${publicCampaigns.length.toPersianDigit()} ختم فعال)',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (publicCampaigns.isEmpty)
            _buildPublicCampaignsEmptyState(colorScheme, isDark)
          else
            ...publicCampaigns.map((campaign) {
              return GroupKhatmCard(
                campaign: campaign,
                onTap: () {
                  context.pushNamed(
                    groupKhatmDetailRoute,
                    pathParameters: {'code': campaign.inviteCode},
                  );
                },
              );
            }),
          const SizedBox(height: 60), // فاصله برای دکمه شناور
        ],
      ),
    );
  }

  /// کارت افقی اختصاصی برای نمایش ختم گروهی کاربر (حداکثر ۳ عدد)
  Widget _buildMyCampaignHorizontalCard(
    GroupKhatmCampaign campaign,
    dynamic colors,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final activeSlot = campaign.mySlots.where((s) => s.isReserved).firstOrNull;

    final String mySlotText;
    if (activeSlot != null) {
      mySlotText = activeSlot.unitNumber != null
          ? 'سهم شما: ${campaign.unitTypeLabel} ${activeSlot.unitNumber!.toPersianDigit()}'
          : 'سهم شما: ${activeSlot.quantity.toPersianDigit()} مرتبه';
    } else if (campaign.mySlots.isNotEmpty) {
      final doneSlot = campaign.mySlots.first;
      mySlotText = doneSlot.unitNumber != null
          ? 'سهم شما: ${campaign.unitTypeLabel} ${doneSlot.unitNumber!.toPersianDigit()} (تکمیل شده)'
          : 'سهم شما: ${doneSlot.quantity.toPersianDigit()} مرتبه (تکمیل شده)';
    } else {
      mySlotText = 'شما سازنده این ختم هستید';
    }

    final deadlineText = campaign.deadline != null
        ? 'مهلت: تا ${JalaliDate.fromDateTime(campaign.deadline!).formatFa().toPersianDigit()}'
        : null;

    return Container(
      width: 285,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.04),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              pathParameters: {'code': campaign.inviteCode},
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // عنوان ختم و مهلت پایان (بدون باکس همراهی در ختم)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        campaign.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (deadlineText != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        deadlineText,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10.5,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // سهم کاربر
                Text(
                  mySlotText,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),

                // پیشرفت
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'پیشرفت ختم',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 10.5,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.75,
                            ),
                          ),
                        ),
                        Text(
                          '${campaign.progressPercent.toInt().toPersianDigit()}٪',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (campaign.progressPercent / 100).clamp(0.0, 1.0),
                        minHeight: 4,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFEBE8E1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
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

  /// وضعیت خالی برای سهم‌های من (بدون دکمه مشارکت، با آیکون و متن آرام)
  Widget _buildMyCampaignsEmptyState(ColorScheme colorScheme, bool isDark) {
    final pillBg = isDark ? const Color(0xFF222224) : const Color(0xFFF6F4F0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.book_fill,
            size: 32,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 10),
          Text(
            'در حال حاضر در هیچ ختم گروهی شرکت نکرده‌اید',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'سهم‌هایی که در ختم‌های عمومی یا اختصاصی برمی‌دارید در این بخش نمایش داده می‌شوند.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11.5,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// وضعیت خالی برای ختم‌های عمومی
  Widget _buildPublicCampaignsEmptyState(ColorScheme colorScheme, bool isDark) {
    final pillBg = isDark ? const Color(0xFF222224) : const Color(0xFFF6F4F0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          'در حال حاضر ختم گروهی فعالی وجود ندارد',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12.5,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }

  /// برگه مشاهده همهٔ ختم‌های گروهی کاربر
  void _showMyCampaignsBottomSheet(
    BuildContext context,
    List<GroupKhatmCampaign> myCampaigns,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'همهٔ ختم‌های گروهی من',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              if (myCampaigns.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'در حال حاضر در هیچ ختم گروهی شرکت نکرده‌اید',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: myCampaigns.length,
                    itemBuilder: (ctx, i) {
                      final c = myCampaigns[i];
                      return GroupKhatmCard(
                        campaign: c,
                        onTap: () {
                          Navigator.of(ctx).pop();
                          context.pushNamed(
                            groupKhatmDetailRoute,
                            pathParameters: {'code': c.inviteCode},
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
