import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/profile/domain/repositories/profile_repository.dart';

/// Use case for logging out the current user.
class LogoutUseCase {
  final ProfileRepository _repository;

  LogoutUseCase(this._repository);

  Future<Either<AppException, void>> call() {
    return _repository.logout();
  }
}
