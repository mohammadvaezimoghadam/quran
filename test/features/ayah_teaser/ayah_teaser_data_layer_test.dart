import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/features/ayah_teaser/domain/repositories/i_ayah_teaser_repository.dart';
import 'package:quran/features/ayah_teaser/infrastructure/datasources/ayah_teaser_remote_datasource.dart';
import 'package:quran/features/ayah_teaser/infrastructure/dtos/ayah_teaser_dto.dart';
import 'package:quran/features/ayah_teaser/infrastructure/repositories/ayah_teaser_repository_impl.dart';

class MockAyahTeaserRemoteDataSource implements AyahTeaserRemoteDataSource {
  int fetchCallCount = 0;
  bool shouldThrow = false;
  String? errorMessage;
  SurahTeasersDto? customResponse;

  @override
  Future<SurahTeasersDto> fetchSurahLatestPosts(int surahNumber) async {
    fetchCallCount++;
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: 'notes/surah-latest-posts/'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: 'notes/surah-latest-posts/'),
          statusCode: 400,
          data: {
            'success': false,
            'error': errorMessage ?? 'خطای اعتبارسنجی سوره',
            'detail': errorMessage ?? 'خطای اعتبارسنجی سوره',
          },
        ),
      );
    }

    if (customResponse != null) {
      return customResponse!;
    }

    return SurahTeasersDto.fromJson({
      'surah': surahNumber,
      'total_ayahs_with_posts': 2,
      'items': [
        {
          'ayah': 2,
          'post_id': 101,
          'topic': {'id': 1, 'name': 'تدبر سوره حجرات'},
          'author': {
            'id': 12,
            'name': 'علی احمدی',
            'phone': '09123456789',
            'avatar': 'https://tafakormag.ir/media/avatars/user.jpg',
          },
          'content': 'این آیه درباره ادب صحبت کردن با پیامبر است',
          'content_preview': 'این آیه درباره ادب صحبت کردن با پیامبر است',
          'media_type': 'text',
          'media_url': null,
          'created_at': '2026-11-05T08:00:00Z',
        },
        {
          'ayah': 5,
          'post_id': 102,
          'topic': {'id': 1, 'name': 'تدبر سوره حجرات'},
          'author': {
            'id': 14,
            'name': 'زهرا حسینی',
            'phone': '09121112233',
            'avatar': null,
          },
          'content': 'نکته بسیار مهم در آیه ۵',
          'content_preview': 'نکته بسیار مهم در آیه ۵',
          'media_type': 'text',
          'media_url': null,
          'created_at': '2026-11-05T08:30:00Z',
        }
      ],
    });
  }
}

void main() {
  group('AyahTeaser DTO & Domain Mapping Tests', () {
    test('Correctly deserializes JSON response and maps to Domain entities', () {
      final json = {
        'surah': 49,
        'total_ayahs_with_posts': 1,
        'items': [
          {
            'ayah': 2,
            'post_id': 50,
            'topic': {'id': 7, 'name': 'اخلاق نبوی'},
            'author': {
              'id': 9,
              'name': 'علی احمدی',
              'phone': '09123456789',
              'avatar': 'https://example.com/avatar.jpg'
            },
            'content': 'این آیه درباره ادب صحبت کردن با پیامبر است',
            'content_preview': 'این آیه درباره ادب صحبت کردن با پیامبر است',
            'media_type': 'text',
            'media_url': null,
            'created_at': '2026-11-05T09:00:00Z'
          }
        ]
      };

      final dto = SurahTeasersDto.fromJson(json);
      expect(dto.surah, 49);
      expect(dto.totalAyahsWithPosts, 1);
      expect(dto.items.length, 1);

      final domain = dto.toDomain();
      expect(domain.surah, 49);
      expect(domain.totalAyahsWithPosts, 1);
      expect(domain.hasTeaserForAyah(2), isTrue);
      expect(domain.hasTeaserForAyah(1), isFalse);

      final item = domain.getForAyah(2);
      expect(item, isNotNull);
      expect(item!.ayah, 2);
      expect(item.postId, 50);
      expect(item.author.name, 'علی احمدی');
      expect(item.author.avatar, 'https://example.com/avatar.jpg');
      expect(item.topic.name, 'اخلاق نبوی');
      expect(item.content, 'این آیه درباره ادب صحبت کردن با پیامبر است');
    });

    test('Gracefully handles empty items list and missing null fields', () {
      final emptyJson = {
        'surah': 1,
        'total_ayahs_with_posts': 0,
        'items': []
      };

      final dto = SurahTeasersDto.fromJson(emptyJson);
      final domain = dto.toDomain();

      expect(domain.surah, 1);
      expect(domain.totalAyahsWithPosts, 0);
      expect(domain.items, isEmpty);
      expect(domain.getForAyah(1), isNull);
      expect(domain.hasTeaserForAyah(1), isFalse);
    });
  });

  group('AyahTeaserRepositoryImpl Tests', () {
    late MockAyahTeaserRemoteDataSource mockDataSource;
    late IAyahTeaserRepository repository;

    setUp(() {
      mockDataSource = MockAyahTeaserRemoteDataSource();
      repository = AyahTeaserRepositoryImpl(mockDataSource);
    });

    test('getSurahLatestPosts successfully returns data and caches it in memory', () async {
      // 1. First call: hits remote data source
      final res1 = await repository.getSurahLatestPosts(surahNumber: 49);
      expect(res1.isSuccess(), isTrue);
      final data1 = res1.tryGetSuccess()!;
      expect(data1.surah, 49);
      expect(data1.totalAyahsWithPosts, 2);
      expect(mockDataSource.fetchCallCount, 1);

      // 2. Second call: should return from in-memory cache without hitting remote data source
      final res2 = await repository.getSurahLatestPosts(surahNumber: 49);
      expect(res2.isSuccess(), isTrue);
      expect(mockDataSource.fetchCallCount, 1); // call count unchanged!

      // 3. Third call with forceRefresh: true -> should hit remote data source again
      final res3 = await repository.getSurahLatestPosts(surahNumber: 49, forceRefresh: true);
      expect(res3.isSuccess(), isTrue);
      expect(mockDataSource.fetchCallCount, 2); // call count incremented
    });

    test('clearCache invalidates cache for specific Surah', () async {
      await repository.getSurahLatestPosts(surahNumber: 49);
      expect(mockDataSource.fetchCallCount, 1);

      repository.clearCache(49);

      await repository.getSurahLatestPosts(surahNumber: 49);
      expect(mockDataSource.fetchCallCount, 2);
    });

    test('Returns Failure on DioException with custom backend error message', () async {
      mockDataSource.shouldThrow = true;
      mockDataSource.errorMessage = 'شماره سوره باید بین ۱ تا ۱۱۴ باشد.';

      final result = await repository.getSurahLatestPosts(surahNumber: 999);
      expect(result.isError(), isTrue);
      final failure = result.tryGetError()!;
      expect(failure.message, 'شماره سوره باید بین ۱ تا ۱۱۴ باشد.');
    });
  });
}

