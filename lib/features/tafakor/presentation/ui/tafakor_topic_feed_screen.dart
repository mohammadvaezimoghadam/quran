import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/services/media/image_picker_service.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/tafakor_auth_controller.dart';
import '../../application/controllers/tafakor_topic_feed_controller.dart';
import '../../../../core/routes/go_router_provider.dart';
import '../../domain/entities/tafakor_post.dart';
import '../../domain/entities/tafakor_quran_reference.dart';
import '../../domain/entities/tafakor_topic.dart';
import '../../domain/entities/tafakor_topic_admins_data.dart';
import '../../infrastructure/datasources/tafakor_local_data_source.dart';
import '../../infrastructure/services/tafakor_quran_extractor.dart';
import 'tafakor_login_screen.dart';
import 'tafakor_post_editor_screen.dart';
import '../widgets/tafakor_manage_ayah_references_sheet.dart';
import '../widgets/tafakor_post_card.dart';

/// Screen displaying the paginated posts/notes feed of a Tafakor Topic,
/// matching Image 3 and Image 1 with full high-performance rendering.
class TafakorTopicFeedScreen extends ConsumerStatefulWidget {
  final TafakorTopic topic;
  final int? highlightPostId;
  final TafakorPost? initialHighlightPost;

  const TafakorTopicFeedScreen({
    super.key,
    required this.topic,
    this.highlightPostId,
    this.initialHighlightPost,
  });

  static Future<void> push(
    BuildContext context,
    TafakorTopic topic, {
    int? highlightPostId,
    TafakorPost? initialHighlightPost,
  }) {
    final navContext = rootNavigatorKey.currentContext ?? context;
    return Navigator.of(navContext).push(
      MaterialPageRoute(
        builder: (_) => TafakorTopicFeedScreen(
          topic: topic,
          highlightPostId: highlightPostId,
          initialHighlightPost: initialHighlightPost,
        ),
      ),
    );
  }

  @override
  ConsumerState<TafakorTopicFeedScreen> createState() =>
      _TafakorTopicFeedScreenState();
}

