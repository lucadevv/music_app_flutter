abstract class AppException implements Exception {
  final String message;
  final int? code;
  final String? details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;

  /// Crea una excepción de cancelación
  factory AppException.cancelled(String message) => CancelledException(message);
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

class CancelledException extends AppException {
  const CancelledException(super.message, {super.code, super.details});
}

/// Excepción para errores relacionados con SSL/Certificados
class SslException extends AppException {
  /// Host que causó el error
  final String? host;

  /// Fingerprints esperados
  final List<String>? expectedFingerprints;

  /// Fingerprint recibido
  final String? receivedFingerprint;

  const SslException(
    super.message, {
    super.code,
    super.details,
    this.host,
    this.expectedFingerprints,
    this.receivedFingerprint,
  });

  @override
  String toString() {
    final buffer = StringBuffer('SslException: $message');
    if (host != null) {
      buffer.write(' (host: $host)');
    }
    return buffer.toString();
  }
}
