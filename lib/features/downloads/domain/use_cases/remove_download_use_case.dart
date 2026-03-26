import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/downloads/domain/repositories/downloads_repository.dart';

/// Caso de uso para eliminar una descarga
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Eliminar una canción descargada
class RemoveDownloadUseCase {
  final DownloadsRepository _repository;

  RemoveDownloadUseCase(this._repository);

  Future<Either<AppException, void>> call(String videoId) async {
    return _repository.removeDownload(videoId);
  }
}
