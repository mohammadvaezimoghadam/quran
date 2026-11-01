import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../../../common/widgets/app_cached_network_image.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/tafakor_post.dart';
import '../../domain/entities/tafakor_quran_reference.dart';
import 'tafakor_ayah_chip.dart';

/// Dedicated Post Card matching Apple-grade monochromatic design with author info,
/// clock time, content, reverse-linked ayah badges, attached media, heart reaction & comments.
class TafakorPostCard extends StatelessWidget {
  final TafakorPost post;
  final bool isDark;
  final dynamic colors;
  final ColorScheme colorScheme;
  final bool isHighlighted;
  final bool isSelectable;
  final bool canModifyPost;
  final bool Function(TafakorQuranReference reference)? isDeletingAyahReference;
  final void Function(TafakorQuranReference reference)? onDeleteAyahReference;
  final VoidCallback onToggleReaction;
  final VoidCallback onMoreOptions;
  final int? maxContentLines;
  final VoidCallback? onExpandContent;
  final double? maxMediaHeight;

  const TafakorPostCard({
    super.key,
    required this.post,
    required this.isDark,
    required this.colors,
    required this.colorScheme,
    this.isHighlighted = false,
    this.isSelectable = true,
    this.canModifyPost = false,
    this.isDeletingAyahReference,
    this.onDeleteAyahReference,
    required this.onToggleReaction,
    required this.onMoreOptions,
    this.maxContentLines,
    this.onExpandContent,
    this.maxMediaHeight,
  });

