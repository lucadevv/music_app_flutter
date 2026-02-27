import 'dart:async';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/core/managers/auth/storage/token_manager.dart';

class AuthManagerImpl implements AuthManager {
  final TokenManager _tokenManager;
  final _authStatusController = StreamController<AuthStatus>.broadcast();

  AuthManagerImpl(this._tokenManager);

  @override
  Future<bool> isUserLoggedIn() async {
    return await _tokenManager.hasToken();
  }

  @override
  Future<void> login(
    String accessToken,
    String refreshToken, {
    bool isEmailVerified = false,
    String? email,
  }) async {
    await _tokenManager.saveToken(
      accessToken,
      refreshToken,
      isEmailVerified: isEmailVerified,
      email: email,
    );
    _authStatusController.add(AuthStatus.authenticated);
  }

  @override
  Future<void> newAccess(String accessToken) async {
    await _tokenManager.updateAccess(accessToken);
    _authStatusController.add(AuthStatus.authenticated);
  }

  @override
  Future<void> refreshTokens(
    String accessToken,
    String refreshToken, {
    bool isEmailVerified = false,
  }) async {
    // Obtener el email actual para mantenerlo
    final currentEmail = await _tokenManager.getUserEmail();
    await _tokenManager.saveToken(
      accessToken,
      refreshToken,
      isEmailVerified: isEmailVerified,
      email: currentEmail,
    );
    _authStatusController.add(AuthStatus.authenticated);
  }

  @override
  Future<void> updateEmailVerification(bool isVerified) async {
    await _tokenManager.updateEmailVerification(isVerified);
  }

  @override
  Future<void> logout() async {
    await _tokenManager.deleteToken();
    _authStatusController.add(AuthStatus.unauthenticated);
  }

  @override
  Future<void> handleAuthError() async {
    await logout();
    _authStatusController.add(AuthStatus.expired);
  }

  @override
  Future<String?> getCurrentAccessToken() async {
    return await _tokenManager.getAccessToken();
  }

  @override
  Future<String?> getCurrentRefreshToken() async {
    return await _tokenManager.getResfreshToken();
  }

  @override
  Future<bool?> isEmailVerified() async {
    return await _tokenManager.getIsEmailVerified();
  }

  @override
  Future<String?> getCurrentUserEmail() async {
    return await _tokenManager.getUserEmail();
  }

  @override
  Stream<AuthStatus> get authStatusStream => _authStatusController.stream;

  /// Libera recursos
  void dispose() {
    _authStatusController.close();
  }
}
