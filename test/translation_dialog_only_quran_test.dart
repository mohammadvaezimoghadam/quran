import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/features/surah_list/domain/entities/surah_entity.dart';
import 'package:quran/features/surah_list/presentation/widgets/surah_action_dialog.dart';

void main() {
  const dummySurah = SurahEntity(
    number: 1,
    name: 'سورة الفاتحة',
    englishName: 'Al-Fatiha',
    englishNameTranslation: 'The Opening',
    numberOfAyahs: 7,
    revelationType: 'Meccan',
    startPage: 1,
    startJuz: 1,
  );

  testWidgets('SurahActionDialog renders فقط صوت قاری button when isTranslation is true and callback provided', (tester) async {
    bool playOnlyQuranCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  SurahActionDialog.show(
                    context: context,
                    surah: dummySurah,
                    surahFontFamily: 'Vazirmatn',
                    isTranslation: true,
                    onReadSurah: () {},
                    onDownloadAudio: () {},
                    onPlayOnlyQuran: () {
                      playOnlyQuranCalled = true;
                    },
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Verify dialog title and buttons
    expect(find.textContaining('صوت ترجمه گویای سوره'), findsOneWidget);
    expect(find.text('فقط صوت قاری'), findsOneWidget);
    expect(find.text('خواندن سوره'), findsOneWidget);
    expect(find.text('دانلود ترجمه گویا'), findsOneWidget);

    // Tap "فقط صوت قاری"
    await tester.tap(find.text('فقط صوت قاری'));
    await tester.pumpAndSettle();

    // Dialog should be dismissed and callback executed
    expect(playOnlyQuranCalled, isTrue);
    expect(find.byType(SurahActionDialog), findsNothing);
  });

  testWidgets('SurahActionDialog does NOT render فقط صوت قاری button when isTranslation is false', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  SurahActionDialog.show(
                    context: context,
                    surah: dummySurah,
                    surahFontFamily: 'Vazirmatn',
                    isTranslation: false,
                    onReadSurah: () {},
                    onDownloadAudio: () {},
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('فقط صوت قاری'), findsNothing);
    expect(find.text('دانلود صوت'), findsOneWidget);
  });
}
