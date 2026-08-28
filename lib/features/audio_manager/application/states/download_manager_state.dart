import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../quran_reader/domain/entities/reciter_entity.dart';
import '../../../quran_reader/application/controllers/quran_audio_controller.dart';

class DownloadManagerReciterNotifier extends Notifier<ReciterEntity?> {
  @override
  ReciterEntity? build() {
    return ref.read(quranAudioControllerProvider).selectedReciter;
  }

  void setReciter(ReciterEntity? reciter) {
    state = reciter;
  }
}

final downloadManagerSelectedReciterProvider = NotifierProvider.autoDispose<DownloadManagerReciterNotifier, ReciterEntity?>(
  DownloadManagerReciterNotifier.new,
);

