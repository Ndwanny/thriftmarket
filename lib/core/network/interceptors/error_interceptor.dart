import 'package:dio/dio.dart';

import '../../errors/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeoutException(message: 'Connection timed out. Please try again.');

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final message = _extractErrorMessage(err.response);
        switch (statusCode) {
          case 400:
            throw BadRequestException(message: message);
          case 401:
            throw UnauthorizedException(message: message);
          case 403:
            throw ForbiddenException(message: message);
          case 404:
            throw NotFoundException(message: message);
          case 422:
            throw ValidationException(
              message: message,
              errors: _extractValidationErrors(err.response),
            );
          case 429:
            throw RateLimitException(message: 'Too many requests. Please slow down.');
          case 500:
          case 502:
          case 503:
            throw ServerException(message: 'Server error. Please try again later.');
          default:
            throw ServerException(message: message);
        }

      case DioExceptionType.connectionError:
        throw NetworkException(message: 'No internet connection.');

      case DioExceptionType.cancel:
        break;

      default:
        throw UnknownException(message: err.message ?? 'An unknown error occurred.');
    }
    handler.next(err);
  }

  String _extractErrorMessage(Response? response) {
    if (response?.data is Map) {
      final data = response!.data as Map;
      return data['message']?.toString() ??
          data['error']?.toString() ??
          'An error occurred';
    }
    return 'An error occurred';
  }

  Map<String, List<String>>? _extractValidationErrors(Response? response) {
    if (response?.data is Map) {
      final data = response!.data as Map;
      final errors = data['errors'];
      if (errors is Map) {
        return errors.map(
          (key, value) => MapEntry(
            key.toString(),
            (value as List).map((e) => e.toString()).toList(),
          ),
        );
      }
    }
    return null;
  }
}
