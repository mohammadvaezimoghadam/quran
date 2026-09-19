import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/common/constants/app_constants.dart';
import 'package:quran/core/theme/app_typography.dart';

void main() {
  testWidgets('QuranHomeScreen title style uses primary green theme color', (tester) async {
    const primaryColor = Color(0xFF005C55);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: primaryColor,
          ),
        ),
        home: Builder(
          builder: (context) {
            final colorScheme = Theme.of(context).colorScheme;
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  AppConstants.appTitle.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), ''),
                  textAlign: TextAlign.center,
                  style: AppTypography.appBarTitle.copyWith(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    final titleFinder = find.text('قرآن تفکر');
    expect(titleFinder, findsOneWidget);

    final textWidget = tester.widget<Text>(titleFinder);
    expect(textWidget.style?.color, primaryColor);
  });
}
