import 'package:multiple_result/multiple_result.dart';
import '../../../../common/exceptions/failure.dart';
import '../entities/recitation_style_entity.dart';
import '../entities/reciter_entity.dart';

abstract interface class IReciterRepository {
  /// Fetches all reciters available in the local database
  Future<Result<List<ReciterEntity>, Failure>> getAllReciters();

  /// Fetches reciters filtered by recitation style ID
  Future<Result<List<ReciterEntity>, Failure>> getRecitersByStyle(int styleId);

  /// Fetches all recitation styles (Murattal, Mujawwad, Teacher, Translation)
  Future<Result<List<RecitationStyleEntity>, Failure>> getRecitationStyles();

  /// Fetches a single reciter by its unique ID
  Future<Result<ReciterEntity, Failure>> getReciterById(int id);
}
