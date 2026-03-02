import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/liked/domain/entities/liked_song_entity.dart';
import 'package:music_app/features/liked/domain/repositories/liked_repository.dart';

/// Use case for adding a song to liked.
class AddLikedSongUseCase {
  final LikedRepository _repository;

  AddLikedSongUseCase(this._repository);

  Future<Either<AppException, void>> call(LikedSongEntity song) {
    return _repository.addLikedSong(song);
  }
}
