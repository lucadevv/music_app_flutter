import 'package:dartz/dartz.dart';
import 'package:music_app/core/data/offline/services/offline_service.dart';
import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/player/domain/repositories/player_repository.dart';
import 'package:music_app/features/recently_played/domain/entities/recently_played_song.dart';
import 'package:music_app/features/recently_played/domain/repositories/recently_played_repository.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final OfflineService _offlineService;
  final RecentlyPlayedRepository _recentlyPlayedRepository;

  PlayerRepositoryImpl({
    required OfflineService offlineService,
    required RecentlyPlayedRepository recentlyPlayedRepository,
  }) : _offlineService = offlineService,
       _recentlyPlayedRepository = recentlyPlayedRepository;

  @override
  Future<Either<AppException, List<Song>>> getHistory({int limit = 50}) async {
    final result = await _recentlyPlayedRepository.getRecentlyPlayed();
    return result.fold((exception) => Left(exception), (songs) {
      // Convert RecentlyPlayedSong to Song
      final convertedSongs = songs
          .map(
            (rps) => Song(
              videoId: rps.videoId,
              title: rps.title,
              artist: rps.artist,
              thumbnail: rps.thumbnail,
              duration: rps.duration,
            ),
          )
          .toList();
      return Right(convertedSongs);
    });
  }

  @override
  Future<Either<AppException, void>> addToHistory(Song song) async {
    final result = await _recentlyPlayedRepository.recordListen(song.videoId);
    return result.fold(
      (exception) => Left(exception),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<AppException, void>> updateHistoryPlayedDuration(
    String historyId,
    int playedDuration,
  ) async {
    // TODO: Implement when RecentlyPlayedRepository supports it
    // For now, just return success
    return const Right(null);
  }

  @override
  Future<Either<AppException, String?>> getLocalAudioPath(
    String videoId,
  ) async {
    try {
      final path = await _offlineService.getLocalAudioPath(videoId);
      return Right(path);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, bool>> isSongAvailableOffline(
    String videoId,
  ) async {
    try {
      final isAvailable = await _offlineService.isSongDownloaded(videoId);
      return Right(isAvailable);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<Song>>> getSimilarSongs(
    String videoId, {
    int limit = 10,
  }) async {
    // TODO: Implement similar songs API call
    // For now, return empty list
    return const Right([]);
  }

  @override
  Future<Either<AppException, void>> recordListen(String videoId) async {
    // TODO: Implement record listen to server
    // For now, just return success
    return const Right(null);
  }
}
