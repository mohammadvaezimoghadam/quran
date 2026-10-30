import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_modal_header.dart';
import '../../../../core/routes/go_router_provider.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../../quran_reader/domain/entities/ayah_entity.dart';
import '../../../topic_studio/application/controllers/in_drawer_editor_controller.dart';
import '../../../topic_studio/domain/entities/topic_drag_data.dart';
import '../../../topic_studio/presentation/ui/tafakor_editor_screen.dart';
import '../../application/controllers/ayah_notes_controller.dart';
import '../../application/controllers/tafakor_auth_controller.dart';
import '../../domain/entities/tafakor_post.dart';
import '../ui/tafakor_login_screen.dart';

/// Luxury, modular bottom sheet for viewing and creating notes & reflections for a specific Quran Ayah.
class AyahNotesBottomSheet extends ConsumerStatefulWidget {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String ayahArabicText;
  final String? translationText;
  final AyahEntity? ayahEntity;

  const AyahNotesBottomSheet({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.ayahArabicText,
    this.translationText,
    this.ayahEntity,
  });

  static Future<void> show(
    BuildContext context, {
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    required String ayahArabicText,
    String? translationText,
    AyahEntity? ayahEntity,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AyahNotesBottomSheet(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        surahName: surahName,
        ayahArabicText: ayahArabicText,
        translationText: translationText,
        ayahEntity: ayahEntity,
      ),
    );
  }

  @override
  ConsumerState<AyahNotesBottomSheet> createState() => _AyahNotesBottomSheetState();
}

