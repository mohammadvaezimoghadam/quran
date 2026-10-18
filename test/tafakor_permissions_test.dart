import 'package:flutter_test/flutter_test.dart';
import 'package:quran/features/tafakor/domain/entities/tafakor_post.dart';
import 'package:quran/features/tafakor/domain/entities/tafakor_topic.dart';
import 'package:quran/features/tafakor/domain/entities/tafakor_topic_admins_data.dart';

void main() {
  group('Tafakor Phone Normalization Tests', () {
    test('normalizes various Iranian phone formats to standard 09xxxxxxxxx', () {
      expect(TafakorTopic.normalizePhone('09123456789'), '09123456789');
      expect(TafakorTopic.normalizePhone('+989123456789'), '09123456789');
      expect(TafakorTopic.normalizePhone('00989123456789'), '09123456789');
      expect(TafakorTopic.normalizePhone('989123456789'), '09123456789');
      expect(TafakorTopic.normalizePhone('9123456789'), '09123456789');
      expect(TafakorTopic.normalizePhone(' +98 912-345-6789 '), '09123456789');
      expect(TafakorTopic.normalizePhone('(0912) 345 6789'), '09123456789');
    });
  });

  group('TafakorTopic isOwner Tests', () {
    const topic = TafakorTopic(
      id: 10,
      name: 'تاپیک تست تفکر',
      createdBy: 5,
      createdByPhone: '09121111111',
    );

    test('returns true when user phone matches creator phone across formats', () {
      expect(topic.isOwner('09121111111'), isTrue);
      expect(topic.isOwner('+989121111111'), isTrue);
      expect(topic.isOwner('00989121111111'), isTrue);
      expect(topic.isOwner('9121111111'), isTrue);
    });

    test('returns false when user phone is different or empty or null', () {
      expect(topic.isOwner('09129999999'), isFalse);
      expect(topic.isOwner(''), isFalse);
      expect(topic.isOwner(null), isFalse);
    });
  });

  group('TafakorPost isAuthor Tests', () {
    const post = TafakorPost(
      id: 100,
      topicId: 10,
      authorId: 5,
      authorPhone: '09122222222',
      authorName: 'علی محمدی',
      content: 'متن یادداشت تفکر',
    );

    test('returns true when phone matches author phone across formats', () {
      expect(post.isAuthor('09122222222'), isTrue);
      expect(post.isAuthor('+989122222222'), isTrue);
      expect(post.isAuthor('00989122222222'), isTrue);
    });

    test('returns false when phone belongs to someone else or is empty or null', () {
      expect(post.isAuthor('09123333333'), isFalse);
      expect(post.isAuthor(''), isFalse);
      expect(post.isAuthor(null), isFalse);
    });
  });

  group('TafakorPost Media Detection Tests', () {
    test('detects video correctly via mediaType or file extension', () {
      const videoPost1 = TafakorPost(
        id: 1,
        topicId: 1,
        authorId: 1,
        authorPhone: '09121111111',
        authorName: 'User',
        content: 'ویدیو تست',
        mediaType: 'video',
        mediaFile: 'media/video.bin',
      );
      expect(videoPost1.isVideo, isTrue);
      expect(videoPost1.isImage, isFalse);

      const videoPost2 = TafakorPost(
        id: 2,
        topicId: 1,
        authorId: 1,
        authorPhone: '09121111111',
        authorName: 'User',
        content: 'ویدیو تست ۲',
        mediaFile: 'https://example.com/clips/lesson1.mp4',
      );
      expect(videoPost2.isVideo, isTrue);
      expect(videoPost2.isImage, isFalse);
      expect(videoPost2.mediaFileName, 'lesson1.mp4');
    });

    test('detects audio correctly via mediaType or file extension', () {
      const audioPost = TafakorPost(
        id: 3,
        topicId: 1,
        authorId: 1,
        authorPhone: '09121111111',
        authorName: 'User',
        content: 'صوت تست',
        mediaFile: 'https://example.com/audio/recitation.mp3',
      );
      expect(audioPost.isAudio, isTrue);
      expect(audioPost.isVideo, isFalse);
      expect(audioPost.isImage, isFalse);
      expect(audioPost.mediaFileName, 'recitation.mp3');
    });

    test('detects image correctly', () {
      const imagePost = TafakorPost(
        id: 4,
        topicId: 1,
        authorId: 1,
        authorPhone: '09121111111',
        authorName: 'User',
        content: 'عکس تست',
        mediaFile: 'https://example.com/photos/banner.jpg',
      );
      expect(imagePost.isImage, isTrue);
      expect(imagePost.isVideo, isFalse);
      expect(imagePost.isAudio, isFalse);
    });

    test('returns false when no media attached', () {
      const textOnlyPost = TafakorPost(
        id: 5,
        topicId: 1,
        authorId: 1,
        authorPhone: '09121111111',
        authorName: 'User',
        content: 'متن ساده',
      );
      expect(textOnlyPost.hasMedia, isFalse);
      expect(textOnlyPost.isVideo, isFalse);
      expect(textOnlyPost.isImage, isFalse);
      expect(textOnlyPost.isAudio, isFalse);
    });
  });

  group('TafakorTopicAdminsData Permissions Tests', () {
    final adminsData = TafakorTopicAdminsData.fromJson({
      'owner': {
        'id': 1,
        'phone': '09121000000',
        'first_name': 'مهدی',
        'last_name': 'رضایی',
      },
      'admins': [
        {
          'id': 2,
          'phone': '09122000000',
          'first_name': 'سارا',
          'last_name': 'احمدی',
          'custom_title': 'ویراستار ارشد',
        },
        {
          'id': 3,
          'phone': '09123000000',
          'first_name': 'حسین',
          'last_name': 'کریمی',
          'custom_title': 'ناظر محتوا',
        },
      ],
    });

    test('parses owner and admins correctly', () {
      expect(adminsData.ownerId, 1);
      expect(adminsData.ownerPhone, '09121000000');
      expect(adminsData.ownerName, 'مهدی رضایی');
      expect(adminsData.admins.length, 2);
      expect(adminsData.admins[0].name, 'سارا احمدی');
      expect(adminsData.admins[0].customTitle, 'ویراستار ارشد');
      expect(adminsData.admins[1].name, 'حسین کریمی');
    });

    test('identifies owner properly across phone formats', () {
      expect(adminsData.isOwner('09121000000'), isTrue);
      expect(adminsData.isOwner('+989121000000'), isTrue);
      expect(adminsData.isOwner('09122000000'), isFalse);
      expect(adminsData.isOwner('09129999999'), isFalse);
      expect(adminsData.isOwner(null), isFalse);
    });

    test('identifies admins properly across phone formats', () {
      expect(adminsData.isAdmin('09122000000'), isTrue);
      expect(adminsData.isAdmin('+989122000000'), isTrue);
      expect(adminsData.isAdmin('09123000000'), isTrue);
      expect(adminsData.isAdmin('+989123000000'), isTrue);
      expect(adminsData.isAdmin('09121000000'), isFalse); // Owner is checked via isOwner
      expect(adminsData.isAdmin('09129999999'), isFalse);
      expect(adminsData.isAdmin(null), isFalse);
    });

    test('canPost returns true only for owner and admins', () {
      // Owner can post
      expect(adminsData.canPost('09121000000'), isTrue);
      expect(adminsData.canPost('+989121000000'), isTrue);

      // Admins can post
      expect(adminsData.canPost('09122000000'), isTrue);
      expect(adminsData.canPost('09123000000'), isTrue);

      // Regular user cannot post
      expect(adminsData.canPost('09129999999'), isFalse);

      // Unauthenticated user cannot post
      expect(adminsData.canPost(null), isFalse);
      expect(adminsData.canPost(''), isFalse);
    });
  });

  group('Complete Permission Matrix Scenarios (Offline Test)', () {
    const ownerPhone = '09121111111';
    const adminPhone = '09122222222';
    const authorPhone = '09123333333';
    const viewerPhone = '09124444444';

    const topic = TafakorTopic(
      id: 50,
      name: 'مباحث تدبر',
      createdBy: 1,
      createdByPhone: ownerPhone,
    );

    final adminsData = TafakorTopicAdminsData.fromJson({
      'owner': {
        'id': 1,
        'phone': ownerPhone,
        'first_name': 'مالک',
        'last_name': 'تاپیک',
      },
      'admins': [
        {
          'id': 2,
          'phone': adminPhone,
          'first_name': 'ادمین',
          'last_name': 'تاپیک',
        },
      ],
    });

    const authorPost = TafakorPost(
      id: 101,
      topicId: 50,
      authorId: 3,
      authorPhone: authorPhone,
      authorName: 'نویسنده پست',
      content: 'یادداشت تدبر ۱',
    );

    // Permission resolver function matching TafakorTopicFeedScreen logic
    bool checkCanPost(String? userPhone) {
      final isOwner = topic.isOwner(userPhone) || adminsData.isOwner(userPhone);
      final isAdmin = adminsData.isAdmin(userPhone);
      return isOwner || isAdmin;
    }

    bool checkCanModifyPost(TafakorPost post, String? userPhone) {
      final isAuthor = post.isAuthor(userPhone);
      final isOwner = topic.isOwner(userPhone) || adminsData.isOwner(userPhone);
      final isAdmin = adminsData.isAdmin(userPhone);
      return isAuthor || isOwner || isAdmin;
    }

    bool checkCanDeleteTopic(String? userPhone) {
      return topic.isOwner(userPhone) || adminsData.isOwner(userPhone);
    }

    test('Scenario 1: Topic Owner permissions', () {
      expect(checkCanPost(ownerPhone), isTrue, reason: 'Owner can post in topic');
      expect(checkCanModifyPost(authorPost, ownerPhone), isTrue, reason: 'Owner can edit/delete any post');
      expect(checkCanDeleteTopic(ownerPhone), isTrue, reason: 'Owner can delete topic');
    });

    test('Scenario 2: Topic Admin permissions', () {
      expect(checkCanPost(adminPhone), isTrue, reason: 'Admin can post in topic');
      expect(checkCanModifyPost(authorPost, adminPhone), isTrue, reason: 'Admin can edit/delete any post');
      expect(checkCanDeleteTopic(adminPhone), isFalse, reason: 'Admin cannot delete topic');
    });

    test('Scenario 3: Post Author (non-admin, non-owner) permissions', () {
      expect(checkCanPost(authorPhone), isFalse, reason: 'Regular user cannot create new posts if not admin/owner');
      expect(checkCanModifyPost(authorPost, authorPhone), isTrue, reason: 'Author can edit/delete their own existing post');
      expect(checkCanDeleteTopic(authorPhone), isFalse, reason: 'Author cannot delete topic');
    });

    test('Scenario 4: Regular Viewer permissions', () {
      expect(checkCanPost(viewerPhone), isFalse, reason: 'Viewer cannot post');
      expect(checkCanModifyPost(authorPost, viewerPhone), isFalse, reason: 'Viewer cannot edit or delete posts');
      expect(checkCanDeleteTopic(viewerPhone), isFalse, reason: 'Viewer cannot delete topic');
    });

    test('Scenario 5: Unauthenticated guest permissions', () {
      expect(checkCanPost(null), isFalse, reason: 'Guest cannot post');
      expect(checkCanModifyPost(authorPost, null), isFalse, reason: 'Guest cannot edit or delete posts');
      expect(checkCanDeleteTopic(null), isFalse, reason: 'Guest cannot delete topic');
    });
  });
}
