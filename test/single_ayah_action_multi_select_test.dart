import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/features/bookmarks/application/controllers/bookmarks_controller.dart';
import 'package:quran/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:quran/features/quran_reader/application/controllers/quran_audio_controller.dart';
import 'package:quran/features/quran_reader/application/controllers/quran_display_settings_controller.dart';
import 'package:quran/features/quran_reader/application/states/quran_audio_state.dart';
import 'package:quran/features/quran_reader/application/states/quran_display_settings_state.dart';
import 'package:quran/features/quran_reader/domain/entities/ayah_entity.dart';
import 'package:quran/features/quran_reader/presentation/widgets/single_ayah_action_bottom_sheet.dart';

class MockBookmarksController extends BookmarksController {
  @override
  List<BookmarkItem> build() => const [];
}

class FakeQuranAudioController extends QuranAudioController {
  @override
  QuranAudioState build() => const QuranAudioState();

  @override
  void suspendAutoScroll() {}
}

class MockQuranDisplaySettingsController extends QuranDisplaySettingsController {
  @override
  QuranDisplaySettingsState build() {
    return const QuranDisplaySettingsState(
      arabicFontSize: 28,
      arabicLineHeight: 2.2,
      translationFontSize: 16,
      translationFontFamily: 'BNazanin',
      showTranslation: true,
      showAyahNumbers: true,
      autoHighlight: true,
      fontScript: 'عثمان طه',
      translatorName: 'شیخ حسین انصاریان',
      harakatColor: '#FF4444',
      removeTranslationBrackets: true,
      showArabicText: true,
    );
  }
}

void main() {
  testWidgets('SingleAyahActionBottomSheet renders multi-select button and returns true when tapped', (tester) async {
    final ayah = const AyahEntity(
      id: 1,
      surahId: 1,
      ayahNumber: 1,
      arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      translationText: 'به نام خداوند بخشنده مهربان',
      juz: 1,
      page: 1,
      hizbQuarter: 1,
    );

    bool? returnedResult;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bookmarksControllerProvider.overrideWith(MockBookmarksController.new),
          quranAudioControllerProvider.overrideWith(FakeQuranAudioController.new),
          quranDisplaySettingsControllerProvider.overrideWith(MockQuranDisplaySettingsController.new),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  returnedResult = await SingleAyahActionBottomSheet.show(
                    context,
                    ayah: ayah,
                    surahName: 'الفاتحة',
                    totalAyahsInSurah: 7,
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open bottom sheet
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Verify multi-select button exists
    final multiSelectFinder = find.text('موارد بیشتر');
    expect(multiSelectFinder, findsOneWidget);

    // Tap multi-select button
    await tester.tap(multiSelectFinder);
    await tester.pumpAndSettle();

    // Verify returned result is true
    expect(returnedResult, true);
  });
}
