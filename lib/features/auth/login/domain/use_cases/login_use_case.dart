import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/auth/register/domain/entities/register_response.dart';
import 'package:music_app/features/auth/register/domain/repositories/auth_repository.dart';

import '../entities/login_request.dart';

/// Caso de uso para iniciar sesión
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Ejecuta el login con email y contraseña
  Future<Either<AppException, RegisterResponse>> call(
    LoginRequest request,
  ) async {
    return _repository.login(request);
  }
}
