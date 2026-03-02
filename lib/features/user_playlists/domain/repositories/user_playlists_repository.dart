import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/user_playlists/domain/entities/user_playlist_entity.dart';

/// Repository interface for user playlists operations.
abstract class UserPlaylistsRepository {
  /// Get all user playlists (user + favorites)
  Future<Either<AppException, List<UserPlaylistEntity>>> getAllPlaylists();

  /// Get user playlists only
  Future<Either<AppException, List<UserPlaylistEntity>>> getUserPlaylists();

  /// Create a new playlist
  Future<Either<AppException, UserPlaylistEntity>> createPlaylist(String name);

  /// Delete a playlist
  Future<Either<AppException, void>> deletePlaylist(String id);
}
