import 'package:dartz/dartz.dart';
import 'package:music_app/core/domain/entities/artist.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/artist/domain/repositories/artist_repository.dart';

class GetArtistAlbumsUseCase {
  final ArtistRepository _repository;

  GetArtistAlbumsUseCase(this._repository);

  Future<Either<AppException, List<ArtistAlbum>>> call(String artistId) {
    return _repository.getArtistAlbums(artistId);
  }
}
