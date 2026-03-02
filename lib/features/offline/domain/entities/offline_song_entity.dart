import 'package:equatable/equatable.dart';

/// Entity representing an offline song.
class OfflineSongEntity extends Equatable {
  final String videoId;
  final String title;
  final String artist;
  final String? thumbnail;
  final String? localPath;
  final int? duration;
  final DateTime? downloadedAt;

  const OfflineSongEntity({
    required this.videoId,
    required this.title,
    required this.artist,
    this.thumbnail,
    this.localPath,
    this.duration,
    this.downloadedAt,
  });

  @override
  List<Object?> get props => [videoId, title, artist, thumbnail, localPath, duration, downloadedAt];
}
