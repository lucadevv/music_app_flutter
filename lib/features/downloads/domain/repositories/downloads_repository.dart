import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/downloads/domain/entities/downloaded_song.dart';

/// Contrato del repositorio de descargas
///
/// SOLID: Interface Segregation Principle (ISP)
/// Interface específica para operaciones de descargas
abstract class DownloadsRepository {
  /// Obtiene todas las canciones descargadas
  Future<Either<AppException, List<DownloadedSong>>> getDownloadedSongs();

  /// Descarga una canción
  Future<Either<AppException, DownloadedSong>> downloadSong({
    required String videoId,
    required String title,
    required String artist,
    required String streamUrl,
    required Duration duration,
    required void Function(double progress) onProgress,
    String? album,
    String? thumbnail,
  });

  /// Elimina una descarga
  Future<Either<AppException, void>> removeDownload(String videoId);

  /// Verifica si una canción está descargada
  Future<Either<AppException, bool>> isDownloaded(String videoId);

  /// Obtiene la ruta local de una canción descargada
  Future<Either<AppException, String?>> getLocalPath(String videoId);
}
