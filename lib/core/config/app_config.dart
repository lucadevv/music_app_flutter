/// Schema/Targets: Configuración de la aplicación
///
/// Esta clase centraliza las configuraciones de la aplicación usando dart-define.
/// Permite tener diferentes configuraciones para desarrollo, staging y producción
/// sin modificar el código, solo cambiando los parámetros de compilación.
///
/// Uso:
/// - Desarrollo: --dart-define-from-file=env.json
/// - Staging: --dart-define=base_url=...
/// - Producción: --dart-define=base_url=...
class AppConfig {
  /// URL base de la API
  /// Se obtiene de la variable de entorno 'base_url'
  static const String baseUrl = String.fromEnvironment('base_url');

  /// Token de acceso para la API
  /// Se obtiene de la variable de entorno 'access_token'
  static const String accessToken = String.fromEnvironment(
    'access_token',
    defaultValue: '',
  );

  /// Indica si la aplicación está en modo debug
  static const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;

  /// Timeout para las peticiones HTTP en segundos
  static const int httpTimeout = 10;

  /// Idioma por defecto de la aplicación
  static const String defaultLanguage = 'es-ES';
}
