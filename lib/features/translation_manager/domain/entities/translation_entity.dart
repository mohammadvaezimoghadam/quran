import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_entity.freezed.dart';

/// The core entity representing a translation in the application.
@freezed
abstract class TranslationEntity with _$TranslationEntity {
  const factory TranslationEntity({
    /// Unique identifier for the translation (e.g., 'fa.makarem', 'fas-alimaleki')
    required String id,

    /// Display name of the translation (e.g., 'مکارم شیرازی')
    required String name,

    /// Name of the translator
    required String translatorName,

    /// ISO Language code (e.g., 'fa', 'en')
    required String languageCode,

    /// The direct API URL to download the JSON from
    required String sourceUrl,

    /// Whether this translation is currently downloaded and available in Hive
    @Default(false) bool isDownloaded,

    /// Whether this is the default pre-loaded translation
    @Default(false) bool isDefault,
  }) = _TranslationEntity;
}
