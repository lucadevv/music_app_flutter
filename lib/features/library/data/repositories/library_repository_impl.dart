import 'package:dartz/dartz.dart';
import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/core/domain/mappers/song_mapper.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/data/datasources/library_remote_data_source.dart';
import 'package:music_app/features/library/domain/entities/library_entities.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';
import 'package:music_app/features/library/library_service.dart';

/// Implementation of LibraryRepository.
/// Handles data mapping between API responses and domain entities.
class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource _remoteDataSource;

  LibraryRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, LibrarySummaryEntity>> getSummary() async {
    try {
      final data = await _remoteDataSource.getSummary();
      return Right(
        LibrarySummaryEntity(
          favoriteSongsCount: data['favoriteSongsCount'] ?? 0,
          favoritePlaylistsCount: data['favoritePlaylistsCount'] ?? 0,
          favoriteGenresCount: data['favoriteGenresCount'] ?? 0,
        ),
      );
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<Song>>> getFavoriteSongs({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final data = await _remoteDataSource.getFavoriteSongs(
        page: page,
        limit: limit,
      );
      final response = FavoriteSongsResponse.fromJson(data);
      final songs = response.data
          .map((s) => SongMapper.fromFavoriteSong(s))
          .toList();
      return Right(songs);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<FavoritePlaylistEntity>>>
  getFavoritePlaylists({int page = 1, int limit = 20}) async {
    try {
      final data = await _remoteDataSource.getFavoritePlaylists(
        page: page,
        limit: limit,
      );
      final response = FavoritePlaylistsResponse.fromJson(data);
      final playlists = response.data
          .map(
            (p) => FavoritePlaylistEntity(
              id: p.playlistId,
              name: p.name,
              thumbnail: p.thumbnail,
              description: p.description,
              trackCount: p.trackCount,
            ),
          )
          .toList();
      return Right(playlists);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<FavoriteGenreEntity>>> getFavoriteGenres({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final data = await _remoteDataSource.getFavoriteGenres(
        page: page,
        limit: limit,
      );
      final response = FavoriteGenresResponse.fromJson(data);
      final genres = response.data
          .map(
            (g) => FavoriteGenreEntity(
              id: g.genreId,
              name: g.name,
              params: g.externalParams,
            ),
          )
          .toList();
      return Right(genres);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> addFavoriteSong(Song song) async {
    try {
      await _remoteDataSource.addFavoriteSong(
        videoId: song.videoId,
        title: song.title,
        artist: song.artist,
        thumbnail: song.thumbnail,
        duration: song.durationSeconds,
      );
      return const Right(null);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> removeFavoriteSong(String videoId) async {
    try {
      await _remoteDataSource.removeFavoriteSong(videoId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, bool>> isFavorite(String videoId) async {
    try {
      final result = await _remoteDataSource.isSongFavorite(videoId);
      return Right(result);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }
}
