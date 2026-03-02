import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/downloads/domain/entities/downloaded_song.dart';
import 'package:music_app/features/downloads/domain/repositories/downloads_repository.dart';

/// Parámetros para descargar una canción
class DownloadParams {
  final String videoId;
  final String title;
  final String artist;
  final String? album;
  final String? thumbnail;
  final String streamUrl;
  final Duration duration;
  final void Function(double progress) onProgress;

  const DownloadParams({
    required this.videoId,
    required this.title,
    required this.artist,
    required this.streamUrl, required this.duration, required this.onProgress, this.album,
    this.thumbnail,
  });
}

/// Caso de uso para descargar una canción
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Orquestar la descarga de una canción
class DownloadSongUseCase {
  final DownloadsRepository _repository;

  DownloadSongUseCase(this._repository);

  Future<(AppException?, DownloadedSong?)> call(DownloadParams params) async {
    final result = await _repository.downloadSong(
      videoId: params.videoId,
      title: params.title,
      artist: params.artist,
      album: params.album,
      thumbnail: params.thumbnail,
      streamUrl: params.streamUrl,
      duration: params.duration,
      onProgress: params.onProgress,
    );

    return result.fold(
      (error) => (error, null),
      (song) => (null, song),
    );
  }
}
