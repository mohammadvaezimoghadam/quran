import 'package:multiple_result/multiple_result.dart';
import '../../../../common/exceptions/failure.dart';
import '../entities/page_navigation_target.dart';

/// Interface (Abstract Class) for the page navigation repository
abstract class IPageNavigationRepository {
  /// Retrieves Surah and Ayah information based on the provided page number
  Future<Result<PageNavigationTarget, Failure>> getTargetByPageNumber(int pageNumber);
}
