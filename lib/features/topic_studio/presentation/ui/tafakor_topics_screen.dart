import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_cached_network_image.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../tafakor/application/controllers/tafakor_topics_controller.dart';
import '../../../tafakor/domain/entities/tafakor_topic.dart';
import '../../../tafakor/presentation/ui/tafakor_topic_feed_screen.dart';

/// Screen displaying the list of Tafakor topics with real-time search,
/// Jalali dates, post count badges, active status pills, and high-performance scrolling.
class TafakorTopicsScreen extends ConsumerStatefulWidget {
  const TafakorTopicsScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TafakorTopicsScreen(),
      ),
    );
  }

  @override
  ConsumerState<TafakorTopicsScreen> createState() => _TafakorTopicsScreenState();
}

class _TafakorTopicsScreenState extends ConsumerState<TafakorTopicsScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(tafakorTopicsControllerProvider.notifier).setSearchQuery(query);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(tafakorTopicsControllerProvider.notifier).clearSearch();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    final state = ref.watch(tafakorTopicsControllerProvider);
    final controller = ref.read(tafakorTopicsControllerProvider.notifier);
    final topics = state.filteredTopics;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : theme.scaffoldBackgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(62.0),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 4,
              left: 8.0,
              right: 8.0,
              bottom: 6.0,
            ),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              border: Border(
                bottom: BorderSide(
                  color: colors.cardBorder,
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'بازگشت',
                  icon: Icon(
                    CupertinoIcons.chevron_forward,
                    size: 24,
                    color: colorScheme.onSurface,
                  ),
                  splashRadius: 22,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).maybePop();
                  },
                ),
                Expanded(
                  child: Text(
                    'تفکر',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'به‌روزرسانی',
                  icon: const Icon(CupertinoIcons.refresh, size: 20),
                  splashRadius: 22,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    controller.loadTopics(isRefresh: true);
                  },
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            // Search Bar Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 10.0),
              child: _buildSearchBar(context, isDark, colors, colorScheme),
            ),

            // Content Body: Loading, Error, or Topic List
            Expanded(
              child: _buildBody(context, state, topics, controller, isDark, colors, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  /// Modern search input matching the Tafakor design system
  Widget _buildSearchBar(
    BuildContext context,
    bool isDark,
    dynamic colors,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.cardBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          12.hSpace,
          Icon(
            CupertinoIcons.search,
            size: 20,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          10.hSpace,
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'جستجو در تاپیک‌ها...',
                hintStyle: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13.5,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (_, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(CupertinoIcons.clear_circled_solid, size: 18),
                splashRadius: 16,
                color: isDark ? Colors.white38 : Colors.black38,
                onPressed: _clearSearch,
              );
            },
          ),
          4.hSpace,
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TafakorTopicsState state,
    List<TafakorTopic> topics,
    TafakorTopicsController controller,
    bool isDark,
    dynamic colors,
    ColorScheme colorScheme,
  ) {
    // 1. Initial Fullscreen Loading
    if (state.isLoading && state.topics.isEmpty) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 14),
      );
    }

    // 2. Fullscreen Error View
    if (state.error != null && state.topics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'خطا در دریافت تاپیک‌ها',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              8.vSpace,
              Text(
                state.error?.message ?? 'لطفاً اتصال اینترنت خود را بررسی کنید.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12.5,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              20.vSpace,
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => controller.loadTopics(isRefresh: true),
                child: const Text(
                  'تلاش مجدد',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Empty Search or Topic List View
    if (topics.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => controller.loadTopics(isRefresh: true),
        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.searchQuery.isNotEmpty
                          ? 'تاپیکی با این عنوان یافت نشد'
                          : 'هیچ تاپیکی یافت نشد',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (state.searchQuery.isNotEmpty) ...[
                      8.vSpace,
                      Text(
                        'عبارت جستجو را تغییر دهید',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 4. Topics List View with Infinite Performance
    return RefreshIndicator(
      onRefresh: () => controller.loadTopics(isRefresh: true),
      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 24.0),
        itemCount: topics.length,
        separatorBuilder: (_, _) => 10.vSpace,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return RepaintBoundary(
            key: ValueKey(topic.id),
            child: _TopicCard(
              topic: topic,
              isDark: isDark,
              colors: colors,
              colorScheme: colorScheme,
              onTap: () {
                HapticFeedback.lightImpact();
                TafakorTopicFeedScreen.push(context, topic);
              },
            ),
          );
        },
      ),
    );
  }
}

/// Dedicated, high-performance Topic Card matching Image 4
class _TopicCard extends StatelessWidget {
  final TafakorTopic topic;
  final bool isDark;
  final dynamic colors;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _TopicCard({
    required this.topic,
    required this.isDark,
    required this.colors,
    required this.colorScheme,
    required this.onTap,
  });

  String _getFirstLetter(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'ت';
    return trimmed.characters.first;
  }

  @override
  Widget build(BuildContext context) {
    final firstLetter = _getFirstLetter(topic.name);
    final isBotActive = topic.telegramBotActive || topic.baleBotActive;
    final jalaliDate = topic.formattedJalaliDate;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.cardBorder,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          highlightColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.02),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Right Side: Topic Avatar / Initial Letter
                _buildAvatar(firstLetter),

                12.hSpace,

                // 2. Middle: Topic Title, Active Badge, Latest Post Snippet
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title + Active Badge Row
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              topic.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (isBotActive) ...[
                            8.hSpace,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : const Color(0xFFF3EFE8),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.10)
                                      : const Color(0xFFE5DFD3),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                'فعال',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      5.vSpace,

                      // Description Snippet (latest post preview)
                      Text(
                        (topic.description != null && topic.description!.trim().isNotEmpty)
                            ? topic.description!.trim()
                            : 'بدون یادداشت',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                10.hSpace,

                // 3. Left Side: Jalali Date + Circular Post Count Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Jalali Date (e.g. ۱۴۰۵/۷/۱۹)
                    if (jalaliDate != null)
                      Text(
                        jalaliDate,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      )
                    else
                      const SizedBox(height: 14),
                    6.vSpace,

                    // Post Count Badge (Matching Surah Medallion soft styling, no black background)
                    Container(
                      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFF3EFE8),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.10)
                              : const Color(0xFFE5DFD3),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        topic.postCount.toPersianDigit(),
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
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

  Widget _buildAvatar(String firstLetter) {
    final badgeBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFF3EFE8);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE5DFD3);

    final textStyle = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    );

    if (topic.fullImageUrl != null && topic.fullImageUrl!.trim().isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: badgeBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: 0.8,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: AppCachedNetworkImage(
          imageUrl: topic.fullImageUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(12),
          backgroundColor: badgeBg,
          errorWidget: (_, _, _) => Container(
            color: badgeBg,
            alignment: Alignment.center,
            child: Text(firstLetter, style: textStyle),
          ),
        ),
      );
    }

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 0.8,
        ),
      ),
      child: Text(
        firstLetter,
        style: textStyle,
      ),
    );
  }
}
