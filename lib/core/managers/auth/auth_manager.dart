/// Manager abstracto para manejar la autenticación
abstract class AuthManager {
  /// Verifica si el usuario está logueado
  Future<bool> isUserLoggedIn();

  /// Realiza login con access y refresh token
  /// [isEmailVerified] indica si el email está verificado
  Future<void> login(
    String accessToken,
    String refreshToken, {
    bool isEmailVerified = false,
    String? email,
  });

  /// Actualiza el access token
  Future<void> newAccess(String accessToken);

  /// Refresca los tokens (access y refresh)
  Future<void> refreshTokens(
    String accessToken,
    String refreshToken, {
    bool isEmailVerified = false,
  });

  /// Actualiza el estado de verificación de email
  Future<void> updateEmailVerification(bool isVerified);

  /// Cierra sesión
  Future<void> logout();

  /// Maneja errores de autenticación
  Future<void> handleAuthError();

  /// Obtiene el access token actual
  Future<String?> getCurrentAccessToken();

  /// Obtiene el refresh token actual
  Future<String?> getCurrentRefreshToken();

  /// Verifica si el email está verificado
  Future<bool?> isEmailVerified();

  /// Obtiene el email del usuario actual
  Future<String?> getCurrentUserEmail();

  /// Stream de cambios en el estado de autenticación
  Stream<AuthStatus> get authStatusStream;
}

/// Estados de autenticación
enum AuthStatus { authenticated, unauthenticated, expired }
