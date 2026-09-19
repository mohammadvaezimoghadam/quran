import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/features/quran_reader/application/controllers/quran_audio_controller.dart';
import 'package:quran/features/quran_reader/application/states/quran_audio_state.dart';
import 'package:quran/features/subscription/application/vip_subscription_controller.dart';
import 'package:quran/features/subscription/domain/models/vip_subscription_state.dart';
import 'package:quran/features/surah_list/presentation/widgets/surah_list_apple_header.dart';

class MockVipSubscriptionController extends VipSubscriptionController {
  final bool mockIsVip;
  MockVipSubscriptionController({this.mockIsVip = false});

  @override
  VipSubscriptionState build() {
    return VipSubscriptionState(
      isVip: mockIsVip,
      isLoading: false,
    );
  }
}

class MockQuranAudioController extends QuranAudioController {
  @override
  QuranAudioState build() {
    return const QuranAudioState();
  }
}

void main() {
  testWidgets('SurahListAppleHeader renders back button when showBackButton is true and handles tap', (tester) async {
    bool backClicked = false;
    final searchController = TextEditingController();
    final searchFocusNode = FocusNode();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vipSubscriptionControllerProvider.overrideWith(
            () => MockVipSubscriptionController(),
          ),
          quranAudioControllerProvider.overrideWith(
            () => MockQuranAudioController(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            appBar: SurahListAppleHeader(
              title: 'فهرست سوره‌ها',
              searchController: searchController,
              searchFocusNode: searchFocusNode,
              showBackButton: true,
              isOnlyFavorites: false,
              onSearchChanged: (_) {},
              onAudioDownloadManagerTap: () {},
              onSortTap: () {},
              onToggleFavoritesTap: () {},
              onBackPressed: () {
                backClicked = true;
              },
            ),
          ),
        ),
      ),
    );

    // Verify back button tooltip
    final backBtn = find.byTooltip('بازگشت');
    expect(backBtn, findsOneWidget);

    // Tap back button
    await tester.tap(backBtn);
    await tester.pump();

    expect(backClicked, isTrue);
  });

  testWidgets('SurahListAppleHeader hides back button when showBackButton is false', (tester) async {
    final searchController = TextEditingController();
    final searchFocusNode = FocusNode();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vipSubscriptionControllerProvider.overrideWith(
            () => MockVipSubscriptionController(),
          ),
          quranAudioControllerProvider.overrideWith(
            () => MockQuranAudioController(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            appBar: SurahListAppleHeader(
              title: 'فهرست سوره‌ها',
              searchController: searchController,
              searchFocusNode: searchFocusNode,
              showBackButton: false,
              isOnlyFavorites: false,
              onSearchChanged: (_) {},
              onAudioDownloadManagerTap: () {},
              onSortTap: () {},
              onToggleFavoritesTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('بازگشت'), findsNothing);
  });
}
