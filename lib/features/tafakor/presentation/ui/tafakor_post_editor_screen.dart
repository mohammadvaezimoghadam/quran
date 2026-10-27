import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/services/media/image_picker_service.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/tafakor_topic_feed_controller.dart';
import '../../domain/entities/tafakor_post.dart';
import '../../domain/entities/tafakor_topic.dart';
import '../../../topic_studio/presentation/widgets/topic_media_picker_sheet.dart';

/// Result returned from [TafakorPostEditorScreen] to preserve user draft on collapse
class TafakorEditorResult {
  final String text;
  final String? mediaPath;
  final bool isAttachedVideo;
  final bool wasSent;

  const TafakorEditorResult({
    required this.text,
    this.mediaPath,
    this.isAttachedVideo = false,
    this.wasSent = false,
  });
}

/// Full-screen Telegram-style Post / Note Editor.
/// Provides a distraction-free writing canvas, Undo/Redo support,
/// keyboard-pinned bottom action bar, and seamless create/edit post capabilities.
class TafakorPostEditorScreen extends ConsumerStatefulWidget {
  final TafakorTopic topic;
  final TafakorPost? editingPost;
  final String? initialText;
  final String? initialMediaPath;
  final bool isAttachedVideo;

  const TafakorPostEditorScreen({
    super.key,
    required this.topic,
    this.editingPost,
    this.initialText,
    this.initialMediaPath,
    this.isAttachedVideo = false,
  });

  static Future<TafakorEditorResult?> push(
    BuildContext context, {
    required TafakorTopic topic,
    TafakorPost? editingPost,
    String? initialText,
    String? initialMediaPath,
    bool isAttachedVideo = false,
  }) {
    return Navigator.of(context).push<TafakorEditorResult>(
      MaterialPageRoute(
        builder: (_) => TafakorPostEditorScreen(
          topic: topic,
          editingPost: editingPost,
          initialText: initialText,
          initialMediaPath: initialMediaPath,
          isAttachedVideo: isAttachedVideo,
        ),
      ),
    );
  }

  @override
  ConsumerState<TafakorPostEditorScreen> createState() =>
      _TafakorPostEditorScreenState();
}

