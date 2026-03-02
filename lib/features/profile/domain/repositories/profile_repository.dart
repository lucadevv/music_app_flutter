import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/profile/domain/entities/entities.dart';

/// Repository interface for profile operations.
/// Defines the contract between domain and data layers.
abstract class ProfileRepository {
  /// Get the current user's profile
  Future<Either<AppException, UserProfileEntity>> getProfile();

  /// Update the current user's profile
  Future<Either<AppException, UserProfileEntity>> updateProfile({
    String? name,
    String? email,
    String? avatar,
  });

  /// Get user settings
  Future<Either<AppException, UserSettingsEntity>> getSettings();

  /// Update user settings
  Future<Either<AppException, UserSettingsEntity>> updateSettings(
    UserSettingsEntity settings,
  );

  /// Get library statistics (favorite songs, playlists, genres count)
  Future<Either<AppException, LibraryStatsEntity>> getLibraryStats();

  /// Logout the current user
  Future<Either<AppException, void>> logout();
}
