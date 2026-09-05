import '../../domain/entities/moezzin.dart';
import '../../domain/repositories/i_adhan_moezzin_repository.dart';
import '../datasources/adhan_local_data_source.dart';

class AdhanMoezzinRepository implements IAdhanMoezzinRepository {
  final IAdhanLocalDataSource _localDataSource;

  AdhanMoezzinRepository(this._localDataSource);

  @override
  Future<List<Moezzin>> getAvailableMoezzins() async {
    final dtos = await _localDataSource.getAllMoezzins();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<Moezzin?> getMoezzinById(String id) async {
    final dto = await _localDataSource.getMoezzinById(id);
    return dto?.toEntity();
  }
}
