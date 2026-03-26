import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';

import '../entities/refresh_token_request.dart';
import '../entities/refresh_token_response.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para refrescar el access token
class RefreshTokenUseCase {
  final AuthRepository _repository;

  RefreshTokenUseCase(this._repository);

  /// Ejecuta el refresh del token
  Future<Either<AppException, RefreshTokenResponse>> call(
    RefreshTokenRequest request,
  ) async {
    return _repository.refreshToken(request);
  }
}
