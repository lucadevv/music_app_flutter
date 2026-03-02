import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/downloads/domain/repositories/downloads_repository.dart';

/// Caso de uso para eliminar una descarga
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Eliminar una canción descargada
class RemoveDownloadUseCase {
  final DownloadsRepository _repository;

  RemoveDownloadUseCase(this._repository);

  Future<(AppException?, bool)> call(String videoId) async {
    final result = await _repository.removeDownload(videoId);

    return result.fold((error) => (error, false), (_) => (null, true));
  }
}
