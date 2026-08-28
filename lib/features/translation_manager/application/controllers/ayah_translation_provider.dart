import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../infrastructure/repositories/translation_repository_impl.dart';
import 'translation_manager_controller.dart';

part 'ayah_translation_provider.g.dart';

/// Provides the translated text for a specific Ayah using the currently active translation.
@riverpod
FutureOr<String?> ayahTranslation(
  Ref ref, 
  int surahNumber, 
  int ayahNumber,
  String? translationId,
) async {
  // Read whether to remove bracket explanations from user display settings
  final removeBrackets = ref.watch(
    quranDisplaySettingsControllerProvider.select((s) => s.removeTranslationBrackets),
  );

  // Fallback to the globally active translation ID if no explicit one is provided
  final stateAsync = ref.watch(translationManagerControllerProvider);
  final activeTranslationId = translationId ?? stateAsync.value?.activeTranslationId;

  if (activeTranslationId == null) return null;

  // Read the local translation from Hive
  final repository = ref.read(translationRepositoryProvider);
  final result = await repository.getAyahTranslation(
    translationId: activeTranslationId, 
    surahNumber: surahNumber, 
    ayahNumber: ayahNumber,
  );
  
  final rawText = result.tryGetSuccess();
  if (rawText == null) return null;
  return removeBrackets ? rawText.removeTranslatorExplanations() : rawText;
}
