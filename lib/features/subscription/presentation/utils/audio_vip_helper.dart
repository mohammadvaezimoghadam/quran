import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/constants/surah_constants.dart';
import '../../../quran_reader/application/controllers/quran_audio_controller.dart';
import '../../../quran_reader/application/controllers/reciter_providers.dart';
import '../../../quran_reader/domain/entities/reciter_entity.dart';
import '../../../quran_reader/domain/enums/audio_playback_mode.dart';
import '../../application/vip_subscription_controller.dart';
import '../../domain/policy/audio_vip_policy.dart';
import '../ui/vip_subscription_sheet.dart';
import '../widgets/vip_audio_prompt_dialog.dart';

/// Helper utility to enforce Audio VIP policies and trigger friction-free conversion dialogs.
abstract class AudioVipHelper {
  /// Checks whether playing audio for the active/target reciter on [surahId] is permitted.
  /// If NOT permitted, opens the [VipAudioPromptDialog] and returns false.
  /// If the user clicks "پخش با صوت رایگان استاد پرهیزگار", switches reciter and executes [onSwitchedToDefaultReciter].
  static Future<bool> checkAndPromptVip({
    required BuildContext context,
    required WidgetRef ref,
    required int surahId,
    ReciterEntity? targetReciter,
    VoidCallback? onSwitchedToDefaultReciter,
  }) async {
    final audioController = ref.read(quranAudioControllerProvider.notifier);
    final audioState = ref.read(quranAudioControllerProvider);
    final reciter = targetReciter ?? audioState.selectedReciter;
    final isVip = ref.read(hasVipAccessProvider);
    if (isVip) {
      // Opportunistic verification to catch expirations in near real-time
      ref.read(vipSubscriptionControllerProvider.notifier).syncWithStore();
    }

    final canPlay = AudioVipPolicy.canPlayReciter(
      reciterIdentifier: reciter?.identifier,
      surahId: surahId,
      isVip: isVip,
    );

    if (canPlay) return true;

    // Check translation VIP access if mode requires translation
    if (audioState.playbackMode.includesTranslation && !isVip) {
      if (!context.mounted) return false;
      VipSubscriptionSheet.show(context);
      return false;
    }

    if (!context.mounted) return false;

    final surahName = SurahConstants.getSurahName(surahId);
    final reciterName = reciter?.name ?? 'قاری منتخب';

    await VipAudioPromptDialog.show(
      context: context,
      reciterName: reciterName,
      surahName: surahName,
      onPlayWithDefaultReciter: () async {
        final recitersResult = await ref.read(allRecitersListProvider.future);
        recitersResult.when(
          (reciters) {
            final parhizgar = reciters.firstWhere(
              (r) => AudioVipPolicy.isDefaultReciter(r.identifier),
              orElse: () => reciters.first,
            );
            audioController.selectReciter(parhizgar);
            onSwitchedToDefaultReciter?.call();
          },
          (error) {},
        );
      },
    );

    return false;
  }

  /// Checks whether playing audio translation is permitted.
  /// If not, opens [VipSubscriptionSheet] and returns false.
  static bool checkAudioTranslation({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    final isVip = ref.read(hasVipAccessProvider);
    if (isVip) {
      ref.read(vipSubscriptionControllerProvider.notifier).syncWithStore();
    }
    if (!isVip) {
      VipSubscriptionSheet.show(context);
      return false;
    }
    return true;
  }
}
