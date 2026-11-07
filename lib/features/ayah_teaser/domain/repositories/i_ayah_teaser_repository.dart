import 'package:multiple_result/multiple_result.dart';
import '../../../../common/exceptions/failure.dart';
import '../entities/surah_teasers_result.dart';

/// Contract for fetching Ayah note teasers for a Surah.
abstract class IAyahTeaserRepository {
  /// Fetches the latest community notes per Ayah for the given [surahNumber].
  ///
  /// If [forceRefresh] is true, cache is bypassed and fresh data is fetched from the server.
  Future<Result<SurahTeasersResult, Failure>> getSurahLatestPosts({
    required int surahNumber,
    bool forceRefresh = false,
  });

  /// Clears the in-memory cache for a specific Surah or all Surahs.
  void clearCache([int? surahNumber]);
}

