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
  AppConfig._();

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

  /// Indica si la aplicación está en modo producción
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );

  /// Timeout para las peticiones HTTP en segundos
  static const int httpTimeout = 10;

  /// Idioma por defecto de la aplicación
  static const String defaultLanguage = 'es-ES';

  // ============================================================
  // SSL PINNING CONFIGURATION
  // ============================================================

  /// Indica si SSL Pinning está habilitado
  /// En producción siempre debe estar habilitado
  static const bool enableSslPinning = bool.fromEnvironment(
    'SSL_PINNING_ENABLED',
    defaultValue: false,
  );

  /// Bypass SSL Pinning en modo debug
  /// Solo usar en desarrollo, NUNCA en producción
  static const bool bypassSslPinningInDebug = bool.fromEnvironment(
    'SSL_PINNING_BYPASS_DEBUG',
    defaultValue: true,
  );

  /// Fingerprints SHA-256 de certificados permitidos
  ///
  /// Para obtener el fingerprint de un servidor:
  /// ```bash
  /// openssl s_client -connect api.example.com:443 | openssl x509 -fingerprint -sha256 -noout
  /// ```
  ///
  /// El formato debe ser: 'AA:BB:CC:DD:EE:FF:...' (hexadecimal con dos puntos)
  static const List<String> sslFingerprints = [
    // ============================================================
    // PRODUCCIÓN - Reemplazar con fingerprints reales
    // ============================================================
    // Ejemplo: 'A1:B2:C3:D4:E5:F6:...'
    // 'PROD_FINGERPRINT_1',
    // 'PROD_FINGERPRINT_2', // Backup certificate

    // ============================================================
    // STAGING - Solo para ambiente de pruebas
    // ============================================================
    // 'STAGING_FINGERPRINT_1',

    // ============================================================
    // DESARROLLO - Para localhost con HTTPS
    // ============================================================
    // Nota: En desarrollo se recomienda usar bypassSslPinningInDebug = true
    // Si usas HTTPS local con certificado autofirmado, agrega el fingerprint aquí
    // 'DEV_FINGERPRINT_1',
  ];

  /// Verifica si SSL Pinning está configurado correctamente
  static bool get isSslPinningConfigured {
    if (!enableSslPinning) return false;
    if (isProduction && sslFingerprints.isEmpty) {
      // En producción, SIEMPRE debe haber fingerprints configurados
      return false;
    }
    return true;
  }

  /// Verifica si se debe usar SSL Pinning estricto
  /// (sin bypass incluso en debug)
  static bool get useStrictSslPinning {
    return enableSslPinning && !bypassSslPinningInDebug;
  }
}
