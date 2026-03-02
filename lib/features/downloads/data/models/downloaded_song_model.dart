import 'package:music_app/features/downloads/domain/entities/downloaded_song.dart';

/// Modelo para la canción descargada que extiende la entidad
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Serialización/deserialización de datos de descarga
class DownloadedSongModel extends DownloadedSong {
  const DownloadedSongModel({
    required super.videoId,
    required super.title,
    required super.artist,
    required super.localPath, required super.fileSize, required super.duration, required super.downloadedAt, super.album,
    super.thumbnail,
  });

  /// Crea un modelo desde un JSON
  factory DownloadedSongModel.fromJson(Map<String, dynamic> json) {
    return DownloadedSongModel(
      videoId: json['videoId'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String?,
      thumbnail: json['thumbnail'] as String?,
      localPath: json['localPath'] as String,
      fileSize: json['fileSize'] as int,
      duration: Duration(milliseconds: json['durationMs'] as int),
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'title': title,
      'artist': artist,
      'album': album,
      'thumbnail': thumbnail,
      'localPath': localPath,
      'fileSize': fileSize,
      'durationMs': duration.inMilliseconds,
      'downloadedAt': downloadedAt.toIso8601String(),
    };
  }

  /// Crea un modelo desde la entidad
  factory DownloadedSongModel.fromEntity(DownloadedSong entity) {
    return DownloadedSongModel(
      videoId: entity.videoId,
      title: entity.title,
      artist: entity.artist,
      album: entity.album,
      thumbnail: entity.thumbnail,
      localPath: entity.localPath,
      fileSize: entity.fileSize,
      duration: entity.duration,
      downloadedAt: entity.downloadedAt,
    );
  }
}
