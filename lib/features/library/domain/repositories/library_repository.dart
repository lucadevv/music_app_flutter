import 'package:dartz/dartz.dart';
import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/data/models/library_models.dart';
import 'package:music_app/features/library/domain/entities/library_entities.dart';

export 'package:music_app/features/library/domain/entities/library_entities.dart';

/// Repository interface for Library feature.
/// Follows Clean Architecture principles - defines contract without dependencies.
abstract class LibraryRepository {
  /// Get library summary
  Future<Either<AppException, LibrarySummaryEntity>> getSummary();

  /// Get favorite songs with pagination
  Future<Either<AppException, List<Song>>> getFavoriteSongs({
    int page = 1,
    int limit = 10,
  });

  /// Get favorite playlists
  Future<Either<AppException, List<FavoritePlaylistEntity>>>
  getFavoritePlaylists({int page = 1, int limit = 10});

  /// Get favorite genres
  Future<Either<AppException, List<FavoriteGenreEntity>>> getFavoriteGenres({
    int page = 1,
    int limit = 10,
  });

  /// Add song to favorites
  Future<Either<AppException, void>> addFavoriteSong(Song song);

  /// Remove song from favorites
  Future<Either<AppException, void>> removeFavoriteSong(String videoId);

  /// Check if song is favorite
  Future<Either<AppException, bool>> isFavorite(String videoId);

  /// Create user playlist
  Future<Either<AppException, UserPlaylist>> createUserPlaylist({
    required String name,
    String? description,
    String? thumbnail,
    bool isPublic = false,
  });

  /// Add song to user playlist
  /// Returns the updated playlist with the new song
  Future<Either<AppException, UserPlaylistDetail>> addSongToUserPlaylist(
    String playlistId, {
    required String videoId,
    String? title,
    String? artist,
    String? thumbnail,
    int? duration,
  });

  /// Remove song from user playlist
  Future<Either<AppException, void>> removeSongFromUserPlaylist(
    String playlistId,
    String songId,
  );

  /// Get user playlists (playlists created by the user)
  Future<Either<AppException, List<UserPlaylist>>> getUserPlaylists({
    int page = 1,
    int limit = 10,
  });

  /// Add playlist to favorites
  Future<Either<AppException, void>> addFavoritePlaylist(
    String externalPlaylistId, {
    String? name,
    String? thumbnail,
    String? description,
    int? trackCount,
  });

  /// Remove playlist from favorites
  Future<Either<AppException, void>> removeFavoritePlaylist(String playlistId);

  /// Add genre to favorites
  Future<Either<AppException, void>> addFavoriteGenre(
    String externalParams, {
    String? name,
  });

  /// Remove genre from favorites
  Future<Either<AppException, void>> removeFavoriteGenre(String genreId);

  /// Get favorite songs with mapping (videoId -> songId) for proper removal
  /// This method is used by FavoriteCubit to maintain the mapping needed
  Future<Either<AppException, FavoriteSongsWithMapping>>
  getFavoriteSongsWithMapping({int page = 1, int limit = 10});

  /// Get favorite playlists with external IDs for proper removal
  Future<Either<AppException, List<FavoritePlaylistEntity>>>
  getFavoritePlaylistsWithMapping({int page = 1, int limit = 10});

  /// Get favorite genres with external params for proper removal
  Future<Either<AppException, List<FavoriteGenreEntity>>>
  getFavoriteGenresWithMapping({int page = 1, int limit = 10});

  /// Get user playlist by ID
  Future<Either<AppException, UserPlaylistDetail>> getUserPlaylist(
    String playlistId,
  );

  /// Update user playlist
  Future<Either<AppException, UserPlaylistDetail>> updateUserPlaylist(
    String playlistId, {
    String? name,
    String? description,
    String? thumbnail,
    bool? isPublic,
  });

  /// Delete user playlist
  Future<Either<AppException, void>> deleteUserPlaylist(String playlistId);
}
