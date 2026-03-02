import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/profile/domain/entities/user_profile_entity.dart';
import 'package:music_app/features/profile/domain/repositories/profile_repository.dart';

/// Use case for getting the current user's profile.
class GetProfileUseCase {
  final ProfileRepository _repository;

  GetProfileUseCase(this._repository);

  Future<Either<AppException, UserProfileEntity>> call() {
    return _repository.getProfile();
  }
}
