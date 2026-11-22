import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import '../../domain/models/hoopoe_game_models.dart';
import 'components/burst_spark_component.dart';
import 'components/hoopoe_character_component.dart';
import 'components/parallax_sky_background.dart';
import 'components/word_gate_component.dart';

class HoopoeFlightGame extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  final VoidCallback onCorrectGate;
  final VoidCallback onWrongGate;
  final SurahStage Function() getCurrentStage;
  final GameAyah Function() getCurrentAyah;
  final int Function() getCurrentWordIndex;
  final bool Function() isGameActive;

  late final HoopoeCharacterComponent player = HoopoeCharacterComponent(
    position: Vector2(100, 260),
  );
  late final ParallaxSkyBackground _skyBackground;
  double _spawnTimer = 1.0;
  static const double spawnInterval = 2.4;
  final math.Random _random = math.Random();

  HoopoeFlightGame({
    required this.onCorrectGate,
    required this.onWrongGate,
    required this.getCurrentStage,
    required this.getCurrentAyah,
    required this.getCurrentWordIndex,
    required this.isGameActive,
  });

  @override
  Future<void> onLoad() async {
    // 1. Celestial Sky Background with Surah Atmosphere
    _skyBackground = ParallaxSkyBackground(
      atmosphere: getCurrentStage().atmosphere,
    );
    await add(_skyBackground);

    // 2. Animated Hoopoe Character
    player.position = Vector2(size.x * 0.24, size.y * 0.48);
    await add(player);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (!isGameActive()) return;

    player.flap();
    HapticFeedback.selectionClick();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isGameActive()) return;

    _spawnTimer -= dt;
    if (_spawnTimer <= 0) {
      _spawnTimer = spawnInterval;
      _spawnGatePair();
    }
  }

  void _spawnGatePair() {
    final stage = getCurrentStage();
    final ayah = getCurrentAyah();
    final wordIndex = getCurrentWordIndex();
    if (wordIndex >= ayah.words.length) return;

    final correctWord = ayah.words[wordIndex];
    final distractors = ayah.distractors;
    final distractorWord = distractors.isNotEmpty
        ? distractors[_random.nextInt(distractors.length)]
        : 'الْحَمْدُ';

    final topY = size.y * 0.30;
    final bottomY = size.y * 0.62;
    final startX = size.x + 70.0;

    final isTopCorrect = _random.nextBool();

    final gateTop = WordGateComponent(
      gateData: WordGateData(
        word: isTopCorrect ? correctWord : distractorWord,
        isCorrect: isTopCorrect,
        wordIndexInAyah: wordIndex,
      ),
      isTopGate: true,
      atmosphere: stage.atmosphere,
      position: Vector2(startX, topY),
    );

    final gateBottom = WordGateComponent(
      gateData: WordGateData(
        word: isTopCorrect ? distractorWord : correctWord,
        isCorrect: !isTopCorrect,
        wordIndexInAyah: wordIndex,
      ),
      isTopGate: false,
      atmosphere: stage.atmosphere,
      position: Vector2(startX, bottomY),
    );

    add(gateTop);
    add(gateBottom);
  }

  void onGateCrossed(WordGateComponent gate, HoopoeCharacterComponent player) {
    final stage = getCurrentStage();
    if (gate.gateData.isCorrect) {
      player.celebrate();
      add(
        BurstSparkComponent(
          position: gate.position.clone(),
          count: 18,
          color: stage.atmosphere.gateGlowColor,
        ),
      );
      HapticFeedback.lightImpact();
      onCorrectGate();
    } else {
      player.hurt();
      add(
        BurstSparkComponent(
          position: gate.position.clone(),
          count: 12,
          color: const Color(0xFFFF7043),
        ),
      );
      HapticFeedback.mediumImpact();
      onWrongGate();
    }
  }

  void resetPlayer() {
    player.position = Vector2(size.x * 0.24, size.y * 0.48);
    player.velocityY = 0;
    _spawnTimer = 1.0;
  }
}
