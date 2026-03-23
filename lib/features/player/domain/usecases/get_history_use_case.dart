import 'package:dartz/dartz.dart';
import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/player/domain/repositories/player_repository.dart';

class GetHistoryUseCase {
  final PlayerRepository _repository;

  GetHistoryUseCase(this._repository);

  Future<Either<AppException, List<Song>>> call({int limit = 50}) async {
    try {
      final songs = await _repository.getHistory(limit: limit);
      return Right(songs);
    } catch (e) {
      return Left(UnknownException('Failed to get history: $e'));
    }
  }
}
