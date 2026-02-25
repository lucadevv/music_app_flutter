import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../../domain/entities/register_request.dart';
import '../../domain/entities/register_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../login/domain/entities/login_request.dart';
import '../../../refresh_token/domain/entities/refresh_token_request.dart';
import '../../../refresh_token/domain/entities/refresh_token_response.dart';
import '../data_sources/auth_remote_data_source.dart';

/// Implementación del repositorio de autenticación
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, RegisterResponse>> register(
    RegisterRequest request,
  ) async {
    return await _remoteDataSource.register(request);
  }

  @override
  Future<Either<AppException, RegisterResponse>> login(
    LoginRequest request,
  ) async {
    return await _remoteDataSource.login(request);
  }

  @override
  Future<Either<AppException, RefreshTokenResponse>> refreshToken(
    RefreshTokenRequest request,
  ) async {
    return await _remoteDataSource.refreshToken(request);
  }
}
