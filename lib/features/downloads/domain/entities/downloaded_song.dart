import 'package:equatable/equatable.dart';

/// Entidad que representa una canción descargada
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Representar los datos de una canción descargada
class DownloadedSong extends Equatable {
  final String videoId;
  final String title;
  final String artist;
  final String? album;
  final String? thumbnail;
  final String localPath;
  final int fileSize;
  final Duration duration;
  final DateTime downloadedAt;

  const DownloadedSong({
    required this.videoId,
    required this.title,
    required this.artist,
    required this.localPath,
    required this.fileSize,
    required this.duration,
    required this.downloadedAt,
    this.album,
    this.thumbnail,
  });

  /// Tamaño formateado en MB
  String get fileSizeFormatted {
    final mb = fileSize / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  /// Duración formateada
  String get durationFormatted {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
    videoId,
    title,
    artist,
    album,
    thumbnail,
    localPath,
    fileSize,
    duration,
    downloadedAt,
  ];
}
