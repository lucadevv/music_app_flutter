import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/auth/data/models/oauth_request.dart';
import 'package:music_app/features/auth/domain/entities/login_request.dart';
import 'package:music_app/features/auth/domain/entities/refresh_token_request.dart';
import 'package:music_app/features/auth/domain/entities/refresh_token_response.dart';

import '../../../auth/domain/entities/register_request.dart';
import '../../../auth/domain/entities/register_response.dart';

/// Interfaz unificada del repositorio de autenticación
/// Define el contrato estricto devolviendo Either `[AppException, T]`
abstract class AuthRepository {
  /// Registra un nuevo usuario
  Future<Either<AppException, RegisterResponse>> register(
    RegisterRequest request,
  );

  /// Inicia sesión con email y contraseña
  Future<Either<AppException, RegisterResponse>> login(LoginRequest request);

  /// Refresca el access token usando el refresh token
  Future<Either<AppException, RefreshTokenResponse>> refreshToken(
    RefreshTokenRequest request,
  );

  /// Inicia sesión con Google OAuth
  Future<Either<AppException, OAuthResponse>> signInWithGoogle(
    OAuthRequest request,
  );

  /// Inicia sesión con Apple OAuth
  Future<Either<AppException, OAuthResponse>> signInWithApple(
    OAuthRequest request,
  );
}
