import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/downloads/domain/entities/downloaded_song.dart';
import 'package:music_app/features/downloads/domain/repositories/downloads_repository.dart';

/// Caso de uso para obtener las canciones descargadas
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Obtener lista de canciones descargadas
class GetDownloadedSongsUseCase {
  final DownloadsRepository _repository;

  GetDownloadedSongsUseCase(this._repository);

  Future<Either<AppException, List<DownloadedSong>>> call() async {
    return _repository.getDownloadedSongs();
  }
}
