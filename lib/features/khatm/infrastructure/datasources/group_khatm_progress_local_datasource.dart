import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/data/local/hive/hive_service_provider.dart';
import '../../../../core/data/local/hive/i_hive_service.dart';
import '../../domain/entities/group_khatm_slot_progress.dart';

abstract class IGroupKhatmProgressLocalDataSource {
  Future<List<GroupKhatmSlotProgress>> getAll();
  Future<GroupKhatmSlotProgress?> getProgress(String inviteCode, int slotId);
  Future<void> saveProgress(GroupKhatmSlotProgress progress);
  Future<void> deleteProgress(String inviteCode, int slotId);
}

class GroupKhatmProgressLocalDataSource
    implements IGroupKhatmProgressLocalDataSource {
  static const String boxName = 'group_khatm_slot_progress_box';

  final IHiveService _hiveService;

  GroupKhatmProgressLocalDataSource(this._hiveService);

  Future<void> _ensureBoxOpen() async {
    if (!Hive.isBoxOpen(boxName)) {
      await _hiveService.openBox(boxName);
    }
  }

  @override
  Future<List<GroupKhatmSlotProgress>> getAll() async {
    try {
      await _ensureBoxOpen();
      final values = _hiveService.getValues(boxName: boxName);
      final list = <GroupKhatmSlotProgress>[];
      for (final val in values) {
        if (val is Map) {
          try {
            final item = GroupKhatmSlotProgress.fromMap(val);
            if (item.inviteCode.isNotEmpty && item.slotId > 0) {
              list.add(item);
            }
          } catch (e) {
            debugPrint('⚠️ [GroupKhatmProgressDS] Parse error: $e');
          }
        }
      }
      return list;
    } catch (e) {
      debugPrint('⚠️ [GroupKhatmProgressDS] getAll error: $e');
      return [];
    }
  }

  @override
  Future<GroupKhatmSlotProgress?> getProgress(
    String inviteCode,
    int slotId,
  ) async {
    try {
      await _ensureBoxOpen();
      final key = GroupKhatmSlotProgress.buildStorageKey(inviteCode, slotId);
      final val = _hiveService.get<dynamic>(key, boxName: boxName);
      if (val is Map) {
        return GroupKhatmSlotProgress.fromMap(val);
      }
    } catch (e) {
      debugPrint('⚠️ [GroupKhatmProgressDS] getProgress error: $e');
    }
    return null;
  }

  @override
  Future<void> saveProgress(GroupKhatmSlotProgress progress) async {
    try {
      await _ensureBoxOpen();
      await _hiveService.put(
        progress.storageKey,
        progress.toMap(),
        boxName: boxName,
      );
    } catch (e) {
      debugPrint('⚠️ [GroupKhatmProgressDS] saveProgress error: $e');
    }
  }

  @override
  Future<void> deleteProgress(String inviteCode, int slotId) async {
    try {
      await _ensureBoxOpen();
      final key = GroupKhatmSlotProgress.buildStorageKey(inviteCode, slotId);
      await _hiveService.delete(key, boxName: boxName);
    } catch (e) {
      debugPrint('⚠️ [GroupKhatmProgressDS] deleteProgress error: $e');
    }
  }
}

final groupKhatmProgressLocalDataSourceProvider =
    Provider<IGroupKhatmProgressLocalDataSource>((ref) {
      final hiveService = ref.read(hiveServiceProvider);
      return GroupKhatmProgressLocalDataSource(hiveService);
    });
