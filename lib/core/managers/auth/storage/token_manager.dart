import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manager para manejar el almacenamiento de tokens de forma segura
/// Usa flutter_secure_storage para tokens y SharedPreferences para isEmailVerified
class TokenManager {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _isEmailVerifiedKey = 'is_email_verified';
  static const String _userEmailKey = 'user_email';

  TokenManager({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  }) : _secureStorage = secureStorage,
       _prefs = prefs;

  /// Guarda los tokens y el estado de verificación de email
  Future<void> saveToken(
    String accessToken,
    String refreshToken, {
    bool isEmailVerified = false,
    String? email,
  }) async {
    try {
      await Future.wait([
        _secureStorage.write(key: _accessTokenKey, value: accessToken),
        _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
        _prefs.setBool(_isEmailVerifiedKey, isEmailVerified),
        if (email != null) _prefs.setString(_userEmailKey, email),
      ]);

      // Verificar que se guardó correctamente
      final savedAccess = await _secureStorage.read(key: _accessTokenKey);
      final savedRefresh = await _secureStorage.read(key: _refreshTokenKey);
      debugPrint(
        'TokenManager.saveToken: ✅ Access token guardado: ${savedAccess != null}, Refresh token guardado: ${savedRefresh != null}',
      );
    } catch (e) {
      debugPrint('TokenManager: Error en saveToken, usando fallback: $e');
      // Fallback a SharedPreferences
      await Future.wait([
        _prefs.setString(_accessTokenKey, accessToken),
        _prefs.setString(_refreshTokenKey, refreshToken),
        _prefs.setBool(_isEmailVerifiedKey, isEmailVerified),
        if (email != null) _prefs.setString(_userEmailKey, email),
      ]);
      debugPrint('TokenManager.saveToken: ✅ Guardado en fallback (SharedPreferences)');
    }
  }

  /// Obtiene el access token
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: _accessTokenKey);
    } catch (e) {
      // Fallback a SharedPreferences si flutter_secure_storage falla
      return _prefs.getString(_accessTokenKey);
    }
  }

  /// Obtiene el refresh token
  Future<String?> getResfreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      // Fallback a SharedPreferences si flutter_secure_storage falla
      return _prefs.getString(_refreshTokenKey);
    }
  }

  /// Verifica si el email está verificado
  Future<bool?> getIsEmailVerified() async {
    final value = _prefs.getBool(_isEmailVerifiedKey);
    debugPrint(
      'TokenManager: getIsEmailVerified = $value (tipo: ${value.runtimeType})',
    );
    return value;
  }

  /// Obtiene el email del usuario
  Future<String?> getUserEmail() async {
    return _prefs.getString(_userEmailKey);
  }

  /// Actualiza el access token
  Future<void> updateAccess(String accessToken) async {
    try {
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    } catch (e) {
      // Fallback a SharedPreferences si flutter_secure_storage falla
      await _prefs.setString(_accessTokenKey, accessToken);
    }
  }

  /// Actualiza el estado de verificación de email
  Future<void> updateEmailVerification(bool isVerified) async {
    await _prefs.setBool(_isEmailVerifiedKey, isVerified);
  }

  /// Verifica si existe un token
  Future<bool> hasToken() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// Elimina todos los tokens y datos de autenticación
  Future<void> deleteToken() async {
    try {
      // Eliminar de FlutterSecureStorage
      await Future.wait([
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
      ]);
      
      // Eliminar de SharedPreferences
      await Future.wait([
        _prefs.remove(_accessTokenKey),
        _prefs.remove(_refreshTokenKey),
        _prefs.remove(_isEmailVerifiedKey),
        _prefs.remove(_userEmailKey),
      ]);
      
      // Verificar que se eliminaron correctamente
      final accessToken = await getAccessToken();
      final refreshToken = await getResfreshToken();
      
      debugPrint(
        'TokenManager: Tokens eliminados. Verificación - accessToken: ${accessToken == null ? "null" : "existe"}, refreshToken: ${refreshToken == null ? "null" : "existe"}',
      );
      
      if (accessToken != null || refreshToken != null) {
        debugPrint('TokenManager: ADVERTENCIA - Algunos tokens no se eliminaron correctamente');
      }
    } catch (e) {
      debugPrint('TokenManager: Error eliminando tokens, usando fallback: $e');
      // Si flutter_secure_storage falla, eliminar de SharedPreferences
      await Future.wait([
        _prefs.remove(_accessTokenKey),
        _prefs.remove(_refreshTokenKey),
        _prefs.remove(_isEmailVerifiedKey),
        _prefs.remove(_userEmailKey),
      ]);
      
      // Verificar que se eliminaron correctamente
      final accessToken = await getAccessToken();
      final refreshToken = await getResfreshToken();
      
      debugPrint(
        'TokenManager: Tokens eliminados usando fallback. Verificación - accessToken: ${accessToken == null ? "null" : "existe"}, refreshToken: ${refreshToken == null ? "null" : "existe"}',
      );
    }
  }
}
