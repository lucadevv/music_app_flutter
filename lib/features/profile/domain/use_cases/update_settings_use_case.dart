import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/profile/domain/entities/user_settings_entity.dart';
import 'package:music_app/features/profile/domain/repositories/profile_repository.dart';

/// Use case for updating user settings.
class UpdateSettingsUseCase {
  final ProfileRepository _repository;

  UpdateSettingsUseCase(this._repository);

  Future<Either<AppException, UserSettingsEntity>> call(
    UserSettingsEntity settings,
  ) {
    return _repository.updateSettings(settings);
  }
}
