import 'package:flutter/material.dart';

import '../../../../../core/theme/app_typography.dart';

/// Bismillah header displayed at the top of the home screen.
class BismillahGreeting extends StatelessWidget {
  const BismillahGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Center(
        child: Text(
          'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: AppTypography.thuluthFont,
            fontSize: 26,
            fontWeight: FontWeight.normal,
            height: 1.6,
            color: Color(0xFFC5A059),
          ),
        ),
      ),
    );
  }
}
