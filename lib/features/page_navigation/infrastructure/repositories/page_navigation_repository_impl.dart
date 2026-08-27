import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';
import '../../../../common/exceptions/failure.dart';
import '../../../../common/constants/app_constants.dart';
import '../../domain/entities/page_navigation_target.dart';
import '../../domain/repositories/page_navigation_repository.dart';
import '../datasources/page_navigation_local_datasource.dart';
import '../extensions/page_navigation_dto_extension.dart';

final pageNavigationRepositoryProvider = Provider<IPageNavigationRepository>((ref) {
  final localDataSource = ref.watch(pageNavigationLocalDataSourceProvider);
  return PageNavigationRepositoryImpl(localDataSource: localDataSource);
});

/// Implementation of the page navigation repository
class PageNavigationRepositoryImpl implements IPageNavigationRepository {
  final IPageNavigationLocalDataSource localDataSource;

  PageNavigationRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<PageNavigationTarget, Failure>> getTargetByPageNumber(int pageNumber) async {
    try {
      final dto = await localDataSource.getSurahInfoByPage(pageNumber);
      
      if (dto == null) {
        return Error(Failure(message: AppConstants.pageNotFoundError));
      }
      
      return Success(dto.toDomain());
    } catch (e) {
      return Error(Failure(message: e.toString()));
    }
  }
}


