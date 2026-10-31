class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Session expired or unauthenticated. Please log in again.',
    super.statusCode = 401,
    super.details,
  });
}

class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Access denied. You do not have permission for this clinical resource.',
    super.statusCode = 403,
    super.details,
  });
}

class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Requested resource was not found.',
    super.statusCode = 404,
    super.details,
  });
}

class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Network connection failed. Please check your internet connection.',
    super.statusCode,
    super.details,
  });
}
