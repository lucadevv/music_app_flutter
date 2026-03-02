import 'package:dartz/dartz.dart';
import 'package:music_app/features/offline/data/datasources/offline_data_source.dart';
import 'package:music_app/features/offline/domain/entities/offline_song_entity.dart';
import 'package:music_app/features/offline/domain/repositories/offline_repository.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';

/// Implementation of OfflineRepository.
class OfflineRepositoryImpl implements OfflineRepository {
  final OfflineDataSource _dataSource;

  OfflineRepositoryImpl(this._dataSource);

  @override
  Future<Either<AppException, bool>> isOnline() async {
    try {
      final result = await _dataSource.isOnline();
      return Right(result);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<OfflineSongEntity>>> getDownloadedSongs() async {
    try {
      final songs = await _dataSource.getDownloadedSongs();
      return Right(songs);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> downloadSong(OfflineSongEntity song, String streamUrl) async {
    try {
      await _dataSource.downloadSong(song, streamUrl);
      return const Right(null);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> removeDownload(String videoId) async {
    try {
      await _dataSource.removeDownload(videoId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, String>> getDownloadStatus(String videoId) async {
    try {
      final status = await _dataSource.getDownloadStatus(videoId);
      return Right(status);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> syncFavorites(List<Map<String, dynamic>> serverSongs) async {
    try {
      await _dataSource.syncFavorites(serverSongs);
      return const Right(null);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }
}
