import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dtos/moezzin_dto.dart';
import 'moezzin_catalog.dart';

final adhanLocalDataSourceProvider = Provider<IAdhanLocalDataSource>((ref) {
  return AdhanLocalDataSource();
});

abstract class IAdhanLocalDataSource {
  Future<List<MoezzinDto>> getAllMoezzins();
  Future<MoezzinDto?> getMoezzinById(String id);
}

class AdhanLocalDataSource implements IAdhanLocalDataSource {
  @override
  Future<List<MoezzinDto>> getAllMoezzins() async {
    return MoezzinCatalog.allMoezzins;
  }

  @override
  Future<MoezzinDto?> getMoezzinById(String id) async {
    try {
      return MoezzinCatalog.allMoezzins.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
