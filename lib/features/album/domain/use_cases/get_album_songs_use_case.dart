import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/album/domain/repositories/album_repository.dart';

class GetAlbumSongsUseCase {
  final AlbumRepository _repository;

  GetAlbumSongsUseCase(this._repository);

  Future<Either<AppException, List<AlbumSong>>> call(String albumId) {
    return _repository.getAlbumSongs(albumId);
  }
}
