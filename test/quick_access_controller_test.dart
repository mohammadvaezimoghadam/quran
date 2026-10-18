import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:quran/common/exceptions/failure.dart';
import 'package:quran/features/quick_access/application/controllers/quick_access_controller.dart';
import 'package:quran/features/quick_access/domain/entities/quick_access_tool_entity.dart';
import 'package:quran/features/quick_access/domain/repositories/quick_access_repository.dart';
import 'package:quran/features/quick_access/infrastructure/repositories/quick_access_repository_impl.dart';

class InMemoryQuickAccessRepository implements IQuickAccessRepository {
  List<String?> slots = ['downloads', 'last_read', 'bookmarks', 'topic_studio'];
  int? pinnedSurahId;

  @override
  List<QuickAccessToolEntity> getAllToolsCatalog() {
    return const [
      QuickAccessToolEntity(
        type: QuickAccessToolType.downloads,
        title: 'دانلودها',
        description: 'مدیریت فایل‌ها',
      ),
      QuickAccessToolEntity(
        type: QuickAccessToolType.lastRead,
        title: 'ادامه قرائت',
        description: 'آخرین آیه',
      ),
      QuickAccessToolEntity(
        type: QuickAccessToolType.bookmarks,
        title: 'نشانه‌ها',
        description: 'آیات نشانه‌گذاری شده',
      ),
      QuickAccessToolEntity(
        type: QuickAccessToolType.topicStudio,
        title: 'تفکر',
        description: 'ثبت تأملات',
      ),
      QuickAccessToolEntity(
        type: QuickAccessToolType.dictionary,
        title: 'لغت‌نامه',
        description: 'ترجمه واژگان',
      ),
    ];
  }

  @override
  Future<Result<List<String?>, Failure>> getRawSlotIds() async {
    return Success(List<String?>.from(slots));
  }

  @override
  Future<Result<void, Failure>> setRawSlotId(int index, String? rawSlotId) async {
    slots[index] = rawSlotId;
    return const Success(null);
  }

  @override
  Future<Result<List<QuickAccessToolType?>, Failure>> getSlots() async {
    return Success(slots.map((id) => QuickAccessToolType.fromId(id)).toList());
  }

  @override
  Future<Result<void, Failure>> setSlot(int index, QuickAccessToolType? toolType) async {
    return setRawSlotId(index, toolType?.id);
  }

  @override
  Future<Result<void, Failure>> clearSlot(int index) async {
    return setRawSlotId(index, null);
  }

  @override
  int? getPinnedSurahId() => pinnedSurahId;

  @override
  Future<Result<void, Failure>> savePinnedSurahId(int? surahId) async {
    pinnedSurahId = surahId;
    return const Success(null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuickAccessController Tests', () {
    late InMemoryQuickAccessRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = InMemoryQuickAccessRepository();
      container = ProviderContainer(
        overrides: [
          quickAccessRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Loads initial slots including topicStudio in slot 3', () async {
      final controller = container.read(quickAccessControllerProvider.notifier);
      await controller.loadSlots();

      final state = container.read(quickAccessControllerProvider);
      expect(state.slots[3]?.type, equals(QuickAccessToolType.topicStudio));
      expect(state.slots[3]?.title, equals('تفکر'));
    });

    test('Removing topicStudio empties slot 3 and does NOT re-inject it', () async {
      final controller = container.read(quickAccessControllerProvider.notifier);
      await controller.loadSlots();

      // Remove slot 3 (topicStudio)
      await controller.removeSlot(3);

      final state = container.read(quickAccessControllerProvider);
      expect(state.slots[3], isNull, reason: 'Slot 3 must be empty after removeSlot');

      // Now topicStudio must be available in the picker
      final availableTools = controller.getAvailableToolsForPicker();
      final hasTopicInPicker = availableTools.any((t) => t.type == QuickAccessToolType.topicStudio);
      expect(hasTopicInPicker, isTrue, reason: 'topicStudio must be pickable once removed');
    });

    test('TopicStudio can be reassigned to a different slot (e.g. slot 0)', () async {
      final controller = container.read(quickAccessControllerProvider.notifier);
      await controller.loadSlots();

      // Remove topicStudio from slot 3
      await controller.removeSlot(3);
      // Remove downloads from slot 0
      await controller.removeSlot(0);

      var state = container.read(quickAccessControllerProvider);
      expect(state.slots[0], isNull);
      expect(state.slots[3], isNull);

      // Reassign topicStudio to slot 0
      await controller.assignToolToSlot(0, QuickAccessToolType.topicStudio);

      state = container.read(quickAccessControllerProvider);
      expect(state.slots[0]?.type, equals(QuickAccessToolType.topicStudio));
      expect(state.slots[3], isNull);
    });
  });
}
