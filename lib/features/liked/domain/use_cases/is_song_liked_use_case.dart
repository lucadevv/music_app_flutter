import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/liked/domain/repositories/liked_repository.dart';

/// Use case for checking if a song is liked.
class IsSongLikedUseCase {
  final LikedRepository _repository;

  IsSongLikedUseCase(this._repository);

  Future<Either<AppException, bool>> call(String videoId) {
    return _repository.isSongLiked(videoId);
  }
}
