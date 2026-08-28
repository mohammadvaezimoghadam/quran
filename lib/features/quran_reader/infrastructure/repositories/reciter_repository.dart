import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../common/exceptions/failure.dart';
import '../../domain/entities/recitation_style_entity.dart';
import '../../domain/entities/reciter_entity.dart';
import '../../domain/repositories/i_reciter_repository.dart';
import '../datasources/reciter_catalog.dart';

final reciterRepositoryProvider = Provider<IReciterRepository>((ref) {
  return ReciterRepository();
});

class ReciterRepository implements IReciterRepository {
  
  ReciterRepository();

  @override
  Future<Result<List<ReciterEntity>, Failure>> getAllReciters() async {
    try {
      return Success(ReciterCatalog.allReciters);
    } catch (e) {
      return Error(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<ReciterEntity>, Failure>> getRecitersByStyle(int styleId) async {
    try {
      final reciters = ReciterCatalog.allReciters.where((r) => r.styleId == styleId).toList();
      return Success(reciters);
    } catch (e) {
      return Error(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<RecitationStyleEntity>, Failure>> getRecitationStyles() async {
    try {
      return Success(ReciterCatalog.styles);
    } catch (e) {
      return Error(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<ReciterEntity, Failure>> getReciterById(int id) async {
    try {
      final reciter = ReciterCatalog.allReciters.firstWhere((r) => r.id == id);
      return Success(reciter);
    } catch (e) {
      return const Error(Failure(message: 'قاری با این شناسه یافت نشد.'));
    }
  }
}
