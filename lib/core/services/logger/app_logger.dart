import 'package:logger/logger.dart';

/// Servicio de logging centralizado para la aplicación
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Proporcionar logging consistente en toda la app
///
/// Uso:
/// ```dart
/// AppLogger.debug('Mensaje de debug');
/// AppLogger.info('Mensaje informativo');
/// AppLogger.warning('Advertencia');
/// AppLogger.error('Error ocurrido', error, stackTrace);
/// ```
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log de nivel debug - para desarrollo
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log de nivel info - para información general
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log de nivel warning - para advertencias
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log de nivel error - para errores
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log de nivel trace - para tracing detallado
  static void trace(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Log de nivel fatal - para errores críticos
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
