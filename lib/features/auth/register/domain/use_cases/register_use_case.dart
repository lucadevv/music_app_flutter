import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';

import '../entities/register_request.dart';
import '../entities/register_response.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para registrar un nuevo usuario
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  /// Ejecuta el registro de un nuevo usuario
  Future<Either<AppException, RegisterResponse>> call(
    RegisterRequest request,
  ) async {
    return _repository.register(request);
  }
}
