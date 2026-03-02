import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/auth/data/models/oauth_request.dart';
import 'package:music_app/features/auth/login/domain/entities/login_request.dart';
import 'package:music_app/features/auth/refresh_token/domain/entities/refresh_token_request.dart';
import 'package:music_app/features/auth/refresh_token/domain/entities/refresh_token_response.dart';
import '../../domain/entities/register_request.dart';
import '../../domain/entities/register_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

/// Implementación del repositorio de autenticación
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, RegisterResponse>> register(
    RegisterRequest request,
  ) async {
    return _remoteDataSource.register(request);
  }

  @override
  Future<Either<AppException, RegisterResponse>> login(
    LoginRequest request,
  ) async {
    return _remoteDataSource.login(request);
  }

  @override
  Future<Either<AppException, RefreshTokenResponse>> refreshToken(
    RefreshTokenRequest request,
  ) async {
    return _remoteDataSource.refreshToken(request);
  }

  @override
  Future<Either<AppException, OAuthResponse>> signInWithGoogle(
    OAuthRequest request,
  ) async {
    return _remoteDataSource.signInWithGoogle(request);
  }

  @override
  Future<Either<AppException, OAuthResponse>> signInWithApple(
    OAuthRequest request,
  ) async {
    return _remoteDataSource.signInWithApple(request);
  }
}
