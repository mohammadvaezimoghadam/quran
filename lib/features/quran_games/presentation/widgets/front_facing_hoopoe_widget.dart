import 'package:flutter/material.dart';
import 'hoopoe_rive_widget.dart';

/// مسکات متحرک و زنده هدهد با استفاده از انیمیشن ویدیویی/برداری Rive
/// بدون استفاده از Canvas دستی یا CustomPainter
class FrontFacingHoopoeWidget extends StatelessWidget {
  final double size;

  const FrontFacingHoopoeWidget({
    super.key,
    this.size = 140.0,
  });

  @override
  Widget build(BuildContext context) {
    return HoopoeRiveWidget(size: size);
  }
}
