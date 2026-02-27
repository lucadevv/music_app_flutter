import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/downloads/domain/repositories/downloads_repository.dart';

/// Caso de uso para verificar si una canción está descargada
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Verificar el estado de descarga
class CheckDownloadStatusUseCase {
  final DownloadsRepository _repository;

  CheckDownloadStatusUseCase(this._repository);

  Future<(AppException?, bool)> call(String videoId) async {
    final result = await _repository.isDownloaded(videoId);

    return result.fold(
      (error) => (error, false),
      (isDownloaded) => (null, isDownloaded),
    );
  }
}
