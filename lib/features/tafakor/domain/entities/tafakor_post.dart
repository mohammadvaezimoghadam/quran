import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../common/constants/app_constants.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../../../common/utils/jalali_date.dart';
import 'tafakor_topic.dart';

part 'tafakor_post.freezed.dart';

@freezed
abstract class TafakorPost with _$TafakorPost {
  const TafakorPost._();

  const factory TafakorPost({
    required int id,
    required int topicId,
    required int authorId,
    required String authorPhone,
    required String authorName,
    String? authorAvatar,
    required String content,
    String? mediaType,
    String? mediaFile,
    String? createdAt,
    String? updatedAt,
    @Default({}) Map<String, int> reactionsSummary,
    String? userReaction,
    @Default(0) int commentsCount,
    @Default([]) List<String> publishedPlatforms,
  }) = _TafakorPost;

  String? get formattedJalaliDate {
    if (createdAt == null || createdAt!.trim().isEmpty) return null;
    try {
      final dt = DateTime.parse(createdAt!).toLocal();
      final j = JalaliDate.fromDateTime(dt);
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      // Format matching Image 3: ۱۴۰۵/۷/۱۹, ۱۵:۲۴
      return '${j.year}/${j.month}/${j.day}, $hour:$minute'.toPersianDigit();
    } catch (_) {
      return null;
    }
  }

  String? get formattedUpdatedJalaliDate {
    if (updatedAt == null || updatedAt!.trim().isEmpty) return null;
    try {
      final dt = DateTime.parse(updatedAt!).toLocal();
      final j = JalaliDate.fromDateTime(dt);
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${j.year}/${j.month}/${j.day}, $hour:$minute'.toPersianDigit();
    } catch (_) {
      return null;
    }
  }

  String? get fullMediaUrl {
    if (mediaFile == null || mediaFile!.trim().isEmpty) return null;
    final file = mediaFile!.trim();
    if (file.startsWith('http://') || file.startsWith('https://')) {
      return file;
    }
    final baseUri = Uri.tryParse(AppConstants.tafakorBaseUrl);
    if (baseUri != null) {
      final hostPort =
          '${baseUri.scheme}://${baseUri.host}${baseUri.hasPort ? ':${baseUri.port}' : ''}';
      return file.startsWith('/') ? '$hostPort$file' : '$hostPort/$file';
    }
    return file;
  }

  int get totalLikes {
    if (reactionsSummary.isEmpty) return 0;
    return reactionsSummary.values.fold(0, (sum, val) => sum + val);
  }

  bool get isLiked => userReaction != null && userReaction!.isNotEmpty;

  bool isAuthor(String? userPhone) {
    if (userPhone == null || userPhone.trim().isEmpty || authorPhone.trim().isEmpty) {
      return false;
    }
    return TafakorTopic.normalizePhone(userPhone) == TafakorTopic.normalizePhone(authorPhone);
  }

  bool get hasMedia => mediaFile != null && mediaFile!.trim().isNotEmpty;

  bool get isVideo {
    if (!hasMedia) return false;
    final type = mediaType?.toLowerCase().trim() ?? '';
    if (type.contains('video')) return true;
    final path = (fullMediaUrl ?? mediaFile!).toLowerCase();
    final cleanPath = path.split('?').first;
    return cleanPath.endsWith('.mp4') ||
        cleanPath.endsWith('.mov') ||
        cleanPath.endsWith('.mkv') ||
        cleanPath.endsWith('.webm') ||
        cleanPath.endsWith('.avi') ||
        cleanPath.endsWith('.m4v') ||
        cleanPath.endsWith('.3gp') ||
        cleanPath.endsWith('.flv');
  }

  bool get isAudio {
    if (!hasMedia) return false;
    final type = mediaType?.toLowerCase().trim() ?? '';
    if (type.contains('audio')) return true;
    final path = (fullMediaUrl ?? mediaFile!).toLowerCase();
    final cleanPath = path.split('?').first;
    return cleanPath.endsWith('.mp3') ||
        cleanPath.endsWith('.m4a') ||
        cleanPath.endsWith('.wav') ||
        cleanPath.endsWith('.ogg') ||
        cleanPath.endsWith('.aac');
  }

  bool get isImage {
    if (!hasMedia) return false;
    if (isVideo || isAudio) return false;
    return true;
  }

  String get mediaFileName {
    if (!hasMedia) return '';
    try {
      final uri = Uri.parse(mediaFile!.trim());
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        return segments.last;
      }
    } catch (_) {}
    return 'فایل ضمیمه';
  }
}

