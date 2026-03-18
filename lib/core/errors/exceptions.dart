abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException({required super.message}) : super(statusCode: null);
}

class TimeoutException extends AppException {
  const TimeoutException({required super.message}) : super(statusCode: 408);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({required super.message}) : super(statusCode: 401);
}

class ForbiddenException extends AppException {
  const ForbiddenException({required super.message}) : super(statusCode: 403);
}

class NotFoundException extends AppException {
  const NotFoundException({required super.message}) : super(statusCode: 404);
}

class BadRequestException extends AppException {
  const BadRequestException({required super.message}) : super(statusCode: 400);
}

class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    required super.message,
    this.errors,
  }) : super(statusCode: 422);
}

class ServerException extends AppException {
  const ServerException({required super.message}) : super(statusCode: 500);
}

class RateLimitException extends AppException {
  const RateLimitException({required super.message}) : super(statusCode: 429);
}

class CacheException extends AppException {
  const CacheException({required super.message}) : super(statusCode: null);
}

class UnknownException extends AppException {
  const UnknownException({required super.message}) : super(statusCode: null);
}