  @override
  Widget build(BuildContext context) {
    final jalaliDate = post.formattedJalaliDate;
    final isLiked = post.isLiked;
    final totalLikes = post.totalLikes;

    return Container(
      decoration: BoxDecoration(
        color: isHighlighted
            ? (isDark ? const Color(0xFF26262A) : const Color(0xFFF3F3F5))
            : (isDark ? const Color(0xFF1C1C1E) : colors.cardBackground),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isHighlighted
              ? (isDark
                    ? Colors.white.withValues(alpha: 0.38)
                    : Colors.black.withValues(alpha: 0.32))
              : colors.cardBorder,
          width: isHighlighted ? 1.1 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Post Header: Author Avatar & Phone (Right) + Clock Date & 3-Dots Menu (Left)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Author Avatar
              _buildAvatar(),

              10.hSpace,

              // Author Phone & "نویسنده" Role Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (post.authorName.isNotEmpty
                              ? post.authorName
                              : post.authorPhone)
                          .toPersianDigit(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    2.vSpace,
                    Text(
                      'نویسنده',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),

              // Jalali Date + Clock Icon (e.g. ۱۴۰۵/۷/۱۹, ۱۵:۲۴)
              if (jalaliDate != null) ...[
                Text(
                  jalaliDate,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
                4.hSpace,
                Icon(
                  CupertinoIcons.clock,
                  size: 13,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                4.hSpace,
              ],

              // 3-dots Context Menu Button
              IconButton(
                icon: const Icon(CupertinoIcons.ellipsis_vertical, size: 17),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                color: isDark ? Colors.white54 : Colors.black45,
                onPressed: onMoreOptions,
              ),
            ],
          ),

          12.vSpace,

          // 2. Post Content (Text)
          if (post.content.isNotEmpty) ...[
            if (maxContentLines != null)
              LayoutBuilder(
                builder: (context, constraints) {
                  final textStyle = TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    height: 1.6,
                    color: colorScheme.onSurface,
                  );
                  final isRtl = Bidi.detectRtlDirectionality(post.content);
                  final span = TextSpan(text: post.content, style: textStyle);
                  final tp = TextPainter(
                    text: span,
                    maxLines: maxContentLines,
                    textDirection:
                        isRtl ? TextDirection.rtl : TextDirection.ltr,
                  );
                  tp.layout(maxWidth: constraints.maxWidth);
                  final exceeds = tp.didExceedMaxLines;

                  return GestureDetector(
                    onTap: exceeds ? onExpandContent : null,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          post.content,
                          textDirection:
                              isRtl ? TextDirection.rtl : TextDirection.ltr,
                          maxLines: maxContentLines,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle,
                        ),
                        if (exceeds && onExpandContent != null) ...[
                          4.vSpace,
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(
                              'مشاهده متن کامل...',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              )
            else
              isSelectable
                  ? SelectableText(
                      post.content,
                      textDirection: Bidi.detectRtlDirectionality(post.content)
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        height: 1.6,
                        color: colorScheme.onSurface,
                      ),
                    )
                  : Text(
                      post.content,
                      textDirection: Bidi.detectRtlDirectionality(post.content)
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        height: 1.6,
                        color: colorScheme.onSurface,
                      ),
                    ),
          ],

          // Quran Ayah Badges (Reverse Linkage)
          if (post.hasQuranReference)
            TafakorPostAyahBadgesSection(
              post: post,
              isDark: isDark,
              canModify: canModifyPost,
              isDeletingReference: isDeletingAyahReference,
              onDeleteReference: onDeleteAyahReference,
            ),

          // Media Section (Video / Image / Audio)
          if (post.hasMedia && post.fullMediaUrl != null)
            TafakorPostMediaSection(
              post: post,
              isDark: isDark,
              colors: colors,
              colorScheme: colorScheme,
              maxHeight: maxMediaHeight,
            ),

          14.vSpace,

          // 3. Post Footer: Share Button (Left) + Comments & Hearts (Right)
          Row(
            children: [
              // Share Button (Left)
              IconButton(
                tooltip: 'اشتراک‌گذاری',
                icon: Icon(
                  CupertinoIcons.share,
                  size: 19,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: post.content));
                  AppSnackBar.showSuccess(
                    context,
                    'متن پست برای اشتراک‌گذاری کپی شد',
                  );
                },
              ),

              const Spacer(),

              // Comments Count & Icon (e.g. 💬 ۰)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      post.commentsCount.toPersianDigit(),
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    6.hSpace,
                    Icon(
                      CupertinoIcons.chat_bubble,
                      size: 16,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ],
                ),
              ),

              8.hSpace,

              // Heart Reaction & Count (e.g. ♡ ۰ or ❤️ ۲)
              InkWell(
                onTap: onToggleReaction,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isLiked
                        ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.03)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isLiked
                          ? const Color(0xFFEF4444).withValues(alpha: 0.35)
                          : Colors.transparent,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        totalLikes > 0 ? totalLikes.toPersianDigit() : '۰',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isLiked
                              ? const Color(0xFFEF4444)
                              : (isDark ? Colors.white60 : Colors.black54),
                        ),
                      ),
                      6.hSpace,
                      Icon(
                        isLiked
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        size: 16,
                        color: isLiked
                            ? const Color(0xFFEF4444)
                            : (isDark ? Colors.white60 : Colors.black54),
                      ),
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

  Widget _buildAvatar() {
    if (post.authorAvatar != null && post.authorAvatar!.isNotEmpty) {
      return AppCachedNetworkImage(
        imageUrl: post.authorAvatar,
        width: 36,
        height: 36,
        borderRadius: BorderRadius.circular(18),
        backgroundColor: isDark
            ? const Color(0xFF2C2C2E)
            : const Color(0xFFE5E5EA),
      );
    }

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 0.8,
        ),
      ),
      child: Text(
        post.authorName.isNotEmpty ? post.authorName.characters.first : 'ن',
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
        ),
      ),
    );
  }
}

/// Dynamic Media Section Widget for Tafakor Post (Video, Image, Audio)
class TafakorPostMediaSection extends StatelessWidget {
  final TafakorPost post;
  final bool isDark;
  final dynamic colors;
  final ColorScheme colorScheme;
  final double? maxHeight;

  const TafakorPostMediaSection({
    super.key,
    required this.post,
    required this.isDark,
    required this.colors,
    required this.colorScheme,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (!post.hasMedia || post.fullMediaUrl == null) {
      return const SizedBox.shrink();
    }

    if (post.isVideo) {
      return Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: TafakorPostVideoWidget(
          videoUrl: post.fullMediaUrl!,
          fileName: post.mediaFileName,
          isDark: isDark,
          colorScheme: colorScheme,
          maxHeight: maxHeight,
        ),
      );
    }

    if (post.isAudio) {
      return Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: TafakorPostAudioWidget(
          audioUrl: post.fullMediaUrl!,
          fileName: post.mediaFileName,
          isDark: isDark,
          colorScheme: colorScheme,
        ),
      );
    }

    // Default to Image
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: TafakorPostImageWidget(
        imageUrl: post.fullMediaUrl!,
        isDark: isDark,
        height: maxHeight,
      ),
    );
  }
}

