import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/liked/domain/repositories/liked_repository.dart';

/// Use case for removing a song from liked.
class RemoveLikedSongUseCase {
  final LikedRepository _repository;

  RemoveLikedSongUseCase(this._repository);

  Future<Either<AppException, void>> call(String videoId) {
    return _repository.removeLikedSong(videoId);
  }
}
