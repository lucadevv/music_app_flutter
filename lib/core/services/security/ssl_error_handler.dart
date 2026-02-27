import 'package:dio/dio.dart';
import 'package:music_app/core/services/security/ssl_pinning_interceptor.dart';

/// Utilidad para manejar errores relacionados con SSL/Certificados
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Proporcionar mensajes de error y detección de errores SSL
class SslErrorHandler {
  SslErrorHandler._();

  /// Obtiene un mensaje de error amigable para el usuario
  static String getErrorMessage(dynamic error) {
    if (error is CertificatePinningException) {
      return _getCertificatePinningErrorMessage(error);
    }

    if (error is DioException) {
      return _getDioErrorMessage(error);
    }

    if (error is Exception) {
      final errorString = error.toString().toLowerCase();
      if (errorString.contains('certificate') ||
          errorString.contains('ssl') ||
          errorString.contains('handshake')) {
        return 'Error de conexión segura. No se pudo verificar la autenticidad del servidor.';
      }
    }

    return 'Error de conexión. Por favor intenta más tarde.';
  }

  /// Verifica si un error está relacionado con SSL/Certificados
  static bool isSslError(dynamic error) {
    if (error is CertificatePinningException) {
      return true;
    }

    if (error is DioException) {
      return _isDioSslError(error);
    }

    if (error is Exception) {
      final errorString = error.toString().toLowerCase();
      return errorString.contains('certificate') ||
          errorString.contains('ssl') ||
          errorString.contains('handshake') ||
          errorString.contains('CERTIFICATE_VERIFY_FAILED');
    }

    return false;
  }

  /// Verifica si el error es crítico y requiere acción inmediata
  static bool isCriticalSslError(dynamic error) {
    if (error is CertificatePinningException) {
      return true;
    }

    if (error is DioException) {
      final message = error.message?.toLowerCase() ?? '';
      return message.contains('CERTIFICATE_VERIFY_FAILED') ||
          message.contains('certificate pinning');
    }

    return false;
  }

  /// Obtiene detalles técnicos del error para debugging
  static String getTechnicalDetails(dynamic error) {
    if (error is CertificatePinningException) {
      final buffer = StringBuffer();
      buffer.writeln('CertificatePinningException:');
      buffer.writeln('  Message: ${error.message}');
      if (error.host != null) {
        buffer.writeln('  Host: ${error.host}');
      }
      if (error.receivedFingerprint != null) {
        buffer.writeln('  Received: ${error.receivedFingerprint}');
      }
      if (error.expectedFingerprints.isNotEmpty) {
        buffer.writeln('  Expected:');
        for (final fp in error.expectedFingerprints) {
          buffer.writeln('    - $fp');
        }
      }
      return buffer.toString();
    }

    if (error is DioException) {
      final buffer = StringBuffer();
      buffer.writeln('DioException:');
      buffer.writeln('  Type: ${error.type}');
      buffer.writeln('  Message: ${error.message}');
      buffer.writeln('  URL: ${error.requestOptions.uri}');
      if (error.response != null) {
        buffer.writeln('  Status: ${error.response?.statusCode}');
      }
      return buffer.toString();
    }

    return error.toString();
  }

  // Métodos privados

  static String _getCertificatePinningErrorMessage(CertificatePinningException error) {
    // Mensajes específicos según el tipo de error
    if (error.message.contains('not in allowed list')) {
      return 'Error de seguridad: La identidad del servidor no pudo ser verificada. '
          'Esto podría indicar un intento de ataque.';
    }

    if (error.message.contains('validation failed')) {
      return 'Error de seguridad: El certificado del servidor no es válido. '
          'Por favor contacta a soporte.';
    }

    if (error.message.contains('Failed to validate')) {
      return 'Error de conexión segura. No se pudo establecer una conexión confiable '
          'con el servidor.';
    }

    return 'Error de seguridad: No se pudo verificar la autenticidad del servidor. '
        'Por favor intenta más tarde.';
  }

  static String _getDioErrorMessage(DioException error) {
    final message = error.message?.toLowerCase() ?? '';
    final errorString = error.error?.toString().toLowerCase() ?? '';

    if (message.contains('CERTIFICATE_VERIFY_FAILED') ||
        errorString.contains('CERTIFICATE_VERIFY_FAILED')) {
      return 'Error de certificado. La conexión no es segura.';
    }

    if (message.contains('handshake') || errorString.contains('handshake')) {
      return 'Error de conexión segura. No se pudo completar el handshake SSL.';
    }

    if (message.contains('ssl') || errorString.contains('ssl')) {
      return 'Error de conexión SSL. Por favor verifica tu conexión.';
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Tiempo de conexión agotado. Por favor verifica tu conexión a internet.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Error de conexión. Por favor verifica tu conexión a internet.';
    }

    if (error.response?.statusCode == 401) {
      return 'Sesión expirada. Por favor inicia sesión nuevamente.';
    }

    if (error.response?.statusCode == 403) {
      return 'Acceso denegado. No tienes permisos para realizar esta acción.';
    }

    if (error.response?.statusCode == 404) {
      return 'Recurso no encontrado.';
    }

    if (error.response?.statusCode != null &&
        error.response!.statusCode! >= 500) {
      return 'Error del servidor. Por favor intenta más tarde.';
    }

    return 'Error de conexión. Por favor intenta más tarde.';
  }

  static bool _isDioSslError(DioException error) {
    final message = error.message?.toLowerCase() ?? '';
    final errorString = error.error?.toString().toLowerCase() ?? '';

    return message.contains('certificate') ||
        message.contains('ssl') ||
        message.contains('handshake') ||
        message.contains('CERTIFICATE_VERIFY_FAILED') ||
        errorString.contains('certificate') ||
        errorString.contains('ssl') ||
        errorString.contains('handshake') ||
        error.error is CertificatePinningException;
  }
}
