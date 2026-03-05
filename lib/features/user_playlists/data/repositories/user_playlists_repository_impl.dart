import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/user_playlists/data/datasources/user_playlists_data_source.dart';
import 'package:music_app/features/user_playlists/domain/entities/user_playlist_entity.dart';
import 'package:music_app/features/user_playlists/domain/repositories/user_playlists_repository.dart';

/// Implementation of UserPlaylistsRepository.
class UserPlaylistsRepositoryImpl implements UserPlaylistsRepository {
  final UserPlaylistsDataSource _dataSource;

  UserPlaylistsRepositoryImpl(this._dataSource);

  @override
  Future<Either<AppException, List<UserPlaylistEntity>>> getAllPlaylists() async {
    try {
      final playlists = await _dataSource.getAllPlaylists();
      return Right(playlists);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<UserPlaylistEntity>>> getUserPlaylists() async {
    try {
      final playlists = await _dataSource.getUserPlaylists();
      return Right(playlists);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, UserPlaylistEntity>> createPlaylist(String name) async {
    try {
      final playlist = await _dataSource.createPlaylist(name);
      return Right(playlist);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> deletePlaylist(String id) async {
    try {
      await _dataSource.deletePlaylist(id);
      return const Right(null);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }
}
