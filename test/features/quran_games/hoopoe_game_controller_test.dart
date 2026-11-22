import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/features/main_navigation/application/tab_navigation_controller.dart';
import 'package:quran/features/quran_games/application/hoopoe_game_controller.dart';

void main() {
  group('HoopoeGameController Tests', () {
    test('Initial state is clean and ready', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(hoopoeGameControllerProvider);
      expect(state.score, 0);
      expect(state.combo, 0);
      expect(state.feathers, 3);
      expect(state.wordIndex, 0);
      expect(state.ayahIndex, 0);
      expect(state.isPlaying, false);
      expect(state.isGameOver, false);
      expect(state.isVictory, false);

      final controller = container.read(hoopoeGameControllerProvider.notifier);
      expect(controller.currentStage.surahNumber, 112);
      expect(controller.expectedWord, 'قُلْ');
    });

    test('startOrResume activates gameplay', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(hoopoeGameControllerProvider.notifier);
      controller.startOrResume();

      final state = container.read(hoopoeGameControllerProvider);
      expect(state.isPlaying, true);
      expect(state.isPaused, false);
    });

    test('recordCorrectGate advances word, builds combo and score', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(hoopoeGameControllerProvider.notifier);
      controller.startOrResume();

      // First word: "قُلْ"
      controller.recordCorrectGate();
      var state = container.read(hoopoeGameControllerProvider);
      expect(state.score, 100);
      expect(state.combo, 1);
      expect(state.wordIndex, 1);
      expect(controller.expectedWord, 'هُوَ');

      // Second word: "هُوَ" (combo x2 -> 200 pts)
      controller.recordCorrectGate();
      state = container.read(hoopoeGameControllerProvider);
      expect(state.score, 300);
      expect(state.combo, 2);
      expect(state.wordIndex, 2);
      expect(controller.expectedWord, 'اللَّهُ');
    });

    test('recordWrongGate drops feathers and breaks combo', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(hoopoeGameControllerProvider.notifier);
      controller.startOrResume();

      // Hit 1 correct gate -> combo = 1
      controller.recordCorrectGate();
      expect(container.read(hoopoeGameControllerProvider).combo, 1);

      // Hit wrong gate
      controller.recordWrongGate();
      var state = container.read(hoopoeGameControllerProvider);
      expect(state.feathers, 2);
      expect(state.combo, 0);
      expect(state.isGameOver, false);

      // 2 more wrong gates -> GameOver
      controller.recordWrongGate();
      controller.recordWrongGate();
      state = container.read(hoopoeGameControllerProvider);
      expect(state.feathers, 0);
      expect(state.isGameOver, true);
      expect(state.isPlaying, false);
    });

    test('Completing all words in all ayahs triggers Victory', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(hoopoeGameControllerProvider.notifier);
      controller.startOrResume();

      final stage = controller.currentStage;
      for (final ayah in stage.ayahs) {
        for (int i = 0; i < ayah.words.length; i++) {
          controller.recordCorrectGate();
        }
      }

      final state = container.read(hoopoeGameControllerProvider);
      expect(state.isVictory, true);
      expect(state.isPlaying, false);
      expect(state.score, greaterThan(1500));
    });

    test('Stage switching and restart reset gameplay state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(hoopoeGameControllerProvider.notifier);
      controller.selectStage(1); // Al-Kawthar

      expect(controller.currentStage.surahNumber, 108);
      expect(controller.expectedWord, 'إِنَّا');

      controller.startOrResume();
      controller.recordCorrectGate();
      expect(container.read(hoopoeGameControllerProvider).wordIndex, 1);

      controller.restartStage();
      final state = container.read(hoopoeGameControllerProvider);
      expect(state.wordIndex, 0);
      expect(state.score, 0);
      expect(state.feathers, 3);
      expect(state.isPlaying, true);
    });
  });

  group('TabNavigationController Integration with Games Tab', () {
    test('Switching to Tab 4 (Games) updates history and currentIndex', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final nav = container.read(tabNavigationControllerProvider.notifier);
      expect(container.read(tabNavigationControllerProvider).currentIndex, 0);

      // Switch to Games tab (index 4)
      nav.switchTab(4);
      var state = container.read(tabNavigationControllerProvider);
      expect(state.currentIndex, 4);
      expect(state.history, [0, 4]);

      // Handle back press pops to Home (index 0)
      final canExit = nav.handleBackPress();
      expect(canExit, false);
      state = container.read(tabNavigationControllerProvider);
      expect(state.currentIndex, 0);
      expect(state.history, [0]);
    });
  });
}
