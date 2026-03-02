import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/downloads/data/data_sources/downloads_local_data_source.dart';
import 'package:music_app/features/downloads/data/models/downloaded_song_model.dart';
import 'package:music_app/features/downloads/domain/entities/downloaded_song.dart';
import 'package:music_app/features/downloads/domain/repositories/downloads_repository.dart';

/// Implementación del repositorio de descargas
///
/// SOLID:
/// - Single Responsibility: Gestiona operaciones de descargas
/// - Dependency Inversion: Depende de abstracciones (DataSource)
class DownloadsRepositoryImpl implements DownloadsRepository {
  final DownloadsLocalDataSource _localDataSource;

  DownloadsRepositoryImpl(this._localDataSource);

  @override
  Future<Either<AppException, List<DownloadedSong>>>
  getDownloadedSongs() async {
    try {
      final songs = await _localDataSource.getDownloadedSongs();
      return Right(songs);
    } catch (e) {
      return Left(UnknownException('Error al obtener descargas: $e'));
    }
  }

  @override
  Future<Either<AppException, DownloadedSong>> downloadSong({
    required String videoId,
    required String title,
    required String artist,
    required String streamUrl,
    required Duration duration,
    required void Function(double progress) onProgress,
    String? album,
    String? thumbnail,
  }) async {
    try {
      // Descargar el archivo
      final localPath = await _localDataSource.downloadFile(
        streamUrl,
        videoId,
        onProgress,
      );

      // Obtener el tamaño del archivo
      final file = File(localPath);
      final fileSize = await file.length();

      // Crear el modelo de canción descargada
      final downloadedSong = DownloadedSongModel(
        videoId: videoId,
        title: title,
        artist: artist,
        album: album,
        thumbnail: thumbnail,
        localPath: localPath,
        fileSize: fileSize,
        duration: duration,
        downloadedAt: DateTime.now(),
      );

      // Guardar los metadatos
      await _localDataSource.saveDownloadedSong(downloadedSong);

      return Right(downloadedSong);
    } catch (e) {
      return Left(UnknownException('Error al descargar: $e'));
    }
  }

  @override
  Future<Either<AppException, void>> removeDownload(String videoId) async {
    try {
      await _localDataSource.removeDownloadedSong(videoId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownException('Error al eliminar descarga: $e'));
    }
  }

  @override
  Future<Either<AppException, bool>> isDownloaded(String videoId) async {
    try {
      final isDownloaded = await _localDataSource.isDownloaded(videoId);
      return Right(isDownloaded);
    } catch (e) {
      return Left(UnknownException('Error al verificar descarga: $e'));
    }
  }

  @override
  Future<Either<AppException, String?>> getLocalPath(String videoId) async {
    try {
      final path = await _localDataSource.getLocalPath(videoId);
      return Right(path);
    } catch (e) {
      return Left(UnknownException('Error al obtener ruta local: $e'));
    }
  }
}
