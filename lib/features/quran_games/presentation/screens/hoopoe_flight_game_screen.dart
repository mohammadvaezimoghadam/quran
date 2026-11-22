import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/hoopoe_game_controller.dart';
import '../flame/components/hoopoe_character_component.dart';
import '../flame/hoopoe_flight_game.dart';
import '../overlays/hoopoe_game_hud_overlay.dart';
import '../overlays/hoopoe_game_pause_overlay.dart';
import '../overlays/hoopoe_game_victory_overlay.dart';
import '../widgets/hoopoe_rive_widget.dart';

class HoopoeFlightGameScreen extends ConsumerStatefulWidget {
  final VoidCallback onExitToHub;

  const HoopoeFlightGameScreen({
    super.key,
    required this.onExitToHub,
  });

  @override
  ConsumerState<HoopoeFlightGameScreen> createState() =>
      _HoopoeFlightGameScreenState();
}

class _HoopoeFlightGameScreenState extends ConsumerState<HoopoeFlightGameScreen> {
  late final HoopoeFlightGame _game;

  @override
  void initState() {
    super.initState();
    final controller = ref.read(hoopoeGameControllerProvider.notifier);

    _game = HoopoeFlightGame(
      onCorrectGate: () {
        controller.recordCorrectGate();
        _syncOverlays();
      },
      onWrongGate: () {
        controller.recordWrongGate();
        _syncOverlays();
      },
      getCurrentStage: () => controller.currentStage,
      getCurrentAyah: () => controller.currentAyah,
      getCurrentWordIndex: () => ref.read(hoopoeGameControllerProvider).wordIndex,
      isGameActive: () {
        final s = ref.read(hoopoeGameControllerProvider);
        return s.isPlaying && !s.isPaused && !s.isGameOver && !s.isVictory;
      },
    );

    // Start game session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.startOrResume();
      }
    });
  }

  void _syncOverlays() {
    final state = ref.read(hoopoeGameControllerProvider);
    if (state.isVictory) {
      _game.overlays.add('Victory');
    } else if (state.isGameOver) {
      _game.overlays.add('GameOver');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(hoopoeGameControllerProvider, (prev, next) {
      if (next.isPaused && !(prev?.isPaused ?? false)) {
        _game.overlays.add('Pause');
      } else if (!next.isPaused && (prev?.isPaused ?? false)) {
        _game.overlays.remove('Pause');
      }

      if (next.isVictory && !(prev?.isVictory ?? false)) {
        _game.overlays.add('Victory');
      }
      if (next.isGameOver && !(prev?.isGameOver ?? false)) {
        _game.overlays.add('GameOver');
      }
    });

    final controller = ref.read(hoopoeGameControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF070B18),
      body: GameWidget<HoopoeFlightGame>(
        game: _game,
        initialActiveOverlays: const ['PlayerRive', 'HUD'],
        overlayBuilderMap: {
          // کاراکتر زنده Rive هدهد درون بازی
          'PlayerRive': (ctx, game) => IgnorePointer(
                child: ValueListenableBuilder<PlayerVisualState>(
                  valueListenable: game.player.visualNotifier,
                  builder: (context, visual, child) {
                    return Stack(
                      children: [
                        Positioned(
                          left: visual.x - 45,
                          top: visual.y - 45,
                          child: HoopoeRiveWidget(
                            size: 90,
                            tiltAngle: visual.angle,
                            isHurt: visual.isHurt,
                            isCelebrating: visual.isCelebrating,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          'HUD': (ctx, game) => HoopoeGameHudOverlay(
                onPause: () {
                  controller.togglePause();
                },
                onExit: widget.onExitToHub,
              ),
          'Pause': (ctx, game) => HoopoeGamePauseOverlay(
                onResume: () {
                  controller.togglePause();
                },
                onRestart: () {
                  _game.overlays.remove('Pause');
                  controller.restartStage();
                  _game.resetPlayer();
                },
                onExit: widget.onExitToHub,
              ),
          'Victory': (ctx, game) => HoopoeGameVictoryOverlay(
                isVictory: true,
                onNextOrRetry: () {
                  _game.overlays.remove('Victory');
                  controller.nextStage();
                  _game.resetPlayer();
                },
                onExit: widget.onExitToHub,
              ),
          'GameOver': (ctx, game) => HoopoeGameVictoryOverlay(
                isVictory: false,
                onNextOrRetry: () {
                  _game.overlays.remove('GameOver');
                  controller.restartStage();
                  _game.resetPlayer();
                },
                onExit: widget.onExitToHub,
              ),
        },
      ),
    );
  }
}
