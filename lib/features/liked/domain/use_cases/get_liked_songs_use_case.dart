import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/liked/domain/entities/liked_song_entity.dart';
import 'package:music_app/features/liked/domain/repositories/liked_repository.dart';

/// Use case for getting liked songs.
class GetLikedSongsUseCase {
  final LikedRepository _repository;

  GetLikedSongsUseCase(this._repository);

  Future<Either<AppException, List<LikedSongEntity>>> call({
    int page = 1,
    int limit = 20,
  }) {
    return _repository.getLikedSongs(page: page, limit: limit);
  }
}
