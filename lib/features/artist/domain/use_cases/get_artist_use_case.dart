import 'package:dartz/dartz.dart';
import 'package:music_app/core/domain/entities/artist.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/artist/domain/repositories/artist_repository.dart';

class GetArtistUseCase {
  final ArtistRepository _repository;

  GetArtistUseCase(this._repository);

  Future<Either<AppException, Artist>> call(String artistId) {
    return _repository.getArtist(artistId);
  }
}