class _TafakorTopicFeedScreenState
    extends ConsumerState<TafakorTopicFeedScreen> {
  late final ScrollController _scrollController;
  late final QuillController _quillController;
  late final FocusNode _textFocusNode;
  late final ScrollController _inputScrollController;
  bool _showScrollToBottom = false;
  TafakorPost? _editingPost;
  bool _isSubmitting = false;
  String? _attachedMediaPath;
  bool _isAttachedVideo = false;
  int _feedFilterIndex = 0; // 0: all, 1: with ayah, 2: without ayah
  final GlobalKey _highlightKey = GlobalKey();
  final Set<String> _deletingAyahKeys = {};
  bool _hasScrolledToHighlight = false;
  bool _isScrollingToHighlight = false;

  String _ayahKey(int postId, TafakorQuranReference ref) =>
      '${postId}_${ref.surahNumber}_${ref.ayahNumber}';

  void _triggerScrollToHighlight() {
    if (widget.highlightPostId == null ||
        _hasScrolledToHighlight ||
        _isScrollingToHighlight) {
      return;
    }
    _isScrollingToHighlight = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // Allow route transition to settle
      await Future.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;

      final targetId = widget.highlightPostId;
      if (targetId == null) {
        _isScrollingToHighlight = false;
        return;
      }

      final state = ref.read(tafakorTopicFeedControllerProvider);
      // Ensure filter is set to 0 (all) so target post is visible
      if (_feedFilterIndex != 0) {
        setState(() {
          _feedFilterIndex = 0;
        });
      }

      final filteredPosts = state.posts;
      final targetIndex = filteredPosts.indexWhere((p) => p.id == targetId);
      if (targetIndex == -1) {
        _isScrollingToHighlight = false;
        return;
      }

      _hasScrolledToHighlight = true;
      _isScrollingToHighlight = false;

      if (!_scrollController.hasClients) return;

      // In reverse: true ListView:
      // Index 0 is at offset 0.0 (bottom of screen).
      if (targetIndex == 0) {
        await _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
        if (mounted && _highlightKey.currentContext != null) {
          Scrollable.ensureVisible(
            _highlightKey.currentContext!,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: 0.5,
          );
        }
        return;
      }

      // If the widget is already rendered in the viewport:
      if (_highlightKey.currentContext != null) {
        Scrollable.ensureVisible(
          _highlightKey.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          alignment: 0.5,
        );
        return;
      }

      // If offscreen, jump close to estimated position (average card is ~340px)
      // This forces Flutter's ListView to build and layout the target card
      final estimatedOffset = (targetIndex * 340.0).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.jumpTo(estimatedOffset);

      // Wait for next frame pipeline to attach the RenderBox
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;

      // Precisely center the card on screen
      if (_highlightKey.currentContext != null) {
        Scrollable.ensureVisible(
          _highlightKey.currentContext!,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          alignment: 0.5,
        );
      } else {
        // If slightly further away, wait briefly and try once more
        await Future.delayed(const Duration(milliseconds: 120));
        if (mounted && _highlightKey.currentContext != null) {
          Scrollable.ensureVisible(
            _highlightKey.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            alignment: 0.5,
          );
        }
      }
    });
  }

  String get _currentText {
    final raw = _quillController.document.toPlainText();
    if (raw.endsWith('\n')) return raw.substring(0, raw.length - 1);
    return raw;
  }

  void _setEditorText(String text) {
    final docLen = _quillController.document.length;
    final replaceLen = docLen > 1 ? docLen - 1 : 0;
    _quillController.replaceText(0, replaceLen, text, null);
    _quillController.updateSelection(
      TextSelection.collapsed(offset: text.length),
      ChangeSource.local,
    );
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  void _clearAttachment() {
    setState(() {
      _attachedMediaPath = null;
      _isAttachedVideo = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _quillController = QuillController.basic()..addListener(_onTextChanged);
    _inputScrollController = ScrollController();
    _textFocusNode = FocusNode();
    Future.microtask(() {
      ref
          .read(tafakorTopicFeedControllerProvider.notifier)
          .loadPosts(
            topicId: widget.topic.id,
            highlightPostId: widget.highlightPostId,
            initialHighlightPost: widget.initialHighlightPost,
          );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _quillController.removeListener(_onTextChanged);
    _quillController.dispose();
    _inputScrollController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      // In reverse: true, maxScrollExtent represents the oldest posts at the top
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 240) {
        ref
            .read(tafakorTopicFeedControllerProvider.notifier)
            .loadNextPage(topicId: widget.topic.id);
      }

      // Show scroll-to-bottom FAB when user has scrolled away from the newest posts
      final shouldShow = _scrollController.position.pixels > 300;
      if (shouldShow != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = shouldShow;
        });
      }
    }
  }

  void _scrollToBottom() {
    HapticFeedback.lightImpact();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _startEditingPost(TafakorPost post) async {
    final result = await TafakorPostEditorScreen.push(
      context,
      topic: widget.topic,
      editingPost: post,
    );
    if (result != null && mounted) {
      if (result.wasSent) {
        _cancelEditing();
      } else {
        setState(() {
          _editingPost = post;
          _setEditorText(result.text);
          _attachedMediaPath = result.mediaPath;
          _isAttachedVideo = result.isAttachedVideo;
        });
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      _editingPost = null;
      final docLen = _quillController.document.length;
      if (docLen > 1) {
        _quillController.replaceText(0, docLen - 1, '', null);
      }
      _attachedMediaPath = null;
      _isAttachedVideo = false;
    });
    _textFocusNode.unfocus();
  }

  Future<void> _submitPost(TafakorTopicFeedController controller) async {
    final text = _currentText.trim();
    if (text.isEmpty && _attachedMediaPath == null) return;

    final token = await ref.read(tafakorLocalDataSourceProvider).getToken();
    if (token == null || token.isEmpty) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          'برای ثبت یا ویرایش یادداشت، لطفاً ابتدا وارد حساب خود شوید',
        );
      }
      return;
    }

    final currentUser = ref.read(tafakorUserProvider);
    final currentPhone = currentUser?.phone;
    final state = ref.read(tafakorTopicFeedControllerProvider);
    final isTopicOwner =
        widget.topic.isOwner(currentPhone) ||
        (state.adminsData?.isOwner(currentPhone) ?? false);
    final isTopicAdmin = state.adminsData?.isAdmin(currentPhone) ?? false;

    if (_editingPost != null) {
      final isAuthor = _editingPost!.isAuthor(currentPhone);
      final canModify = isAuthor || isTopicOwner || isTopicAdmin;
      if (!canModify) {
        if (mounted) {
          AppSnackBar.showError(
            context,
            'شما اجازه ویرایش این یادداشت را ندارید',
          );
        }
        return;
      }
    }

    setState(() => _isSubmitting = true);

    if (_editingPost != null) {
      final success = await controller.updatePost(
        postId: _editingPost!.id,
        content: text,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          _cancelEditing();
          AppSnackBar.showSuccess(context, 'یادداشت با موفقیت ویرایش شد');
        } else {
          AppSnackBar.showError(context, 'خطا در ویرایش یادداشت');
        }
      }
    } else {
      final success = await controller.createPost(
        topicId: widget.topic.id,
        content: text,
        mediaFilePath: _attachedMediaPath,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          _cancelEditing();
          _scrollToBottom();
          AppSnackBar.showSuccess(context, 'یادداشت جدید با موفقیت ثبت شد');
        } else {
          final errorMsg =
              ref.read(tafakorTopicFeedControllerProvider).error?.message ??
              'خطا در ثبت یادداشت';
          AppSnackBar.showError(context, errorMsg);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    ref.listen<TafakorTopicFeedState>(tafakorTopicFeedControllerProvider, (
      previous,
      next,
    ) {
      if (widget.highlightPostId != null &&
          !_hasScrolledToHighlight &&
          next.posts.any((p) => p.id == widget.highlightPostId)) {
        _triggerScrollToHighlight();
      }
    });

    final state = ref.watch(tafakorTopicFeedControllerProvider);
    if (widget.highlightPostId != null &&
        !_hasScrolledToHighlight &&
        state.posts.any((p) => p.id == widget.highlightPostId)) {
      _triggerScrollToHighlight();
    }

    final controller = ref.read(tafakorTopicFeedControllerProvider.notifier);

    final currentUser = ref.watch(tafakorUserProvider);
    final isAuthenticated = ref.watch(isTafakorAuthenticatedProvider);
    final currentPhone = currentUser?.phone;

    final isTopicOwner =
        widget.topic.isOwner(currentPhone) ||
        (state.adminsData?.isOwner(currentPhone) ?? false);
    final isTopicAdmin = state.adminsData?.isAdmin(currentPhone) ?? false;
    final canPostInTopic = isAuthenticated;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF121212)
            : theme.scaffoldBackgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(62.0),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 4,
              left: 12.0,
              right: 8.0,
              bottom: 6.0,
            ),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              border: Border(
                bottom: BorderSide(color: colors.cardBorder, width: 0.8),
              ),
            ),
            child: Row(
              children: [
                // Back Button
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
                4.hSpace,

                // Topic Title (e.g. تست ۲)
                Expanded(
                  child: Text(
                    widget.topic.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),

                // Question Mark Icon with "به‌زودی" Badge (Matching Image 3)
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        CupertinoIcons.question_circle,
                        size: 21,
                      ),
                      splashRadius: 20,
                      color: isDark ? Colors.white70 : Colors.black54,
                      onPressed: () {
                        AppSnackBar.showInfo(
                          context,
                          'راهنما و مستندات به زودی اضافه می‌شود',
                        );
                      },
                    ),
                    Positioned(
                      top: 4,
                      left: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2C2E)
                              : Colors.black12,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: isDark ? Colors.white24 : Colors.black26,
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          'به‌زودی',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // 3-Dots Topic Options Menu (Matching Image 3 & Image 2)
                IconButton(
                  tooltip: 'گزینه‌های تاپیک',
                  icon: const Icon(CupertinoIcons.ellipsis_vertical, size: 20),
                  splashRadius: 20,
                  color: isDark ? Colors.white70 : Colors.black54,
                  onPressed: () => _showTopicOptionsMenu(
                    context,
                    isDark,
                    colors,
                    colorScheme,
                    isTopicOwner: isTopicOwner,
                    isTopicAdmin: isTopicAdmin,
                    adminsData: state.adminsData,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            _buildMonochromeFilterBar(isDark, state),
            Expanded(
              child: Stack(
                children: [
                  _buildBody(
                    context,
                    state,
                    controller,
                    isDark,
                    colors,
                    colorScheme,
                    currentPhone: currentPhone,
                    isTopicOwner: isTopicOwner,
                    isTopicAdmin: isTopicAdmin,
                  ),
                  if (_showScrollToBottom)
                    Positioned(
                      left: 16,
                      bottom: 12,
                      child: FloatingActionButton.small(
                        onPressed: _scrollToBottom,
                        backgroundColor: isDark
                            ? const Color(0xFF2C2C2E)
                            : Colors.white,
                        foregroundColor: isDark
                            ? Colors.white
                            : const Color(0xFF1C1C1E),
                        elevation: 3,
                        shape: const CircleBorder(),
                        child: const Icon(
                          CupertinoIcons.chevron_down,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _buildBottomInputBar(
              context,
              controller,
              isDark,
              colors,
              colorScheme,
              canPostInTopic: canPostInTopic,
              isAuthenticated: isAuthenticated,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TafakorTopicFeedState state,
    TafakorTopicFeedController controller,
    bool isDark,
    dynamic colors,
    ColorScheme colorScheme, {
    required String? currentPhone,
    required bool isTopicOwner,
    required bool isTopicAdmin,
  }) {
    // 1. Initial Fullscreen Loading
    if (state.isLoading && state.posts.isEmpty) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }

    // 2. Fullscreen Error View
    if (state.error != null && state.posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'خطا در دریافت پست‌ها',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              8.vSpace,
              Text(
                state.error?.message ??
                    'لطفاً اتصال اینترنت خود را بررسی کنید.',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => controller.loadPosts(
                  topicId: widget.topic.id,
                  isRefresh: true,
                ),
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

    // 3. Empty Posts View
    if (state.posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: () =>
            controller.loadPosts(topicId: widget.topic.id, isRefresh: true),
        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'هنوز یادداشتی ثبت نشده است',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 4. Paginated Posts List View (Reverse scroll: newest at bottom, history upwards)
    final filteredPosts = _feedFilterIndex == 1
        ? state.posts.where((p) => p.quranReferences.isNotEmpty).toList()
        : (_feedFilterIndex == 2
              ? state.posts.where((p) => p.quranReferences.isEmpty).toList()
              : state.posts);

    if (filteredPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _feedFilterIndex == 1
                ? 'یادداشت مرتبط با آیه یافت نشد'
                : (_feedFilterIndex == 2
                      ? 'یادداشت آزادی یافت نشد'
                      : 'هنوز یادداشتی ثبت نشده است'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          controller.loadPosts(topicId: widget.topic.id, isRefresh: true),
      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
      child: ListView.separated(
        controller: _scrollController,
        reverse: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
        itemCount: filteredPosts.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => 14.vSpace,
        itemBuilder: (context, index) {
          if (index == filteredPosts.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CupertinoActivityIndicator(radius: 12)),
            );
          }

          final post = filteredPosts[index];
          final isAuthor = post.isAuthor(currentPhone);
          final canModifyPost = isAuthor || isTopicOwner || isTopicAdmin;
          final isHighlighted =
              widget.highlightPostId != null &&
              post.id == widget.highlightPostId;

          return RepaintBoundary(
            key: isHighlighted ? _highlightKey : ValueKey(post.id),
            child: TafakorPostCard(
              post: post,
              isDark: isDark,
              colors: colors,
              colorScheme: colorScheme,
              isHighlighted: isHighlighted,
              canModifyPost: canModifyPost,
              isDeletingAyahReference: (reference) =>
                  _deletingAyahKeys.contains(_ayahKey(post.id, reference)),
              onDeleteAyahReference: (reference) => _confirmDeleteAyahReference(
                context,
                post,
                reference,
                controller,
              ),
              onToggleReaction: () {
                HapticFeedback.lightImpact();
                controller.toggleReaction(post.id);
              },
              onMoreOptions: () => _showPostOptionsMenu(
                context,
                post,
                controller,
                isDark,
                colors,
                colorScheme,
                canModifyPost: canModifyPost,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonochromeFilterBar(bool isDark, TafakorTopicFeedState state) {
    final allCount = state.posts.length;
    final withAyahCount = state.posts
        .where((p) => p.quranReferences.isNotEmpty)
        .length;
    final withoutAyahCount = allCount - withAyahCount;

    Widget buildItem(String title, int count, int index) {
      final isSelected = _feedFilterIndex == index;
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _feedFilterIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF2C2C2E) : Colors.white)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? (isDark ? Colors.white24 : Colors.black12)
                  : (isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.04)),
              width: 0.8,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.30 : 0.06,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black87)
                      : (isDark ? Colors.white60 : Colors.black54),
                ),
              ),
              if (state.posts.isNotEmpty) ...[
                5.hSpace,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.5,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                              ? Colors.white.withValues(alpha: 0.16)
                              : Colors.black.withValues(alpha: 0.08))
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.04)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toPersianDigit(),
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
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

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            buildItem('همه', allCount, 0),
            6.hSpace,
            buildItem('مرتبط با آیه', withAyahCount, 1),
            6.hSpace,
            buildItem('یادداشت آزاد', withoutAyahCount, 2),
          ],
        ),
      ),
    );
  }

  /// Bottom Sheet for Post Actions (Matching Image 1)
  void _showPostOptionsMenu(
    BuildContext context,
    TafakorPost post,
    TafakorTopicFeedController controller,
    bool isDark,
    dynamic colors,
    ColorScheme colorScheme, {
    required bool canModifyPost,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.cardBorder, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              8.vSpace,
              // Top drag pill
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              6.vSpace,

              // 1. کپی متن پست
              _MenuActionTile(
                icon: CupertinoIcons.doc_on_doc,
                title: 'کپی متن پست',
                onTap: () {
                  Navigator.pop(sheetContext);
                  Clipboard.setData(ClipboardData(text: post.content));
                  AppSnackBar.showSuccess(context, 'متن پست کپی شد');
                },
              ),

              // 2. وضعیت انتشار
              _MenuActionTile(
                icon: CupertinoIcons.paperplane,
                title: 'وضعیت انتشار',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showPublishStatusDialog(
                    context,
                    post,
                    isDark,
                    colors,
                    colorScheme,
                  );
                },
              ),

              // 3. تاریخچه ویرایش‌ها
              _MenuActionTile(
                icon: CupertinoIcons.clock,
                title: 'تاریخچه ویرایش‌ها',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showEditHistoryDialog(
                    context,
                    post,
                    isDark,
                    colors,
                    colorScheme,
                  );
                },
              ),

              // Only show Edit and Delete if the user is Author, Owner, or Admin
              if (canModifyPost) ...[
                const Divider(height: 1),

                // افزودن آیه مرتبط
                _MenuActionTile(
                  icon: CupertinoIcons.link,
                  title: 'افزودن آیه مرتبط',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    TafakorManageAyahReferencesSheet.show(
                      context,
                      post: post,
                      onPostUpdated: (updatedPost) {
                        controller.updatePostLocally(updatedPost);
                      },
                    );
                  },
                ),

                // 4. ویرایش پست
                _MenuActionTile(
                  icon: CupertinoIcons.pencil,
                  title: 'ویرایش پست',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _startEditingPost(post);
                  },
                ),

                // 5. حذف پست
                _MenuActionTile(
                  icon: CupertinoIcons.trash,
                  title: 'حذف پست',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _confirmDeletePost(context, post, controller);
                  },
                ),
              ],
              8.vSpace,
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteAyahReference(
    BuildContext context,
    TafakorPost post,
    TafakorQuranReference reference,
    TafakorTopicFeedController controller,
  ) {
    HapticFeedback.lightImpact();
    showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: CupertinoAlertDialog(
          title: Text(
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
              onPressed: () => Navigator.pop(dialogCtx),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text(
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
                      (r) =>
                          !(r.surahNumber == reference.surahNumber &&
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

                final key = _ayahKey(post.id, reference);
                setState(() => _deletingAyahKeys.add(key));

                try {
                  final success = await controller.updatePostReferences(
                    postId: post.id,
                    pluginReferences: payload,
                  );

                  if (context.mounted) {
                    if (success) {
                      TafakorQuranRegistry.register(post.id, remainingRefs);
                      AppSnackBar.showSuccess(
                        context,
                        'ارجاع آیه با موفقیت حذف شد.',
                      );
                    } else {
                      AppSnackBar.showError(
                        context,
                        'خطا در حذف ارجاع آیه از یادداشت.',
                      );
                    }
                  }
                } finally {
                  if (mounted) {
                    setState(() => _deletingAyahKeys.remove(key));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePost(
    BuildContext context,
    TafakorPost post,
    TafakorTopicFeedController controller,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: Text(
          'حذف پست',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
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
            child: Text(
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
            child: Text(
              'حذف',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await controller.deletePost(post.id);
              if (context.mounted) {
                if (success) {
                  AppSnackBar.showSuccess(context, 'پست با موفقیت حذف شد');
                } else {
                  AppSnackBar.showError(context, 'خطا در حذف پست');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showPublishStatusDialog(
    BuildContext context,
    TafakorPost post,
    bool isDark,
    dynamic colors,
    ColorScheme colorScheme,
  ) {
    final hasTg = post.publishedPlatforms.contains('telegram');
    final hasBale = post.publishedPlatforms.contains('bale');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'وضعیت انتشار پست در پیام‌رسان‌ها',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            14.vSpace,
            Row(
              children: [
                Icon(
                  hasTg
                      ? CupertinoIcons.check_mark_circled_solid
                      : CupertinoIcons.xmark_circle,
                  color: hasTg ? const Color(0xFF22C55E) : Colors.grey,
                  size: 20,
                ),
                10.hSpace,
                Text(
                  hasTg
                      ? 'منتشر شده در کانال تلگرام'
                      : 'در تلگرام منتشر نشده است',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            10.vSpace,
            Row(
              children: [
                Icon(
                  hasBale
                      ? CupertinoIcons.check_mark_circled_solid
                      : CupertinoIcons.xmark_circle,
                  color: hasBale ? const Color(0xFF22C55E) : Colors.grey,
                  size: 20,
                ),
                10.hSpace,
                Text(
                  hasBale ? 'منتشر شده در کانال بله' : 'در بله منتشر نشده است',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditHistoryDialog(
    BuildContext context,
    TafakorPost post,
    bool isDark,
    dynamic colors,
    ColorScheme colorScheme,
  ) {
    final createdDate = post.formattedJalaliDate ?? 'نامشخص';
    final updatedDate = post.formattedUpdatedJalaliDate ?? createdDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.cardBorder, width: 0.8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.clock,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
                10.hSpace,
                const Text(
                  'تاریخچه ویرایش‌های یادداشت',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            16.vSpace,
            _buildHistoryRow('شناسه پست:', '#${post.id}', colorScheme),
            10.vSpace,
            _buildHistoryRow('زمان ثبت اولیه:', createdDate, colorScheme),
            10.vSpace,
            _buildHistoryRow('آخرین تغییر:', updatedDate, colorScheme),
            if (post.authorName.isNotEmpty || post.authorPhone.isNotEmpty) ...[
              10.vSpace,
              _buildHistoryRow(
                'نویسنده:',
                post.authorName.isNotEmpty ? post.authorName : post.authorPhone,
                colorScheme,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryRow(String label, String value, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            color: colorScheme.onSurface.withValues(alpha: 0.70),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// Bottom Sheet for Topic Options (Matching Image 2 and permission rules)
  void _showTopicOptionsMenu(
    BuildContext context,
    bool isDark,
    dynamic colors,
    ColorScheme colorScheme, {
    required bool isTopicOwner,
    required bool isTopicAdmin,
    required TafakorTopicAdminsData? adminsData,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.cardBorder, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              8.vSpace,
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              6.vSpace,

              // 1. اطلاعات و ادمین‌ها / مدیریت ادمین‌ها (Available to everyone)
              _MenuActionTile(
                icon: CupertinoIcons.shield,
                title: isTopicOwner ? 'مدیریت ادمین‌ها' : 'اطلاعات و ادمین‌ها',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showTopicAdminsInfoDialog(
                    context,
                    isDark,
                    colors,
                    colorScheme,
                    adminsData,
                  );
                },
              ),

              // Editorial & Info options (Available to Owner & Admins)
              if (isTopicOwner || isTopicAdmin) ...[
                // 2. میز ویراستاری تاپیک
                _MenuActionTile(
                  icon: CupertinoIcons.tray,
                  title: 'میز ویراستاری تاپیک',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    AppSnackBar.showInfo(
                      context,
                      'میز ویراستاری تاپیک به زودی فعال می‌شود',
                    );
                  },
                ),

                // 3. ویرایش مشخصات تاپیک
                _MenuActionTile(
                  icon: CupertinoIcons.pencil,
                  title: 'ویرایش مشخصات تاپیک',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    AppSnackBar.showInfo(
                      context,
                      'نام تاپیک: ${widget.topic.name}',
                    );
                  },
                ),

                // 4. تنظیمات اتصالات تاپیک
                _MenuActionTile(
                  icon: CupertinoIcons.link,
                  title: 'تنظیمات اتصالات تاپیک',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    final tg = widget.topic.telegramBotActive
                        ? 'فعال'
                        : 'غیرفعال';
                    final bale = widget.topic.baleBotActive
                        ? 'فعال'
                        : 'غیرفعال';
                    AppSnackBar.showInfo(
                      context,
                      'اتصال تلگرام: $tg | اتصال بله: $bale',
                    );
                  },
                ),
              ],

              // Owner-only options (Import Telegram history & Delete Topic)
              if (isTopicOwner) ...[
                // 5. آپلود تاریخچه تلگرام
                _MenuActionTile(
                  icon: CupertinoIcons.cloud_upload,
                  title: 'آپلود تاریخچه تلگرام',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    AppSnackBar.showInfo(
                      context,
                      'امکان ورود فایل خروجی تاریخچه JSON تلگرام به زودی',
                    );
                  },
                ),

                const Divider(height: 1),

                // 6. حذف تاپیک
                _MenuActionTile(
                  icon: CupertinoIcons.trash,
                  title: 'حذف تاپیک',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _confirmDeleteTopic(context);
                  },
                ),
              ],
              8.vSpace,
            ],
          ),
        );
      },
    );
  }

  void _showTopicAdminsInfoDialog(
    BuildContext context,
    bool isDark,
    dynamic colors,
    ColorScheme colorScheme,
    TafakorTopicAdminsData? adminsData,
  ) {
    final ownerName =
        adminsData?.ownerName ??
        (widget.topic.createdByPhone != null
            ? widget.topic.createdByPhone!.toPersianDigit()
            : 'نامشخص');
    final adminsList = adminsData?.admins ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.cardBorder, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.shield,
                    size: 20,
                    color: colorScheme.onSurface,
                  ),
                  10.hSpace,
                  const Text(
                    'اطلاعات و ادمین‌های تاپیک',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              16.vSpace,
              // Owner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(
                        0xFF00A884,
                      ).withValues(alpha: 0.15),
                      child: const Icon(
                        CupertinoIcons.person_fill,
                        size: 16,
                        color: Color(0xFF00A884),
                      ),
                    ),
                    10.hSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ownerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'سازنده و مالک تاپیک',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A884).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'مالک',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00A884),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              12.vSpace,
              if (adminsList.isNotEmpty) ...[
                Text(
                  'ادمین‌های فعال (${adminsList.length})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                8.vSpace,
                ...adminsList.map(
                  (admin) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.black.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.blue.withValues(
                              alpha: 0.15,
                            ),
                            child: const Icon(
                              CupertinoIcons.person,
                              size: 14,
                              color: Colors.blue,
                            ),
                          ),
                          10.hSpace,
                          Expanded(
                            child: Text(
                              admin.name.isNotEmpty
                                  ? admin.name
                                  : admin.phone.toPersianDigit(),
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            admin.customTitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'ادمین دیگری برای این تاپیک تعریف نشده است.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteTopic(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: Text(
          'حذف تاپیک',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'آیا از حذف تاپیک «${widget.topic.name}» اطمینان دارید؟ تمامی یادداشت‌های آن حذف خواهند شد.',
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
            onPressed: () => Navigator.pop(dialogCtx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(dialogCtx);
              AppSnackBar.showInfo(
                context,
                'حذف تاپیک نیازمند دسترسی ویژه سازنده تاپیک است',
              );
            },
            child: Text(
              'حذف',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Modern bottom input capsule bar matching reference image
  Widget _buildBottomInputBar(
    BuildContext context,
    TafakorTopicFeedController controller,
    bool isDark,
    dynamic colors,
    ColorScheme colorScheme, {
    required bool canPostInTopic,
    required bool isAuthenticated,
  }) {
    if (!canPostInTopic) {
      return Container(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 6.0,
          bottom: MediaQuery.paddingOf(context).bottom + 8.0,
        ),
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.black.withValues(alpha: 0.08),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (isAuthenticated) ...[
                Icon(
                  CupertinoIcons.lock_fill,
                  size: 19,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                10.hSpace,
              ],
              Expanded(
                child: Text(
                  isAuthenticated
                      ? 'ارسال یادداشت در این تاپیک فقط برای سازنده و ادمین‌ها مجاز است'
                      : 'برای ارسال یادداشت، لطفاً ابتدا وارد حساب کاربری شوید',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12.5,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
              if (!isAuthenticated) ...[
                6.hSpace,
                TextButton(
                  onPressed: () => TafakorLoginScreen.push(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: const Color(0xFF00A884),
                  ),
                  child: const Text(
                    'ورود',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return _buildChatInputBar(context, isDark, colorScheme, colors, controller);
  }

  /// Modern floating card input bar matching "دفتر تفکر" (tafakor_editor_screen.dart)
  Widget _buildChatInputBar(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
    dynamic colors,
    TafakorTopicFeedController controller,
  ) {
    final text = _currentText;
    final hasText = text.trim().isNotEmpty;
    final canSend = (hasText || _attachedMediaPath != null) && !_isSubmitting;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF222226) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.18)
                  : const Color(0xFFE5E5EA),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.50)
                    : const Color(0xFF000000).withValues(alpha: 0.08),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
              if (!isDark)
                BoxShadow(
                  color: const Color(0xFF000000).withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: _buildCompactInputContent(
            context,
            isDark,
            colorScheme,
            colors,
            controller,
            canSend,
          ),
        ),
      ),
    );
  }

  /// Compact mode of the input bar
  Widget _buildCompactInputContent(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
    dynamic colors,
    TafakorTopicFeedController controller,
    bool canSend,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. 1:1 media preview if attached
        if (_attachedMediaPath != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _buildMinimal1x1MediaPreview(isDark),
            ),
          ),
        ],

        // 2. Quill Editor for compact mode
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36, maxHeight: 110),
            child: QuillEditor.basic(
              controller: _quillController,
              focusNode: _textFocusNode,
              scrollController: _inputScrollController,
              config: QuillEditorConfig(
                placeholder: _isAttachedVideo
                    ? 'توضیحات اختیاری ویدیو...'
                    : (_attachedMediaPath != null
                          ? 'توضیحات اختیاری تصویر...'
                          : (_editingPost != null
                                ? 'ویرایش متن یادداشت...'
                                : 'یادداشت یا تفکر خود را بنویسید...')),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                autoFocus: false,
                expands: false,
                scrollable: true,
                customStyles: DefaultStyles(
                  paragraph: DefaultTextBlockStyle(
                    TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                    HorizontalSpacing.zero,
                    VerticalSpacing.zero,
                    VerticalSpacing.zero,
                    null,
                  ),
                  placeHolder: DefaultTextBlockStyle(
                    TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : const Color(0xFF8E8E93),
                    ),
                    HorizontalSpacing.zero,
                    VerticalSpacing.zero,
                    VerticalSpacing.zero,
                    null,
                  ),
                ),
              ),
            ),
          ),
        ),

        4.vSpace,

        // 3. Action row UNDERNEATH the text field
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Attachment (+) & Telegram-style Fullscreen Editor button
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMediaPickerButton(context, isDark, colors, colorScheme),
                8.hSpace,
                _buildOpenEditorButton(isDark, colorScheme),
              ],
            ),

            // Right: Send button
            _buildSendButton(canSend, isDark, colorScheme, controller),
          ],
        ),
      ],
    );
  }

  Widget _buildMinimal1x1MediaPreview(bool isDark) {
    if (_attachedMediaPath == null) {
      return const SizedBox.shrink();
    }

    const double size = 72.0;
    final file = File(_attachedMediaPath!);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.12),
              width: 0.9,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: _isAttachedVideo
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.videocam_fill,
                        size: 26,
                        color: isDark ? Colors.white60 : Colors.black45,
                      ),
                      4.vSpace,
                      Text(
                        'ویدیو',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  )
                : Image.file(
                    file,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Center(
                      child: Icon(
                        CupertinoIcons.photo,
                        size: 24,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ),
          ),
        ),

        // Close button in top-left corner
        Positioned(
          top: -4,
          left: -4,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              HapticFeedback.lightImpact();
              _clearAttachment();
            },
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF222226) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                CupertinoIcons.xmark_circle_fill,
                size: 20,
                color: isDark ? Colors.white70 : Colors.black45,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Telegram-style Fullscreen Editor launcher button
  Widget _buildOpenEditorButton(bool isDark, ColorScheme colorScheme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          HapticFeedback.lightImpact();
          final result = await TafakorPostEditorScreen.push(
            context,
            topic: widget.topic,
            editingPost: _editingPost,
            initialText: _currentText,
            initialMediaPath: _attachedMediaPath,
            isAttachedVideo: _isAttachedVideo,
          );
          if (result != null && mounted) {
            if (result.wasSent) {
              _cancelEditing();
            } else {
              setState(() {
                _setEditorText(result.text);
                _attachedMediaPath = result.mediaPath;
                _isAttachedVideo = result.isAttachedVideo;
              });
            }
          }
        },
        child: Tooltip(
          message: 'ویرایشگر تمام‌صفحه (تلگرامی)',
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF2F2F7),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFFE5E5EA),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.unfold_more_rounded,
                size: 20,
                color: isDark ? Colors.white70 : const Color(0xFF3A3A3C),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Circular media attachment button (+ icon)
  Widget _buildMediaPickerButton(
    BuildContext context,
    bool isDark,
    dynamic colors,
    ColorScheme colorScheme,
  ) {
    final isEditing = _editingPost != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          HapticFeedback.lightImpact();
          if (isEditing) {
            _cancelEditing();
          } else {
            _showAddOptions(context, isDark, colors, colorScheme);
          }
        },
        child: Tooltip(
          message: isEditing ? 'انصراف از ویرایش' : 'پیوست رسانه',
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF2F2F7),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFFE5E5EA),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Icon(
                isEditing ? CupertinoIcons.xmark : CupertinoIcons.plus,
                size: isEditing ? 18 : 20,
                color: isEditing
                    ? (isDark
                          ? const Color(0xFFFF6B6B)
                          : const Color(0xFFE53935))
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Circular Send / Action button matching "دفتر تفکر"
  Widget _buildSendButton(
    bool canSend,
    bool isDark,
    ColorScheme colorScheme,
    TafakorTopicFeedController controller, {
    VoidCallback? onPressedOverride,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: canSend
            ? (onPressedOverride ?? () => _submitPost(controller))
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: canSend
                ? const Color(0xFF00A884)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFFE5E5EA)),
            boxShadow: canSend
                ? [
                    BoxShadow(
                      color: const Color(0xFF00A884).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: _isSubmitting
                ? const CupertinoActivityIndicator(
                    color: Colors.white,
                    radius: 9,
                  )
                : Icon(
                    CupertinoIcons.arrow_up,
                    size: 20,
                    color: canSend
                        ? Colors.white
                        : (isDark ? Colors.white30 : const Color(0xFF8E8E93)),
                  ),
          ),
        ),
      ),
    );
  }

  void _showAddOptions(
    BuildContext context,
    bool isDark,
    dynamic colors,
    ColorScheme colorScheme,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.cardBorder, width: 0.8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            8.vSpace,
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            6.vSpace,
            _MenuActionTile(
              icon: CupertinoIcons.photo,
              title: 'ارسال تصویر یادداشت',
              onTap: () async {
                Navigator.pop(sheetContext);
                final file = await ref
                    .read(imagePickerServiceProvider)
                    .pickImageFromGallery();
                if (file != null && mounted) {
                  setState(() {
                    _attachedMediaPath = file.path;
                    _isAttachedVideo = false;
                  });
                  HapticFeedback.lightImpact();
                  AppSnackBar.showSuccess(this.context, 'تصویر ضمیمه شد');
                }
              },
            ),
            _MenuActionTile(
              icon: CupertinoIcons.videocam_fill,
              title: 'ارسال ویدیوی یادداشت',
              onTap: () async {
                Navigator.pop(sheetContext);
                final file = await ref
                    .read(imagePickerServiceProvider)
                    .pickVideoFromGallery();
                if (file != null && mounted) {
                  setState(() {
                    _attachedMediaPath = file.path;
                    _isAttachedVideo = true;
                  });
                  HapticFeedback.lightImpact();
                  AppSnackBar.showSuccess(this.context, 'ویدیو ضمیمه شد');
                }
              },
            ),
            _MenuActionTile(
              icon: CupertinoIcons.link,
              title: 'افزودن پیوند یا مرجع',
              onTap: () {
                Navigator.pop(sheetContext);
                final cur = _currentText;
                final appended = cur.isEmpty ? 'https://' : '$cur\nhttps://';
                _setEditorText(appended);
                _textFocusNode.requestFocus();
              },
            ),
            8.vSpace,
          ],
        ),
      ),
    );
  }
}

/// Menu Action item inside context bottom sheet
class _MenuActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? const Color(0xFFEF4444)
        : context.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              14.hSpace,
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

