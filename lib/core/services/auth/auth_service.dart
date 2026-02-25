import 'package:flutter/foundation.dart';
import 'package:music_app/core/services/local/local_storage_service.dart';

/// Servicio para manejar la autenticación y almacenamiento de tokens
class AuthService {
  final LocalStorageService _localStorage;
  
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _isEmailVerifiedKey = 'is_email_verified';
  static const String _userEmailKey = 'user_email';

  AuthService(this._localStorage);

  /// Guarda los tokens y el estado de verificación de email
  Future<bool> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required bool isEmailVerified,
    String? email,
  }) async {
    try {
      final results = await Future.wait([
        _localStorage.setString(_accessTokenKey, accessToken),
        _localStorage.setString(_refreshTokenKey, refreshToken),
        _localStorage.setBool(_isEmailVerifiedKey, isEmailVerified),
        if (email != null) _localStorage.setString(_userEmailKey, email),
      ]);
      return results.every((result) => result == true);
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el access token
  Future<String?> getAccessToken() async {
    return await _localStorage.getString(_accessTokenKey);
  }

  /// Obtiene el refresh token
  Future<String?> getRefreshToken() async {
    return await _localStorage.getString(_refreshTokenKey);
  }

  /// Verifica si el email está verificado
  Future<bool?> isEmailVerified() async {
    return await _localStorage.getBool(_isEmailVerifiedKey);
  }

  /// Obtiene el email del usuario
  Future<String?> getUserEmail() async {
    return await _localStorage.getString(_userEmailKey);
  }

  /// Actualiza el estado de verificación de email
  Future<bool> updateEmailVerificationStatus(bool isVerified) async {
    return await _localStorage.setBool(_isEmailVerifiedKey, isVerified);
  }

  /// Elimina todos los tokens y datos de autenticación
  Future<bool> clearAuthData() async {
    try {
      final results = await Future.wait([
        _localStorage.remove(_accessTokenKey),
        _localStorage.remove(_refreshTokenKey),
        _localStorage.remove(_isEmailVerifiedKey),
        _localStorage.remove(_userEmailKey),
      ]);
      final success = results.every((result) => result == true);
      if (success) {
        debugPrint('AuthService: Datos de autenticación eliminados correctamente de LocalStorageService');
      } else {
        debugPrint('AuthService: Algunos datos no se pudieron eliminar');
      }
      return success;
    } catch (e) {
      debugPrint('AuthService: Error eliminando datos de autenticación: $e');
      return false;
    }
  }

  /// Verifica si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}
