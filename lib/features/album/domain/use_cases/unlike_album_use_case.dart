import 'package:music_app/features/album/domain/repositories/album_repository.dart';

class UnlikeAlbumUseCase {
  final AlbumRepository _repository;

  UnlikeAlbumUseCase(this._repository);

  Future<void> call(String albumId) {
    return _repository.unlikeAlbum(albumId);
  }
}
