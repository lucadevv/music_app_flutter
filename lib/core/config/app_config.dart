/// Configuración de la aplicación usando dart-define
class AppConfig {
  AppConfig._();

  /// URL base de la API
  static const String baseUrl = String.fromEnvironment('base_url');

  /// Token de acceso para la API
  static const String accessToken = String.fromEnvironment(
    'access_token',
    defaultValue: '',
  );

  /// Indica si la aplicación está en modo debug
  static const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;

  /// Indica si la aplicación está en modo producción
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );

  /// Timeout para las peticiones HTTP en segundos
  static const int httpTimeout = 10;

  /// Idioma por defecto de la aplicación
  static const String defaultLanguage = 'es-ES';

  /// Indica si SSL Pinning está habilitado
  static const bool enableSslPinning = bool.fromEnvironment(
    'SSL_PINNING_ENABLED',
    defaultValue: false,
  );

  /// Bypass SSL Pinning en modo debug
  static const bool bypassSslPinningInDebug = bool.fromEnvironment(
    'SSL_PINNING_BYPASS_DEBUG',
    defaultValue: true,
  );

  /// Fingerprints SHA-256 de certificados permitidos
  static const List<String> sslFingerprints = [];

  /// Verifica si SSL Pinning está configurado correctamente
  static bool get isSslPinningConfigured {
    if (!enableSslPinning) return false;
    if (isProduction && sslFingerprints.isEmpty) {
      return false;
    }
    return true;
  }

  /// Verifica si se debe usar SSL Pinning estricto
  static bool get useStrictSslPinning {
    return enableSslPinning && !bypassSslPinningInDebug;
  }
}
