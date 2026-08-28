import 'package:multiple_result/multiple_result.dart';
import '../../../../common/exceptions/failure.dart';
import '../entities/translation_entity.dart';

/// Abstract repository defining the contract for managing translations.
abstract class ITranslationRepository {
  /// Returns a complete list of all available translations (both downloaded and not downloaded).
  /// This checks the local Hive registry and compares it with the hardcoded catalog.
  Future<Result<List<TranslationEntity>, Failure>> getAllTranslations();

  /// Downloads a translation and saves it to local storage.
  Future<Result<void, Failure>> downloadTranslation(TranslationEntity translation, {void Function(int, int)? onReceiveProgress});

  /// Preloads a translation from a local JSON asset file into Hive.
  Future<Result<void, Failure>> preloadTranslationFromJson(String translationId, String assetPath);

  /// Deletes a downloaded translation from Hive.
  Future<Result<void, Failure>> deleteTranslation(String translationId);

  /// Retrieves the translated text for a specific ayah.
  /// Returns null if the translation is not downloaded or text is not found.
  Future<Result<String?, Failure>> getAyahTranslation({
    required String translationId,
    required int surahNumber,
    required int ayahNumber,
  });

  /// Saves the user's selected translation ID so it persists across app restarts.
  Future<Result<void, Failure>> setActiveTranslation(String translationId);

  /// Retrieves the last selected translation ID (or null if none selected).
  Future<Result<String?, Failure>> getActiveTranslation();
}
