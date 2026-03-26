import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';

import '../entities/login_request.dart';
import '../entities/register_response.dart';
import '../repositories/auth_repository.dart';

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
