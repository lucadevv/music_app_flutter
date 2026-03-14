import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/recently_played/data/datasources/recently_played_remote_data_source.dart';
import 'package:music_app/features/recently_played/data/models/recently_played_song_model.dart';
import 'package:music_app/features/recently_played/domain/entities/recently_played_song.dart';
import 'package:music_app/features/recently_played/domain/repositories/recently_played_repository.dart';

/// Repository implementation for recently played.
/// Maneja el parseo de datos: Map -> Model -> Entity.
class RecentlyPlayedRepositoryImpl implements RecentlyPlayedRepository {
  final RecentlyPlayedRemoteDataSource _remoteDataSource;

  RecentlyPlayedRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, List<RecentlyPlayedSong>>> getRecentlyPlayed() async {
    try {
      final data = await _remoteDataSource.getRecentlyPlayed();
      final response = RecentlyPlayedResponse.fromJson(data);
      return Right(response.songs);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> recordListen(String videoId) async {
    try {
      await _remoteDataSource.recordListen(videoId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }
}
