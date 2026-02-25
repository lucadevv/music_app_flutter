import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import 'app_exceptions.dart';

class ExceptionHandler {
  static AppException handleException(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is FormatException) {
      return ValidationException(
        'Error en el formato de los datos',
        details: error.message,
      );
    } else if (error is AppException) {
      return error;
    } else {
      return UnknownException(
        'Error inesperado',
        details: error.toString(),
      );
    }
  }

  static AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Tiempo de conexión agotado',
          code: 408,
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.cancel:
        return NetworkException('Solicitud cancelada');

      case DioExceptionType.unknown:
        return NetworkException(
          'Error de conexión',
          details: error.message,
        );

      case DioExceptionType.badCertificate:
        return NetworkException('Error de certificado SSL');

      case DioExceptionType.connectionError:
        return NetworkException('Error de conexión de red');
    }
  }

  static AppException _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    switch (statusCode) {
      case 400:
        return ValidationException(
          _getErrorMessage(data, 'Solicitud incorrecta'),
          code: statusCode,
          details: _getErrorDetails(data),
        );

      case 401:
        return AuthenticationException(
          _getErrorMessage(data, 'No autorizado'),
          code: statusCode,
          details: _getErrorDetails(data),
        );

      case 403:
        return AuthenticationException(
          _getErrorMessage(data, 'Acceso denegado'),
          code: statusCode,
          details: _getErrorDetails(data),
        );

      case 404:
        return ServerException(
          _getErrorMessage(data, 'Recurso no encontrado'),
          code: statusCode,
          details: _getErrorDetails(data),
        );

      case 409:
        return ValidationException(
          _getErrorMessage(data, 'Conflicto de datos'),
          code: statusCode,
          details: _getErrorDetails(data),
        );

      case 422:
        return ValidationException(
          _getErrorMessage(data, 'Error de validación'),
          code: statusCode,
          details: _getErrorDetails(data),
        );

      case 500:
      case 502:
      case 503:
        return ServerException(
          _getErrorMessage(data, 'Error del servidor'),
          code: statusCode,
          details: _getErrorDetails(data),
        );

      default:
        return ServerException(
          _getErrorMessage(data, 'Error del servidor'),
          code: statusCode,
          details: _getErrorDetails(data),
        );
    }
  }

  static String _getErrorMessage(dynamic data, String defaultMessage) {
    if (data is Map<String, dynamic>) {
      return data['message'] ?? data['error'] ?? defaultMessage;
    }
    return defaultMessage;
  }

  static String? _getErrorDetails(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['details'] ?? data['description'];
    }
    return null;
  }

  static void logException(AppException exception, {String? context}) {
    debugPrint('${context ?? 'Exception'}: ${exception.message}');
    if (exception.details != null) {
      debugPrint('Details: ${exception.details}');
    }
    if (exception.code != null) {
      debugPrint('Code: ${exception.code}');
    }
  }
}
