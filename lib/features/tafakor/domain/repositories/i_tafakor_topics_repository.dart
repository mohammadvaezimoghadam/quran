import 'package:multiple_result/multiple_result.dart';
import '../../../../common/exceptions/failure.dart';
import '../entities/tafakor_topic.dart';

abstract class ITafakorTopicsRepository {
  Future<Result<List<TafakorTopic>, Failure>> getTopics();
}
