import 'package:dartz/dartz.dart';
import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/core/utils/exeptions/app_exception.dart';
import 'package:music_app/features/library/domain/entities/library_entities.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case for getting library summary
class GetLibrarySummaryUseCase {
  final LibraryRepository repository;

  GetLibrarySummaryUseCase(this.repository);

  Future<Either<AppException, LibrarySummaryEntity>> call() {
    return repository.getSummary();
  }
}

/// Use case for getting favorite songs
class GetFavoriteSongsUseCase {
  final LibraryRepository repository;

  GetFavoriteSongsUseCase(this.repository);

  Future<Either<AppException, List<Song>>> call({int page = 1, int limit = 20}) {
    return repository.getFavoriteSongs(page: page, limit: limit);
  }
}

/// Use case for getting favorite playlists
class GetFavoritePlaylistsUseCase {
  final LibraryRepository repository;

  GetFavoritePlaylistsUseCase(this.repository);

  Future<Either<AppException, List<FavoritePlaylistEntity>>> call({int page = 1, int limit = 20}) {
    return repository.getFavoritePlaylists(page: page, limit: limit);
  }
}

/// Use case for getting favorite genres
class GetFavoriteGenresUseCase {
  final LibraryRepository repository;

  GetFavoriteGenresUseCase(this.repository);

  Future<Either<AppException, List<FavoriteGenreEntity>>> call({int page = 1, int limit = 20}) {
    return repository.getFavoriteGenres(page: page, limit: limit);
  }
}

/// Use case for adding a song to favorites
class AddFavoriteSongUseCase {
  final LibraryRepository repository;

  AddFavoriteSongUseCase(this.repository);

  Future<Either<AppException, void>> call(Song song) {
    return repository.addFavoriteSong(song);
  }
}

/// Use case for removing a song from favorites
class RemoveFavoriteSongUseCase {
  final LibraryRepository repository;

  RemoveFavoriteSongUseCase(this.repository);

  Future<Either<AppException, void>> call(String videoId) {
    return repository.removeFavoriteSong(videoId);
  }
}

/// Use case for checking if a song is favorite
class IsFavoriteSongUseCase {
  final LibraryRepository repository;

  IsFavoriteSongUseCase(this.repository);

  Future<Either<AppException, bool>> call(String videoId) {
    return repository.isFavorite(videoId);
  }
}
