import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_cached_network_image.dart';
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
import '../../application/controllers/tafakor_topics_controller.dart';
import '../../domain/entities/tafakor_post.dart';
import '../ui/tafakor_login_screen.dart';
import '../ui/tafakor_single_post_screen.dart';

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
  ConsumerState<AyahNotesBottomSheet> createState() =>
      _AyahNotesBottomSheetState();
}

class _AyahNotesBottomSheetState extends ConsumerState<AyahNotesBottomSheet> {
  late final TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();
  // bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(ayahNotesControllerProvider.notifier)
          .loadInitial(
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
      container
          .read(inDrawerEditorControllerProvider.notifier)
          .setBlocks(blocks);
    }

    Navigator.of(context).pop();

    Navigator.of(
      navContext,
    ).push(MaterialPageRoute(builder: (_) => const TafakorEditorScreen()));
  }

  void _openTopicPost(TafakorPost post) {
    HapticFeedback.lightImpact();
    final cachedTopics = ref.read(tafakorTopicsProvider).asData?.value;
    final topic = cachedTopics?.where((t) => t.id == post.topicId).firstOrNull;

    final state = ref.read(ayahNotesControllerProvider);
    final currentList = state.currentPosts;
    final postIndex = currentList.indexWhere((p) => p.id == post.id);

    TafakorSinglePostScreen.push(
      context,
      post: post,
      topic: topic,
      posts: currentList.isNotEmpty ? currentList : [post],
      initialIndex: postIndex >= 0 ? postIndex : 0,
      surahNumber: widget.surahNumber,
      ayahNumber: widget.ayahNumber,
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
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
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: AppModalHeader(
                    showDragHandle: true,
                    title: 'جامعه تفکر',
                    bottomSpacing: 6,
                  ),
                ),

                8.vSpace,

                // Segmented Tabs: Community vs Mine
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF141416)
                          : const Color(0xFFF1F2F4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 0.7),
                    ),
                    child: Row(
                      children: [
                        // Tab 1: Others (تفکر دیگران)
                        Expanded(
                          child: _buildTabButton(
                            title: 'تفکر دیگران',
                            count: state.communityTotal,
                            isSelected:
                                state.activeTab == AyahNotesTab.community,
                            isDark: isDark,
                            primaryColor: primaryColor,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              controller.switchTab(AyahNotesTab.community);
                            },
                          ),
                        ),

                        4.hSpace,

                        // Tab 2: Contributors / Authors (اهل تفکر)
                        Expanded(
                          child: _buildTabButton(
                            title: 'اهل تفکر',
                            count: state.authors.length,
                            isSelected: state.activeTab == AyahNotesTab.authors,
                            isDark: isDark,
                            primaryColor: primaryColor,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              controller.switchTab(AyahNotesTab.authors);
                            },
                          ),
                        ),

                        4.hSpace,

                        // Tab 3: My Reflections (تفکر من)
                        Expanded(
                          child: _buildTabButton(
                            title: 'تفکر من',
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

                /*
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
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (query) => controller.setSearch(query),
                      onChanged: (val) {
                        if (val.isEmpty && _isSearching) {
                          setState(() => _isSearching = false);
                          controller.setSearch('');
                        } else if (val.isNotEmpty && !_isSearching) {
                          // setState(() => _isSearching = true);
                        }
                      },
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'جستجو در یادداشت‌های این آیه...',
                        hintStyle: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12.5,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(
                            CupertinoIcons.search,
                            size: 17,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 38,
                          minHeight: 42,
                        ),
                        suffixIcon: _isSearching
                            ? IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 42,
                                ),
                                icon: const Icon(
                                  CupertinoIcons.clear_circled_solid,
                                  size: 16,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _isSearching = false);
                                  controller.setSearch('');
                                },
                              )
                            : null,
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 42,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),

                12.vSpace,
                */
                6.vSpace,

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
                    border: Border(
                      top: BorderSide(color: borderColor, width: 0.8),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _openEditor,
                      child: Text(
                        'نگارش تفکر',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
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
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
            ),
            if (count > 0) ...[
              4.hSpace,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.08))
                      : (isDark
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.04)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toPersianDigit(),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white60 : Colors.black45),
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
      return const Center(child: CupertinoActivityIndicator(radius: 14));
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        size: 36,
                        color: Colors.orange.shade300,
                      ),
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

    if (state.activeTab == AyahNotesTab.authors) {
      return _buildAuthorsGrid(
        context: context,
        state: state,
        controller: controller,
        isDark: isDark,
        borderColor: borderColor,
        primaryColor: primaryColor,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isMine
                            ? CupertinoIcons.square_pencil
                            : CupertinoIcons.bubble_left_bubble_right,
                        size: 38,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                      10.vSpace,
                      Text(
                        state.searchQuery.isNotEmpty
                            ? 'موردی یافت نشد'
                            : (isMine
                                  ? 'هنوز تفکری ثبت نکرده‌اید'
                                  : 'هنوز یادداشتی ثبت نشده است'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white60 : Colors.black54,
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

    final currentUser = ref.watch(tafakorUserProvider);
    final currentPhone = currentUser?.phone;

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: posts.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => 12.vSpace,
      itemBuilder: (context, index) {
        if (index == posts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 14.0),
            child: Center(child: CupertinoActivityIndicator(radius: 10)),
          );
        }

        final post = posts[index];
        final isAuthor = post.isAuthor(currentPhone);

        return _AyahPostCard(
          post: post,
          isDark: isDark,
          primaryColor: primaryColor,
          borderColor: borderColor,
          onToggleReaction: () => controller.toggleReaction(post.id),
          onOpenPost: () => _openTopicPost(post),
          onUnlink: isAuthor ? () => _confirmUnlink(post) : null,
        );
      },
    );
  }

  void _confirmUnlink(TafakorPost post) {
    HapticFeedback.lightImpact();
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(
          'قطع ارتباط با آیه',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'آیا ارتباط این یادداشت با آیه ${widget.ayahNumber.toPersianDigit()} سوره ${widget.surahName} قطع شود؟',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'انصراف',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(
              'قطع ارتباط',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(ayahNotesControllerProvider.notifier)
                  .unlinkAyahFromPost(
                    postId: post.id,
                    surahNumber: widget.surahNumber,
                    ayahNumber: widget.ayahNumber,
                  );
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'ارتباط با این آیه برداشته شد',
                      style: TextStyle(fontFamily: AppTypography.fontFamily),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorsGrid({
    required BuildContext context,
    required AyahNotesState state,
    required AyahNotesController controller,
    required bool isDark,
    required Color borderColor,
    required Color primaryColor,
  }) {
    final query = state.searchQuery.trim().toLowerCase();
    final authors = query.isEmpty
        ? state.authors
        : state.authors
              .where((a) => a.authorName.toLowerCase().contains(query))
              .toList();

    if (authors.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.person_2,
                        size: 38,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                      10.vSpace,
                      Text(
                        query.isNotEmpty
                            ? 'نویسنده‌ای یافت نشد'
                            : 'هنوز نویسنده‌ای ثبت نشده است',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white60 : Colors.black54,
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

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.18,
      ),
      itemCount: authors.length,
      itemBuilder: (context, index) {
        final author = authors[index];
        return _AyahAuthorCard(
          author: author,
          isDark: isDark,
          borderColor: borderColor,
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
  final VoidCallback onOpenPost;
  final VoidCallback? onUnlink;

  const _AyahPostCard({
    required this.post,
    required this.isDark,
    required this.primaryColor,
    required this.borderColor,
    required this.onToggleReaction,
    required this.onOpenPost,
    this.onUnlink,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF161618) : const Color(0xFFFBFBFB);
    final isLiked = post.isLiked;
    final totalLikes = post.totalLikes;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenPost,
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
                    backgroundColor: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.06),
                    child: Text(
                      post.authorName.isNotEmpty
                          ? post.authorName.substring(0, 1)
                          : 'ک',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                  10.hSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName.isNotEmpty
                              ? post.authorName
                              : 'کاربر تفکر',
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

              // Post Text Content (Collapsed summary)
              Text(
                post.content.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  height: 1.6,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.88)
                      : Colors.black87,
                ),
              ),

              10.vSpace,

              // Actions Row: Reactions & Comments Count + "مشاهده پست" + Unlink (if author)
              Row(
                children: [
                  // View Post Text Link (No box)
                  GestureDetector(
                    onTap: onOpenPost,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'مشاهده پست',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          3.hSpace,
                          Icon(
                            CupertinoIcons.chevron_left,
                            size: 11,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (onUnlink != null) ...[
                    8.hSpace,
                    GestureDetector(
                      onTap: onUnlink,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: borderColor, width: 0.6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.xmark,
                              size: 11,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                            4.hSpace,
                            Text(
                              'حذف از این آیه',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 10.5,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const Spacer(),

                  if (post.commentsCount > 0) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.chat_bubble,
                          size: 14,
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
                    12.hSpace,
                  ],

                  // Heart Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onToggleReaction();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLiked
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart,
                            size: 14,
                            color: isLiked
                                ? const Color(0xFFE05353)
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                          if (totalLikes > 0) ...[
                            4.hSpace,
                            Text(
                              totalLikes.toPersianDigit(),
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white60 : Colors.black54,
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
        ),
      ),
    );
  }
}

class _AyahAuthorCard extends StatelessWidget {
  final TafakorAyahAuthor author;
  final bool isDark;
  final Color borderColor;

  const _AyahAuthorCard({
    required this.author,
    required this.isDark,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF161618) : const Color(0xFFFBFBFB);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAvatar(),
          8.vSpace,
          Text(
            author.authorName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          5.vSpace,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${author.notesCount.toPersianDigit()} یادداشت',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    const size = 44.0;
    if (author.authorAvatar != null && author.authorAvatar!.trim().isNotEmpty) {
      return AppCachedNetworkImage(
        imageUrl: author.authorAvatar!,
        width: size,
        height: size,
        borderRadius: BorderRadius.circular(size / 2),
        backgroundColor: isDark
            ? const Color(0xFF2C2C2E)
            : const Color(0xFFE5E5EA),
      );
    }

    final initial = author.authorName.trim().isNotEmpty
        ? author.authorName.trim().substring(0, 1)
        : 'ک';

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 0.8,
        ),
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }
}
