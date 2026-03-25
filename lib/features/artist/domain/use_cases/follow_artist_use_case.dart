import 'package:music_app/features/artist/domain/repositories/artist_repository.dart';

class FollowArtistUseCase {
  final ArtistRepository _repository;

  FollowArtistUseCase(this._repository);

  Future<void> call(String artistId) {
    return _repository.followArtist(artistId);
  }
}
