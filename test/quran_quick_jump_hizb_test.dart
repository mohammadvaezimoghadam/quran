import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/features/quran_reader/application/controllers/quran_reader_controller.dart';
import 'package:quran/features/quran_reader/application/states/quran_reader_state.dart';
import 'package:quran/features/quran_reader/domain/entities/ayah_entity.dart';
import 'package:quran/features/quran_reader/presentation/widgets/quran_quick_jump_bottom_sheet.dart';
import 'package:quran/features/surah_list/application/controllers/surah_list_controller.dart';
import 'package:quran/features/surah_list/application/states/surah_list_state.dart';
import 'package:quran/features/surah_list/domain/entities/surah_entity.dart';

class FakeSurahListController extends SurahListController {
  final List<SurahEntity> _mockSurahs;
  FakeSurahListController(this._mockSurahs);

  @override
  SurahListState build() {
    return SurahListState(surahs: _mockSurahs, isLoading: false);
  }
}

class FakeQuranReaderController extends QuranReaderController {
  final int _surahId;
  final List<AyahEntity> _ayahs;
  FakeQuranReaderController(this._surahId, this._ayahs);

  @override
  QuranReaderState build() {
    return QuranReaderState(currentSurahId: _surahId, ayahs: _ayahs);
  }
}

void main() {
  testWidgets('QuranQuickJumpBottomSheet renders Hizb row and allows navigation', (tester) async {
    const mockSurahs = [
      SurahEntity(
        number: 1,
        name: 'الفاتحة',
        englishName: 'Al-Faatiha',
        englishNameTranslation: 'The Opening',
        numberOfAyahs: 7,
        revelationType: 'Meccan',
        startPage: 1,
        startJuz: 1,
      ),
      SurahEntity(
        number: 2,
        name: 'البقرة',
        englishName: 'Al-Baqara',
        englishNameTranslation: 'The Cow',
        numberOfAyahs: 286,
        revelationType: 'Medinan',
        startPage: 2,
        startJuz: 1,
      ),
    ];

    const mockAyahs = [
      AyahEntity(
        id: 1,
        surahId: 1,
        ayahNumber: 1,
        arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        page: 1,
        juz: 1,
        hizbQuarter: 1,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          surahListControllerProvider.overrideWith(
            () => FakeSurahListController(mockSurahs),
          ),
          quranReaderControllerProvider.overrideWith(
            () => FakeQuranReaderController(1, mockAyahs),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: QuranQuickJumpBottomSheet(initialTab: QuickJumpTab.hizb),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Hizb title and initial value exist
    expect(find.text('شماره حزب'), findsOneWidget);
    expect(find.textContaining('حزب ۱'), findsOneWidget);

    // Verify all other interconnected rows exist
    expect(find.text('سوره'), findsOneWidget);
    expect(find.text('شماره آیه'), findsOneWidget);
    expect(find.text('شماره صفحه'), findsOneWidget);
    expect(find.text('شماره جزء'), findsOneWidget);
  });
}
