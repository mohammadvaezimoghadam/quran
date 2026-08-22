import 'package:multiple_result/multiple_result.dart';

import '../../../../common/exceptions/failure.dart';
import '../entities/ayah_of_the_day.dart';

/// Contract repository for Home feature domain operations
abstract interface class IHomeRepository {
  /// Fetches the Verse of the Day from data source
  Future<Result<AyahOfTheDay, Failure>> getAyahOfTheDay();
}
