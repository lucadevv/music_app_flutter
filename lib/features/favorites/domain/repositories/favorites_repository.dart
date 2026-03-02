import 'package:dartz/dartz.dart';
import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';

/// Repository interface for Favorites feature.
abstract class FavoritesRepository {
  /// Get all favorite songs with pagination
  Future<Either<AppException, List<Song>>> getFavorites({
    int page = 1,
    int limit = 20,
  });

  /// Add a song to favorites
  Future<Either<AppException, void>> addFavorite(Song song);

  /// Remove a song from favorites
  Future<Either<AppException, void>> removeFavorite(String videoId);

  /// Check if a song is favorite
  Future<Either<AppException, bool>> isFavorite(String videoId);
}
