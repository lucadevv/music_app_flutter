import 'package:music_app/features/album/domain/repositories/album_repository.dart';

class LikeAlbumUseCase {
  final AlbumRepository _repository;

  LikeAlbumUseCase(this._repository);

  Future<void> call(String albumId) {
    return _repository.likeAlbum(albumId);
  }
}
