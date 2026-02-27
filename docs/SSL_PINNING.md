# SSL Pinning Implementation

Esta implementación de SSL Pinning proporciona seguridad adicional para las conexiones HTTPS de la aplicación.

## Estructura de Archivos

```
lib/core/
├── config/
│   └── app_config.dart              # Configuración de fingerprints SSL
├── services/
│   ├── network/
│   │   └── dio_services_impl.dart   # Cliente Dio con SSL Pinning
│   └── security/
│       ├── ssl_pinning_interceptor.dart  # Interceptor de validación
│       └── ssl_error_handler.dart        # Manejo de errores SSL
└── utils/
    └── exeptions/
        └── app_exceptions.dart      # Excepción SslException

scripts/
└── get_cert_fingerprints.sh         # Script para obtener fingerprints
```

## Configuración

### 1. Obtener Fingerprints de Certificados

Ejecuta el script para obtener los fingerprints:

```bash
./scripts/get_cert_fingerprints.sh
```

O manualmente:

```bash
# Para un servidor específico
openssl s_client -connect api.example.com:443 | openssl x509 -fingerprint -sha256 -noout

# Output ejemplo:
# SHA256 Fingerprint=A1:B2:C3:D4:E5:F6:...
```

### 2. Configurar Fingerprints en app_config.dart

```dart
static const List<String> sslFingerprints = [
  // Producción
  'A1:B2:C3:D4:E5:F6:...',  // Certificado principal
  '11:22:33:44:55:66:...',  // Certificado de backup
];
```

### 3. Habilitar SSL Pinning

**En desarrollo (env.json):**
```json
{
    "base_url": "http://localhost:3000/api",
    "SSL_PINNING_ENABLED": false,
    "SSL_PINNING_BYPASS_DEBUG": true
}
```

**En producción:**
```bash
flutter build apk --dart-define=SSL_PINNING_ENABLED=true --dart-define=SSL_PINNING_BYPASS_DEBUG=false
```

## Variables de Configuración

| Variable | Descripción | Default |
|----------|-------------|---------|
| `SSL_PINNING_ENABLED` | Habilita/deshabilita SSL Pinning | `false` |
| `SSL_PINNING_BYPASS_DEBUG` | Permite bypass en modo debug | `true` |
| `PRODUCTION` | Modo producción | `false` |

## Uso

El SSL Pinning se integra automáticamente con el cliente Dio. No se requiere configuración adicional.

### Validación Automática

- Cada petición HTTPS valida el certificado del servidor
- Los fingerprints se cachean por host para mejorar performance
- Los errores SSL se manejan automáticamente

### Manejo de Errores

```dart
import 'package:music_app/core/services/security/ssl_error_handler.dart';

try {
  // Hacer petición HTTP
} catch (e) {
  if (SslErrorHandler.isSslError(e)) {
    final message = SslErrorHandler.getErrorMessage(e);
    // Mostrar mensaje al usuario
  }
}
```

## Consideraciones de Producción

### Let's Encrypt y Certificados Rotativos

Los certificados de Let's Encrypt rotan cada 90 días. Para evitar problemas:

1. **Usar fingerprints de CA**: En lugar del fingerprint del certificado del servidor, usa el fingerprint de la CA intermedia o raíz.

2. **Incluir múltiples fingerprints**: Agrega el fingerprint actual y el de backup.

3. **Monitoreo**: Implementa alertas cuando los certificados estén próximos a expirar.

### Ejemplo con CA de Let's Encrypt

```dart
static const List<String> sslFingerprints = [
  // ISRG Root X1 (Let's Encrypt)
  'B9:C9:A6:45:5E:6B:...',
  // ISRG Root X2 (Let's Encrypt Backup)
  '79:64:B2:0E:85:9B:...',
];
```

## Troubleshooting

### Error: Certificate validation failed

1. Verifica que el fingerprint en `app_config.dart` sea correcto
2. Ejecuta el script `get_cert_fingerprints.sh` para obtener el fingerprint actual
3. Verifica que el servidor tenga un certificado SSL válido

### Error: Handshake failed

1. Verifica que el servidor tenga HTTPS habilitado
2. Verifica que el puerto sea correcto (443 por defecto)
3. Verifica que no haya firewall bloqueando la conexión

### Bypass en Desarrollo

Si necesitas bypass temporal en desarrollo:

```json
{
    "SSL_PINNING_ENABLED": true,
    "SSL_PINNING_BYPASS_DEBUG": true
}
```

**⚠️ IMPORTANTE**: Nunca uses `bypassSslPinningInDebug = true` en producción.

## Testing

Para probar SSL Pinning:

1. Configura un fingerprint incorrecto
2. Verifica que la petición falle con `CertificatePinningException`
3. Configura el fingerprint correcto
4. Verifica que la petición sea exitosa

```dart
test('SSL Pinning blocks invalid certificates', () async {
  // Configurar fingerprint incorrecto
  // Verificar que lanza CertificatePinningException
});
```
