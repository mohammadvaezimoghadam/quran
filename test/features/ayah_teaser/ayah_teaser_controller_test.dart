import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:quran/common/exceptions/failure.dart';
import 'package:quran/features/ayah_teaser/application/controllers/ayah_teaser_controller.dart';
import 'package:quran/features/ayah_teaser/domain/entities/ayah_teaser_author.dart';
import 'package:quran/features/ayah_teaser/domain/entities/ayah_teaser_item.dart';
import 'package:quran/features/ayah_teaser/domain/entities/ayah_teaser_topic.dart';
import 'package:quran/features/ayah_teaser/domain/entities/surah_teasers_result.dart';
import 'package:quran/features/ayah_teaser/domain/repositories/i_ayah_teaser_repository.dart';
import 'package:quran/features/ayah_teaser/infrastructure/repositories/ayah_teaser_repository_impl.dart';
import 'package:quran/features/quran_reader/application/controllers/quran_reader_controller.dart';

class MockAyahTeaserRepository implements IAyahTeaserRepository {
  SurahTeasersResult? customResult;

  @override
  Future<Result<SurahTeasersResult, Failure>> getSurahLatestPosts({
    required int surahNumber,
    bool forceRefresh = false,
  }) async {
    if (customResult != null) {
      return Success(customResult!);
    }

    return Success(
      SurahTeasersResult(
        surah: surahNumber,
        totalAyahsWithPosts: 1,
        items: [
          const AyahTeaserItem(
            ayah: 2,
            postId: 100,
            topic: AyahTeaserTopic(id: 1, name: 'تدبر سوره حجرات'),
            author: AyahTeaserAuthor(
              id: 5,
              name: 'علی احمدی',
              phone: '09120000000',
              avatar: 'https://example.com/avatar.jpg',
            ),
            content: 'این آیه درباره ادب صحبت کردن با پیامبر است',
            contentPreview: 'این آیه درباره ادب صحبت کردن با پیامبر است',
            mediaType: 'text',
          ),
        ],
      ),
    );
  }

  @override
  void clearCache([int? surahNumber]) {}
}

