import 'package:multiple_result/multiple_result.dart';

import '../../../../common/exceptions/failure.dart';
import '../entities/quick_access_tool_entity.dart';

abstract class IQuickAccessRepository {
  /// Returns the 4 slots. Each slot contains a tool type, or null if empty.
  Future<Result<List<QuickAccessToolType?>, Failure>> getSlots();

  /// Persists a tool type into a specific slot index (0..3).
  Future<Result<void, Failure>> setSlot(int index, QuickAccessToolType? toolType);

  /// Clears a specific slot index, setting it to empty (+).
  Future<Result<void, Failure>> clearSlot(int index);

  /// Returns the full catalog of available tools.
  List<QuickAccessToolEntity> getAllToolsCatalog();

  /// Returns the raw slot identifiers (e.g. 'downloads', 'pinned_surah:36', null).
  Future<Result<List<String?>, Failure>> getRawSlotIds();

  /// Persists a raw slot identifier into a specific slot index (0..3).
  Future<Result<void, Failure>> setRawSlotId(int index, String? rawSlotId);

  /// Gets the currently pinned surah ID (1..114), or null if none selected.
  int? getPinnedSurahId();

  /// Saves or clears the pinned surah ID.
  Future<Result<void, Failure>> savePinnedSurahId(int? surahId);
}
