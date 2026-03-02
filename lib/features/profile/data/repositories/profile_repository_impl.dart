import 'package:dartz/dartz.dart';
import 'package:music_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:music_app/features/profile/data/models/user_settings_model.dart';
import 'package:music_app/features/profile/domain/entities/entities.dart';
import 'package:music_app/features/profile/domain/entities/library_stats_entity.dart';
import 'package:music_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';

/// Implementation of ProfileRepository.
/// Handles data operations and maps between data and domain layers.
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, UserProfileEntity>> getProfile() async {
    try {
      final model = await _remoteDataSource.getProfile();
      return Right(model.toEntity());
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, UserProfileEntity>> updateProfile({
    String? name,
    String? email,
    String? avatar,
  }) async {
    try {
      final model = await _remoteDataSource.updateProfile(
        name: name,
        email: email,
        avatar: avatar,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, UserSettingsEntity>> getSettings() async {
    try {
      final model = await _remoteDataSource.getSettings();
      return Right(model.toEntity());
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, UserSettingsEntity>> updateSettings(
    UserSettingsEntity settings,
  ) async {
    try {
      final model = UserSettingsModel.fromEntity(settings);
      final result = await _remoteDataSource.updateSettings(model);
      return Right(result.toEntity());
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, LibraryStatsEntity>> getLibraryStats() async {
    try {
      final model = await _remoteDataSource.getLibraryStats();
      return Right(model.toEntity());
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }
}
