import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/album/domain/repositories/album_repository.dart';

class IsLikedAlbumUseCase {
  final AlbumRepository _repository;

  IsLikedAlbumUseCase(this._repository);

  Future<Either<AppException, bool>> call(String albumId) {
    return _repository.isLiked(albumId);
  }
}
