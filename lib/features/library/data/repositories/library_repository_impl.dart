import 'package:dartz/dartz.dart';
import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/core/domain/mappers/song_mapper.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/data/datasources/library_remote_data_source.dart';
import 'package:music_app/features/library/data/models/library_models.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Implementation of LibraryRepository.
/// Handles data mapping between API responses (DTOs) and domain entities.
class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource _remoteDataSource;

  LibraryRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, LibrarySummaryEntity>> getSummary() async {
    try {
      final data = await _remoteDataSource.getSummary();
      return Right(
        LibrarySummaryEntity(
          favoriteSongsCount: data.favoriteSongs,
          favoritePlaylistsCount: data.favoritePlaylists,
          favoriteGenresCount: data.favoriteGenres,
        ),
      );
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<Song>>> getFavoriteSongs({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _remoteDataSource.getFavoriteSongs(
        page: page,
        limit: limit,
      );
      final songs = response.data.map(SongMapper.fromFavoriteSong).toList();
      return Right(songs);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<FavoritePlaylistEntity>>>
  getFavoritePlaylists({int page = 1, int limit = 10}) async {
    try {
      final response = await _remoteDataSource.getFavoritePlaylists(
        page: page,
        limit: limit,
      );
      final playlists = response.data
          .map(
            (p) => FavoritePlaylistEntity(
              id: p.id,
              externalPlaylistId: p.externalPlaylistId,
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
    int limit = 10,
  }) async {
    try {
      final response = await _remoteDataSource.getFavoriteGenres(
        page: page,
        limit: limit,
      );
      final genres = response.data
          .map(
            (g) => FavoriteGenreEntity(
              id: g.id,
              externalParams: g.externalParams,
              name: g.name,
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

  @override
  Future<Either<AppException, UserPlaylist>> createUserPlaylist({
    required String name,
    String? description,
    String? thumbnail,
    bool isPublic = false,
  }) async {
    try {
      final userPlaylist = await _remoteDataSource.createUserPlaylist(
        name: name,
        description: description,
        thumbnail: thumbnail,
        isPublic: isPublic,
      );
      return Right(userPlaylist);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, UserPlaylistDetail>> addSongToUserPlaylist(
    String playlistId, {
    required String videoId,
    String? title,
    String? artist,
    String? thumbnail,
    int? duration,
  }) async {
    try {
      final userPlaylist = await _remoteDataSource.addSongToUserPlaylist(
        playlistId,
        videoId: videoId,
        title: title,
        artist: artist,
        thumbnail: thumbnail,
        duration: duration,
      );
      return Right(userPlaylist);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> removeSongFromUserPlaylist(
    String playlistId,
    String songId,
  ) async {
    try {
      await _remoteDataSource.removeSongFromUserPlaylist(playlistId, songId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<UserPlaylist>>> getUserPlaylists({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _remoteDataSource.getUserPlaylists(
        page: page,
        limit: limit,
      );
      return Right(response.data);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> addFavoritePlaylist(
    String externalPlaylistId, {
    String? name,
    String? thumbnail,
    String? description,
    int? trackCount,
  }) async {
    try {
      await _remoteDataSource.addFavoritePlaylist(
        externalPlaylistId,
        name: name,
        thumbnail: thumbnail,
        description: description,
        trackCount: trackCount,
      );
      return const Right(null);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> removeFavoritePlaylist(
    String playlistId,
  ) async {
    try {
      await _remoteDataSource.removeFavoritePlaylist(playlistId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> addFavoriteGenre(
    String externalParams, {
    String? name,
  }) async {
    try {
      await _remoteDataSource.addFavoriteGenre(externalParams, name: name);
      return const Right(null);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> removeFavoriteGenre(String genreId) async {
    try {
      await _remoteDataSource.removeFavoriteGenre(genreId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, FavoriteSongsWithMapping>>
  getFavoriteSongsWithMapping({int page = 1, int limit = 10}) async {
    try {
      final response = await _remoteDataSource.getFavoriteSongs(
        page: page,
        limit: limit,
      );

      // Build mapping videoId -> songId
      final songIdByVideoId = <String, String>{};
      final songs = <FavoriteSongEntity>[];

      for (final song in response.data) {
        songIdByVideoId[song.videoId] = song.songId;
        songs.add(
          FavoriteSongEntity(
            videoId: song.videoId,
            songId: song.songId,
            title: song.title,
            artist: song.artist,
            thumbnail: song.thumbnail,
            duration: song.duration,
            addedAt: song.createdAt,
          ),
        );
      }

      return Right(
        FavoriteSongsWithMapping(
          songs: songs,
          songIdByVideoId: songIdByVideoId,
        ),
      );
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<FavoritePlaylistEntity>>>
  getFavoritePlaylistsWithMapping({int page = 1, int limit = 10}) async {
    try {
      final response = await _remoteDataSource.getFavoritePlaylists(
        page: page,
        limit: limit,
      );
      final playlists = response.data
          .map(
            (p) => FavoritePlaylistEntity(
              id: p.id,
              externalPlaylistId: p.externalPlaylistId,
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
  Future<Either<AppException, List<FavoriteGenreEntity>>>
  getFavoriteGenresWithMapping({int page = 1, int limit = 10}) async {
    try {
      final response = await _remoteDataSource.getFavoriteGenres(
        page: page,
        limit: limit,
      );
      final genres = response.data
          .map(
            (g) => FavoriteGenreEntity(
              id: g.id,
              externalParams: g.externalParams,
              name: g.name,
            ),
          )
          .toList();
      return Right(genres);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, UserPlaylistDetail>> getUserPlaylist(
    String playlistId,
  ) async {
    try {
      final playlist = await _remoteDataSource.getUserPlaylist(playlistId);
      return Right(playlist);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, UserPlaylistDetail>> updateUserPlaylist(
    String playlistId, {
    String? name,
    String? description,
    String? thumbnail,
    bool? isPublic,
  }) async {
    try {
      final playlist = await _remoteDataSource.updateUserPlaylist(
        playlistId,
        name: name,
        description: description,
        thumbnail: thumbnail,
        isPublic: isPublic,
      );
      return Right(playlist);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> deleteUserPlaylist(
    String playlistId,
  ) async {
    try {
      await _remoteDataSource.deleteUserPlaylist(playlistId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }
}
