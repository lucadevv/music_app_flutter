import 'package:equatable/equatable.dart';
import '../exeptions/app_exceptions.dart';

/// Clase base para representar fallos en la aplicación
abstract class Failure extends Equatable {
  final String message;
  final int? code;
  final String? details;

  const Failure(this.message, {this.code, this.details});

  @override
  List<Object?> get props => [message, code, details];
}

/// Failure para errores de red
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.details});
}

/// Failure para errores del servidor
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.details});
}

/// Failure para errores de autenticación
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, {super.code, super.details});
}

/// Failure para errores de validación
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.details});
}

/// Failure para errores desconocidos
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code, super.details});
}

/// Extensión para convertir AppException a Failure
extension AppExceptionToFailure on AppException {
  Failure toFailure() {
    if (this is NetworkException) {
      return NetworkFailure(message, code: code, details: details);
    } else if (this is ServerException) {
      return ServerFailure(message, code: code, details: details);
    } else if (this is AuthenticationException) {
      return AuthenticationFailure(message, code: code, details: details);
    } else if (this is ValidationException) {
      return ValidationFailure(message, code: code, details: details);
    } else {
      return UnknownFailure(message, code: code, details: details);
    }
  }
}
