import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';
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
      final cleanData = qrData.trim();
      int? pageNumber = int.tryParse(cleanData);

      // Support 'P150' or 'p150'
      if (pageNumber == null && cleanData.toUpperCase().startsWith('P')) {
        pageNumber = int.tryParse(cleanData.substring(1));
      }

      // Extract numbers from URL e.g. https://quran.com/page/150
      if (pageNumber == null) {
        final match = RegExp(r'/page/(\d{1,3})|/(\d{1,3})|(\d{1,3})').firstMatch(cleanData);
        if (match != null) {
          final matchedGroup = match.group(1) ?? match.group(2) ?? match.group(3);
          if (matchedGroup != null) {
            pageNumber = int.tryParse(matchedGroup);
          }
        }
      }

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
