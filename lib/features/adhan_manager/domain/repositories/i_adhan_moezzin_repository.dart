import '../entities/moezzin.dart';

abstract class IAdhanMoezzinRepository {
  /// Fetches the available moezzins.
  Future<List<Moezzin>> getAvailableMoezzins();

  /// Gets a specific moezzin by ID.
  Future<Moezzin?> getMoezzinById(String id);
}
