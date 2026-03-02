import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/recently_played/data/datasources/recently_played_remote_data_source.dart';
import 'package:music_app/features/recently_played/domain/entities/recently_played_song.dart';
import 'package:music_app/features/recently_played/domain/repositories/recently_played_repository.dart';

/// Repository implementation for recently played
class RecentlyPlayedRepositoryImpl implements RecentlyPlayedRepository {
  final RecentlyPlayedRemoteDataSource _remoteDataSource;

  RecentlyPlayedRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, List<RecentlyPlayedSong>>> getRecentlyPlayed() async {
    try {
      final songs = await _remoteDataSource.getRecentlyPlayed();
      return Right(songs);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }
}