/// Rich Telegram-style Video Player Card for Post Feed
class TafakorPostVideoWidget extends StatelessWidget {
  final String videoUrl;
  final String fileName;
  final bool isDark;
  final ColorScheme colorScheme;
  final double? maxHeight;

  const TafakorPostVideoWidget({
    super.key,
    required this.videoUrl,
    required this.fileName,
    required this.isDark,
    required this.colorScheme,
    this.maxHeight,
  });

  Future<void> _playVideo(BuildContext context) async {
    HapticFeedback.lightImpact();
    final uri = Uri.tryParse(videoUrl);
    if (uri == null) {
      AppSnackBar.showError(context, 'آدرس ویدیو نامعتبر است');
      return;
    }
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, 'خطا در باز کردن ویدیو: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Material(
        color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF2F2F7),
        child: InkWell(
          onTap: () => _playVideo(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Dark gradient background container
              Container(
                height: maxHeight ?? 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)]
                        : [const Color(0xFFE5E5EA), const Color(0xFFD1D1D6)],
                  ),
                ),
              ),

              // Video Badge at Top Right (RTL: top left / top right)
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.videocam_fill,
                        size: 12,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'ویدیو',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Large Glowing Play Button (Telegram / iOS style)
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : Colors.black87,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  CupertinoIcons.play_arrow_solid,
                  size: 26,
                  color: isDark ? Colors.black87 : Colors.white,
                ),
              ),

              // Video File Name / Play Prompt at Bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.70),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          fileName.isNotEmpty
                              ? fileName
                              : 'مشاهده ویدیوی ضمیمه‌شده',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      10.hSpace,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.play_circle,
                              size: 13,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'پخش ویدیو',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rich Telegram-style Audio Waveform & Player Card for Post Feed
class TafakorPostAudioWidget extends StatelessWidget {
  final String audioUrl;
  final String fileName;
  final bool isDark;
  final ColorScheme colorScheme;

  const TafakorPostAudioWidget({
    super.key,
    required this.audioUrl,
    required this.fileName,
    required this.isDark,
    required this.colorScheme,
  });

  Future<void> _playAudio(BuildContext context) async {
    HapticFeedback.lightImpact();
    final uri = Uri.tryParse(audioUrl);
    if (uri == null) return;
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          width: 0.8,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Play Button
          InkWell(
            onTap: () => _playAudio(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.black87,
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.play_arrow_solid,
                size: 16,
                color: isDark ? Colors.black87 : Colors.white,
              ),
            ),
          ),

          12.hSpace,

          // Audio File Info & Waveform placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fileName.isNotEmpty ? fileName : 'فایل صوتی ضمیمه‌شده',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                4.vSpace,
                // Waveform indicator
                Row(
                  children: List.generate(24, (i) {
                    final heights = [
                      8.0,
                      14.0,
                      6.0,
                      18.0,
                      10.0,
                      12.0,
                      16.0,
                      7.0,
                      15.0,
                      9.0,
                      20.0,
                      11.0,
                      8.0,
                      14.0,
                      6.0,
                      18.0,
                      10.0,
                      12.0,
                      16.0,
                      7.0,
                      15.0,
                      9.0,
                      17.0,
                      8.0,
                    ];
                    return Container(
                      width: 2.5,
                      height: heights[i % heights.length],
                      margin: const EdgeInsets.symmetric(horizontal: 1.2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white30 : Colors.black26,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Image viewer widget for post media
class TafakorPostImageWidget extends StatelessWidget {
  final String imageUrl;
  final bool isDark;
  final double? height;

  const TafakorPostImageWidget({
    super.key,
    required this.imageUrl,
    required this.isDark,
    this.height,
  });

  void _showFullScreen(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.94),
      builder: (dialogCtx) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              CupertinoIcons.xmark,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () => Navigator.pop(dialogCtx),
          ),
        ),
        body: Center(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.8,
            maxScale: 4.0,
            child: AppCachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showFullScreen(context),
          child: AppCachedNetworkImage(
            imageUrl: imageUrl,
            height: height ?? 200,
            width: double.infinity,
            fit: BoxFit.cover,
            backgroundColor: isDark
                ? const Color(0xFF2C2C2E)
                : const Color(0xFFE5E5EA),
          ),
        ),
      ),
    );
  }
}
