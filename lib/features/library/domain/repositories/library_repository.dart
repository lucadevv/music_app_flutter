import 'package:dartz/dartz.dart';
import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/core/utils/exeptions/app_exception.dart';
import 'package:music_app/features/library/domain/entities/library_entities.dart';

/// Repository interface for Library feature.
/// Follows Clean Architecture principles - defines contract without dependencies.
abstract class LibraryRepository {
  /// Get library summary
  Future<Either<AppException, LibrarySummaryEntity>> getSummary();

  /// Get favorite songs with pagination
  Future<Either<AppException, List<Song>>> getFavoriteSongs({int page = 1, int limit = 20});

  /// Get favorite playlists
  Future<Either<AppException, List<FavoritePlaylistEntity>>> getFavoritePlaylists({int page = 1, int limit = 20});

  /// Get favorite genres
  Future<Either<AppException, List<FavoriteGenreEntity>>> getFavoriteGenres({int page = 1, int limit = 20});

  /// Add song to favorites
  Future<Either<AppException, void>> addFavoriteSong(Song song);

  /// Remove song from favorites
  Future<Either<AppException, void>> removeFavoriteSong(String videoId);

  /// Check if song is favorite
  Future<Either<AppException, bool>> isFavorite(String videoId);
}
