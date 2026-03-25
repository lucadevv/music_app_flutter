import 'package:music_app/features/artist/domain/repositories/artist_repository.dart';

class UnfollowArtistUseCase {
  final ArtistRepository _repository;

  UnfollowArtistUseCase(this._repository);

  Future<void> call(String artistId) {
    return _repository.unfollowArtist(artistId);
  }
}
