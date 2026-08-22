import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/services/audio/audio_player_state.dart';
import '../../domain/entities/ayah_entity.dart';
import 'quran_audio_controller.dart';

/// Provider for managing focused Ayah selection for copy, share, and bookmark actions.
final selectedAyahActionProvider =
    NotifierProvider<SelectedAyahActionController, int?>(
  SelectedAyahActionController.new,
);

class SelectedAyahActionController extends Notifier<int?> {
  @override
  int? build() => null;

  /// Select an Ayah for context action (copy/share/bookmark)
  void selectAyah(int ayahNumber) {
    if (state == ayahNumber) {
      // Toggle off if re-tapped
      clearSelection();
      return;
    }

    state = ayahNumber;
    // Suspend auto-scroll ONLY if audio is currently playing so page doesn't jump
    final isAudioPlaying = ref.read(quranAudioControllerProvider).status == AudioStatus.playing;
    if (isAudioPlaying) {
      ref.read(quranAudioControllerProvider.notifier).suspendAutoScroll();
    }
  }

  /// Clear selection and return to normal reading state
  void clearSelection() {
    state = null;
  }

  /// Copy Ayah Arabic text + Translation to Clipboard
  Future<void> copyAyahToClipboard(BuildContext context, AyahEntity ayah) async {
    final arabic = ayah.arabicText;
    final translation = ayah.translationText ?? '';
    
    final fullContent = '''
$arabic

$translation
(سوره ${ayah.surahId}، آیه ${ayah.ayahNumber})
''';

    await Clipboard.setData(ClipboardData(text: fullContent.trim()));
    if (context.mounted) {
      AppSnackBar.showSuccess(context, 'متن آیه با موفقیت کپی شد');
    }

    // Dismiss context menu after copy action
    clearSelection();
  }
}
