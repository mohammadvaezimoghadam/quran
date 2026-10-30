import 'package:flutter_test/flutter_test.dart';
import 'package:quran/features/tafakor/domain/entities/tafakor_post.dart';
import 'package:quran/features/tafakor/infrastructure/services/tafakor_quran_extractor.dart';

void main() {
  group('TafakorQuranRegistry Tests (Strict Server-Driven)', () {
    setUp(() {
      TafakorQuranRegistry.clear();
    });

    test('registers references strictly from server plugin_references payload', () {
      final rawPost = {
        'id': 125,
        'plugin_references': [
          {
            'plugin_identifier': 'quran',
            'resource_type': 'ayah',
            'external_id': 'surah:1,ayah:6',
            'metadata': {
              'surah_number': 1,
              'ayah_number': 6,
              'surah_name': 'فاتحه',
            },
          }
        ]
      };

      TafakorQuranRegistry.registerFromRaw(rawPost);

      const post = TafakorPost(
        id: 125,
        topicId: 1,
        authorId: 1,
        authorPhone: '09123456789',
        authorName: 'تست',
        content: 'تست',
      );

      final refs = post.quranReferences;
      expect(refs.length, 1);
      expect(refs.first.surahNumber, 1);
      expect(refs.first.ayahNumber, 6);
      expect(refs.first.surahName, 'فاتحه');
      expect(post.hasQuranReference, true);
    });

    test('returns empty list if server plugin_references is empty (No Client Heuristics)', () {
      final rawPost = {
        'id': 51,
        'plugin_references': [],
      };

      TafakorQuranRegistry.registerFromRaw(rawPost);

      const post = TafakorPost(
        id: 51,
        topicId: 1,
        authorId: 1,
        authorPhone: '09123456789',
        authorName: 'تست',
        content: 'الرحمن\nكُلُّ مَنْ عَلَيْهَا فَانٍ\n.(۲۶)',
      );

      // Client strictly adheres to server data: server sent [], so refs is empty!
      final refs = post.quranReferences;
      expect(refs.isEmpty, true);
      expect(post.hasQuranReference, false);
    });
  });
}
