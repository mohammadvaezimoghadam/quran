import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';
import '../../../common/constants/app_constants.dart';
import '../../../common/exceptions/failure.dart';
import '../domain/entities/page_navigation_target.dart';
import '../domain/repositories/page_navigation_repository.dart';
import '../infrastructure/repositories/page_navigation_repository_impl.dart';

final pageNavigationServiceProvider = Provider<PageNavigationService>((ref) {
  final repository = ref.watch(pageNavigationRepositoryProvider);
  return PageNavigationService(repository);
});

/// Application Service orchestrating Page Navigation business logic
class PageNavigationService {
  final IPageNavigationRepository _repository;

  PageNavigationService(this._repository);

  Future<Result<PageNavigationTarget, Failure>> getTargetByPageNumber(int pageNumber) {
    return _repository.getTargetByPageNumber(pageNumber);
  }

  Future<Result<PageNavigationTarget, Failure>> getTargetFromQrData(String qrData) async {
    try {
      // Logic for parsing QR data is separated here in the Service Layer
      final pageNumber = int.tryParse(qrData.trim());
      
      if (pageNumber == null || pageNumber <= 0 || pageNumber > 604) {
        final shortData = qrData.length > 20 ? '${qrData.substring(0, 20)}...' : qrData;
        return Error(Failure(message: 'کد اسکن شده ($shortData) معتبر نیست.'));
      }

      return _repository.getTargetByPageNumber(pageNumber);
    } catch (e) {
      return Error(Failure(message: e.toString()));
    }
  }
}
