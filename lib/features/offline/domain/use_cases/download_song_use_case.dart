import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/offline/domain/entities/offline_song_entity.dart';
import 'package:music_app/features/offline/domain/repositories/offline_repository.dart';

/// Use case for downloading a song for offline use.
class DownloadSongUseCase {
  final OfflineRepository _repository;

  DownloadSongUseCase(this._repository);

  Future<Either<AppException, void>> call(OfflineSongEntity song, String streamUrl) {
    return _repository.downloadSong(song, streamUrl);
  }
}
