import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/profile/domain/entities/user_profile_entity.dart';
import 'package:music_app/features/profile/domain/repositories/profile_repository.dart';

/// Parameters for updating user profile.
class UpdateProfileParams {
  final String? name;
  final String? email;
  final String? avatar;

  const UpdateProfileParams({this.name, this.email, this.avatar});
}

/// Use case for updating the current user's profile.
class UpdateProfileUseCase {
  final ProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<AppException, UserProfileEntity>> call(
    UpdateProfileParams params,
  ) {
    return _repository.updateProfile(
      name: params.name,
      email: params.email,
      avatar: params.avatar,
    );
  }
}
