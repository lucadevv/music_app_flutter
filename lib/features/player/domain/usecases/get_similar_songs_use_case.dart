import 'package:dartz/dartz.dart';
import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/player/domain/repositories/player_repository.dart';

class GetSimilarSongsUseCase {
  final PlayerRepository _repository;

  GetSimilarSongsUseCase(this._repository);

  Future<Either<AppException, List<Song>>> call(
    String videoId, {
    int limit = 10,
  }) async {
    try {
      final songs = await _repository.getSimilarSongs(videoId, limit: limit);
      return Right(songs);
    } catch (e) {
      return Left(UnknownException('Failed to get similar songs: $e'));
    }
  }
}
