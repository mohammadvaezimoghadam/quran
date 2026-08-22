import 'package:multiple_result/multiple_result.dart';
import '../../../../common/exceptions/failure.dart';
import '../entities/surah_entity.dart';

abstract interface class ISurahRepository {
  Future<Result<List<SurahEntity>, Failure>> getSurahs();
}
