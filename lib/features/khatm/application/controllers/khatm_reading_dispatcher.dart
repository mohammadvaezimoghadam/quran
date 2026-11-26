import 'package:flutter_riverpod/misc.dart';

import 'group_khatm_reading_controller.dart';
import 'khatm_detail_controller.dart';

/// Result of dispatching reading progress to any active Personal or Group Khatm.
class KhatmDispatchResult {
  final bool personalCompleted;
  final bool personalPlanCompleted;
  final GroupKhatmProgressEvent groupEvent;

  const KhatmDispatchResult({
    this.personalCompleted = false,
    this.personalPlanCompleted = false,
    this.groupEvent = GroupKhatmProgressEvent.none,
  });

  bool get anyCompleted =>
      personalPlanCompleted ||
      groupEvent == GroupKhatmProgressEvent.slotCompleted ||
      groupEvent == GroupKhatmProgressEvent.passCompleted;
}

/// Callback signature matching both `WidgetRef.read` and `Ref.read`.
typedef KhatmReaderFn = T Function<T>(ProviderListenable<T> provider);

/// Returns `true` if either a Personal Khatm session or a Group Khatm slot
/// is currently active in the reader.
bool hasAnyActiveKhatm(KhatmReaderFn read) {
  return read(activeKhatmSessionProvider) != null ||
      read(activeGroupKhatmSlotProvider) != null;
}

/// Shared dispatcher used by [QuranReaderScreen], [SurahAyahPageView], and
/// [QuranAudioController] to route reading progress to Personal Khatm and
/// Group Khatm without duplicating tracking logic.
Future<KhatmDispatchResult> dispatchActiveKhatmProgress({
  required KhatmReaderFn read,
  required int surahId,
  required int ayahNumber,
  int? page,
  int? juz,
  int? hizb,
  bool isEndOfPage = false,
  double pageFraction = 0.0,
  int? coverStartGlobal,
  int? coverEndGlobal,
  bool isAudio = false,
  bool recordCoverage = true,
}) async {
  bool personalCompleted = false;
  bool personalPlanCompleted = false;
  GroupKhatmProgressEvent groupEvent = GroupKhatmProgressEvent.none;

  final activePersonal = read(activeKhatmSessionProvider);
  if (activePersonal != null &&
      (isAudio || !activePersonal.isDetachedFromReader)) {
    personalCompleted =
        await read(
          khatmDetailControllerProvider(activePersonal.khatmId).notifier,
        ).recordReadingProgress(
          sessionIndex: activePersonal.sessionIndex,
          surahId: surahId,
          ayahNumber: ayahNumber,
          page: page,
          juz: juz,
          hizb: hizb,
          isEndOfPage: isEndOfPage,
          pageFraction: pageFraction,
          coverStartGlobal: coverStartGlobal,
          coverEndGlobal: coverEndGlobal,
          isAudio: isAudio,
          recordCoverage: recordCoverage,
        );
    if (personalCompleted) {
      final updatedPlan = read(
        khatmDetailControllerProvider(activePersonal.khatmId),
      ).plan;
      personalPlanCompleted = updatedPlan?.isCompleted ?? true;
    }
  }

  final activeGroup = read(activeGroupKhatmSlotProvider);
  if (activeGroup != null && (isAudio || !activeGroup.isDetachedFromReader)) {
    groupEvent = await read(groupKhatmReadingControllerProvider.notifier)
        .recordReadingProgress(
          activeSlot: activeGroup,
          surahId: surahId,
          ayahNumber: ayahNumber,
          page: page,
          isEndOfPage: isEndOfPage,
          pageFraction: pageFraction,
          coverStartGlobal: coverStartGlobal,
          coverEndGlobal: coverEndGlobal,
          isAudio: isAudio,
          recordCoverage: recordCoverage,
        );
  }

  return KhatmDispatchResult(
    personalCompleted: personalCompleted,
    personalPlanCompleted: personalPlanCompleted,
    groupEvent: groupEvent,
  );
}
