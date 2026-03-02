import 'package:dartz/dartz.dart';
import 'package:music_app/features/song_options/data/datasources/song_options_data_source.dart';
import 'package:music_app/features/song_options/domain/entities/song_option_entity.dart';
import 'package:music_app/features/song_options/domain/repositories/song_options_repository.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';

/// Implementation of SongOptionsRepository.
class SongOptionsRepositoryImpl implements SongOptionsRepository {
  final SongOptionsDataSource _dataSource;

  SongOptionsRepositoryImpl(this._dataSource);

  @override
  Future<Either<AppException, SongOptionEntity>> getSongOptions(String videoId) async {
    try {
      final options = await _dataSource.getSongOptions(videoId);
      return Right(options);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, SongOptionEntity>> toggleFavorite(SongOptionEntity song) async {
    try {
      await _dataSource.toggleFavorite(song.videoId, song.isFavorite);
      return Right(song.copyWith(isFavorite: !song.isFavorite));
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> downloadSong(SongOptionEntity song, String streamUrl) async {
    try {
      await _dataSource.downloadSong(song.videoId, song.title, song.artist, song.thumbnail, streamUrl);
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
}
