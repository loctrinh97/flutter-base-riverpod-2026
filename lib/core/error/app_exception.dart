sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException(super.message, {this.statusCode});
  final int? statusCode;
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized. Please login again.']);
}

final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found.']);
}

final class ValidationException extends AppException {
  const ValidationException(super.message);
}

final class StorageException extends AppException {
  const StorageException(super.message);
}

final class CacheException extends AppException {
  const CacheException(super.message);
}

final class UnknownException extends AppException {
  const UnknownException([super.message = 'An unexpected error occurred.']);
}
