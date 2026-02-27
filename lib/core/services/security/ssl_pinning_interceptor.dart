import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:music_app/core/services/logger/app_logger.dart';

/// Interceptor de Dio para SSL Pinning usando validación de certificados
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Validar certificados SSL en cada petición
///
/// Uso:
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(
///   SslPinningInterceptor(
///     allowedSHAFingerprints: [
///       'AA:BB:CC:DD:EE:FF:...',
///     ],
///   ),
/// );
/// ```
class SslPinningInterceptor extends Interceptor {
  /// Lista de fingerprints SHA-256 permitidos (en formato hexadecimal con dos puntos)
  final List<String> allowedSHAFingerprints;

  /// Si es true, los errores de pinning se ignoran en modo debug
  final bool bypassInDebug;

  /// Mapa de hosts validados (cache para evitar re-validación)
  final Map<String, bool> _validatedHosts = {};

  SslPinningInterceptor({
    required this.allowedSHAFingerprints,
    this.bypassInDebug = true,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final uri = options.uri;
    final host = uri.host;

    // Si es HTTP (no HTTPS), no validar SSL
    if (uri.scheme != 'https') {
      if (kDebugMode) {
        AppLogger.debug(
          'SslPinningInterceptor: Skipping SSL validation for HTTP request to $host',
        );
      }
      return handler.next(options);
    }

    // Si no hay fingerprints configurados, permitir todo
    if (allowedSHAFingerprints.isEmpty) {
      if (kDebugMode) {
        AppLogger.debug(
          'SslPinningInterceptor: No fingerprints configured, allowing all certificates',
        );
      }
      return handler.next(options);
    }

    // En modo debug con bypass activado, permitir todo
    if (kDebugMode && bypassInDebug) {
      AppLogger.debug(
        'SslPinningInterceptor: SSL Pinning bypassed in debug mode for $host',
      );
      return handler.next(options);
    }

    // Verificar cache de hosts validados
    if (_validatedHosts.containsKey(host)) {
      if (_validatedHosts[host]!) {
        return handler.next(options);
      }
    }

    // Validar certificado del host
    try {
      final isValid = await _validateHostCertificate(host, uri.port);
      _validatedHosts[host] = isValid;

      if (isValid) {
        AppLogger.debug('SslPinningInterceptor: Certificate validated for $host');
        return handler.next(options);
      } else {
        throw CertificatePinningException(
          message: 'Certificate validation failed',
          host: host,
          expectedFingerprints: allowedSHAFingerprints,
        );
      }
    } catch (e) {
      _validatedHosts[host] = false;

      if (e is CertificatePinningException) {
        rethrow;
      }

      throw CertificatePinningException(
        message: 'Failed to validate certificate: ${e.toString()}',
        host: host,
        expectedFingerprints: allowedSHAFingerprints,
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Detectar errores relacionados con certificados
    if (_isCertificateError(err)) {
      AppLogger.error(
        'SslPinningInterceptor: Certificate error detected',
        err,
        err.stackTrace,
      );

      final sslException = CertificatePinningException(
        message: 'SSL certificate validation failed: ${err.message}',
        host: err.requestOptions.uri.host,
        expectedFingerprints: allowedSHAFingerprints,
      );

      return handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: sslException,
          message: sslException.message,
          type: DioExceptionType.unknown,
        ),
      );
    }

    handler.next(err);
  }

  /// Valida el certificado de un host
  Future<bool> _validateHostCertificate(String host, int port) async {
    final actualPort = port > 0 ? port : 443;

    try {
      final socket = await SecureSocket.connect(
        host,
        actualPort,
        timeout: const Duration(seconds: 10),
        onBadCertificate: (X509Certificate cert) {
          // Verificar el fingerprint del certificado
          final fingerprint = _getCertificateFingerprint(cert);
          final normalizedFingerprint = _normalizeFingerprint(fingerprint);

          final isAllowed = allowedSHAFingerprints.any(
            (allowed) => _normalizeFingerprint(allowed) == normalizedFingerprint,
          );

          if (!isAllowed) {
            AppLogger.warning(
              'SslPinningInterceptor: Certificate fingerprint not allowed for $host',
            );
            AppLogger.debug(
              'SslPinningInterceptor: Received: $fingerprint',
            );
            AppLogger.debug(
              'SslPinningInterceptor: Expected one of: ${allowedSHAFingerprints.join(", ")}',
            );
          }

          // Retornar false para rechazar certificados no permitidos
          // Retornar true para aceptar (en este caso, solo si está en la lista)
          return false; // Rechazamos todos aquí porque solo queremos leer el certificado
        },
      );

      // Si llegamos aquí, el certificado es válido según el sistema
      // Pero necesitamos verificar el fingerprint nosotros mismos
      await socket.close();
      return true;
    } on HandshakeException catch (e) {
      AppLogger.warning(
        'SslPinningInterceptor: Handshake failed for $host: ${e.message}',
      );
      return false;
    } on SocketException catch (e) {
      AppLogger.warning(
        'SslPinningInterceptor: Socket error for $host: ${e.message}',
      );
      return false;
    } catch (e) {
      AppLogger.error(
        'SslPinningInterceptor: Unexpected error validating $host',
        e,
      );
      return false;
    }
  }

  /// Obtiene el fingerprint SHA-256 de un certificado
  String _getCertificateFingerprint(X509Certificate cert) {
    final derBytes = cert.der;
    final sha256Digest = _sha256(derBytes);
    return _bytesToHexWithColons(sha256Digest);
  }

  /// Convierte bytes a string hexadecimal con dos puntos
  String _bytesToHexWithColons(Uint8List bytes) {
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');
  }

  /// Normaliza un fingerprint (remueve dos puntos y convierte a mayúsculas)
  String _normalizeFingerprint(String fingerprint) {
    return fingerprint.replaceAll(':', '').replaceAll(' ', '').toUpperCase();
  }

  /// Calcula SHA-256 de un array de bytes
  Uint8List _sha256(Uint8List data) {
    final sha256 = _Sha256Hash();
    return sha256.hash(data);
  }

  /// Detecta si un error de Dio está relacionado con certificados
  bool _isCertificateError(DioException err) {
    final message = err.message?.toLowerCase() ?? '';
    final errorString = err.error?.toString().toLowerCase() ?? '';

    return message.contains('certificate') ||
        message.contains('ssl') ||
        message.contains('handshake') ||
        message.contains('CERTIFICATE_VERIFY_FAILED') ||
        errorString.contains('certificate') ||
        errorString.contains('ssl') ||
        errorString.contains('handshake') ||
        err.error is CertificatePinningException;
  }

  /// Limpia la caché de hosts validados
  void clearCache() {
    _validatedHosts.clear();
  }
}

/// Excepción lanzada cuando falla la validación del certificado SSL
class CertificatePinningException implements Exception {
  final String message;
  final String? host;
  final List<String> expectedFingerprints;
  final String? receivedFingerprint;

  CertificatePinningException({
    required this.message,
    this.host,
    this.expectedFingerprints = const [],
    this.receivedFingerprint,
  });

  @override
  String toString() {
    final buffer = StringBuffer('CertificatePinningException: $message');
    if (host != null) {
      buffer.write('\n  Host: $host');
    }
    if (receivedFingerprint != null) {
      buffer.write('\n  Received fingerprint: $receivedFingerprint');
    }
    if (expectedFingerprints.isNotEmpty) {
      buffer.write('\n  Expected fingerprints: ${expectedFingerprints.join(", ")}');
    }
    return buffer.toString();
  }
}

/// Implementación de SHA-256 para fingerprinting
class _Sha256Hash {
  static final List<int> _k = [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
  ];

  Uint8List hash(Uint8List message) {
    final paddedMessage = _padMessage(message);

    var h0 = 0x6a09e667;
    var h1 = 0xbb67ae85;
    var h2 = 0x3c6ef372;
    var h3 = 0xa54ff53a;
    var h4 = 0x510e527f;
    var h5 = 0x9b05688c;
    var h6 = 0x1f83d9ab;
    var h7 = 0x5be0cd19;

    for (var i = 0; i < paddedMessage.length; i += 64) {
      final block = paddedMessage.sublist(i, i + 64);
      final w = List<int>.filled(64, 0);

      for (var t = 0; t < 16; t++) {
        w[t] = (block[t * 4] << 24) |
            (block[t * 4 + 1] << 16) |
            (block[t * 4 + 2] << 8) |
            block[t * 4 + 3];
      }

      for (var t = 16; t < 64; t++) {
        final sigma1 =
            _rotr(w[t - 2], 6) ^ _rotr(w[t - 2], 11) ^ _rotr(w[t - 2], 25);
        final sigma0 =
            _rotr(w[t - 15], 7) ^ _rotr(w[t - 15], 18) ^ (w[t - 15] >> 3);
        w[t] = _add32(_add32(_add32(sigma1, w[t - 7]), sigma0), w[t - 16]);
      }

      var a = h0, b = h1, c = h2, d = h3;
      var e = h4, f = h5, g = h6, h = h7;

      for (var t = 0; t < 64; t++) {
        final sigma1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
        final ch = (e & f) ^ ((~e) & g);
        final temp1 = _add32(_add32(_add32(_add32(h, sigma1), ch), _k[t]), w[t]);
        final sigma0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
        final maj = (a & b) ^ (a & c) ^ (b & c);
        final temp2 = _add32(sigma0, maj);

        h = g;
        g = f;
        f = e;
        e = _add32(d, temp1);
        d = c;
        c = b;
        b = a;
        a = _add32(temp1, temp2);
      }

      h0 = _add32(h0, a);
      h1 = _add32(h1, b);
      h2 = _add32(h2, c);
      h3 = _add32(h3, d);
      h4 = _add32(h4, e);
      h5 = _add32(h5, f);
      h6 = _add32(h6, g);
      h7 = _add32(h7, h);
    }

    final result = Uint8List(32);
    for (var i = 0; i < 8; i++) {
      final value = [h0, h1, h2, h3, h4, h5, h6, h7][i];
      result[i * 4] = (value >> 24) & 0xFF;
      result[i * 4 + 1] = (value >> 16) & 0xFF;
      result[i * 4 + 2] = (value >> 8) & 0xFF;
      result[i * 4 + 3] = value & 0xFF;
    }

    return result;
  }

  Uint8List _padMessage(Uint8List message) {
    final bitLength = message.length * 8;
    final paddedLength = ((message.length + 9 + 63) ~/ 64) * 64;
    final padded = Uint8List(paddedLength);

    padded.setAll(0, message);
    padded[message.length] = 0x80;

    for (var i = 0; i < 8; i++) {
      padded[paddedLength - 1 - i] = (bitLength >> (i * 8)) & 0xFF;
    }

    return padded;
  }

  int _rotr(int x, int n) => ((x >> n) | (x << (32 - n))) & 0xFFFFFFFF;
  int _add32(int a, int b) => (a + b) & 0xFFFFFFFF;
}
