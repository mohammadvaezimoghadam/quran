import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// ویجت متحرک و زنده کاراکتر هدهد با استفاده از ران‌تایم Rive
/// جایگزین کامل Canvas و CustomPainter برای کاراکتر
class HoopoeRiveWidget extends StatefulWidget {
  final double size;
  final double tiltAngle;
  final bool isHurt;
  final bool isCelebrating;

  const HoopoeRiveWidget({
    super.key,
    this.size = 130.0,
    this.tiltAngle = 0.0,
    this.isHurt = false,
    this.isCelebrating = false,
  });

  @override
  State<HoopoeRiveWidget> createState() => _HoopoeRiveWidgetState();
}

class _HoopoeRiveWidgetState extends State<HoopoeRiveWidget> {
  late final FileLoader _fileLoader;

  @override
  void initState() {
    super.initState();
    _fileLoader = FileLoader.fromAsset(
      'assets/rive/hoopoe_character.riv',
      riveFactory: Factory.flutter,
    );
  }

  @override
  void dispose() {
    _fileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: widget.tiltAngle,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: RiveWidgetBuilder(
          fileLoader: _fileLoader,
          dataBind: DataBind.auto(),
          builder: (context, state) {
            return switch (state) {
              RiveLoaded(:final controller) => AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  foregroundDecoration: widget.isHurt
                      ? BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        )
                      : null,
                  child: RiveWidget(
                    controller: controller,
                    fit: Fit.contain,
                  ),
                ),
              RiveFailed(:final error) => _buildFallbackGraphic(error),
              _ => const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Color(0xFFFFD54F),
                    ),
                  ),
                ),
            };
          },
        ),
      ),
    );
  }

  Widget _buildFallbackGraphic(Object? error) {
    return Center(
      child: Container(
        width: widget.size * 0.75,
        height: widget.size * 0.75,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Color(0xFFFFD54F), Color(0xFFE65100)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD54F).withValues(alpha: 0.4),
              blurRadius: 14,
            ),
          ],
        ),
        child: const Icon(
          Icons.flutter_dash,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }
}
