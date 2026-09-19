import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/features/bookmarks/application/controllers/bookmarks_controller.dart';
import 'package:quran/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:quran/features/quran_reader/application/controllers/quran_display_settings_controller.dart';
import 'package:quran/features/quran_reader/application/states/quran_display_settings_state.dart';
import 'package:quran/features/quick_access/presentation/widgets/bookmarks_manager_bottom_sheet.dart';

class MockBookmarksController extends BookmarksController {
  final List<BookmarkItem> initialBookmarks;

  MockBookmarksController(this.initialBookmarks);

  @override
  List<BookmarkItem> build() {
    return initialBookmarks;
  }
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
  testWidgets('BookmarksManagerBottomSheet renders without decorative icons and displays text actions', (tester) async {
    final mockItem = BookmarkItem(
      surahId: 1,
      ayahNumber: 1,
      surahName: 'الفاتحة',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      totalAyahs: 7,
      isAyahBookmark: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bookmarksControllerProvider.overrideWith(
            () => MockBookmarksController([mockItem]),
          ),
          quranDisplaySettingsControllerProvider.overrideWith(
            () => MockQuranDisplaySettingsController(),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: BookmarksManagerBottomSheet(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify title is rendered
    expect(find.text('نشانه‌های ذخیره‌شده'), findsOneWidget);

    // Verify text button "پاک‌سازی" exists instead of trash icon
    expect(find.text('پاک‌سازی'), findsOneWidget);

    // Verify item has "حذف" text button instead of delete icon
    expect(find.text('حذف'), findsOneWidget);

    // Verify surah title
    expect(find.textContaining('فاتحه'), findsOneWidget);
  });
}
