import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/liked/data/datasources/liked_data_source.dart';
import 'package:music_app/features/liked/domain/entities/liked_song_entity.dart';
import 'package:music_app/features/liked/domain/repositories/liked_repository.dart';

/// Implementation of LikedRepository.
class LikedRepositoryImpl implements LikedRepository {
  final LikedDataSource _dataSource;

  LikedRepositoryImpl(this._dataSource);

  @override
  Future<Either<AppException, List<LikedSongEntity>>> getLikedSongs({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final songs = await _dataSource.getLikedSongs(page: page, limit: limit);
      return Right(songs);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> addLikedSong(LikedSongEntity song) async {
    try {
      await _dataSource.addLikedSong(song);
      return const Right(null);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> removeLikedSong(String videoId) async {
    try {
      await _dataSource.removeLikedSong(videoId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, bool>> isSongLiked(String videoId) async {
    try {
      final result = await _dataSource.isSongLiked(videoId);
      return Right(result);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }
}
