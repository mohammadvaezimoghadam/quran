import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/translation_entity.dart';
import '../../infrastructure/repositories/translation_repository_impl.dart';
import '../states/translation_manager_state.dart';

part 'translation_manager_controller.g.dart';

@Riverpod(keepAlive: true)
class TranslationManagerController extends _$TranslationManagerController {
  @override
  FutureOr<TranslationManagerState> build() async {
    return _loadInitialState();
  }

  Future<TranslationManagerState> _loadInitialState() async {
    final repository = ref.read(translationRepositoryProvider);
    
    final translationsResult = await repository.getAllTranslations();
    final translations = translationsResult.tryGetSuccess() ?? [];
    
    final activeIdResult = await repository.getActiveTranslation();
    final activeId = activeIdResult.tryGetSuccess();

    final initialActiveId = activeId ?? (translations.isNotEmpty ? translations.first.id : null);

    return TranslationManagerState(
      translations: translations,
      activeTranslationId: initialActiveId,
    );
  }

  /// Downloads a specific translation and updates the UI state
  Future<void> downloadTranslation(TranslationEntity translation) async {
    if (state.value?.downloadProgress.containsKey(translation.id) ?? false) return;

    final currentProgress = Map<String, double>.from(state.value?.downloadProgress ?? {});
    currentProgress[translation.id] = 0.0;
    
    state = AsyncData(state.value!.copyWith(
      downloadProgress: currentProgress,
      errorMessage: null,
    ));

    final repository = ref.read(translationRepositoryProvider);
    final downloadResult = await repository.downloadTranslation(
      translation,
      onReceiveProgress: (received, total) {
        // Many APIs don't send content-length (total == -1). 
        // We estimate a typical translation JSON size to be ~1.5MB for a smooth determinate loading bar.
        final estimatedTotal = total != -1 ? total : 1500000;
        final progress = (received / estimatedTotal).clamp(0.0, 1.0);
        
        final updatedProgress = Map<String, double>.from(state.value?.downloadProgress ?? {});
        updatedProgress[translation.id] = progress;
        state = AsyncData(state.value!.copyWith(downloadProgress: updatedProgress));
      },
    );

    await downloadResult.when(
      (success) async {
        final updatedTranslationsResult = await repository.getAllTranslations();
        final updatedTranslations = updatedTranslationsResult.tryGetSuccess() ?? [];
        
        final finalProgress = Map<String, double>.from(state.value?.downloadProgress ?? {});
        finalProgress.remove(translation.id);
        
        state = AsyncData(state.value!.copyWith(
          translations: updatedTranslations,
          downloadProgress: finalProgress,
        ));
      },
      (error) {
        final finalProgress = Map<String, double>.from(state.value?.downloadProgress ?? {});
        finalProgress.remove(translation.id);
        
        state = AsyncData(state.value!.copyWith(
          downloadProgress: finalProgress,
          errorMessage: error.message,
        ));
      },
    );
  }

  /// Deletes a downloaded translation from local storage
  Future<void> deleteTranslation(String translationId) async {
    final repository = ref.read(translationRepositoryProvider);
    final deleteResult = await repository.deleteTranslation(translationId);

    await deleteResult.when(
      (success) async {
        final updatedTranslationsResult = await repository.getAllTranslations();
        final updatedTranslations = updatedTranslationsResult.tryGetSuccess() ?? [];
        state = AsyncData(state.value!.copyWith(translations: updatedTranslations));
      },
      (error) {
        state = AsyncData(state.value!.copyWith(errorMessage: error.message));
      },
    );
  }

  /// Sets the currently active translation that the user wants to read
  Future<void> setActiveTranslation(String translationId) async {
    final repository = ref.read(translationRepositoryProvider);
    final setActiveResult = await repository.setActiveTranslation(translationId);

    setActiveResult.when(
      (success) {
        state = AsyncData(state.value!.copyWith(activeTranslationId: translationId));
      },
      (error) {
        state = AsyncData(state.value!.copyWith(errorMessage: error.message));
      },
    );
  }
}