void main() {
  group('AyahTeaserController 1-Second Debounce & Lifecycle Tests', () {
    late MockAyahTeaserRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockAyahTeaserRepository();
      container = ProviderContainer(
        overrides: [
          ayahTeaserRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      // Eagerly initialize controller so ref.listen is active
      container.read(ayahTeaserControllerProvider);
    });

    tearDown(() {
      container.dispose();
    });

    test('Does NOT show teaser immediately before 1 second elapses', () async {
      final controller = container.read(ayahTeaserControllerProvider.notifier);

      // User scrolls to / focuses on Surah 49, Ayah 2
      await controller.onReadingPositionChanged(49, 2);

      // Immediately after arriving on Ayah: card should NOT be visible yet
      var state = container.read(ayahTeaserControllerProvider);
      expect(state.isVisible, isFalse);

      // Wait 500ms (< 1 second): still NOT visible
      await Future.delayed(const Duration(milliseconds: 500));
      state = container.read(ayahTeaserControllerProvider);
      expect(state.isVisible, isFalse);

      // Wait remaining 600ms (total > 1000ms): now visible!
      await Future.delayed(const Duration(milliseconds: 650));
      state = container.read(ayahTeaserControllerProvider);
      expect(state.isVisible, isTrue);
      expect(state.activeTeaser, isNotNull);
      expect(state.activeTeaser!.ayah, 2);
      expect(state.activeTeaser!.author.name, 'علی احمدی');
    });

    test('Fast scrolling across Ayahs cancels previous timer and does not show teaser', () async {
      final controller = container.read(ayahTeaserControllerProvider.notifier);

      // User scrolls to Ayah 2
      await controller.onReadingPositionChanged(49, 2);

      // Within 300ms, user scrolls quickly to Ayah 3 (which has no teaser)
      await Future.delayed(const Duration(milliseconds: 300));
      await controller.onReadingPositionChanged(49, 3);

      // Wait 800ms (total from start = 1100ms, but only 800ms on Ayah 3): not visible
      await Future.delayed(const Duration(milliseconds: 800));
      var state = container.read(ayahTeaserControllerProvider);
      expect(state.isVisible, isFalse);

      // Wait another 300ms (Ayah 3 now has stayed > 1s, but Ayah 3 has no teaser)
      await Future.delayed(const Duration(milliseconds: 300));
      state = container.read(ayahTeaserControllerProvider);
      expect(state.isVisible, isFalse);
      expect(state.activeTeaser, isNull);
    });

    test('Dismissing teaser hides card and prevents re-trigger for that same Ayah', () async {
      final controller = container.read(ayahTeaserControllerProvider.notifier);

      await controller.onReadingPositionChanged(49, 2);
      await Future.delayed(const Duration(milliseconds: 1100));

      var state = container.read(ayahTeaserControllerProvider);
      expect(state.isVisible, isTrue);

      // User dismisses card
      controller.dismiss();
      state = container.read(ayahTeaserControllerProvider);
      expect(state.isVisible, isFalse);
      expect(state.dismissedAyahs.contains(2), isTrue);

      // If user comes back to Ayah 2, it does not re-open because it was dismissed
      await controller.onReadingPositionChanged(49, 2);
      await Future.delayed(const Duration(milliseconds: 1100));
      state = container.read(ayahTeaserControllerProvider);
      expect(state.isVisible, isFalse);
    });

    test('Listens to currentReadingAyahProvider updates from QuranInfoBar', () async {
      // Trigger update via reading provider (simulating QuranInfoBar output)
      container.read(currentReadingAyahProvider.notifier).updateAyah(49, 2);

      // Wait for 1 second debounce
      await Future.delayed(const Duration(milliseconds: 1200));

      final state = container.read(ayahTeaserControllerProvider);
      expect(state.isVisible, isTrue);
      expect(state.activeTeaser?.ayah, 2);
      expect(state.activeTeaser?.author.name, 'علی احمدی');
    });

    test('Moving away to another Ayah immediately hides visible teaser so it animates out', () async {
      final controller = container.read(ayahTeaserControllerProvider.notifier);

      await controller.onReadingPositionChanged(49, 2);
      await Future.delayed(const Duration(milliseconds: 1100));

      var state = container.read(ayahTeaserControllerProvider);
      expect(state.isVisible, isTrue);

      // Now user changes Ayah to 3
      await controller.onReadingPositionChanged(49, 3);
      state = container.read(ayahTeaserControllerProvider);
      // Immediately hides so exit animation triggers
      expect(state.isVisible, isFalse);
    });

    test('Auto-dismisses teaser card after 5 seconds of staying on the same Ayah', () async {
      final controller = container.read(ayahTeaserControllerProvider.notifier);

      await controller.onReadingPositionChanged(49, 2);
      await Future.delayed(const Duration(milliseconds: 1100));

      var state = container.read(ayahTeaserControllerProvider);
      expect(state.isVisible, isTrue);

      // After 3 seconds: still visible
      await Future.delayed(const Duration(milliseconds: 3000));
      state = container.read(ayahTeaserControllerProvider);
      expect(state.isVisible, isTrue);

      // After another 2.2 seconds (total > 5s): automatically dismissed!
      await Future.delayed(const Duration(milliseconds: 2200));
      state = container.read(ayahTeaserControllerProvider);
      expect(state.isVisible, isFalse);
    });

    test('Initial state has isEnabled = true by default', () {
      final state = container.read(ayahTeaserControllerProvider);
      expect(state.isEnabled, isTrue);
    });

    test('Disabling teaser hides visible card immediately and cancels timers', () async {
      final controller = container.read(ayahTeaserControllerProvider.notifier);

      await controller.onReadingPositionChanged(49, 2);
      await Future.delayed(const Duration(milliseconds: 1100));

      var state = container.read(ayahTeaserControllerProvider);
      expect(state.isVisible, isTrue);

      // User mutes / disables teasers
      await controller.toggleEnabled(false);
      state = container.read(ayahTeaserControllerProvider);
      expect(state.isEnabled, isFalse);
      expect(state.isVisible, isFalse);
      expect(state.activeTeaser, isNull);

      // Fast forward and ensure it stays hidden
      await Future.delayed(const Duration(milliseconds: 1200));
      state = container.read(ayahTeaserControllerProvider);
      expect(state.isVisible, isFalse);
    });

    test('When disabled, advancing across Ayahs does not show teasers', () async {
      final controller = container.read(ayahTeaserControllerProvider.notifier);

      await controller.toggleEnabled(false);

      await controller.onReadingPositionChanged(49, 2);
      await Future.delayed(const Duration(milliseconds: 1200));

      final state = container.read(ayahTeaserControllerProvider);
      expect(state.isEnabled, isFalse);
      expect(state.isVisible, isFalse);
      expect(state.activeTeaser, isNull);
    });

    test('Re-enabling teaser re-evaluates and shows teaser for current Ayah', () async {
      final controller = container.read(ayahTeaserControllerProvider.notifier);

      await controller.toggleEnabled(false);
      await controller.onReadingPositionChanged(49, 2);
      await Future.delayed(const Duration(milliseconds: 1200));

      var state = container.read(ayahTeaserControllerProvider);
      expect(state.isVisible, isFalse);

      // Re-enable
      await controller.toggleEnabled(true);
      state = container.read(ayahTeaserControllerProvider);
      expect(state.isEnabled, isTrue);
      expect(state.isVisible, isTrue);
      expect(state.activeTeaser?.ayah, 2);
    });
  });
}
