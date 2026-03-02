import 'package:dartz/dartz.dart';
import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/favorites/domain/repositories/favorites_repository.dart';

/// Use case for getting favorite songs
class GetFavoritesUseCase {
  final FavoritesRepository repository;

  GetFavoritesUseCase(this.repository);

  Future<Either<AppException, List<Song>>> call({
    int page = 1,
    int limit = 20,
  }) {
    return repository.getFavorites(page: page, limit: limit);
  }
}

/// Use case for adding a song to favorites
class AddFavoriteUseCase {
  final FavoritesRepository repository;

  AddFavoriteUseCase(this.repository);

  Future<Either<AppException, void>> call(Song song) {
    return repository.addFavorite(song);
  }
}

/// Use case for removing a song from favorites
class RemoveFavoriteUseCase {
  final FavoritesRepository repository;

  RemoveFavoriteUseCase(this.repository);

  Future<Either<AppException, void>> call(String videoId) {
    return repository.removeFavorite(videoId);
  }
}

/// Use case for checking if a song is favorite
class IsFavoriteUseCase {
  final FavoritesRepository repository;

  IsFavoriteUseCase(this.repository);

  Future<Either<AppException, bool>> call(String videoId) {
    return repository.isFavorite(videoId);
  }
}
