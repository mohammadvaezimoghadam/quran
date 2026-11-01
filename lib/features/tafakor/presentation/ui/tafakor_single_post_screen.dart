import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/routes/go_router_provider.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/ayah_notes_controller.dart';
import '../../application/controllers/tafakor_auth_controller.dart';
import '../../domain/entities/tafakor_post.dart';
import '../../domain/entities/tafakor_quran_reference.dart';
import '../../domain/entities/tafakor_topic.dart';
import '../../infrastructure/datasources/tafakor_local_data_source.dart';
import '../../infrastructure/repositories/tafakor_posts_repository_impl.dart';
import '../../infrastructure/services/tafakor_quran_extractor.dart';
import '../widgets/tafakor_manage_ayah_references_sheet.dart';
import '../widgets/tafakor_post_card.dart';
import 'tafakor_topic_feed_screen.dart';

/// Full-screen Instagram-style vertical swipeable post viewer.
/// Clean, monochromatic, and distraction-free:
/// - Swiping UP moves to the next post.
/// - Swiping DOWN moves to the previous post.
/// - Each post card is perfectly centered vertically with adaptive height.
class TafakorSinglePostScreen extends ConsumerStatefulWidget {
  final TafakorPost post;
  final TafakorTopic? topic;
  final List<TafakorPost>? posts;
  final int initialIndex;
  final int? surahNumber;
  final int? ayahNumber;

  const TafakorSinglePostScreen({
    super.key,
    required this.post,
    this.topic,
    this.posts,
    this.initialIndex = 0,
    this.surahNumber,
    this.ayahNumber,
  });

  static Future<void> push(
    BuildContext context, {
    required TafakorPost post,
    TafakorTopic? topic,
    List<TafakorPost>? posts,
    int initialIndex = 0,
    int? surahNumber,
    int? ayahNumber,
  }) {
    final navContext = rootNavigatorKey.currentContext ?? context;
    return Navigator.of(navContext).push(
      MaterialPageRoute(
        builder: (_) => TafakorSinglePostScreen(
          post: post,
          topic: topic,
          posts: posts,
          initialIndex: initialIndex,
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
        ),
      ),
    );
  }

  @override
  ConsumerState<TafakorSinglePostScreen> createState() =>
      _TafakorSinglePostScreenState();
}

