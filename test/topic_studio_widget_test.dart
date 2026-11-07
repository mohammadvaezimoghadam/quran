import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/features/topic_studio/application/controllers/topics_controller.dart';
import 'package:quran/features/topic_studio/domain/entities/topic_item.dart';
import 'package:quran/features/topic_studio/domain/entities/topic_status.dart';
import 'package:quran/features/topic_studio/domain/repositories/i_topic_repository.dart';
import 'package:quran/features/topic_studio/application/controllers/topic_mini_drawer_controller.dart';
import 'package:quran/features/topic_studio/presentation/widgets/add_to_topic_bottom_sheet.dart';
import 'package:quran/features/topic_studio/presentation/widgets/new_topic_dialog.dart';
import 'package:quran/features/topic_studio/presentation/widgets/topic_mini_drawer.dart';

void main() {
  testWidgets('AddToTopicBottomSheet handles 50 topics without overflow', (
    tester,
  ) async {
    // Generate 50 topics
    final fiftyTopics = List.generate(
      50,
      (i) => TopicItem(
        id: 'topic-$i',
        title: 'موضوع تفکر شماره $i با توضیحات نسبتا طولانی برای تست اورفلو',
        status: TopicStatus.open,
        createdAt: 1000 + i,
        updatedAt: 1000 + i,
        blocks: const [],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allTopicsProvider.overrideWithValue(fiftyTopics),
          openTopicsProvider.overrideWithValue(fiftyTopics),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: AddToTopicBottomSheet(
              arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              translationText: 'به نام خداوند بخشنده مهربان',
              ayahNumber: 1,
              surahName: 'فاتحه',
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify header and elements render without any RenderFlex overflow exceptions
    expect(find.text('افزودن به دفتر تفکر'), findsOneWidget);
    expect(find.text('انتخاب موضوع:'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Scroll through the topics list to ensure smooth scrolling without overflow
    final listFinder = find.byType(Scrollbar);
    expect(listFinder, findsOneWidget);

    await tester.drag(
      find.textContaining('موضوع تفکر شماره 0'),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('NewTopicDialog in edit mode does NOT create a new topic', (
    tester,
  ) async {
    final fakeRepo = _FakeTopicRepository();
    final controller = TopicsController(fakeRepo);

    TopicItem? result;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [topicsControllerProvider.overrideWith((ref) => controller)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await NewTopicDialog.show(
                    context,
                    topicId: 'topic-1',
                    initialTitle: 'عنوان قبلی',
                    isEditing: true,
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      ),
    );

    // Tap to open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify edit dialog texts
    expect(find.text('ویرایش عنوان موضوع'), findsOneWidget);
    expect(find.text('ذخیره'), findsOneWidget);

    // Change title
    await tester.enterText(find.byType(TextField), 'عنوان جدید ویرایش شده');
    await tester.pumpAndSettle();

    // Tap save
    await tester.tap(find.text('ذخیره'));
    await tester.pumpAndSettle();

    // Dialog should be closed and returned TopicItem should have new title
    expect(result, isNotNull);
    expect(result!.title, 'عنوان جدید ویرایش شده');

    // Crucially: no new topic was created in topicsController!
    expect(controller.state.isEmpty, isTrue);
  });

  testWidgets(
    'TopicMiniDrawer displays contemplation notebook and allows adding block',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            topicMiniDrawerControllerProvider.overrideWith(
              () => _FakeTopicMiniDrawerController(
                initialState: const TopicMiniDrawerState(
                  isEnabled: true,
                  isOpen: true,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: TopicMiniDrawer())),
        ),
      );

      await tester.pumpAndSettle();

      // Drawer header should be visible
      expect(find.text('دفتر تفکر'), findsOneWidget);
      expect(
        find.text('هنوز مطلبی در این پیش‌نویس وجود ندارد'),
        findsOneWidget,
      );
      expect(find.text('نوشتن یادداشت'), findsOneWidget);

      // Tap 'نوشتن یادداشت' to add a block
      await tester.tap(find.text('نوشتن یادداشت'));
      await tester.pumpAndSettle();

      // Empty state should be gone, user text caption should be visible
      expect(find.text('هنوز مطلبی در این پیش‌نویس وجود ندارد'), findsNothing);
      expect(find.text('یادداشت / توضیحات'), findsOneWidget);
    },
  );
}

class _FakeTopicMiniDrawerController extends TopicMiniDrawerController {
  final TopicMiniDrawerState _initial;

  _FakeTopicMiniDrawerController({required TopicMiniDrawerState initialState})
    : _initial = initialState;

  @override
  TopicMiniDrawerState build() => _initial;

  @override
  void setHideCompleted(bool hide) {
    state = state.copyWith(hideCompleted: hide);
  }

  @override
  void toggleHideCompleted() {
    setHideCompleted(!state.hideCompleted);
  }
}

class _FakeTopicRepository implements ITopicRepository {
  final Map<String, TopicItem> _storage = {};

  @override
  Future<List<TopicItem>> getAllTopics() async => _storage.values.toList();

  @override
  Future<List<TopicItem>> getOpenTopics() async =>
      _storage.values.where((t) => t.status == TopicStatus.open).toList();

  @override
  Future<List<TopicItem>> getClosedTopics() async =>
      _storage.values.where((t) => t.status == TopicStatus.closed).toList();

  @override
  Future<TopicItem?> getTopicById(String id) async => _storage[id];

  @override
  Future<void> saveTopic(TopicItem topic) async {
    _storage[topic.id] = topic;
  }

  @override
  Future<void> deleteTopic(String id) async {
    _storage.remove(id);
  }

  @override
  Future<void> updateTopicStatus(String id, TopicStatus status) async {
    final t = _storage[id];
    if (t != null) {
      _storage[id] = t.copyWith(status: status);
    }
  }
}