class _AyahNotesBottomSheetState extends ConsumerState<AyahNotesBottomSheet> {
  late final TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ayahNotesControllerProvider.notifier).loadInitial(
            surahNumber: widget.surahNumber,
            ayahNumber: widget.ayahNumber,
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(ayahNotesControllerProvider.notifier).loadNextPage();
    }
  }

  void _openEditor() {
    HapticFeedback.lightImpact();
    final navContext = rootNavigatorKey.currentContext ?? context;
    final container = ProviderScope.containerOf(navContext, listen: false);

    final removeBrackets = container
        .read(quranDisplaySettingsControllerProvider)
        .removeTranslationBrackets;

    if (widget.ayahEntity != null) {
      final dragData = TopicDragData(
        ayahs: [widget.ayahEntity!],
        surahName: widget.surahName,
        translations: {widget.ayahNumber: widget.translationText ?? ''},
        removeBrackets: removeBrackets,
      );
      final blocks = dragData.toBlocks();
      container.read(inDrawerEditorControllerProvider.notifier).setBlocks(blocks);
    }

    Navigator.of(context).pop();

    Navigator.of(navContext).push(
      MaterialPageRoute(
        builder: (_) => const TafakorEditorScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    final state = ref.watch(ayahNotesControllerProvider);
    final controller = ref.read(ayahNotesControllerProvider.notifier);
    final isAuthenticated = ref.watch(isTafakorAuthenticatedProvider);

    final cardBg = isDark ? const Color(0xFF1E1E22) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.82,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, sheetScrollController) {
          return Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 30,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header & Ayah Badge
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Column(
                    children: [
                      AppModalHeader(
                        showDragHandle: true,
                        title: 'یادداشت‌های سوره ${widget.surahName} • آیه ${widget.ayahNumber.toPersianDigit()}',
                        bottomSpacing: 8,
                      ),

                      // Ayah Arabic snippet card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor, width: 0.8),
                        ),
                        child: Text(
                          widget.ayahArabicText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                            height: 1.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                10.vSpace,

                // Segmented Tabs: Community vs Mine
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF141416) : const Color(0xFFF1F2F4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 0.7),
                    ),
                    child: Row(
                      children: [
                        // Tab 1: Community (مجله تفکر / عمومی)
                        Expanded(
                          child: _buildTabButton(
                            title: 'مجله تفکر',
                            count: state.communityTotal,
                            isSelected: state.activeTab == AyahNotesTab.community,
                            isDark: isDark,
                            primaryColor: primaryColor,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              controller.switchTab(AyahNotesTab.community);
                            },
                          ),
                        ),

                        6.hSpace,

                        // Tab 2: My Notes (یادداشت‌های من)
                        Expanded(
                          child: _buildTabButton(
                            title: 'یادداشت‌های من',
                            count: state.mineTotal,
                            isSelected: state.activeTab == AyahNotesTab.mine,
                            isDark: isDark,
                            primaryColor: primaryColor,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              if (!isAuthenticated) {
                                TafakorLoginScreen.push(context);
                              } else {
                                controller.switchTab(AyahNotesTab.mine);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                10.vSpace,

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 0.8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (query) => controller.setSearch(query),
                      onChanged: (val) {
                        if (val.isEmpty && _isSearching) {
                          setState(() => _isSearching = false);
                          controller.setSearch('');
                        } else if (val.isNotEmpty && !_isSearching) {
                          setState(() => _isSearching = true);
                        }
                      },
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'جستجو در یادداشت‌های این آیه...',
                        hintStyle: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12.5,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        prefixIcon: Icon(
                          CupertinoIcons.search,
                          size: 18,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                        suffixIcon: _isSearching
                            ? IconButton(
                                icon: const Icon(CupertinoIcons.clear_circled_solid, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _isSearching = false);
                                  controller.setSearch('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      ),
                    ),
                  ),
                ),

                12.vSpace,

                // Feed List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.refresh,
                    color: primaryColor,
                    child: _buildFeed(
                      context: context,
                      state: state,
                      controller: controller,
                      isDark: isDark,
                      primaryColor: primaryColor,
                      borderColor: borderColor,
                    ),
                  ),
                ),

                // Bottom Floating Action Button
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    border: Border(top: BorderSide(color: borderColor, width: 0.8)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _openEditor,
                      icon: const Icon(CupertinoIcons.pencil_ellipsis_rectangle, size: 20),
                      label: Text(
                        'ثبت یادداشت جدید روی این آیه',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required int count,
    required bool isSelected,
    required bool isDark,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF28282E) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
            ),
            if (count > 0) ...[
              6.hSpace,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withValues(alpha: 0.15)
                      : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toPersianDigit(),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? primaryColor
                        : (isDark ? Colors.white60 : Colors.black54),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeed({
    required BuildContext context,
    required AyahNotesState state,
    required AyahNotesController controller,
    required bool isDark,
    required Color primaryColor,
    required Color borderColor,
  }) {
    if (state.isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 14),
      );
    }

    if (state.error != null && state.currentPosts.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.exclamationmark_triangle, size: 36, color: Colors.orange.shade300),
                      12.vSpace,
                      Text(
                        state.error?.message ?? 'خطا در بارگذاری یادداشت‌ها',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      14.vSpace,
                      OutlinedButton(
                        onPressed: controller.refresh,
                        child: const Text('تلاش مجدد'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    final posts = state.currentPosts;

    if (posts.isEmpty) {
      final isMine = state.activeTab == AyahNotesTab.mine;
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isMine ? CupertinoIcons.square_pencil : CupertinoIcons.bubble_left_bubble_right,
                        size: 44,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                      10.vSpace,
                      Text(
                        isMine
                            ? 'شما هنوز یادداشتی روی این آیه ننوشته‌اید'
                            : 'هنوز تفکری پیرامون این آیه در کانال‌ها منتشر نشده است',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      6.vSpace,
                      Text(
                        isMine
                            ? 'افکار و تدبرهای خود پیرامون این آیه را در دفتر تفکر ثبت کنید.'
                            : 'اولین نفری باشید که برداشت خود را از این آیه با دیگران به اشتراک می‌گذارد.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11.5,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                      14.vSpace,
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor, width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: _openEditor,
                        icon: Icon(CupertinoIcons.add, size: 15, color: primaryColor),
                        label: Text(
                          'نگارش تفکر',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: posts.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => 12.vSpace,
      itemBuilder: (context, index) {
        if (index == posts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 14.0),
            child: Center(
              child: CupertinoActivityIndicator(radius: 10),
            ),
          );
        }

        final post = posts[index];
        return _AyahPostCard(
          post: post,
          isDark: isDark,
          primaryColor: primaryColor,
          borderColor: borderColor,
          onToggleReaction: () => controller.toggleReaction(post.id),
        );
      },
    );
  }
}

class _AyahPostCard extends StatelessWidget {
  final TafakorPost post;
  final bool isDark;
  final Color primaryColor;
  final Color borderColor;
  final VoidCallback onToggleReaction;

  const _AyahPostCard({
    required this.post,
    required this.isDark,
    required this.primaryColor,
    required this.borderColor,
    required this.onToggleReaction,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF161618) : const Color(0xFFFBFBFB);
    final isLiked = post.isLiked;
    final totalLikes = post.totalLikes;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: primaryColor.withValues(alpha: 0.15),
                child: Text(
                  post.authorName.isNotEmpty ? post.authorName.substring(0, 1) : 'ک',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              10.hSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName.isNotEmpty ? post.authorName : 'کاربر تفکر',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      post.formattedJalaliDate ?? '',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          10.vSpace,

          // Post Text Content
          SelectableText(
            post.content,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13.5,
              height: 1.7,
              color: isDark ? Colors.white.withValues(alpha: 0.88) : Colors.black87,
            ),
          ),

          8.vSpace,

          // Actions Row: Reactions & Comments Count
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (post.commentsCount > 0) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.chat_bubble,
                      size: 15,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    4.hSpace,
                    Text(
                      post.commentsCount.toPersianDigit(),
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
                14.hSpace,
              ],

              // Heart Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onToggleReaction();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLiked
                        ? Colors.red.withValues(alpha: 0.12)
                        : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                        size: 15,
                        color: isLiked ? Colors.redAccent : (isDark ? Colors.white38 : Colors.black38),
                      ),
                      if (totalLikes > 0) ...[
                        4.hSpace,
                        Text(
                          totalLikes.toPersianDigit(),
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isLiked ? Colors.redAccent : (isDark ? Colors.white38 : Colors.black38),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
