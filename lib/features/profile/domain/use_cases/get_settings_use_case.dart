import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/profile/domain/entities/user_settings_entity.dart';
import 'package:music_app/features/profile/domain/repositories/profile_repository.dart';

/// Use case for getting user settings.
class GetSettingsUseCase {
  final ProfileRepository _repository;

  GetSettingsUseCase(this._repository);

  Future<Either<AppException, UserSettingsEntity>> call() {
    return _repository.getSettings();
  }
}
