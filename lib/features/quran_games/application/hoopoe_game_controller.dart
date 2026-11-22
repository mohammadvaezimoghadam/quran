import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/hoopoe_game_models.dart';

final hoopoeGameControllerProvider =
    NotifierProvider<HoopoeGameController, HoopoeGameState>(
  HoopoeGameController.new,
);

class HoopoeGameController extends Notifier<HoopoeGameState> {
  @override
  HoopoeGameState build() {
    return const HoopoeGameState(
      stageStars: {0: 3}, // Level 1 starts with 3 stars preview
      unlockedUpToStage: 1, // First 2 levels unlocked
    );
  }

  SurahStage get currentStage =>
      QuranGameStages.stages[state.stageIndex.clamp(0, QuranGameStages.stages.length - 1)];

  GameAyah get currentAyah =>
      currentStage.ayahs[state.ayahIndex.clamp(0, currentStage.ayahs.length - 1)];

  String get expectedWord {
    final words = currentAyah.words;
    if (state.wordIndex < words.length) {
      return words[state.wordIndex];
    }
    return '';
  }

  int get totalStarsEarned {
    return state.stageStars.values.fold(0, (sum, stars) => sum + stars);
  }

  int get maxPossibleStars {
    return QuranGameStages.stages.length * 3;
  }

  void startOrResume() {
    state = state.copyWith(
      isPlaying: true,
      isPaused: false,
      isGameOver: false,
      isVictory: false,
      statusMessage: 'از میان دروازه کلمه صحیح پرواز کنید',
    );
  }

  void togglePause() {
    if (state.isGameOver || state.isVictory) return;
    state = state.copyWith(isPaused: !state.isPaused);
  }

  void recordCorrectGate() {
    final nextCombo = state.combo + 1;
    final points = 100 * nextCombo;
    final nextWordIndex = state.wordIndex + 1;

    if (nextWordIndex >= currentAyah.words.length) {
      // Completed current Ayah!
      final nextAyahIndex = state.ayahIndex + 1;
      if (nextAyahIndex >= currentStage.ayahs.length) {
        // Completed entire Surah Stage!
        // Calculate stars: 3 feathers left = 3 stars, 2 feathers = 2 stars, 1 feather = 1 star
        final earnedStars = state.feathers.clamp(1, 3);
        final newStarsMap = Map<int, int>.from(state.stageStars);
        final prevStars = newStarsMap[state.stageIndex] ?? 0;
        if (earnedStars > prevStars) {
          newStarsMap[state.stageIndex] = earnedStars;
        }

        final nextUnlocked = (state.stageIndex + 1).clamp(0, QuranGameStages.stages.length - 1);
        final updatedUnlocked = nextUnlocked > state.unlockedUpToStage ? nextUnlocked : state.unlockedUpToStage;

        state = state.copyWith(
          score: state.score + points + 1000,
          combo: nextCombo,
          isVictory: true,
          isPlaying: false,
          stageStars: newStarsMap,
          unlockedUpToStage: updatedUnlocked,
          statusMessage: 'ماشاءالله! سوره با موفقیت تکمیل شد!',
        );
      } else {
        // Next Ayah in stage
        state = state.copyWith(
          score: state.score + points + 400,
          combo: nextCombo,
          ayahIndex: nextAyahIndex,
          wordIndex: 0,
          statusMessage: 'آفرین! آیه بعدی...',
        );
      }
    } else {
      // Next Word in current Ayah
      state = state.copyWith(
        score: state.score + points,
        combo: nextCombo,
        wordIndex: nextWordIndex,
        statusMessage: 'صحیح! کلمه بعد: ${currentAyah.words[nextWordIndex]}',
      );
    }
  }

  void recordWrongGate() {
    final remainingFeathers = (state.feathers - 1).clamp(0, 3);
    if (remainingFeathers <= 0) {
      state = state.copyWith(
        feathers: 0,
        combo: 0,
        isGameOver: true,
        isPlaying: false,
        statusMessage: 'فرصت‌ها تمام شد! دوباره تلاش کنید.',
      );
    } else {
      state = state.copyWith(
        feathers: remainingFeathers,
        combo: 0,
        statusMessage: 'اشتباه بود! دقت کن: $expectedWord',
      );
    }
  }

  void restartStage() {
    state = state.copyWith(
      isPlaying: true,
      feathers: 3,
      score: 0,
      combo: 0,
      ayahIndex: 0,
      wordIndex: 0,
      isVictory: false,
      isGameOver: false,
      isPaused: false,
      statusMessage: 'آماده پرواز...',
    );
  }

  void selectStage(int index) {
    state = state.copyWith(
      stageIndex: index.clamp(0, QuranGameStages.stages.length - 1),
      isPlaying: false,
      feathers: 3,
      score: 0,
      combo: 0,
      ayahIndex: 0,
      wordIndex: 0,
      isVictory: false,
      isGameOver: false,
      isPaused: false,
      statusMessage: 'برای شروع پرواز ضربه بزنید',
    );
  }

  void nextStage() {
    final nextIdx = (state.stageIndex + 1) % QuranGameStages.stages.length;
    selectStage(nextIdx);
    startOrResume();
  }
}