class _TafakorPostEditorScreenState
    extends ConsumerState<TafakorPostEditorScreen> {
  late final QuillController _quillController;
  late final FocusNode _quillFocusNode;
  late final ScrollController _scrollController;

  String? _attachedMediaPath;
  bool _isAttachedVideo = false;
  bool _isSubmitting = false;

  bool get _isEditing => widget.editingPost != null;

  String get _currentText {
    final raw = _quillController.document.toPlainText();
    if (raw.endsWith('\n')) {
      return raw.substring(0, raw.length - 1);
    }
    return raw;
  }

  @override
  void initState() {
    super.initState();
    final initialContent =
        widget.editingPost?.content ?? widget.initialText ?? '';
    final doc = initialContent.isEmpty
        ? Document()
        : (Document()
          ..insert(
            0,
            initialContent.endsWith('\n') ? initialContent : '$initialContent\n',
          ));
    _quillController = QuillController(
      document: doc,
      selection: TextSelection.collapsed(
        offset: initialContent.isNotEmpty ? initialContent.length : 0,
      ),
    );
    _quillFocusNode = FocusNode();
    _scrollController = ScrollController();

    _attachedMediaPath = widget.initialMediaPath;
    _isAttachedVideo = widget.isAttachedVideo;

    _quillController.addListener(_onTextChanged);

    // Auto-focus the editor once the view is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _quillFocusNode.requestFocus();
      }
    });
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _quillController.removeListener(_onTextChanged);
    _quillController.dispose();
    _quillFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment([BuildContext? buttonContext]) async {
    HapticFeedback.lightImpact();
    if (_isEditing) {
      AppSnackBar.showInfo(
        context,
        'در حالت ویرایش، فقط امکان ویرایش متن یادداشت وجود دارد.',
      );
      return;
    }

    final type = await TopicMediaPickerSheet.show(buttonContext ?? context);
    if (type == null || !mounted) return;

    final pickerService = ref.read(imagePickerServiceProvider);
    if (type == TopicAttachmentType.image) {
      final image = await pickerService.pickImageFromGallery();
      if (image != null && mounted) {
        setState(() {
          _attachedMediaPath = image.path;
          _isAttachedVideo = false;
        });
        HapticFeedback.mediumImpact();
        AppSnackBar.showSuccess(context, 'تصویر ضمیمه شد');
      }
    } else if (type == TopicAttachmentType.video) {
      final video = await pickerService.pickVideoFromGallery();
      if (video != null && mounted) {
        setState(() {
          _attachedMediaPath = video.path;
          _isAttachedVideo = true;
        });
        HapticFeedback.mediumImpact();
        AppSnackBar.showSuccess(context, 'ویدیو ضمیمه شد');
      }
    }
  }

  void _clearAttachment() {
    HapticFeedback.lightImpact();
    setState(() {
      _attachedMediaPath = null;
      _isAttachedVideo = false;
    });
  }

  Future<void> _handleSubmit() async {
    final text = _currentText.trim();
    if (text.isEmpty && _attachedMediaPath == null) {
      AppSnackBar.showInfo(context, 'لطفاً ابتدا متنی بنویسید.');
      return;
    }

    HapticFeedback.lightImpact();
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() => _isSubmitting = true);
    final controller = ref.read(tafakorTopicFeedControllerProvider.notifier);

    if (_isEditing) {
      final success = await controller.updatePost(
        postId: widget.editingPost!.id,
        content: text,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          AppSnackBar.showSuccess(context, 'یادداشت با موفقیت ویرایش شد');
          Navigator.of(context).pop(const TafakorEditorResult(text: '', wasSent: true));
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
          AppSnackBar.showSuccess(context, 'یادداشت با موفقیت ثبت شد');
          Navigator.of(context).pop(const TafakorEditorResult(text: '', wasSent: true));
        } else {
          AppSnackBar.showError(context, 'خطا در ثبت یادداشت');
        }
      }
    }
  }

  void _popWithDraft() {
    Navigator.of(context).pop(
      TafakorEditorResult(
        text: _currentText,
        mediaPath: _attachedMediaPath,
        isAttachedVideo: _isAttachedVideo,
        wasSent: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDark;
    final colorScheme = context.colorScheme;
    final canSubmit = (_currentText.trim().isNotEmpty ||
            _attachedMediaPath != null) &&
        !_isSubmitting;

    // Seamless background matching app scaffold
    final scaffoldBg = isDark ? const Color(0xFF121212) : theme.scaffoldBackgroundColor;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _popWithDraft();
        },
        child: Scaffold(
          backgroundColor: scaffoldBg,
          resizeToAvoidBottomInset: true,
          appBar: _buildAppBar(isDark, colorScheme, scaffoldBg),
          body: Column(
            children: [
              // 1. Full-bleed, scrollable writing canvas
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      controller: _scrollController,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _quillFocusNode.requestFocus();
                            final textLen = _currentText.length;
                            _quillController.updateSelection(
                              TextSelection.collapsed(offset: textLen),
                              ChangeSource.local,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Media attachment preview card (if any)
                                if (_attachedMediaPath != null) ...[
                                  _buildMediaPreview(isDark, cardBg),
                                  14.vSpace,
                                ],

                                // Web & Telegram-style editor powered by flutter_quill
                                QuillEditor.basic(
                                  controller: _quillController,
                                  focusNode: _quillFocusNode,
                                  scrollController: _scrollController,
                                  config: QuillEditorConfig(
                                    placeholder: _isEditing
                                        ? 'متن یادداشت را ویرایش کنید...'
                                        : 'یادداشت یا تفکر خود را بنویسید...',
                                    padding: EdgeInsets.zero,
                                    autoFocus: true,
                                    expands: false,
                                    scrollable: false,
                                    customStyles: DefaultStyles(
                                      paragraph: DefaultTextBlockStyle(
                                        TextStyle(
                                          fontFamily: AppTypography.fontFamily,
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w500,
                                          height: 1.75,
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
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w400,
                                          color: isDark
                                              ? Colors.white.withValues(alpha: 0.32)
                                              : const Color(0xFF8E8E93),
                                        ),
                                        HorizontalSpacing.zero,
                                        VerticalSpacing.zero,
                                        VerticalSpacing.zero,
                                        null,
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
                  },
                ),
              ),

              // 2. Docked bottom toolbar directly above the keyboard
              _buildBottomBar(isDark, cardBg, colorScheme, canSubmit),
            ],
          ),
        ),
      ),
    );
  }

  /// Top Navigation Bar with Back button and native Undo/Redo controls (Telegram style)
  PreferredSizeWidget _buildAppBar(bool isDark, ColorScheme colorScheme, Color scaffoldBg) {
    return AppBar(
      backgroundColor: scaffoldBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        tooltip: 'بازگشت',
        splashRadius: 22,
        icon: Icon(
          CupertinoIcons.chevron_forward,
          size: 24,
          color: colorScheme.onSurface,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          _popWithDraft();
        },
      ),
      title: Text(
        _isEditing ? 'ویرایش یادداشت' : 'یادداشت جدید',
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 16.5,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      actions: [
        // Undo and Redo actions powered by QuillController document history
        ListenableBuilder(
          listenable: _quillController,
          builder: (context, _) {
            final canUndo = _quillController.hasUndo;
            final canRedo = _quillController.hasRedo;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Undo Button (↶)
                IconButton(
                  tooltip: 'واگرد (Undo)',
                  icon: Icon(
                    Icons.undo_rounded,
                    size: 23,
                    color: canUndo
                        ? (isDark ? Colors.white70 : const Color(0xFF2C3E50))
                        : (isDark ? Colors.white24 : Colors.black26),
                  ),
                  onPressed: canUndo
                      ? () {
                          HapticFeedback.selectionClick();
                          _quillController.undo();
                        }
                      : null,
                ),

                // Redo Button (↷)
                IconButton(
                  tooltip: 'تکرار (Redo)',
                  icon: Icon(
                    Icons.redo_rounded,
                    size: 23,
                    color: canRedo
                        ? (isDark ? Colors.white70 : const Color(0xFF2C3E50))
                        : (isDark ? Colors.white24 : Colors.black26),
                  ),
                  onPressed: canRedo
                      ? () {
                          HapticFeedback.selectionClick();
                          _quillController.redo();
                        }
                      : null,
                ),
                4.hSpace,
              ],
            );
          },
        ),
      ],
    );
  }

  /// Media Preview Card inside the canvas
  Widget _buildMediaPreview(bool isDark, Color cardBg) {
    final file = File(_attachedMediaPath!);
    const double previewHeight = 160.0;

    return Stack(
      children: [
        Container(
          height: previewHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _isAttachedVideo
              ? Container(
                  color: isDark ? const Color(0xFF1A1F26) : const Color(0xFF2C3E50),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          CupertinoIcons.videocam_fill,
                          size: 38,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'ویدیوی پیوست شده',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Image.file(
                  file,
                  width: double.infinity,
                  height: previewHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Center(
                    child: Icon(
                      CupertinoIcons.photo,
                      size: 32,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ),
        ),

        // Remove media button in top-left
        Positioned(
          top: 8,
          left: 8,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _clearAttachment,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.xmark,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Pinned bottom bar above keyboard (Telegram style)
  Widget _buildBottomBar(
    bool isDark,
    Color cardBg,
    ColorScheme colorScheme,
    bool canSubmit,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 6,
        bottom: MediaQuery.paddingOf(context).bottom > 0
            ? (MediaQuery.paddingOf(context).bottom / 2) + 6
            : 10,
      ),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Attachment paperclip button (disabled if in edit mode)
          if (!_isEditing)
            Builder(
              builder: (btnCtx) => Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => _pickAttachment(btnCtx),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _attachedMediaPath != null
                          ? const Color(0xFF00A884).withValues(alpha: 0.15)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.paperclip,
                        size: 22,
                        color: _attachedMediaPath != null
                            ? const Color(0xFF00A884)
                            : (isDark ? Colors.white60 : Colors.black54),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 42),

          // Right: Circular Send button with CupertinoIcons.arrow_up (identical to compact mode)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: canSubmit ? _handleSubmit : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: canSubmit
                      ? const Color(0xFF00A884)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.10)
                          : const Color(0xFFE5E5EA)),
                  boxShadow: canSubmit
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
                          color: canSubmit
                              ? Colors.white
                              : (isDark ? Colors.white30 : const Color(0xFF8E8E93)),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
