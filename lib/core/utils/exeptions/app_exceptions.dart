abstract class AppException implements Exception {
  final String message;
  final int? code;
  final String? details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.details});
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.details});
}

class AuthenticationException extends AppException {
  const AuthenticationException(super.message, {super.code, super.details});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.details});
}

class UnknownException extends AppException {
  const UnknownException(super.message, {super.code, super.details});
}
