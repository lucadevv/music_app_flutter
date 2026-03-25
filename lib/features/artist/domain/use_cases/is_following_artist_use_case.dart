import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/artist/domain/repositories/artist_repository.dart';

class IsFollowingArtistUseCase {
  final ArtistRepository _repository;

  IsFollowingArtistUseCase(this._repository);

  Future<Either<AppException, bool>> call(String artistId) {
    return _repository.isFollowing(artistId);
  }
}
