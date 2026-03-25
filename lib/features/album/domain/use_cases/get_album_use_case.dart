// ignore_for_file: deprecated_member_use_from_same_package
import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/album/domain/repositories/album_repository.dart';

class GetAlbumUseCase {
  final AlbumRepository _repository;

  GetAlbumUseCase(this._repository);

  Future<Either<AppException, Album>> call(String albumId) {
    return _repository.getAlbum(albumId);
  }
}
