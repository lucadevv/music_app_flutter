import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/offline/domain/entities/offline_song_entity.dart';
import 'package:music_app/features/offline/domain/repositories/offline_repository.dart';

/// Use case for getting downloaded songs.
class GetDownloadedSongsUseCase {
  final OfflineRepository _repository;

  GetDownloadedSongsUseCase(this._repository);

  Future<Either<AppException, List<OfflineSongEntity>>> call() {
    return _repository.getDownloadedSongs();
  }
}
