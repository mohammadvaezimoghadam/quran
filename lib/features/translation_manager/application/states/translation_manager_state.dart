import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/translation_entity.dart';

part 'translation_manager_state.freezed.dart';

@freezed
abstract class TranslationManagerState with _$TranslationManagerState {
  const factory TranslationManagerState({
    /// List of all available translations (merged from catalog and Hive)
    @Default([]) List<TranslationEntity> translations,

    /// The ID of the currently active/selected translation
    String? activeTranslationId,

    /// Map of translation IDs to their download progress (0.0 to 1.0).
    /// If an ID is in this map, it is currently downloading.
    @Default({}) Map<String, double> downloadProgress,

    /// General error message to display in UI if something fails
    String? errorMessage,
  }) = _TranslationManagerState;
}
