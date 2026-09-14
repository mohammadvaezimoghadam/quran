import 'package:flutter/material.dart';

import '../../../../../common/extensions/context_extension.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_typography.dart';

/// Bismillah header displayed at the top of the home screen.
class BismillahGreeting extends StatelessWidget {
  const BismillahGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.stackXs),
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
            color: context.colors.goldAccent,
          ),
        ),
      ),
    );
  }
}
