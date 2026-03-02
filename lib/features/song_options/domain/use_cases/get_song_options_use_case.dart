import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/song_options/domain/entities/song_option_entity.dart';
import 'package:music_app/features/song_options/domain/repositories/song_options_repository.dart';

/// Use case for getting song options.
class GetSongOptionsUseCase {
  final SongOptionsRepository _repository;

  GetSongOptionsUseCase(this._repository);

  Future<Either<AppException, SongOptionEntity>> call(String videoId) {
    return _repository.getSongOptions(videoId);
  }
}