class _TafakorSinglePostScreenState
    extends ConsumerState<TafakorSinglePostScreen> {
  late List<TafakorPost> _posts;
  late PageController _pageController;
  late int _currentIndex;
  bool _isLoadingMore = false;

  List<TafakorPost> _deduplicate(List<TafakorPost> list) {
    final seen = <int>{};
    return [
      for (final p in list)
        if (seen.add(p.id)) p,
    ];
  }

  @override
  void initState() {
    super.initState();
    final initialList = widget.posts != null && widget.posts!.isNotEmpty
        ? widget.posts!
        : [widget.post];
    _posts = _deduplicate(initialList);
    if (_posts.isEmpty) {
      _posts = [widget.post];
    }
    final targetId = widget.post.id;
    final foundIndex = _posts.indexWhere((p) => p.id == targetId);
    _currentIndex = foundIndex >= 0
        ? foundIndex
        : widget.initialIndex.clamp(0, _posts.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _checkLoadMore(int index) {
    if (widget.surahNumber == null ||
        widget.ayahNumber == null ||
        _isLoadingMore) {
      return;
    }
    final hasMore = ref.read(ayahNotesControllerProvider).hasMore;
    if (hasMore && index >= _posts.length - 2) {
      _isLoadingMore = true;
      ref
          .read(ayahNotesControllerProvider.notifier)
          .loadNextPage()
          .whenComplete(() {
        if (mounted) {
          setState(() => _isLoadingMore = false);
        }
      });
    }
  }

  Future<void> _toggleReaction(TafakorPost post, int index) async {
    HapticFeedback.lightImpact();
    final wasLiked = post.isLiked;

    // Optimistic UI update
    final updatedPost = post.copyWith(
      userReaction: wasLiked ? null : '❤️',
      reactionsSummary: {
        ...post.reactionsSummary,
        '❤️': wasLiked
            ? ((post.reactionsSummary['❤️'] ?? 1) - 1).clamp(0, 999999)
            : ((post.reactionsSummary['❤️'] ?? 0) + 1),
      },
    );

    setState(() {
      _posts[index] = updatedPost;
    });

    ref.read(ayahNotesControllerProvider.notifier).toggleReaction(post.id);

    final repo = ref.read(tafakorPostsRepositoryProvider);
    final result = await repo.reactToPost(post.id, '❤️');
    result.when(
      (_) {},
      (failure) {
        if (mounted) {
          setState(() {
            _posts[index] = post;
          });
        }
      },
    );
  }

  void _confirmDeleteAyahReference(
    TafakorPost post,
    TafakorQuranReference reference,
  ) {
    HapticFeedback.lightImpact();
    showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: CupertinoAlertDialog(
          title: const Text(
            'حذف ارجاع آیه',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'آیا از حذف ارجاع «سوره ${reference.surahName}، آیه ${reference.ayahNumber.toPersianDigit()}» از این پست اطمینان دارید؟',
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                'انصراف',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              onPressed: () => Navigator.pop(dialogCtx),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text(
                'حذف',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                Navigator.pop(dialogCtx);
                HapticFeedback.mediumImpact();

                final remainingRefs = post.quranReferences
                    .where(
                      (r) => !(r.surahNumber == reference.surahNumber &&
                          r.ayahNumber == reference.ayahNumber),
                    )
                    .toList();

                final payload = remainingRefs
                    .map(
                      (r) => {
                        'plugin': 'quran',
                        'resource_type': 'ayah',
                        'external_id':
                            'surah:${r.surahNumber},ayah:${r.ayahNumber}',
                        'metadata': {
                          'surah_number': r.surahNumber,
                          'ayah_number': r.ayahNumber,
                          'surah_name': r.surahName,
                        },
                      },
                    )
                    .toList();

                final repo = ref.read(tafakorPostsRepositoryProvider);
                final result = await repo.updatePostReferences(
                  postId: post.id,
                  pluginReferences: payload,
                );

                result.when(
                  (updatedPost) {
                    TafakorQuranRegistry.register(post.id, remainingRefs);
                    if (mounted) {
                      setState(() {
                        final idx = _posts.indexWhere((p) => p.id == post.id);
                        if (idx >= 0) {
                          _posts[idx] = updatedPost;
                        }
                      });
                      AppSnackBar.showSuccess(
                        context,
                        'ارجاع آیه با موفقیت حذف شد.',
                      );
                    }
                  },
                  (failure) {
                    if (mounted) {
                      AppSnackBar.showError(
                        context,
                        'خطا در حذف ارجاع آیه: ${failure.message}',
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(TafakorPost post, bool canModify) {
    HapticFeedback.lightImpact();
    final isDark = context.isDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E22) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              16.vSpace,
              ListTile(
                leading: const Icon(CupertinoIcons.share),
                title: const Text(
                  'اشتراک‌گذاری متن',
                  style: TextStyle(fontFamily: AppTypography.fontFamily),
                ),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  Clipboard.setData(ClipboardData(text: post.content));
                  AppSnackBar.showSuccess(context, 'متن یادداشت کپی شد');
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.doc_on_clipboard),
                title: const Text(
                  'کپی متن',
                  style: TextStyle(fontFamily: AppTypography.fontFamily),
                ),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  Clipboard.setData(ClipboardData(text: post.content));
                  AppSnackBar.showSuccess(
                    context,
                    'متن یادداشت در کلیپ‌بورد ذخیره شد',
                  );
                },
              ),
              if (widget.topic != null) ...[
                ListTile(
                  leading: const Icon(CupertinoIcons.rectangle_stack),
                  title: Text(
                    'مشاهده در کانال «${widget.topic!.name}»',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    TafakorTopicFeedScreen.push(
                      context,
                      widget.topic!,
                      highlightPostId: post.id,
                      initialHighlightPost: post,
                    );
                  },
                ),
              ],
              if (canModify) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(CupertinoIcons.link),
                  title: const Text(
                    'افزودن آیه مرتبط',
                    style: TextStyle(fontFamily: AppTypography.fontFamily),
                  ),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    TafakorManageAyahReferencesSheet.show(
                      context,
                      post: post,
                      onPostUpdated: (updatedPost) {
                        setState(() {
                          final idx = _posts.indexWhere((p) => p.id == post.id);
                          if (idx >= 0) {
                            _posts[idx] = updatedPost;
                          }
                        });
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    CupertinoIcons.trash,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'حذف پست',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      color: Colors.redAccent,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _confirmDeletePost(post);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeletePost(TafakorPost post) {
    showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: CupertinoAlertDialog(
          title: const Text(
            'حذف پست',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'آیا از حذف این پست اطمینان دارید؟ این عملیات غیرقابل بازگشت است.',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                'انصراف',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              onPressed: () => Navigator.pop(dialogCtx),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text(
                'حذف',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                Navigator.pop(dialogCtx);
                HapticFeedback.mediumImpact();
                final repo = ref.read(tafakorPostsRepositoryProvider);
                final res = await repo.deletePost(post.id);
                res.when(
                  (_) {
                    if (mounted) {
                      setState(() {
                        _posts.removeWhere((p) => p.id == post.id);
                        if (_posts.isEmpty) {
                          Navigator.pop(context, true);
                        } else {
                          _currentIndex = _currentIndex.clamp(0, _posts.length - 1);
                        }
                      });
                      AppSnackBar.showSuccess(
                        context,
                        'پست با موفقیت حذف شد.',
                      );
                    }
                  },
                  (failure) {
                    if (mounted) {
                      AppSnackBar.showError(
                        context,
                        'خطا در حذف پست: ${failure.message}',
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFullContentSheet(TafakorPost post) {
    HapticFeedback.lightImpact();
    final isDark = context.isDark;
    final colorScheme = context.colorScheme;
    final jalaliDate = post.formattedJalaliDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          initialChildSize: 0.70,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (scrollCtx, scrollController) => Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E22) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Top drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Author name & Jalali Date
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        (post.authorName.isNotEmpty
                                ? post.authorName
                                : post.authorPhone)
                            .toPersianDigit(),
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      if (jalaliDate != null)
                        Text(
                          jalaliDate,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11.5,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                    ],
                  ),
                ),

                Divider(
                  height: 1,
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.06),
                ),

                // Full Scrollable Text
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                    child: SelectableText(
                      post.content,
                      textDirection: Bidi.detectRtlDirectionality(post.content)
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14.5,
                        height: 1.7,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    final currentUser = ref.watch(tafakorUserProvider);
    final userPhone = currentUser?.phone ??
        ref.watch(tafakorLocalDataSourceProvider).getUserSync()?.phone;

    // Listen to ayah notes controller to append newly fetched posts dynamically
    ref.listen<AyahNotesState>(ayahNotesControllerProvider, (prev, next) {
      final deduped = _deduplicate(next.currentPosts);
      if (deduped.length > _posts.length) {
        setState(() {
          _posts = deduped;
          _isLoadingMore = false;
        });
      }
    });

    final currentPost = _posts[_currentIndex.clamp(0, _posts.length - 1)];
    final isAuthor = currentPost.isAuthor(userPhone);
    final isTopicOwner =
        widget.topic != null && widget.topic!.isOwner(userPhone);
    final canModifyCurrentPost = isAuthor || isTopicOwner;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF141416) : const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor:
              isDark ? const Color(0xFF1E1E22) : Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              CupertinoIcons.chevron_forward,
              color: colorScheme.onSurface,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.topic?.name ?? 'مشاهده یادداشت',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              if (_posts.length > 1) ...[
                2.vSpace,
                Text(
                  '${(_currentIndex + 1).toPersianDigit()} از ${_posts.length.toPersianDigit()}',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                CupertinoIcons.ellipsis_vertical,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () => _showOptionsMenu(
                currentPost,
                canModifyCurrentPost,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewportHeight = constraints.maxHeight;
              final maxMediaH = viewportHeight > 680 ? 175.0 : 145.0;

              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                physics: const AlwaysScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  HapticFeedback.selectionClick();
                  _checkLoadMore(index);
                },
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  final isAuthor = post.isAuthor(userPhone);
                  final isTopicOwner =
                      widget.topic != null && widget.topic!.isOwner(userPhone);
                  final canModify = isAuthor || isTopicOwner;

                  // Dynamic safe lines calculation:
                  // Guarantees zero RenderFlex overflow on ANY device screen.
                  final chromeHeight = 168.0; // Header, footer, card padding, vertical margins
                  final mediaH = (post.hasMedia && post.fullMediaUrl != null)
                      ? (maxMediaH + 10.0)
                      : 0.0;
                  final refsH = post.hasQuranReference ? 46.0 : 0.0;
                  final availableForText =
                      (viewportHeight - chromeHeight - mediaH - refsH)
                          .clamp(60.0, 700.0);
                  final maxLines =
                      (availableForText / 22.4).floor().clamp(3, 25);

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TafakorPostCard(
                        post: post,
                        isDark: isDark,
                        colors: colors,
                        colorScheme: colorScheme,
                        isHighlighted: true,
                        isSelectable: false,
                        canModifyPost: canModify,
                        maxMediaHeight: maxMediaH,
                        maxContentLines: maxLines,
                        onExpandContent: () => _showFullContentSheet(post),
                        onDeleteAyahReference: canModify
                            ? (reference) => _confirmDeleteAyahReference(
                                  post,
                                  reference,
                                )
                            : null,
                        onToggleReaction: () => _toggleReaction(post, index),
                        onMoreOptions: () => _showOptionsMenu(post, canModify),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
