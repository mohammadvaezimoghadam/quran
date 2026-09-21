import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/constants/surah_constants.dart';
import '../../../../core/routes/go_router_provider.dart';
import '../../../quran_reader/application/controllers/quran_audio_controller.dart';
import '../../../quran_reader/application/controllers/reciter_providers.dart';
import '../../../quran_reader/domain/entities/reciter_entity.dart';
import '../../../quran_reader/domain/enums/audio_playback_mode.dart';
import '../../application/vip_subscription_controller.dart';
import '../../domain/policy/audio_vip_policy.dart';
import '../widgets/vip_audio_prompt_dialog.dart';
import '../widgets/vip_required_dialog.dart';

/// Helper utility to enforce Audio VIP policies and trigger friction-free conversion dialogs.
abstract class AudioVipHelper {
  /// Checks whether playing audio for the active/target reciter on [surahId] is permitted.
  /// If NOT permitted, opens the [VipAudioPromptDialog] and returns false.
  /// If the user clicks "پخش با صوت رایگان استاد پرهیزگار", switches reciter and executes [onSwitchedToDefaultReciter].
  static Future<bool> checkAndPromptVip({
    required BuildContext context,
    WidgetRef? ref,
    required int surahId,
    ReciterEntity? targetReciter,
    VoidCallback? onSwitchedToDefaultReciter,
  }) async {
    final targetContext = (context.mounted ? context : null) ?? rootNavigatorKey.currentContext;
    if (targetContext == null) return false;

    final container = ProviderScope.containerOf(targetContext, listen: false);
    final audioController = container.read(quranAudioControllerProvider.notifier);
    final audioState = container.read(quranAudioControllerProvider);
    final reciter = targetReciter ?? audioState.selectedReciter;
    final isVip = container.read(hasVipAccessProvider);
    if (isVip) {
      // Opportunistic verification to catch expirations in near real-time
      container.read(vipSubscriptionControllerProvider.notifier).syncWithStore();
    }

    // If playbackMode requires translation and user is non-VIP, immediately revert to onlyQuran
    if (audioState.playbackMode.includesTranslation && !isVip) {
      audioController.setPlaybackMode(AudioPlaybackMode.onlyQuran);
      VipRequiredDialog.show(
        context: targetContext,
        isTranslation: true,
      );
      return false;
    }

    final canPlay = AudioVipPolicy.canPlayReciter(
      reciterIdentifier: reciter?.identifier,
      surahId: surahId,
      isVip: isVip,
    );

    if (canPlay) return true;

    final surahName = SurahConstants.getSurahName(surahId);
    final reciterName = reciter?.name ?? 'قاری منتخب';

    await VipAudioPromptDialog.show(
      context: targetContext,
      reciterName: reciterName,
      surahName: surahName,
      onPlayWithDefaultReciter: () async {
        final recitersResult = await container.read(allRecitersListProvider.future);
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
  /// If not, opens [VipRequiredDialog] and returns false.
  static bool checkAudioTranslation({
    required BuildContext context,
    WidgetRef? ref,
  }) {
    final targetContext = (context.mounted ? context : null) ?? rootNavigatorKey.currentContext;
    if (targetContext == null) return false;
    final container = ProviderScope.containerOf(targetContext, listen: false);
    final isVip = container.read(hasVipAccessProvider);
    if (isVip) {
      container.read(vipSubscriptionControllerProvider.notifier).syncWithStore();
    }
    if (!isVip) {
      container
          .read(quranAudioControllerProvider.notifier)
          .setPlaybackMode(AudioPlaybackMode.onlyQuran);
      VipRequiredDialog.show(
        context: targetContext,
        isTranslation: true,
      );
      return false;
    }
    return true;
  }
}
