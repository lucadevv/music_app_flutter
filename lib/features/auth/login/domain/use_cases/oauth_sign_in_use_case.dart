import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/auth/data/services/oauth_service.dart';
import 'package:music_app/features/auth/register/domain/repositories/auth_repository.dart';
import '../../../data/models/oauth_request.dart';

/// Caso de uso para iniciar sesión con Google
class GoogleSignInUseCase {
  final AuthRepository _repository;
  final OAuthService _oauthService;

  GoogleSignInUseCase(this._repository, this._oauthService);

  /// Ejecuta el flujo de autenticación con Google
  Future<Either<AppException, OAuthResponse>> call() async {
    // 1. Obtener credenciales de Google
    final oauthResult = await _oauthService.signInWithGoogle();

    if (oauthResult == null) {
      return Left(AppException.cancelled('Sign in cancelled'));
    }

    // 2. Enviar al backend para validación
    final request = OAuthRequest(
      provider: 'google',
      accessToken: oauthResult.accessToken,
      idToken: oauthResult.idToken,
      email: oauthResult.email,
      name: oauthResult.name,
    );

    return _repository.signInWithGoogle(request);
  }
}

/// Caso de uso para iniciar sesión con Apple
class AppleSignInUseCase {
  final AuthRepository _repository;
  final OAuthService _oauthService;

  AppleSignInUseCase(this._repository, this._oauthService);

  /// Ejecuta el flujo de autenticación con Apple
  Future<Either<AppException, OAuthResponse>> call() async {
    // 1. Obtener credenciales de Apple
    final oauthResult = await _oauthService.signInWithApple();

    if (oauthResult == null) {
      return Left(AppException.cancelled('Sign in cancelled'));
    }

    // 2. Enviar al backend para validación
    final request = OAuthRequest(
      provider: 'apple',
      accessToken: oauthResult.accessToken,
      idToken: oauthResult.idToken,
      email: oauthResult.email,
      name: oauthResult.name,
    );

    return _repository.signInWithApple(request);
  }
}
