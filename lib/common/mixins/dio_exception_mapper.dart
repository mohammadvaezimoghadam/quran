import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../constants/http_status_codes.dart';
import '../exceptions/failure.dart';

mixin DioExceptionMapper {
  Failure mapDioExceptionToFailure(DioException e, StackTrace stackTrace) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Failure(
          message: AppConstants.connectionTimeoutError,
          statusCode: e.response?.statusCode,
          exception: e,
          stackTrace: stackTrace,
        );
      case DioExceptionType.sendTimeout:
        return Failure(
          message: AppConstants.sendTimeoutError,
          statusCode: e.response?.statusCode,
          exception: e,
          stackTrace: stackTrace,
        );
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return Failure(
          message: AppConstants.receiveTimeoutError,
          statusCode: e.response?.statusCode,
          exception: e,
          stackTrace: stackTrace,
        );
      case DioExceptionType.badCertificate:
        return Failure(
          message: AppConstants.badCertificateError,
          statusCode: e.response?.statusCode,
          exception: e,
          stackTrace: stackTrace,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        return Failure(
          message: _getErrorMessageForStatusCode(statusCode),
          statusCode: statusCode,
          exception: e,
          stackTrace: stackTrace,
        );
      case DioExceptionType.cancel:
        return Failure(
          message: AppConstants.requestCancelledError,
          statusCode: e.response?.statusCode,
          exception: e,
          stackTrace: stackTrace,
        );
      case DioExceptionType.connectionError:
        return Failure(
          message: AppConstants.connectionError,
          statusCode: e.response?.statusCode,
          exception: e,
          stackTrace: stackTrace,
        );
      case DioExceptionType.unknown:
        return Failure(
          message: AppConstants.unexpectedError,
          statusCode: e.response?.statusCode,
          exception: e,
          stackTrace: stackTrace,
        );
    }
  }

  String _getErrorMessageForStatusCode(int? statusCode) {
    switch (statusCode) {
      case HttpStatusCodes.badRequest:
        return AppConstants.badRequestError;
      case HttpStatusCodes.unauthorized:
        return AppConstants.unauthorizedError;
      case HttpStatusCodes.forbidden:
        return AppConstants.forbiddenError;
      case HttpStatusCodes.notFound:
        return AppConstants.notFoundError;
      case HttpStatusCodes.tooManyRequests:
        return AppConstants.tooManyRequestsError;
      case HttpStatusCodes.internalServerError:
        return AppConstants.internalServerError;
      case HttpStatusCodes.serviceUnavailable:
        return AppConstants.serviceUnavailableError;
      default:
        return 'خطایی با کد وضعیت $statusCode در ارتباط با سرور رخ داد.';
    }
  }
}
