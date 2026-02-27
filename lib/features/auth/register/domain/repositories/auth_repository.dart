import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/auth/login/domain/entities/login_request.dart';
import 'package:music_app/features/auth/refresh_token/domain/entities/refresh_token_request.dart';
import 'package:music_app/features/auth/refresh_token/domain/entities/refresh_token_response.dart';

import '../entities/register_request.dart';
import '../entities/register_response.dart';
import '../../../data/models/oauth_request.dart';

/// Interfaz del repositorio de autenticación
/// Define el contrato que debe cumplir cualquier implementación
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
